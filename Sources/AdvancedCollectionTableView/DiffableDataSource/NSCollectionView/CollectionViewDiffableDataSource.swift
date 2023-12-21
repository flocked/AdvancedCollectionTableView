//
//  CollectionViewDiffableDataSource.swift
//  Coll
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import FZQuicklook
import QuickLookUI

/**
 A `NSCollectionViewDiffableDataSource` with additional functionality..
 
 The diffable data source provides:
 - Reordering of items by enabling ``allowsReordering``.
 - Deleting of items by enabling  ``allowsDeleting``.
 - Quicklook of items via spacebar by providing elements conforming to `QuicklookPreviewable`.
 - A right click menu provider for selected items via ``menuProvider``.

 ### Handlers
 
 It includes handlers for:
 - Prefetching of items via ``prefetchHandlers-swift.property``.
 - Reordering of items via ``reorderingHandlers-swift.property``.
 - Deleting of items via ``deletionHandlers-swift.property``.
 - Selecting of items via ``selectionHandlers-swift.property``.
 - Highlight state of items via ``highlightHandlers-swift.property``.
 - Displayed items via ``displayHandlers-swift.property``.
 - Items that are hovered by mouse via ``hoverHandlers-swift.property``.
 - Drag and drop of files from and to the collection view via ``dragDropHandlers-swift.property``.
 - Pinching of the collection view via ``pinchHandler``.

 ### Configurating the data source
 
 To connect a diffable data source to a collection view, you create the diffable data source using its ``init(collectionView:itemProvider:)`` or ``init(collectionView:itemRegistration:)`` initializer, passing in the collection view you want to associate with that data source.
 
 ```swift
 collectionView.dataSource = CollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, itemRegistration: itemRegistration)
 ```
 
 Then, you generate the current state of the data and display the data in the UI by constructing and applying a snapshot. For more information, see `NSDiffableDataSourceSnapshot`.
 
 - Note: Don’t change the dataSource or delegate on the collection view after you configure it with a diffable data source. If the collection view needs a new data source after you configure it initially, create and configure a new collection view and diffable data source.
 */
public class CollectionViewDiffableDataSource<Section: Identifiable & Hashable, Element: Identifiable & Hashable>: NSObject, NSCollectionViewDataSource {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Element>
    typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Element.ID>
    typealias DataSoure = NSCollectionViewDiffableDataSource<Section.ID,  Element.ID>
    
    weak var collectionView: NSCollectionView!
    var dataSource: DataSoure!
    var delegateBridge: DelegateBridge!
    var magnifyGestureRecognizer: NSMagnificationGestureRecognizer?
    var currentSnapshot: Snapshot = Snapshot()
    var draggingIndexPaths = Set<IndexPath>()
    var previousDisplayingElements = [Element]()
    var rightDownMonitor: NSEvent.Monitor? = nil
    var hoveredItemObserver: NSKeyValueObservation? = nil
    
    /**
     A closure that configures and returns a item for a collection view from its diffable data source.
     
     A non-`nil` configured item object. The item provider must return a valid item object to the collection view.
     
     - Parameters:
        - collectionView: The collection view to configure this cell for.
        -  indexpath: The index path that specifies the location of the item in the collection view.
        - element: An object, with a type that implements the Hashable protocol, the data source uses to uniquely identify the item for this cell.
     
     - Returns: A non-`nil` configured item object. The item provider must return a valid cell object to the collection view.
     */
    public typealias ItemProvider = (_ collectionView: NSCollectionView, _ indexPath: IndexPath, _ element: Element) -> NSCollectionViewItem?
    
    /**
     The closure that configures and returns the collection view’s supplementary views, such as headers and footers, from the diffable data source.
     */
    public var supplementaryViewProvider: SupplementaryViewProvider? = nil
    /**
     A closure that configures and returns a collection view’s supplementary view, such as a header or footer, from a diffable data source.
     
     - Parameters:
        - collectionView: The collection view to configure this supplementary view for.
        -  elementKind: The kind of supplementary view to provide. The layout object that supports the supplementary view defines the value of this string.
        - indexpath: The index path that specifies the location of the supplementary view in the collection view.
     
     - Returns: A non-`nil` configured supplementary view object. The supplementary view provider must return a valid view object to the collection view.
     */
    public typealias SupplementaryViewProvider = (_ collectionView: NSCollectionView, _ elementKind: String, _ indexPath: IndexPath) -> (NSView & NSCollectionViewElement)?
    
