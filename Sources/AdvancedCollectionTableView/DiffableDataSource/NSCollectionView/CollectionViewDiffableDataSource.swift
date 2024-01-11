//
//  CollectionViewDiffableDataSource.swift
//
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZQuicklook
import FZSwiftUtils
import FZUIKit
import QuickLookUI

/**
 A  `NSCollectionViewDiffableDataSource` with additional functionality.

 The diffable data source provides:
 - Reordering elements via ``ReorderingHandlers-swift.struct``.
 - Deleting elements via  ``DeletingHandlers-swift.struct``.
 - Quicklook previews of elements via spacebar by providing elements conforming to `QuicklookPreviewable`.
 - A right click menu for selected elements via ``menuProvider``.

 __It includes handlers for:__

 - Prefetching elements via ``prefetchHandlers-swift.property``.
 - Selecting elements via ``selectionHandlers-swift.property``.
 - Highlighting elements via ``highlightHandlers-swift.property``.
 - Displaying elements via ``displayHandlers-swift.property``.
 - Hovering elements by mouse via ``hoverHandlers-swift.property``.
 - Pinching of the collection view via ``pinchHandler``.

 ### Configurating the data source

 To connect a diffable data source to a collection view, you create the diffable data source using its ``init(collectionView:itemProvider:)`` or ``init(collectionView:itemRegistration:)`` initializer, passing in the collection view you want to associate with that data source.

 ```swift
 collectionView.dataSource = CollectionViewDiffableDataSource<Section, Element>(collectionView: collectionView, itemRegistration: itemRegistration)
 ```

 Then, you generate the current state of the data and display the data in the UI by constructing and applying a snapshot. For more information, see `NSDiffableDataSourceSnapshot`.

 - Note: Don’t change the dataSource or delegate on the collection view after you configure it with a diffable data source. If the collection view needs a new data source after you configure it initially, create and configure a new collection view and diffable data source.
 */
public class CollectionViewDiffableDataSource<Section: Identifiable & Hashable, Element: Identifiable & Hashable>: NSObject, NSCollectionViewDataSource {
    weak var collectionView: NSCollectionView!
    var dataSource: NSCollectionViewDiffableDataSource<Section.ID, Element.ID>!
    var delegateBridge: DelegateBridge!
    var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Element>()
    var previousDisplayingItems = [Element.ID]()
    var magnifyGestureRecognizer: NSMagnificationGestureRecognizer?
    var rightDownMonitor: NSEvent.Monitor?
    var hoveredItemObserver: NSKeyValueObservation?

    /// The closure that configures and returns the collection view’s supplementary views, such as headers and footers, from the diffable data source.
    public var supplementaryViewProvider: SupplementaryViewProvider?
    /**
     A closure that configures and returns a collection view’s supplementary view, such as a header or footer, from a diffable data source.

     - Parameters:
        - collectionView: The collection view to configure this supplementary view for.
        -  itemKind: The kind of supplementary view to provide. The layout object that supports the supplementary view defines the value of this string.
        - indexpath: The index path that specifies the location of the supplementary view in the collection view.

     - Returns: A non-`nil` configured supplementary view object. The supplementary view provider must return a valid view object to the collection view.
     */
    public typealias SupplementaryViewProvider = (_ collectionView: NSCollectionView, _ itemKind: String, _ indexPath: IndexPath) -> (NSView & NSCollectionViewElement)?

    /**
     Right click menu provider.

     The provided menu is used when right clicking the collection view.

     `elements` provides:
     - if right-click on a selected element, all selected elements,
     - else if right-click on a non selected element, that element,
     - else an empty array.
     */
    public var menuProvider: ((_ elements: [Element]) -> NSMenu?)? {
        didSet { observeRightMouseDown() }
    }

    /// A handler that gets called whenever collection view magnifies.
    public var pinchHandler: ((_ mouseLocation: CGPoint, _ magnification: CGFloat, _ state: NSMagnificationGestureRecognizer.State) -> Void)? { didSet { observeMagnificationGesture() } }

