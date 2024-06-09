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
 
 - Note: Each of your sections and elements must have unique identifiers.

 - Note: Don’t change the `dataSource` or `delegate` on the collection view after you configure it with a diffable data source. If the collection view needs a new data source after you configure it initially, create and configure a new collection view and diffable data source.
 */
open class CollectionViewDiffableDataSource<Section: Identifiable & Hashable, Element: Identifiable & Hashable>: NSObject, NSCollectionViewDataSource {
    weak var collectionView: NSCollectionView!
    var dataSource: NSCollectionViewDiffableDataSource<Section.ID, Element.ID>!
    var delegateBridge: DelegateBridge!
    var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Element>()
    var previousDisplayingItems = [Element.ID]()
    var magnifyGestureRecognizer: NSMagnificationGestureRecognizer?
    var rightDownMonitor: NSEvent.Monitor?
    var keyDownMonitor: NSEvent.Monitor?
    var hoveredItemObserver: KeyValueObservation?
    var pinchItem: Element?

    /// The closure that configures and returns the collection view’s supplementary views, such as headers and footers, from the diffable data source.
    open var supplementaryViewProvider: SupplementaryViewProvider?
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

     The provided menu is displayed when the user right-clicks the collection view. If you don't want to display a menu, return `nil`.

     `elements` provides:
     - if right-click on a **selected element**, all selected elements,
     - else if right-click on a **non-selected element**, that element,
     - else an empty array.
     */
    open var menuProvider: ((_ elements: [Element]) -> NSMenu?)? {
        didSet { setupMenuProvider() }
    }
    
    /**
     The handler that gets called when the user right-clicks the collection view.

     `elements` provides:
     - if right-click on a **selected element**, all selected elements,
     - else if right-click on a **non-selected element**, that element,
     - else an empty array.
     */
    open var rightClickHandler: ((_ elements: [Element]) -> ())? {
        didSet { setupRightDownHandler() }
    }


    /// A handler that gets called whenever collection view magnifies.
    open var pinchHandler: ((_ element: Element?, _ mouseLocation: CGPoint, _ magnification: CGFloat, _ state: NSMagnificationGestureRecognizer.State) -> Void)? { didSet { observeMagnificationGesture() } }

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

    @objc func didMagnify(_ gesture: NSMagnificationGestureRecognizer) {
        guard let pinchHandler = self.pinchHandler else { return }
        let pinchLocation = gesture.location(in: collectionView)
        switch gesture.state {
        case .began:
            //    let center = CGPoint(x: collectionView.frame.midX, y: collectionView.frame.midY)
            pinchItem = element(at: pinchLocation)
            pinchHandler(pinchItem, pinchLocation, gesture.magnification, gesture.state)
        case .ended, .cancelled, .failed:
            pinchHandler(pinchItem, pinchLocation, gesture.magnification, gesture.state)
            pinchItem = nil
        default:
            pinchHandler(pinchItem, pinchLocation, gesture.magnification, gesture.state)
        }
    }
    
    func setupMenuProvider() {
        if menuProvider != nil  {
            collectionView.menuProvider = { [weak self] location in
                guard let self = self else { return nil }
                return self.menuProvider?(self.elements(for: location))
            }
        } else {
            collectionView.menuProvider = nil
        }
    }

    func setupRightDownHandler() {
        if rightClickHandler != nil {
            collectionView.mouseHandlers.rightDown = { [weak self] event in
                guard let self = self, let handler = self.rightClickHandler else { return }
                let location = event.location(in: self.collectionView)
                handler(self.elements(for: location))
            }
        } else {
            collectionView.mouseHandlers.rightDown = nil
        }
    }
    
    func setupRightClick(for location: CGPoint) {
        guard let rightClick = rightClickHandler else { return }
        rightClick(elements(for: location))
    }
    
    func elements(for location: CGPoint) -> [Element] {
        if let item = element(at: location) {
            var items: [Element] = [item]
            let selectedItems = selectedElements
            if selectedItems.contains(item) {
                items = selectedItems
            }
            return items
        }
        return []
    }