    /**
     A Boolean value that indicates whether users can delete items either via keyboard shortcut or right click menu.
     
     If the value of this property is true (the default is false), users can delete items.
     */
    public var allowsDeleting: Bool = false {
        didSet { self.setupKeyDownMonitor() }
    }
    /**
     A Boolean value that indicates whether users can reorder items in the collection view when dragging them via mouse.
     
     If the value of this property is true (the default is false), users can reorder items in the collection view.
     */
    public var allowsReordering: Bool = false
    
    /**
     Right click menu provider.
     
     `elements` provides:
     - if right-click on a selected element, all selected elements,
     - or else if right-click on a non selected element, that element,
     - or else an empty array.
     
     When returning a menu to the `menuProvider`, the collection view will display a menu on right click.
     */
    public var menuProvider: ((_ elements: [Element]) -> NSMenu?)? = nil {
        didSet { setupRightDownMonitor() } }
    
    /// A handler that gets called whenever collection view magnifies.
    public var pinchHandler: ((_ mouseLocation: CGPoint, _ magnification: CGFloat, _ state: NSMagnificationGestureRecognizer.State) -> ())? = nil { didSet { self.setupMagnificationHandler() } }
    
    internal func setupMagnificationHandler() {
        if pinchHandler != nil {
            if (magnifyGestureRecognizer == nil) {
                self.magnifyGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(didMagnify(_:)))
                self.collectionView.addGestureRecognizer(self.magnifyGestureRecognizer!)
            }
        } else {
            if let magnifyGestureRecognizer = magnifyGestureRecognizer {
                self.collectionView.removeGestureRecognizer(magnifyGestureRecognizer)
            }
            self.magnifyGestureRecognizer = nil
        }
    }
    
    internal var pinchElement: Element? = nil
    @objc internal func didMagnify(_ gesture: NSMagnificationGestureRecognizer) {
        let pinchLocation = gesture.location(in: self.collectionView)
        switch gesture.state {
        case .began:
            //    let center = CGPoint(x: self.collectionView.frame.midX, y: self.collectionView.frame.midY)
            pinchElement = self.element(at: pinchLocation)
        case .ended, .cancelled, .failed:
            pinchElement = nil
        default:
            break
        }
        self.pinchHandler?(pinchLocation, gesture.magnification, gesture.state)
    }
    
    internal func setupRightDownMonitor() {
        if menuProvider != nil, rightDownMonitor == nil {
            self.rightDownMonitor = NSEvent.localMonitor(for: [.rightMouseDown]) { event in
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
    
    internal func setupMenu(for location: CGPoint) {
        if let menuProvider = self.menuProvider {
            if let element = self.element(at: location) {
                var menuItems: [Element] = [element]
                let selectedElements = self.selectedElements
                if selectedElements.contains(element) {
                    menuItems = selectedElements
                }
                self.collectionView.menu = menuProvider(menuItems)
            } else {
                self.collectionView.menu = menuProvider([])
            }
        }
    }
    
    internal func setupHoverObserving() {
        if self.hoverHandlers.isHovering != nil || self.hoverHandlers.didEndHovering != nil {
            self.collectionView.setupObservingView()
            if hoveredItemObserver == nil {
                hoveredItemObserver = self.collectionView.observeChanges(for: \.hoveredIndexPath, handler: { old, new in
                    guard old != new else { return }
                    if let didEndHovering = self.hoverHandlers.didEndHovering,  let old = old, let element = self.element(for: old) {
                        didEndHovering(element)
                    }
                    if let isHovering = self.hoverHandlers.isHovering,  let new = new, let element = self.element(for: new) {
                        isHovering(element)
                    }
                })
            }
        } else {
            hoveredItemObserver = nil
        }
    }
    
    internal func ensureTrackingDisplayingItems() {
        if (self.displayHandlers.isDisplaying != nil || self.displayHandlers.didEndDisplaying != nil) {
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
    
    @objc internal func scrollViewContentBoundsDidChange(_ notification: Notification) {
        guard (notification.object as? NSClipView) != nil else { return }
        let displayingElements = self.displayingElements
        let added = displayingElements.filter({previousDisplayingElements.contains($0) == false})
        let removed = previousDisplayingElements.filter({displayingElements.contains($0) == false})
        
        if (added.isEmpty == false) {
            self.displayHandlers.isDisplaying?(added)
        }
        if (removed.isEmpty == false) {
            self.displayHandlers.didEndDisplaying?(removed)
        }
        previousDisplayingElements = displayingElements
    }
    
    // MARK: - Snapshot
    
    /**
     Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes.
     
     The system interrupts any ongoing item animations and immediately reloads the collection view’s content.
     
     - Parameters:
        - snapshot: The snapshot that reflects the new state of the data in the collection view.
        - option: Option how to apply the snapshot to the collection view.
        - completion: A optional completion handlers which gets called after applying the snapshot.
     */
    public func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Element>, _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        let internalSnapshot = convertSnapshot(snapshot)
        self.currentSnapshot = snapshot
        self.dataSource.apply(internalSnapshot, option, completion: completion)
    }
    
    /**
     Returns a representation of the current state of the data in the collection view.
     
     A snapshot containing section and item identifiers in the order that they appear in the UI.
     */
    public func snapshot() -> NSDiffableDataSourceSnapshot<Section, Element> {
        var snapshot = Snapshot()
        snapshot.appendSections(currentSnapshot.sectionIdentifiers)
        for section in currentSnapshot.sectionIdentifiers {
            snapshot.appendItems(currentSnapshot.itemIdentifiers(inSection: section), toSection: section)
        }
        return snapshot
    }
    
    internal func convertSnapshot(_ snapshot: Snapshot) -> InternalSnapshot {
        var internalSnapshot = InternalSnapshot()
        let sections = snapshot.sectionIdentifiers
        internalSnapshot.appendSections(sections.ids)
        for section in sections {
            let elements = snapshot.itemIdentifiers(inSection: section)
            internalSnapshot.appendItems(elements.ids, toSection: section.id)
        }
        return internalSnapshot
    }
    
    // MARK: - Init
    
    /**
     Creates a diffable data source with the specified item provider, and connects it to the specified collection view.
     
     To connect a diffable data source to a collection view, you create the diffable data source using this initializer, passing in the collection view you want to associate with that data source. You also pass in a item provider, where you configure each of your items to determine how to display your data in the UI.
     
     ```swift
     dataSource = CollectionViewDiffableDataSource<Section, Element>(collectionView: collectionView, itemProvider: {
     (collectionView, indexPath, element) in
     // configure and return item
     })
     ```
     
     - Parameters:
        - collectionView: The initialized collection view object to connect to the diffable data source.
        - itemProvider: A closure that creates and returns each of the items for the collection view from the data the diffable data source provides.
     */
    public init(collectionView: NSCollectionView, itemProvider: @escaping ItemProvider) {
        self.collectionView = collectionView
        super.init()
        
        self.dataSource = DataSoure(collectionView: self.collectionView, itemProvider: {
            [weak self] collectionView, indePath, elementID in
            
            guard let self = self, let element = self.allElements[id: elementID] else { return nil }
            return itemProvider(collectionView, indePath, element)
        })
        
        self.dataSource.supplementaryViewProvider = { [weak self] collectionView, elementKind, indePath in
            guard let self = self else { return nil }
            return self.supplementaryViewProvider?(collectionView, elementKind, indePath)
        }
        
        sharedInit()
    }
    /**
     Creates a diffable data source with the specified item registration, and connects it to the specified collection view.
     
     To connect a diffable data source to a collection view, you create the diffable data source using this initializer, passing in the collection view you want to associate with that data source. You also pass in a item registration, where each of your items gets determine how to display your data in the UI.
     
     ```swift
     dataSource = CollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, itemRegistration: itemRegistration)
     ```
     
     - Parameters:
        - collectionView: The initialized collection view object to connect to the diffable data source.
        - itemRegistration: A item registration which returns each of the items for the collection view from the data the diffable data source provides.
     */
    public convenience init<Item: NSCollectionViewItem>(collectionView: NSCollectionView, itemRegistration: NSCollectionView.ItemRegistration<Item, Element>) {
        self.init(collectionView: collectionView, itemProvider: { collectionView,indePath,element in
            return collectionView.makeItem(using: itemRegistration, for: indePath, element: element) })
    }
    
    internal func sharedInit() {
        self.collectionView.postsFrameChangedNotifications = false
        self.collectionView.postsBoundsChangedNotifications = false
        
        self.collectionView.setupCollectionViewFirstResponderObserver()
        self.collectionView.isQuicklookPreviewable = Element.self is QuicklookPreviewable.Type
        self.collectionView.registerForDraggedTypes([.itemID])
        self.collectionView.setDraggingSourceOperationMask(.move, forLocal: true)
        
        self.delegateBridge = DelegateBridge(self)
    }
        
    // MARK: - DataSource implementation
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        return dataSource.collectionView(collectionView, itemForRepresentedObjectAt: indexPath)
    }
    
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return dataSource.numberOfSections(in: collectionView)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        return dataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    // MARK: - Elements
        
    /// All current elements in the collection view.
    internal var allElements: [Element] {
        return self.currentSnapshot.itemIdentifiers
    }
    
    /// An array of the selected elements.
    public var selectedElements: [Element] {
        return self.collectionView.selectionIndexPaths.compactMap({element(for: $0)})
    }
    
    /**
     Returns the element at the specified index path in the collection view.
     
     - Parameter indexPath: The indexPath
     - Returns: The element at the index path or nil if there isn't any element at the index path.
     */
    public func element(for indexPath: IndexPath) ->  Element? {
        if let itemId = self.dataSource.itemIdentifier(for: indexPath) {
            return self.currentSnapshot.itemIdentifiers[id: itemId]
        }
        return nil
    }
    
    /// Returns the index path for the specified element in the collection view.
    public func indexPath(for element: Element) -> IndexPath? {
        return dataSource.indexPath(for: element.id)
    }
    
    /**
     Returns the element at the specified point.
     
     - Parameter point: The point in the collection view’s bounds that you want to test.
     - Returns: The element at the specified point or `nil` if no element was found at that point.
     */
    public func element(at point: CGPoint) -> Element? {
        if let indexPath = self.collectionView.indexPathForItem(at: point) {
            return element(for: indexPath)
        }
        return nil
    }
    
    /// Updates the data for the elements you specify, preserving the existing collection view items for the elements.
    public func reconfigureElements(_ elements: [Element]) {
        let indexPaths = elements.compactMap({self.indexPath(for:$0)})
        self.collectionView.reconfigureItems(at: indexPaths)
    }
    
    /// Reloads the specified elements.
    public func reloadElements(_ elements: [Element], animated: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(elements.ids)
        dataSource.apply(snapshot, animated ? .animated: .withoutAnimation)
    }
    
    /// Selects all collection view items of the specified elements.
    internal func selectElements(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition, addSpacing: CGFloat? = nil) {
        let indexPaths = Set(elements.compactMap({indexPath(for: $0)}))
        self.collectionView.selectItems(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    /// Deselects all collection view items of the specified elements.
    internal func deselectElements(_ elements: [Element]) {
        let indexPaths = Set(elements.compactMap({indexPath(for: $0)}))
        self.collectionView.deselectItems(at: indexPaths)
    }
    
    /// Selects all collection view items of the elements in the specified sections.
    internal func selectElements(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let elements = self.elements(for: sections)
        self.selectElements(elements, scrollPosition: scrollPosition)
    }
    
    /// Deselects all collection view items of the elements in the specified sections.
    internal func deselectElements(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let indexPaths = sections.flatMap({self.indexPaths(for: $0)})
        self.collectionView.deselectItems(at: Set(indexPaths))
    }
    
    /// Scrolls the collection view to the specified elements.
    public func scrollToElements(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition = []) {
        let indexPaths = Set(self.indexPaths(for: elements))
        self.collectionView.scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    /// An array of elements that are displaying (currently visible).
    internal var displayingElements: [Element] {
        self.collectionView.displayingIndexPaths().compactMap({self.element(for: $0)})
    }
    
    /// The collection view item for the specified element.
    internal func item(for element: Element) -> NSCollectionViewItem? {
        if let indexPath = indexPath(for: element) {
            return self.collectionView.item(at: indexPath)
        }
        return nil
    }
    
    /// The frame of the collection view item for the specified element.
    internal func itemFrame(for element: Element) -> CGRect? {
        if let indexPath = indexPath(for: element) {
            return self.collectionView.frameForItem(at: indexPath)
        }
        return nil
    }
    
    internal func indexPaths(for elements: [Element]) -> [IndexPath] {
        return elements.compactMap({indexPath(for: $0)})
    }
    
    internal func indexPaths(for section: Section) -> [IndexPath] {
        let elements = self.currentSnapshot.itemIdentifiers(inSection: section)
        return self.indexPaths(for: elements)
    }
    
    internal func indexPaths(for sections: [Section]) -> [IndexPath] {
        return sections.flatMap({self.indexPaths(for: $0)})
    }
    
    internal func elements(for sections: [Section]) -> [Element] {
        let currentSnapshot = self.currentSnapshot
        return sections.flatMap({currentSnapshot.itemIdentifiers(inSection: $0)})
    }
    
    internal func isSelected(at indexPath: IndexPath) -> Bool {
        self.collectionView.selectionIndexPaths.contains(indexPath)
    }
    
    internal func isSelected(for element: Element) -> Bool {
        if let indexPath = indexPath(for: element) {
            return isSelected(at: indexPath)
        }
        return false
    }
    
    internal func removeElements( _ elements: [Element]) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(elements)
        self.apply(snapshot, .animated)
    }
    
    internal func deletionTransaction(_ elements: [Element]) -> DiffableDataSourceTransaction<Section, Element> {
        let initalSnapshot = self.currentSnapshot
        var finalSnapshot = self.snapshot()
        finalSnapshot.deleteItems(elements)
        let difference = initalSnapshot.itemIdentifiers.difference(from: finalSnapshot.itemIdentifiers)
        return DiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: finalSnapshot, difference: difference)
    }
    
    internal func movingTransaction(at indexPaths: [IndexPath], to toIndexPath: IndexPath) -> DiffableDataSourceTransaction<Section, Element>? {
        let elements = indexPaths.compactMap({self.element(for: $0)})
        var toIndexPath = toIndexPath
        var isLast = false
        if let section = currentSnapshot.sectionIdentifiers[safe: toIndexPath.section], toIndexPath.item >= currentSnapshot.numberOfItems(inSection: section) {
            toIndexPath.item -= 1
            isLast = true
        }
        
        if let toElement = self.element(for: toIndexPath), elements.isEmpty == false {
            var snapshot = self.snapshot()
            if isLast {
                elements.reversed().forEach({snapshot.moveItem($0, afterItem: toElement)})
            } else {
                elements.forEach({snapshot.moveItem($0, beforeItem: toElement)})
            }
            let initalSnapshot = self.currentSnapshot
            let difference = initalSnapshot.itemIdentifiers.difference(from: snapshot.itemIdentifiers)
            return DiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: snapshot, difference: difference)
        }
        return nil
    }
    
    // MARK: - Sections
    
    /// All current sections in the collection view.
    internal var sections: [Section] { currentSnapshot.sectionIdentifiers }
    
    /// Returns the index for the section in the collection view.
    public func index(for section: Section) -> Int? {
        return sections.firstIndex(of: section)
    }
    
    /// Returns the section at the index in the collection view.
    public func section(for index: Int) -> Section? {
        return sections[safe: index]
    }
    
    internal func section(for element: Element) -> Section? {
        return self.currentSnapshot.sectionIdentifier(containingItem: element)
    }
    
    internal func section(at indexPath: IndexPath) -> Section? {
        if (indexPath.section <= self.sections.count-1) {
            return sections[indexPath.section]
        }
        return nil
    }
    
    /// Scrolls the collection view to the specified section.
    public func scrollToSection(_ section: Section, scrollPosition: NSCollectionView.ScrollPosition = []) {
        guard let index = index(for: section) else { return }
        let indexPaths = Set([IndexPath(item: 0, section: index)])
        self.collectionView.scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    // MARK: - Handlers
    
    /// Handlers that get called whenever the mouse is hovering an item.
    public var hoverHandlers = HoverHandlers() {
        didSet { self.setupHoverObserving() } }
    
    /// Handlers for selection of items.
    public var selectionHandlers = SelectionHandlers()
    
    /// Handlers for deletion of items.
    public var deletionHandlers = DeletionHandlers()
    
    /// Handlers for reordering of items.
    public var reorderingHandlers = ReorderingHandlers()
    
    ///Handlers for the displayed items. The handlers get called whenever the collection view is displaying new items (e.g. when the enclosing scrollview scrolls to new items).
    public var displayHandlers = DisplayHandlers() {
        didSet {  self.ensureTrackingDisplayingItems() } }
    
    /// Handlers for prefetching elements.
    public var prefetchHandlers = PrefetchHandlers()
    
    /// Handlers for drag and drop of files from and to the collection view.
    public var dragDropHandlers = DragdropHandlers()
    
    /// Handlers for the highlight state of elements.
    public var highlightHandlers = HighlightHandlers()
    
    /// Handlers for prefetching items.
    public struct PrefetchHandlers {
        /// The Handler that tells you to begin preparing data for the elements.
        public var willPrefetch: ((_ elements: [Element]) -> ())? = nil
        /// Cancels a previously triggered data prefetch request.
        public var didCancelPrefetching: ((_ elements: [Element]) -> ())? = nil
    }
    
    /// Handlers for selection of items.
    public struct SelectionHandlers {
        /// The Handler that determines whether elements should get selected.
        public var shouldSelect: ((_ elements: [Element]) -> [Element])? = nil
        /// The Handler that determines whether elements should get deselected.
        public var shouldDeselect: ((_ elements: [Element]) -> [Element])? = nil
        /// The Handler that gets called whenever elements get selected.
        public var didSelect: ((_ elements: [Element]) -> ())? = nil
        /// The Handler that gets called whenever elements get deselected.
        public var didDeselect: ((_ elements: [Element]) -> ())? = nil
    }
    
    /// Handlers for deletion of items.
    public struct DeletionHandlers {
        /// The Handler that determines whether elements should get deleted.
        public var shouldDelete: ((_ elements: [Element]) -> [Element])? = nil
        /// The Handler that that prepares the diffable data source for deleting elements.
        public var willDelete: ((_ elements: [Element], _ transaction: DiffableDataSourceTransaction<Section, Element>) -> ())? = nil
        /// The Handler that gets called whenever elements get deleted.
        public var didDelete: ((_ elements: [Element], _ transaction: DiffableDataSourceTransaction<Section, Element>) -> ())? = nil
    }
    
    /// Handlers for reordering items.
    public struct ReorderingHandlers {
        /// The Handler that determines whether you can reorder a particular item.
        public var canReorder: ((_ elements: [Element]) -> Bool)? = nil
        /// The Handler that prepares the diffable data source for reordering its items.
        public var willReorder: ((DiffableDataSourceTransaction<Section, Element>) -> ())? = nil
        /// The Handler that processes a reordering transaction.
        public var didReorder: ((DiffableDataSourceTransaction<Section, Element>) -> ())? = nil
    }
    
    /// Handlers for the highlight state of items.
    public struct HighlightHandlers {
        /// The Handler that determines which elements should change to a highlight state.
        public var shouldChange: ((_ elements: [Element], NSCollectionViewItem.HighlightState) -> [Element])? = nil
        /// The Handler that gets called whenever elements changed their highlight state.
        public var didChange: ((_ elements: [Element], NSCollectionViewItem.HighlightState) -> ())? = nil
    }
    
    /**
     Handlers for the displayed items.
     
     The handlers get called whenever the collection view is displaying new items (e.g. when the enclosing scrollview scrolls to new items).
     */
    public struct DisplayHandlers {
        /// The Handler that gets called whenever elements start getting displayed.
        public var isDisplaying: ((_ elements: [Element]) -> ())?
        /// The Handler that gets called whenever elements end getting displayed.
        public var didEndDisplaying: ((_ elements: [Element]) -> ())?
    }
    
    /// Handlers that get called whenever the mouse is hovering an item.
    public struct HoverHandlers {
        /// The handler that gets called whenever the mouse is hovering an item.
        public var isHovering: ((_ element: Element) -> ())?
        /// The handler that gets called whenever the mouse did end hovering an item.
        public var didEndHovering: ((_ element: Element) -> ())?
    }
    
    /// Handlers for drag and drop of files from and to the collection view.
    public struct DragdropHandlers {
        /// The handler that determines which items can be dragged outside the collection view.
        public var canDragOutside: ((_ elements: [Element]) -> [Element])? = nil
        /// The handler that gets called whenever items did drag ouside the collection view.
        public var didDragOutside: (([Element]) -> ())? = nil
        /// The handler that determines the pasteboard value of an item when dragged outside the collection view.
        public var pasteboardValue: ((_ element: Element) -> PasteboardWriting)? = nil
        /// The handler that determines whenever pasteboard items can be dragged inside the collection view.
        public var canDragInside: (([PasteboardWriting]) -> [PasteboardWriting])? = nil
        /// The handler that gets called whenever pasteboard items did drag inside the collection view.
        public var didDragInside: (([PasteboardWriting]) -> ())? = nil
        /// The handler that determines the image when dragging items.
        public var draggingImage: ((_ elements: [Element], NSEvent, NSPointPointer) -> NSImage?)? = nil
        
        var acceptsDragInside: Bool {
            canDragInside != nil && didDragInside != nil
        }
        
        var acceptsDragOutside: Bool {
            canDragOutside != nil
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