    func observeMagnificationGesture() {
        if pinchHandler != nil {
            if magnifyGestureRecognizer == nil {
                magnifyGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(didMagnify(_:)))
                collectionView.addGestureRecognizer(magnifyGestureRecognizer!)
            }
        } else {
            if let magnifyGestureRecognizer = magnifyGestureRecognizer {
                collectionView.removeGestureRecognizer(magnifyGestureRecognizer)
            }
            magnifyGestureRecognizer = nil
        }
    }

    var pinchItem: Element?
    @objc func didMagnify(_ gesture: NSMagnificationGestureRecognizer) {
        let pinchLocation = gesture.location(in: collectionView)
        switch gesture.state {
        case .began:
            //    let center = CGPoint(x: collectionView.frame.midX, y: collectionView.frame.midY)
            pinchItem = element(at: pinchLocation)
        case .ended, .cancelled, .failed:
            pinchItem = nil
        default:
            break
        }
        pinchHandler?(pinchLocation, gesture.magnification, gesture.state)
    }

    func observeRightMouseDown() {
        if menuProvider != nil, rightDownMonitor == nil {
            rightDownMonitor = NSEvent.localMonitor(for: [.rightMouseDown]) { event in
                self.collectionView.menu = nil
                if let contentView = self.collectionView.window?.contentView {
                    let location = event.location(in: contentView)
                    if let view = contentView.hitTest(location), view.isDescendant(of: self.collectionView) {
                        let location = event.location(in: self.collectionView)
                        if self.collectionView.bounds.contains(location) {
                            self.setupMenu(for: location)
                        }
                    }
                }
                return event
            }
        } else if menuProvider == nil, rightDownMonitor != nil {
            rightDownMonitor = nil
        }
    }

    func setupMenu(for location: CGPoint) {
        if let menuProvider = menuProvider {
            if let item = element(at: location) {
                var menuItems: [Element] = [item]
                let selectedItems = selectedElements
                if selectedItems.contains(item) {
                    menuItems = selectedItems
                }
                collectionView.menu = menuProvider(menuItems)
            } else {
                collectionView.menu = menuProvider([])
            }
        }
    }

    func observeHoveredItem() {
        if hoverHandlers.shouldObserve {
            collectionView.setupObservation()
            if hoveredItemObserver == nil {
                hoveredItemObserver = collectionView.observeChanges(for: \.hoveredIndexPath, handler: { old, new in
                    guard old != new else { return }
                    if let didEndHovering = self.hoverHandlers.didEndHovering, let old = old, let item = self.element(for: old) {
                        didEndHovering(item)
                    }
                    if let isHovering = self.hoverHandlers.isHovering, let new = new, let item = self.element(for: new) {
                        isHovering(item)
                    }
                })
            }
        } else {
            hoveredItemObserver = nil
        }
    }

    func observeDisplayingItems() {
        if displayHandlers.shouldObserve {
            collectionView.enclosingScrollView?.contentView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(scrollViewContentBoundsDidChange(_:)),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: collectionView.enclosingScrollView?.contentView)
        } else {
            collectionView.enclosingScrollView?.contentView.postsBoundsChangedNotifications = false
            NotificationCenter.default.removeObserver(self)
        }
    }

    @objc func scrollViewContentBoundsDidChange(_ notification: Notification) {
        guard (notification.object as? NSClipView) != nil else { return }
        let displayingItems = displayingElements.ids

        if let isDisplaying = displayHandlers.isDisplaying {
            let added = displayingItems.filter { previousDisplayingItems.contains($0) == false }
            let addedElements = elements[ids: added]
            if addedElements.isEmpty == false {
                isDisplaying(addedElements)
            }
        }

        if let didEndDisplaying = displayHandlers.didEndDisplaying {
            let removed = previousDisplayingItems.filter { displayingItems.contains($0) == false }
            let removedElements = elements[ids: removed]
            if removedElements.isEmpty == false {
                didEndDisplaying(removedElements)
            }
        }
        previousDisplayingItems = displayingItems
    }

    var keyDownMonitor: NSEvent.Monitor?

    func observeKeyDown() {
        if let canDelete = deletingHandlers.canDelete {
            keyDownMonitor = NSEvent.localMonitor(for: .keyDown, handler: { [weak self] event in
                guard let self = self, self.collectionView.isFirstResponder else { return event }
                if event.keyCode == 51 {
                    let elementsToDelete = canDelete(self.selectedElements)
                    var section: Section? = nil
                    var selectionElement: Element? = nil
                    if let element = elementsToDelete.first {
                        if var indexPath = indexPath(for: element), indexPath.item > 0,  let element = self.element(for: IndexPath(item: indexPath.item - 1, section: indexPath.section)), !elementsToDelete.contains(element) {
                            selectionElement = element
                        } else {
                            section = self.section(for: element)
                        }
                    }
                    if elementsToDelete.isEmpty == false {
                        let transaction = self.deletionTransaction(elementsToDelete)
                        self.deletingHandlers.willDelete?(elementsToDelete, transaction)
                        if QuicklookPanel.shared.isVisible {
                            QuicklookPanel.shared.close()
                        }
                        self.apply(transaction.finalSnapshot, .animated)
                        deletingHandlers.didDelete?(elementsToDelete, transaction)
                        
                        if collectionView.allowsEmptySelection == false, collectionView.selectionIndexPaths.isEmpty {
                            var selectionIndexPath: IndexPath?
                            if let element = selectionElement, let indexPath = indexPath(for: element) {
                                selectionIndexPath = indexPath
                            } else if let section = section, let element = elements(for: section).first, let indexPath = indexPath(for: element) {
                                selectionIndexPath = indexPath
                            } else if let item = currentSnapshot.itemIdentifiers.first, let indexPath = indexPath(for: item) {
                                selectionIndexPath = indexPath
                            }
                            if let indexPath = selectionIndexPath {
                                collectionView.selectItems(at: [indexPath], scrollPosition: [])
                            }
                        }
                        return nil
                    }
                }
                return event
            })
        } else {
            keyDownMonitor = nil
        }
    }

    // MARK: - Snapshot

    /**
     Returns a representation of the current state of the data in the collection view.

     A snapshot containing section and item identifiers in the order that they appear in the UI.
     */
    public func snapshot() -> NSDiffableDataSourceSnapshot<Section, Element> {
        currentSnapshot
    }

    /// Returns an empty snapshot.
    public func emptySnapshot() -> NSDiffableDataSourceSnapshot<Section, Element> {
        .init()
    }

    /**
     Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes.

     The system interrupts any ongoing item animations and immediately reloads the collection view’s content.

     - Parameters:
        - snapshot: The snapshot that reflects the new state of the data in the collection view.
        - option: Option how to apply the snapshot to the collection view. The default value is `animated`.
        - completion: An optional completion handler which gets called after applying the snapshot.
     */
    public func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Element>, _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        let internalSnapshot = snapshot.toIdentifiableSnapshot()
        currentSnapshot = snapshot
        dataSource.apply(internalSnapshot, option, completion: completion)
    }

    // MARK: - Init

    /**
     Creates a diffable data source with the specified item provider, and connects it to the specified collection view.

     To connect a diffable data source to a collection view, you create the diffable data source using this initializer, passing in the collection view you want to associate with that data source. You also pass in a item provider, where you configure each of your elements to determine how to display your data in the UI.

     ```swift
     dataSource = CollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, itemProvider: {
     (collectionView, indexPath, item) in
     // configure and return item
     })
     ```

     - Parameters:
        - collectionView: The initialized collection view object to connect to the diffable data source.
        - itemProvider: A closure that creates and returns each of the elements for the collection view from the data the diffable data source provides.
     */
    public init(collectionView: NSCollectionView, itemProvider: @escaping ItemProvider) {
        self.collectionView = collectionView
        super.init()

        dataSource = .init(collectionView: self.collectionView, itemProvider: {
            [weak self] collectionView, indePath, itemID in

            guard let self = self, let item = self.elements[id: itemID] else { return nil }
            return itemProvider(collectionView, indePath, item)
        })

        dataSource.supplementaryViewProvider = { [weak self] collectionView, itemKind, indePath in
            guard let self = self else { return nil }
            return self.supplementaryViewProvider?(collectionView, itemKind, indePath)
        }

        delegateBridge = DelegateBridge(self)
        collectionView.isQuicklookPreviewable = Element.self is QuicklookPreviewable.Type
        collectionView.registerForDraggedTypes([.itemID])
        // collectionView.setDraggingSourceOperationMask(.move, forLocal: true)
        // collectionView.setDraggingSourceOperationMask(.copy, forLocal: false)
    }

    /**
     A closure that configures and returns an item for a collection view from its diffable data source.

     A non-`nil` configured item object. The item provider must return a valid item object to the collection view.

     - Parameters:
        - collectionView: The collection view to configure this cell for.
        -  indexpath: The index path that specifies the location of the item in the collection view.
        - element: An object, with a type that implements the Hashable protocol, the data source uses to uniquely identify the item for this cell.

     - Returns: A non-`nil` configured collection view item object. The item provider must return a valid item object to the collection view.
     */
    public typealias ItemProvider = (_ collectionView: NSCollectionView, _ indexPath: IndexPath, _ element: Element) -> NSCollectionViewItem?

    /**
     Creates a diffable data source with the specified item registration, and connects it to the specified collection view.

     To connect a diffable data source to a collection view, you create the diffable data source using this initializer, passing in the collection view you want to associate with that data source. You also pass in a item registration, where each of your elements gets determine how to display your data in the UI.

     ```swift
     dataSource = CollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, itemRegistration: itemRegistration)
     ```

     - Parameters:
        - collectionView: The initialized collection view object to connect to the diffable data source.
        - itemRegistration: A item registration which returns each of the elements for the collection view from the data the diffable data source provides.
     */
    public convenience init<Item: NSCollectionViewItem>(collectionView: NSCollectionView, itemRegistration: NSCollectionView.ItemRegistration<Item, Element>) {
        self.init(collectionView: collectionView, itemProvider: { collectionView, indePath, item in
            collectionView.makeItem(using: itemRegistration, for: indePath, element: item)
        })
    }

    // MARK: - DataSource implementation

    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.collectionView(collectionView, numberOfItemsInSection: section)
    }

    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        dataSource.collectionView(collectionView, itemForRepresentedObjectAt: indexPath)
    }

    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        dataSource.numberOfSections(in: collectionView)
    }

    public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        dataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }

    // MARK: - Elements

    /// All current elements in the collection view.
    public var elements: [Element] {
        currentSnapshot.itemIdentifiers
    }

    /// The selected elements.
    public var selectedElements: [Element] {
        collectionView.selectionIndexPaths.compactMap { element(for: $0) }
    }

    /**
     Returns the element at the specified index path in the collection view.

     - Parameter indexPath: The index path.
     - Returns: The element at the index path or nil if there isn't any element at the index path.
     */
    public func element(for indexPath: IndexPath) -> Element? {
        if let itemId = dataSource.itemIdentifier(for: indexPath) {
            return currentSnapshot.itemIdentifiers[id: itemId]
        }
        return nil
    }
    
    public func elements(for section: Section) -> [Element] {
        currentSnapshot.itemIdentifiers(inSection: section)
    }

    /// Returns the index path for the specified element in the collection view.
    public func indexPath(for element: Element) -> IndexPath? {
        dataSource.indexPath(for: element.id)
    }

    /**
     Returns the element at the specified point.

     - Parameter point: The point in the collection view’s bounds that you want to test.
     - Returns: The element at the specified point or `nil` if no element was found at that point.
     */
    public func element(at point: CGPoint) -> Element? {
        if let indexPath = collectionView.indexPathForItem(at: point) {
            return element(for: indexPath)
        }
        return nil
    }

    /// Updates the data for the elements you specify, preserving the existing collection view elements for the elements.
    public func reconfigureElements(_ elements: [Element]) {
        let indexPaths = elements.compactMap { indexPath(for: $0) }
        collectionView.reconfigureItems(at: indexPaths)
    }

    /// Reloads the specified elements.
    public func reloadElements(_ elements: [Element], animated: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(elements.ids)
        dataSource.apply(snapshot, animated ? .animated : .withoutAnimation)
    }

    /// Selects the specified elements.
    public func selectElements(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition, addSpacing _: CGFloat? = nil) {
        let indexPaths = Set(elements.compactMap { indexPath(for: $0) })
        collectionView.selectItems(at: indexPaths, scrollPosition: scrollPosition)
    }

    /// Deselects the specified elements.
    public func deselectElements(_ elements: [Element]) {
        let indexPaths = Set(elements.compactMap { indexPath(for: $0) })
        collectionView.deselectItems(at: indexPaths)
    }

    /// Selects all elements in the specified sections.
    public func selectElements(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let elements = elements(for: sections)
        selectElements(elements, scrollPosition: scrollPosition)
    }

    /// Deselects all elementsin the specified sections.
    public func deselectElements(in sections: [Section], scrollPosition _: NSCollectionView.ScrollPosition) {
        let elementIndexPaths = Set(sections.flatMap { indexPaths(for: $0) })
        collectionView.deselectItems(at: elementIndexPaths)
    }

    /// Scrolls the collection view to the specified elements.
    public func scrollToElements(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition = []) {
        let indexPaths = Set(indexPaths(for: elements))
        collectionView.scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
    }

    /// An array of elements that are displaying (currently visible).
    var displayingElements: [Element] {
        collectionView.displayingIndexPaths().compactMap { element(for: $0) }
    }

    /// The collection view item for the specified item.
    func collectionTtem(for element: Element) -> NSCollectionViewItem? {
        if let indexPath = indexPath(for: element) {
            return collectionView.item(at: indexPath)
        }
        return nil
    }

    /// The frame of the collection view item for the specified item.
    func itemFrame(for element: Element) -> CGRect? {
        if let indexPath = indexPath(for: element) {
            return collectionView.frameForItem(at: indexPath)
        }
        return nil
    }

    func indexPaths(for elements: [Element]) -> [IndexPath] {
        elements.compactMap { indexPath(for: $0) }
    }

    func indexPaths(for section: Section) -> [IndexPath] {
        let elements = currentSnapshot.itemIdentifiers(inSection: section)
        return indexPaths(for: elements)
    }

    func indexPaths(for sections: [Section]) -> [IndexPath] {
        sections.flatMap { indexPaths(for: $0) }
    }

    func elements(for sections: [Section]) -> [Element] {
        let currentSnapshot = currentSnapshot
        return sections.flatMap { currentSnapshot.itemIdentifiers(inSection: $0) }
    }

    func isSelected(at indexPath: IndexPath) -> Bool {
        collectionView.selectionIndexPaths.contains(indexPath)
    }

    func isSelected(for element: Element) -> Bool {
        if let indexPath = indexPath(for: element) {
            return isSelected(at: indexPath)
        }
        return false
    }

    func removeItems(_ elements: [Element]) {
        var snapshot = snapshot()
        snapshot.deleteItems(elements)
        apply(snapshot, .animated)
    }

    func deletionTransaction(_ elements: [Element]) -> NSDiffableDataSourceTransaction<Section, Element> {
        var finalSnapshot = snapshot()
        finalSnapshot.deleteItems(elements)
        return NSDiffableDataSourceTransaction(initial: currentSnapshot, final: finalSnapshot)
    }

    func movingTransaction(at indexPaths: [IndexPath], to toIndexPath: IndexPath) -> NSDiffableDataSourceTransaction<Section, Element>? {
        var newSnapshot = snapshot()
        let newItems = indexPaths.compactMap { element(for: $0) }
        if let item = element(for: toIndexPath) {
            newSnapshot.insertItems(newItems, beforeItem: item)
        } else if let section = section(at: toIndexPath) {
            var indexPath = toIndexPath
            indexPath.item -= 1
            if let item = element(for: indexPath) {
                newSnapshot.insertItems(newItems, afterItem: item)
            } else {
                newSnapshot.appendItems(newItems, toSection: section)
            }
        } else if let section = sections.last {
            newSnapshot.appendItems(newItems, toSection: section)
        }
        return NSDiffableDataSourceTransaction(initial: currentSnapshot, final: newSnapshot)
    }

    // MARK: - Sections

    /// All current sections in the collection view.
    public var sections: [Section] {
        currentSnapshot.sectionIdentifiers
    }

    /// Returns the index for the section in the collection view.
    public func index(for section: Section) -> Int? {
        sections.firstIndex(of: section)
    }

    /// Returns the section at the index in the collection view.
    public func section(for index: Int) -> Section? {
        sections[safe: index]
    }
    
    public func section(for element: Element) -> Section? {
        currentSnapshot.sectionIdentifier(containingItem: element)
    }

    /// Scrolls the collection view to the specified section.
    public func scrollToSection(_ section: Section, scrollPosition: NSCollectionView.ScrollPosition = []) {
        guard let index = index(for: section) else { return }
        let indexPaths = Set([IndexPath(item: 0, section: index)])
        collectionView.scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
    }

    func section(at indexPath: IndexPath) -> Section? {
        if indexPath.section <= sections.count - 1 {
            return sections[indexPath.section]
        }
        return nil
    }

    // MARK: - Handlers

    /// The handlers for hovering elements with the mouse.
    public var hoverHandlers = HoverHandlers() {
        didSet { observeHoveredItem() }
    }

    /// The handlers for selecting elements.
    public var selectionHandlers = SelectionHandlers()

    /**
     The handlers for deleting elements.
     
     Provide ``DeletingHandlers-swift.struct/canDelete`` to support the deleting of elements in your collection view.
     
     The system calls the ``DeletingHandlers-swift.struct/didDelete`` handler after a deleting transaction (``NSDiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
     ```swift
     // Allow every element to be deleted
     dataSource.deletingHandlers.canDelete = { elements in return elements }

     // Option 1: Update the backing store from a CollectionDifference
     dataSource.deletingHandlers.didDelete = { [weak self] elements, transaction in
         guard let self = self else { return }
         
         if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
             self.backingStore = updatedBackingStore
         }
     }
     
     // Option 2: Update the backing store from the final elements
     dataSource.deletingHandlers.didDelete = { [weak self] elements, transaction in
         guard let self = self else { return }
         
         self.backingStore = transaction.finalSnapshot.itemIdentifiers
     }
     ```
     */
    public var deletingHandlers = DeletingHandlers() {
        didSet { observeKeyDown() }
    }

    /**
     The handlers for reordering elements.
     
     Provide ``ReorderingHandlers-swift.struct/canReorder`` to support the reordering of items in your collection view.
     
     The system calls the ``ReorderingHandlers-swift.struct/didReorder`` handler after a reordering transaction (``NSDiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
     ```swift
     // Allow every element to be reordered
     dataSource.reorderingHandlers.canReorder = { elements in return true }
     
     // Option 1: Update the backing store from a CollectionDifference
     dataSource.reorderingHandlers.didDelete = { [weak self] elements, transaction in
         guard let self = self else { return }
         
         if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
             self.backingStore = updatedBackingStore
         }
     }

     // Option 2: Update the backing store from the final elements
     dataSource.reorderingHandlers.didReorder = { [weak self] elements, transaction in
         guard let self = self else { return }
         
         self.backingStore = transaction.finalSnapshot.itemIdentifiers
     }
     ```
     */
    public var reorderingHandlers = ReorderingHandlers()

    /**
     The handlers for the displaying elements.

     The handlers get called whenever the collection view is displaying new elements (e.g. when the enclosing scrollview scrolls to new elements).
     */
    public var displayHandlers = DisplayHandlers() {
        didSet { observeDisplayingItems() }
    }

    /// The handlers for prefetching elements.
    public var prefetchHandlers = PrefetchHandlers()

    /// The handlers highlighting elements.
    public var highlightHandlers = HighlightHandlers()

    /// The handlers for drag and drop of files from and to the collection view.
    var dragDropHandlers = DragDropHandlers()

    /// Handlers for prefetching elements.
    public struct PrefetchHandlers {
        /// The handler that tells you to begin preparing data for the elements.
        public var willPrefetch: ((_ elements: [Element]) -> Void)?

        /// Cancels a previously triggered data prefetch request.
        public var didCancelPrefetching: ((_ elements: [Element]) -> Void)?
    }

    /// Handlers for selecting elements.
    public struct SelectionHandlers {
        /// The handler that determines whether elements should get selected. The default value is `nil` which indicates that all elements should be selected.
        public var shouldSelect: ((_ elements: [Element]) -> [Element])?

        /// The handler that gets called whenever elements get selected.
        public var didSelect: ((_ elements: [Element]) -> Void)?

        /// The handler that determines whether elements should get deselected. The default value is `nil` which indicates that all elements should be deselected.
        public var shouldDeselect: ((_ elements: [Element]) -> [Element])?

        /// The handler that gets called whenever elements get deselected.
        public var didDeselect: ((_ elements: [Element]) -> Void)?
    }

    /**
     Handlers for deleting elements.
     
     Take a look at ``deletingHandlers-swift.property`` how to support deleting elements.
     */
    public struct DeletingHandlers {
        /// The handler that determines which elements can be be deleted. The default value is `nil`, which indicates that all elements can be deleted.
        public var canDelete: ((_ elements: [Element]) -> [Element])?

        /// The handler that that gets called before deleting elements.
        public var willDelete: ((_ elements: [Element], _ transaction: NSDiffableDataSourceTransaction<Section, Element>) -> Void)?

        /**
         The handler that that gets called after deleting elements.
         
         The system calls the `didDelete` handler after a deleting transaction (``NSDiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
         
         ```swift
         // Allow every element to be deleted
         dataSource.deletingHandlers.canDelete = { elements in return elements }

         // Option 1: Update the backing store from a CollectionDifference
         dataSource.deletingHandlers.didDelete = { [weak self] elements, transaction in
             guard let self = self else { return }
             
             if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
                 self.backingStore = updatedBackingStore
             }
         }

         // Option 2: Update the backing store from the final elements
         dataSource.deletingHandlers.didReorder = { [weak self] elements, transaction in
             guard let self = self else { return }
             
             self.backingStore = transaction.finalSnapshot.itemIdentifiers
         }
         ```
         */
        public var didDelete: ((_ elements: [Element], _ transaction: NSDiffableDataSourceTransaction<Section, Element>) -> Void)?
    }

    /**
     Handlers for reordering elements.
     
     Take a look at ``reorderingHandlers-swift.property`` how to support reordering elements.
     */
    public struct ReorderingHandlers {
        /// The handler that determines if elements can be reordered. The default value is `nil` which indicates that the elements can be reordered.
        public var canReorder: ((_ elements: [Element]) -> Bool)?

        /// The handler that that gets called before reordering elements.
        public var willReorder: ((NSDiffableDataSourceTransaction<Section, Element>) -> Void)?

        /**
         The handler that that gets called after reordering elements.

         The system calls the `didReorder` handler after a reordering transaction (``NSDiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
         
         ```swift
         // Allow every element to be reordered
         dataSource.reorderingHandlers.canDelete = { elements in return true }

         // Option 1: Update the backing store from a CollectionDifference
         dataSource.reorderingHandlers.didDelete = { [weak self] elements, transaction in
             guard let self = self else { return }
             
             if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
                 self.backingStore = updatedBackingStore
             }
         }

         // Option 2: Update the backing store from the final elements
         dataSource.reorderingHandlers.didReorder = { [weak self] elements, transaction in
             guard let self = self else { return }
             
             self.backingStore = transaction.finalSnapshot.itemIdentifiers
         }
         ```
         */
        public var didReorder: ((NSDiffableDataSourceTransaction<Section, Element>) -> Void)?
    }

    /// Handlers for the highlight state of elements.
    public struct HighlightHandlers {
        /// The handler that determines which elements should change to a new highlight state. The default value is `nil` which indicates that all elements should change.
        public var shouldChange: ((_ elements: [Element], NSCollectionViewItem.HighlightState) -> [Element])?

        /// The handler that gets called whenever elements changed their highlight state.
        public var didChange: ((_ elements: [Element], NSCollectionViewItem.HighlightState) -> Void)?
    }

    /**
     Handlers for displaying elements.

     The handlers get called whenever the collection view is displaying new elements (e.g. when the enclosing scrollview scrolls to new elements).
     */
    public struct DisplayHandlers {
        /// The handler that gets called whenever elements start getting displayed.
        public var isDisplaying: ((_ elements: [Element]) -> Void)?

        /// The handler that gets called whenever elements end getting displayed.
        public var didEndDisplaying: ((_ elements: [Element]) -> Void)?

        var shouldObserve: Bool {
            isDisplaying != nil || didEndDisplaying != nil
        }
    }

    /// Handlers for hovering elements with the mouse.
    public struct HoverHandlers {
        /// The handler that gets called whenever the mouse is hovering an element.
        public var isHovering: ((_ element: Element) -> Void)?

        /// The handler that gets called whenever the mouse did end hovering an element.
        public var didEndHovering: ((_ element: Element) -> Void)?

        var shouldObserve: Bool {
            isHovering != nil || didEndHovering != nil
        }
    }

    /// Handlers for drag and drop of files from and to the collection view.
    struct DragDropHandlers {
        public struct DropHandlers {
            public var fileURLs: ((_ urls: [URL]) -> [Element])?
            public var urls: ((_ urls: [URL]) -> [Element])?
            public var images: ((_ images: [NSImage]) -> [Element])?
            public var string: ((_ string: String) -> Element?)?
        }

        public struct DraggedInside {
            public var fileURLs: ((_ urls: [URL]) -> [Element])?
            public var urls: ((_ urls: [URL]) -> [Element])?
            public var images: ((_ images: [NSImage]) -> [Element])?
            public var string: ((_ string: String) -> Element?)?
            public var color: ((_ string: NSColor) -> Element?)?
            public var item: ((_ item: NSPasteboardItem) -> Element?)?
        }

        public var inside = DraggedInside()

        public var drop = DropHandlers()

        /// The handler that determines which elements can be dragged outside the collection view.
        public var canDragOutside: ((_ elements: [Element]) -> [Element])?

        /// The handler that gets called whenever elements did drag ouside the collection view.
        public var didDragOutside: (([Element]) -> Void)?

        /// The handler that determines the pasteboard value of an element when dragged outside the collection view.
        public var pasteboardValue: ((_ element: Element) -> PasteboardReadWriting)?

        /// The handler that determines whenever pasteboard elements can be dragged inside the collection view.
        public var canDragInside: (([PasteboardReadWriting]) -> [PasteboardReadWriting])?

        /// The handler that gets called whenever pasteboard elements did drag inside the collection view.
        public var didDragInside: (([PasteboardReadWriting]) -> Void)?

        /// The handler that determines the image when dragging elements.
        public var draggingImage: ((_ elements: [Element], NSEvent, NSPointPointer) -> NSImage?)?

        var acceptsDragInside: Bool {
            canDragInside != nil && didDragInside != nil
        }

        var acceptsDragOutside: Bool {
            canDragOutside != nil
        }
    }
}