    func setupMenu(for location: CGPoint) {
        guard let menuProvider = menuProvider else { return }
        let items = elements(for: location)
        collectionView.menu = menuProvider(items)
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

    func observeKeyDown() {
        if let canDelete = deletingHandlers.canDelete {
            /*
            collectionView.keyHandlers.keyDown = { [weak self] event in
                guard let self = self, event.keyCode == 51 else { return }
                let elementsToDelete = canDelete(self.selectedElements)
                guard let element = elementsToDelete.first  else { return }
                var section: Section? = nil
                var selectionElement: Element? = nil
                if let indexPath = self.indexPath(for: element), indexPath.item > 0,  let element = self.element(for: IndexPath(item: indexPath.item - 1, section: indexPath.section)), !elementsToDelete.contains(element) {
                    selectionElement = element
                } else {
                    section = self.section(for: element)
                }
                let transaction = self.deletionTransaction(elementsToDelete)
                self.deletingHandlers.willDelete?(elementsToDelete, transaction)
                QuicklookPanel.shared.close()
                self.apply(transaction.finalSnapshot, .animated)
                self.deletingHandlers.didDelete?(elementsToDelete, transaction)
                if self.collectionView.allowsEmptySelection == false, self.collectionView.selectionIndexPaths.isEmpty {
                    var selectionIndexPath: IndexPath?
                    if let element = selectionElement, let indexPath = self.indexPath(for: element) {
                        selectionIndexPath = indexPath
                    } else if let section = section, let element = self.elements(for: section).first, let indexPath = self.indexPath(for: element) {
                        selectionIndexPath = indexPath
                    } else if let item = self.currentSnapshot.itemIdentifiers.first, let indexPath = self.indexPath(for: item) {
                        selectionIndexPath = indexPath
                    }
                    if let indexPath = selectionIndexPath {
                        self.collectionView.selectItems(at: [indexPath], scrollPosition: [])
                    }
                }
            }
            */
            
            keyDownMonitor = NSEvent.monitorLocal(.keyDown) { [weak self] event in
                guard let self = self, event.keyCode == 51, self.collectionView.isFirstResponder else { return event }
                let elementsToDelete = canDelete(self.selectedElements)
                var section: Section? = nil
                var selectionElement: Element? = nil
                if let element = elementsToDelete.first {
                    if let indexPath = indexPath(for: element), indexPath.item > 0,  let element = self.element(for: IndexPath(item: indexPath.item - 1, section: indexPath.section)), !elementsToDelete.contains(element) {
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
                return event
            }
        } else {
            keyDownMonitor = nil
        }
    }

    // MARK: - Snapshot

    /**
     Returns a representation of the current state of the data in the collection view.

     A snapshot containing section and item identifiers in the order that they appear in the UI.
     */
    open func snapshot() -> NSDiffableDataSourceSnapshot<Section, Element> {
        currentSnapshot
    }

    /// Returns an empty snapshot.
    open func emptySnapshot() -> NSDiffableDataSourceSnapshot<Section, Element> {
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
    open func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Element>, _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        var previousIsEmpty: Bool?
        if emptyHandler != nil {
            previousIsEmpty = currentSnapshot.isEmpty
        }
        let internalSnapshot = snapshot.toIdentifiableSnapshot()
        currentSnapshot = snapshot
        dataSource.apply(internalSnapshot, option, completion: completion)
        updateEmptyView(snapshot, previousIsEmpty: previousIsEmpty)
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
        collectionView.registerForDraggedTypes([.itemID, .fileURL, .tiff, .png, .string])
        
        // collectionView.setDraggingSourceOperationMask(.move, forLocal: true)
         collectionView.setDraggingSourceOperationMask(.copy, forLocal: false)
    }

    /**
     A closure that configures and returns an item for a collection view from its diffable data source.

     You use this closure to configure and return collection view items when creating a diffable data source using ``init(collectionView:itemProvider:)``.

     - Parameters:
        - collectionView: The collection view to configure this cell for.
        -  indexpath: The index path that specifies the location of the item in the collection view.
        - element: The element for the collection view item.

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

    /**
     Returns the number of items in the specified section.
     
     If you call this method with the index of a section that doesn’t exist in the collection view, the app throws an error.
     
     - Parameters:
        - collectionView: The collection view requesting this information.
        - section: An index number identifying a section in the collection view. This index value is 0-based.
     
     - Returns: The number of items in the specified section. This method returns 0 if the section is empty.
     */
    open func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.collectionView(collectionView, numberOfItemsInSection: section)
    }

    /**
     Returns the item at the specified index path in the collection view.
     
     - Parameters:
        - collectionView: The collection view requesting this information.
        - indexPath: The index path that specifies the location of the item.
     
     - Returns: A configured item object.
     */
    open func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        dataSource.collectionView(collectionView, itemForRepresentedObjectAt: indexPath)
    }

    /**
     Returns the number of sections in the collection view.
     
     - Parameter collectionView: The collection view requesting this information.
     - Returns: The number of sections in the collection view. This method returns 0 if the collection view is empty.
     */
    open func numberOfSections(in collectionView: NSCollectionView) -> Int {
        dataSource.numberOfSections(in: collectionView)
    }

    /**
     Returns a supplementary view for the specified element kind to display in the collection view.
     
     - Parameters:
        - collectionView: The collection view requesting this information.
        - kind: The kind of supplementary view to provide. The value of this string is defined by the layout object that supports the supplementary view.
        - indexPath: The index path that specifies the location of the new supplementary view.
     
     - Returns: A configured supplementary view object.
     */
    open func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        dataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }

    // MARK: - Elements

    /// All current elements in the collection view.
    open var elements: [Element] {
        currentSnapshot.itemIdentifiers
    }

    /// The selected elements.
    open var selectedElements: [Element] {
        get { collectionView.selectionIndexPaths.compactMap { element(for: $0) } }
        set {
            guard newValue != selectedElements else { return }
            selectElements(newValue, scrollPosition: [])
        }
    }

    /**
     Returns the element at the specified index path in the collection view.

     - Parameter indexPath: The index path.
     - Returns: The element at the index path or nil if there isn't any element at the index path.
     */
    open func element(for indexPath: IndexPath) -> Element? {
        if let itemId = dataSource.itemIdentifier(for: indexPath) {
            return currentSnapshot.itemIdentifiers[id: itemId]
        }
        return nil
    }
    
    /// Returns the elements for the specified section.
    open func elements(for section: Section) -> [Element] {
        currentSnapshot.itemIdentifiers(inSection: section)
    }

    /// Returns the index path for the specified element in the collection view.
    open func indexPath(for element: Element) -> IndexPath? {
        dataSource.indexPath(for: element.id)
    }

    /**
     Returns the element at the specified point.

     - Parameter point: The point in the collection view’s bounds that you want to test.
     - Returns: The element at the specified point or `nil` if no element was found at that point.
     */
    open func element(at point: CGPoint) -> Element? {
        if let indexPath = collectionView.indexPathForItem(at: point) {
            return element(for: indexPath)
        }
        return nil
    }

    /// Updates the data for the specified elements, preserving the existing collection view items for the elements.
    open func reconfigureElements(_ elements: [Element]) {
        let indexPaths = elements.compactMap { indexPath(for: $0) }
        collectionView.reconfigureItems(at: indexPaths)
    }

    /// Reloads the collection view items for the specified elements.
    open func reloadElements(_ elements: [Element], animated: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(elements.ids)
        dataSource.apply(snapshot, animated ? .animated : .withoutAnimation)
    }

    /// Selects the specified elements.
    open func selectElements(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition) {
        let indexPaths = Set(elements.compactMap { indexPath(for: $0) })
        collectionView.selectItems(at: indexPaths, scrollPosition: scrollPosition)
    }

    /// Deselects the specified elements.
    open func deselectElements(_ elements: [Element]) {
        let indexPaths = Set(elements.compactMap { indexPath(for: $0) })
        collectionView.deselectItems(at: indexPaths)
    }

    /// Selects all elements in the specified sections.
    open func selectElements(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let elements = elements(for: sections)
        selectElements(elements, scrollPosition: scrollPosition)
    }

    /// Deselects all elementsin the specified sections.
    open func deselectElements(in sections: [Section]) {
        let elementIndexPaths = Set(sections.flatMap { indexPaths(for: $0) })
        collectionView.deselectItems(at: elementIndexPaths)
    }