// MARK: - Quicklook

public extension CollectionViewDiffableDataSource where Element: QuicklookPreviewable {
    /// A Boolean value that indicates whether the user can quicklook selected elements by pressing space bar.
    var isQuicklookPreviewable: Bool {
        get { collectionView.isQuicklookPreviewable }
        set { collectionView.isQuicklookPreviewable = newValue }
    }

    /**
     Opens `QuicklookPanel` that presents quicklook previews of the specified elements.

     To quicklook the selected elements, use collection view's `quicklookSelectedItems()`.

     - Parameters:
        - elements: The elements to preview.
        - current: The element that starts the preview. The default value is `nil`.
     */
    func quicklookElements(_ elements: [Element], current: Element? = nil) where Element: QuicklookPreviewable {
        let indexPaths = elements.compactMap { indexPath(for: $0) }.sorted()
        if let current = current, let currentIndexPath = indexPath(for: current) {
            collectionView.quicklookItems(at: indexPaths, current: currentIndexPath)
        } else {
            collectionView.quicklookItems(at: indexPaths)
        }
    }
}

extension CollectionViewDiffableDataSource: NSCollectionViewQuicklookProvider {
    public func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let item = collectionView.item(at: indexPath), let previewable = element(for: indexPath) as? QuicklookPreviewable {
            return QuicklookPreviewItem(previewable, view: item.view)
        } else if let item = collectionView.item(at: indexPath), let preview = item.quicklookPreview {
            return QuicklookPreviewItem(preview, view: item.view)
        }
        return nil
    }
}