    /**
     Scrolls the collection view to the specified elements.
     
     - Parameters:
        - elements: The elements to scroll to.
        - scrollPosition: The options for scrolling the bounding box of the specified elements into view. You may combine one vertical and one horizontal scrolling option when calling this method. Specifying more than one option for either the vertical or horizontal directions raises an exception.
     */
    open func scrollToElements(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition = []) {
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

    func removeItems(_ elements: [Element]) {
        var snapshot = snapshot()
        snapshot.deleteItems(elements)
        apply(snapshot, .animated)
    }

    func deletionTransaction(_ elements: [Element]) -> DiffableDataSourceTransaction<Section, Element> {
        var finalSnapshot = snapshot()
        finalSnapshot.deleteItems(elements)
        return DiffableDataSourceTransaction(initial: currentSnapshot, final: finalSnapshot)
    }

    func movingTransaction(at indexPaths: [IndexPath], to toIndexPath: IndexPath) -> DiffableDataSourceTransaction<Section, Element>? {
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
        return DiffableDataSourceTransaction(initial: currentSnapshot, final: newSnapshot)
    }

    // MARK: - Sections

    /// All current sections in the collection view.
    open var sections: [Section] {
        currentSnapshot.sectionIdentifiers
    }

    /// Returns the index for the section in the collection view.
    open func index(for section: Section) -> Int? {
        sections.firstIndex(of: section)
    }

    /*
    /// Returns the section at the index in the collection view.
    open func section(for index: Int) -> Section? {
        sections[safe: index]
    }
     */
    
    /**
     Returns the section for the specified element.
     
     - Parameter element: The element in your collection view.
     - Returns: The section, or `nil` if the element isn't in any section.
     */
    open func section(for element: Element) -> Section? {
        currentSnapshot.sectionIdentifier(containingItem: element)
    }

    /**
     Scrolls the collection view to the specified section.
     
     - Parameters:
        - section: The section to scroll to.
        - scrollPosition: The options for scrolling the bounding box of the specified section into view. You may combine one vertical and one horizontal scrolling option when calling this method. Specifying more than one option for either the vertical or horizontal directions raises an exception.
     */
    open func scrollToSection(_ section: Section, scrollPosition: NSCollectionView.ScrollPosition) {
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
    
    // MARK: - Empty Collection View
    
    /**
     The view that is displayed when the datasource doesn't contain any elements.
     
     When using this property, ``emptyContentConfiguration`` is set to `nil`.
     */
    open var emptyView: NSView? = nil {
        didSet {
            guard oldValue != emptyView else { return }
            oldValue?.removeFromSuperview()
            if emptyView != nil {
                emptyContentConfiguration = nil
                updateEmptyView(snapshot())
            }
        }
    }
    
    /**
     The content configuration that content view is displayed when the datasource doesn't contain any elements.
     
     When using this property, ``emptyView`` is set to `nil`.
     */
    open var emptyContentConfiguration: NSContentConfiguration? = nil {
        didSet {
            if let configuration = emptyContentConfiguration {
                emptyView = nil
                if let emptyContentView = self.emptyContentView {
                    emptyContentView.contentConfiguration = configuration
                } else {
                    emptyContentView = .init(configuration: configuration)
                }
                updateEmptyView(snapshot())
            } else {
                emptyContentView?.removeFromSuperview()
                emptyContentView = nil
            }
        }
    }
    
    /**
     The handler that gets called when the data source switches between an empty and non-empty snapshot or viceversa.

     You can use this handler e.g. if you want to update your empty view or content configuration.
     
     - Parameter isEmpty: A Boolean value indicating whether the current snapshot is empty.
     */
    open var emptyHandler: ((_ isEmpty: Bool)->())? {
        didSet {
            emptyHandler?(snapshot().isEmpty)
        }
    }
    
    var emptyContentView: ContentConfigurationView?
    
     func updateEmptyView(_ snapshot: NSDiffableDataSourceSnapshot<Section, Element>, previousIsEmpty: Bool? = nil) {
         if !snapshot.isEmpty {
             emptyView?.removeFromSuperview()
             emptyContentView?.removeFromSuperview()
         } else if let emptyView = self.emptyView, emptyView.superview != collectionView {
             collectionView?.addSubview(withConstraint: emptyView)
         } else if let emptyContentView = self.emptyContentView, emptyContentView.superview != collectionView {
             collectionView?.addSubview(withConstraint: emptyContentView)
         }
         if let emptyHandler = self.emptyHandler, let previousIsEmpty = previousIsEmpty {
             let isEmpty = snapshot.isEmpty
             if previousIsEmpty != isEmpty {
                 emptyHandler(isEmpty)
             }
         }
     }

    // MARK: - Handlers

    /// The handlers for hovering elements with the mouse.
    open var hoverHandlers = HoverHandlers() {
        didSet { observeHoveredItem() }
    }

    /// The handlers for selecting elements.
    open var selectionHandlers = SelectionHandlers()

    /**
     The handlers for deleting elements.
     
     Provide ``DeletingHandlers-swift.struct/canDelete`` to support the deleting of elements in your collection view.
     
     The system calls the ``DeletingHandlers-swift.struct/didDelete`` handler after a deleting transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
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
    open var deletingHandlers = DeletingHandlers() {
        didSet { observeKeyDown() }
    }

    /**
     The handlers for reordering elements.
     
     Provide ``ReorderingHandlers-swift.struct/canReorder`` to support the reordering of elements in your collection view.
     
     The system calls the ``ReorderingHandlers-swift.struct/didReorder`` handler after a reordering transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
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
    open var reorderingHandlers = ReorderingHandlers()

    /**
     The handlers for the displaying elements.

     The handlers get called whenever the collection view is displaying new elements (e.g. when the enclosing scrollview scrolls to new elements).
     
     Using these handlers can cost performance as the collection view is constantly observed for scrolling.
     */
    open var displayHandlers = DisplayHandlers() {
        didSet { observeDisplayingItems() }
    }

    /// The handlers for prefetching elements.
    open var prefetchHandlers = PrefetchHandlers()

    /// The handlers highlighting elements.
    open var highlightHandlers = HighlightHandlers()

    /// The handlers for dropping files inside the collection view and elements outside the collection view.
    public var droppingHandlers = DroppingHandlers()

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
        public var willDelete: ((_ elements: [Element], _ transaction: DiffableDataSourceTransaction<Section, Element>) -> Void)?

        /**
         The handler that that gets called after deleting elements.
         
         The system calls the `didDelete` handler after a deleting transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
         
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
        public var didDelete: ((_ elements: [Element], _ transaction: DiffableDataSourceTransaction<Section, Element>) -> Void)?
    }

    /**
     Handlers for reordering elements.
     
     Take a look at ``reorderingHandlers-swift.property`` how to support reordering elements.
     */
    public struct ReorderingHandlers {
        /// The handler that determines if elements can be reordered. The default value is `nil` which indicates that the elements can be reordered.
        public var canReorder: ((_ elements: [Element]) -> Bool)?

        /// The handler that that gets called before reordering elements.
        public var willReorder: ((DiffableDataSourceTransaction<Section, Element>) -> Void)?

        /**
         The handler that that gets called after reordering elements.

         The system calls the `didReorder` handler after a reordering transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
         
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
        public var didReorder: ((DiffableDataSourceTransaction<Section, Element>) -> Void)?
    }

    /// Handlers for the highlight state of elements.
    public struct HighlightHandlers {
        /// The handler that determines which elements should change to a new highlight state. The default value is `nil` which indicates that all elements should change the state.
        public var shouldChange: ((_ elements: [Element], NSCollectionViewItem.HighlightState) -> [Element])?

        /// The handler that gets called when elements changed their highlight state.
        public var didChange: ((_ elements: [Element], NSCollectionViewItem.HighlightState) -> Void)?
    }

    /**
     Handlers for displaying elements.

     The handlers get called whenever the collection view is displaying new elements (e.g. when the enclosing scrollview scrolls to new elements).
     
     Using these handlers can cost performance as the collection view is constantly observed for scrolling.
     */
    public struct DisplayHandlers {
        /// The handler that gets called whenever elements start getting displayed. (e.g. when the enclosing scrollview scrolls to new elements).
        public var isDisplaying: ((_ elements: [Element]) -> Void)?

        /// The handler that gets called whenever elements end getting displayed.
        public var didEndDisplaying: ((_ elements: [Element]) -> Void)?

        var shouldObserve: Bool {
            isDisplaying != nil || didEndDisplaying != nil
        }
    }

    /**
     Handlers for hovering elements with the mouse.
     
     The handlers get called when the mouse is hovering collection view items.
     */
    public struct HoverHandlers {
        /// The handler that gets called whenever the mouse is hovering an element.
        public var isHovering: ((_ element: Element) -> Void)?

        /// The handler that gets called whenever the mouse did end hovering an element.
        public var didEndHovering: ((_ element: Element) -> Void)?

        var shouldObserve: Bool {
            isHovering != nil || didEndHovering != nil
        }
    }

    /// Handlers dropping files inside the collection view and elements outside the collection view.
    public struct DroppingHandlers {
        
        /// The handlers for dragging elements outside the collection view.
        public struct OutsideHandlers {
            /// The strings for the specified elements to write to the pasteboard.
            public var string: ((_ element: Element) -> String?)?
            /// The urls for the specified elements to write to the pasteboard.
            public var url: ((_ element: Element) -> URL?)?
            /// The images for the specified elements to write to the pasteboard.
            public var image: ((_ element: Element) -> NSImage?)?
            /// The colors for the specified elements to write to the pasteboard.
            public var color: ((_ element: Element) -> NSColor?)?
            /// The pasteboard items for the specified elements to write to the pasteboard.
            public var pasteboardItem: ((_ element: Element) -> [NSPasteboardItem])?

            /// The handler that determines whenever elements can be dragged outside the collection view.
            public var canDrag: (([Element]) -> Bool)?
            /// The handler that gets called when the handler will drag elements outside the collection view.
            public var willDrag: (() -> ())?
            /// The handler that gets called when the handler did drag elements outside the collection view.
            public var didDrag: (() -> ())?
        }

        /// The handlers for dragging pasteboard items inside the collection view.
        public struct InsideHandlers {
            /// The handler that specifies the elements for the strings in the pasteboard.
            public var strings: ((_ strings: [String]) -> [Element])?
            /// The handler that specifies the elements for the file urls in the pasteboard.
            public var fileURLs: ((_ fileURLs: [URL]) -> [Element])?
            /// The handler that specifies the elements for the urls in the pasteboard.
            public var urls: ((_ urls: [URL]) -> [Element])?
            /// The handler that specifies the elements for the images in the pasteboard.
            public var images: ((_ images: [NSImage]) -> [Element])?
            /// The handler that specifies the elements for the colors in the pasteboard.
            public var colors: ((_ colors: [NSColor]) -> [Element])?
            /// The handler that specifies the elements for the pasteboard items in the pasteboard.
            public var pasteboardItems: ((_ items: [NSPasteboardItem]) -> [Element])?
            
            /// The handler that determines whenever pasteboard elements can be dragged inside the collection view.
            public var canDrag: (([PasteboardContent]) -> Bool)?
            /// The handler that gets called when the handler will drag elements inside the collection view.
            public var willDrag: ((_ transaction: DiffableDataSourceTransaction<Section, Element>) -> ())?
            /// The handler that gets called when the handler did drag elements inside the collection view.
            public var didDrag: ((_ transaction: DiffableDataSourceTransaction<Section, Element>) -> ())?
            var needsTransaction: Bool {
                willDrag != nil || didDrag != nil
            }
        }

        /// The handlers for dragging pasteboard items inside the collection view.
        public var inside = InsideHandlers()

        /// The handlers for dragging elements outside the collection view.
        public var outside = OutsideHandlers()

        /// The handler that determines the pasteboard value of an element when dragged outside the collection view.
        public var pasteboardValue: ((_ element: Element) -> PasteboardContent)?
        
        /// The handler that determines the image when dragging elements.
        public var draggingImage: ((_ elements: [Element], _ event: NSEvent, _ screenLocation: CGPoint) -> NSImage?)?
    }
}

// MARK: - Quicklook

extension CollectionViewDiffableDataSource where Element: QuicklookPreviewable {
    /**
     A Boolean value that indicates whether the user can open a quicklook preview of selected elements by pressing space bar.
     
     Any element conforming to `QuicklookPreviewable` can be previewed by providing a preview file url.
     
     For more information on how to provide previews, take a look at the `FZQuicklook` documentation.
     */
    public var isQuicklookPreviewable: Bool {
        get { collectionView.isQuicklookPreviewable }
        set { collectionView.isQuicklookPreviewable = newValue }
    }

    /**
     Opens `QuicklookPanel` that presents quicklook previews of the specified elements.

     To quicklook the selected elements, use collection view's `quicklookSelectedItems()`.
     
     For more information on how to provide previews, take a look at the `FZQuicklook` documentation.

     - Parameters:
        - elements: The elements to preview.
        - current: The element that starts the preview. The default value is `nil`.
     */
    public func quicklookElements(_ elements: [Element], current: Element? = nil) where Element: QuicklookPreviewable {
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
