//
//  CollectionViewDiffableDataSource.swift
//  
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
 - Quicklook of items via spacebar by providing items conforming to `QuicklookPreviewable`.
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
public class CollectionViewDiffableDataSource<Section: Identifiable & Hashable, Item: Identifiable & Hashable>: NSObject, NSCollectionViewDataSource {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Item.ID>
    typealias DataSoure = NSCollectionViewDiffableDataSource<Section.ID,  Item.ID>
    
    weak var collectionView: NSCollectionView!
    var dataSource: DataSoure!
    var delegateBridge: DelegateBridge!
    var magnifyGestureRecognizer: NSMagnificationGestureRecognizer?
    var currentSnapshot: Snapshot = Snapshot()
    var draggingIndexPaths = Set<IndexPath>()
    var previousDisplayingItems = [Item]()
    var rightDownMonitor: NSEvent.Monitor? = nil
    var hoveredItemObserver: NSKeyValueObservation? = nil
    
    /// The closure that configures and returns the collection view’s supplementary views, such as headers and footers, from the diffable data source.
    public var supplementaryViewProvider: SupplementaryViewProvider? = nil {
        didSet {
            if let supplementaryViewProvider = self.supplementaryViewProvider {
                self.dataSource.supplementaryViewProvider = { collectionView, itemKind, indePath in
                    return supplementaryViewProvider(collectionView, itemKind, indePath)
                }
            } else {
                self.dataSource.supplementaryViewProvider = nil
            }
        }
    }
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
     A Boolean value that indicates whether users can delete items either via keyboard shortcut or right click menu.
     
     If the value of this property is true (the default is false), users can delete items.
     */
    public var allowsDeleting: Bool = false {
        didSet { self.observeKeyDown() }
    }
    /**
     A Boolean value that indicates whether users can reorder items in the collection view when dragging them via mouse.
     
     If the value of this property is true (the default is false), users can reorder items in the collection view.
     */
    public var allowsReordering: Bool = false
    
    /**
     Right click menu provider.
     
     `items` provides:
     - if right-click on a selected item, all selected items,
     - or else if right-click on a non selected item, that item,
     - or else an empty array.
     
     When returning a menu to the `menuProvider`, the collection view will display a menu on right click.
     */
    public var menuProvider: ((_ items: [Item]) -> NSMenu?)? = nil {
        didSet { observeRightMouseDown() } }
    
    /// A handler that gets called whenever collection view magnifies.
    public var pinchHandler: ((_ mouseLocation: CGPoint, _ magnification: CGFloat, _ state: NSMagnificationGestureRecognizer.State) -> ())? = nil { didSet { self.observeMagnificationGesture() } }
                    
    func observeMagnificationGesture() {
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
    
    var pinchItem: Item? = nil
    @objc func didMagnify(_ gesture: NSMagnificationGestureRecognizer) {
        let pinchLocation = gesture.location(in: self.collectionView)
        switch gesture.state {
        case .began:
            //    let center = CGPoint(x: self.collectionView.frame.midX, y: self.collectionView.frame.midY)
            pinchItem = self.item(at: pinchLocation)
        case .ended, .cancelled, .failed:
            pinchItem = nil
        default:
            break
        }
        self.pinchHandler?(pinchLocation, gesture.magnification, gesture.state)
    }
    
    func observeRightMouseDown() {
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
    
    func setupMenu(for location: CGPoint) {
        if let menuProvider = self.menuProvider {
            if let item = self.item(at: location) {
                var menuItems: [Item] = [item]
                let selectedItems = self.selectedItems
                if selectedItems.contains(item) {
                    menuItems = selectedItems
                }
                self.collectionView.menu = menuProvider(menuItems)
            } else {
                self.collectionView.menu = menuProvider([])
            }
        }
    }
    
    func observeHoveredItem() {
        if self.hoverHandlers.isHovering != nil || self.hoverHandlers.didEndHovering != nil {
            self.collectionView.setupObservation()
            if hoveredItemObserver == nil {
                hoveredItemObserver = self.collectionView.observeChanges(for: \.hoveredIndexPath, handler: { old, new in
                    guard old != new else { return }
                    if let didEndHovering = self.hoverHandlers.didEndHovering,  let old = old, let item = self.item(for: old) {
                        didEndHovering(item)
                    }
                    if let isHovering = self.hoverHandlers.isHovering,  let new = new, let item = self.item(for: new) {
                        isHovering(item)
                    }
                })
            }
        } else {
            hoveredItemObserver = nil
        }
    }
    
    func observeDisplayingItems() {
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
    
    @objc func scrollViewContentBoundsDidChange(_ notification: Notification) {
        guard (notification.object as? NSClipView) != nil else { return }
        let displayingItems = self.displayingItems
        let added = displayingItems.filter({previousDisplayingItems.contains($0) == false})
        let removed = previousDisplayingItems.filter({displayingItems.contains($0) == false})
        
        if (added.isEmpty == false) {
            self.displayHandlers.isDisplaying?(added)
        }
        if (removed.isEmpty == false) {
            self.displayHandlers.didEndDisplaying?(removed)
        }
        previousDisplayingItems = displayingItems
    }
    
    var keyDownMonitor: NSEvent.Monitor? = nil
    
    func observeKeyDown() {
        if self.allowsDeleting {
            if keyDownMonitor == nil {
                keyDownMonitor = NSEvent.localMonitor(for: .keyDown, handler: { [weak self] event in
                    guard let self = self, self.collectionView.isFirstResponder else { return event }
                    if allowsDeleting, event.keyCode == 51 {
                        let itemsToDelete =  deletionHandlers.canDelete?(self.selectedItems) ?? self.selectedItems
                        if (itemsToDelete.isEmpty == false) {
                            let transaction = self.deletionTransaction(itemsToDelete)
                            self.deletionHandlers.willDelete?(itemsToDelete, transaction)
                            if QuicklookPanel.shared.isVisible {
                                QuicklookPanel.shared.close()
                            }
                            self.apply(transaction.finalSnapshot, .animated)
                            deletionHandlers.didDelete?(itemsToDelete, transaction)
                            return nil
                        }
                    }
                    return event
                })
            }
        } else {
            if let keyDownMonitor = self.keyDownMonitor {
                NSEvent.removeMonitor(keyDownMonitor)
            }
            keyDownMonitor = nil
        }
    }
    
    // MARK: - Snapshot
    
    /**
     Returns a representation of the current state of the data in the collection view.
     
     A snapshot containing section and item identifiers in the order that they appear in the UI.
     */
    public func snapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        return currentSnapshot
    }
    
    /**
     Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes.
     
     The system interrupts any ongoing item animations and immediately reloads the collection view’s content.
     
     - Parameters:
        - snapshot: The snapshot that reflects the new state of the data in the collection view.
        - option: Option how to apply the snapshot to the collection view. The default value is `animated`.
        - completion: An optional completion handler which gets called after applying the snapshot.
     */
    public func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>, _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        let internalSnapshot = snapshot.toIdentifiableSnapshot()
        self.currentSnapshot = snapshot
        self.dataSource.apply(internalSnapshot, option, completion: completion)
    }
            
    // MARK: - Init
    
    /**
     Creates a diffable data source with the specified item provider, and connects it to the specified collection view.
     
     To connect a diffable data source to a collection view, you create the diffable data source using this initializer, passing in the collection view you want to associate with that data source. You also pass in a item provider, where you configure each of your items to determine how to display your data in the UI.
     
     ```swift
     dataSource = CollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, itemProvider: {
     (collectionView, indexPath, item) in
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
            [weak self] collectionView, indePath, itemID in
            
            guard let self = self, let item = self.items[id: itemID] else { return nil }
            return itemProvider(collectionView, indePath, item)
        })
                
        self.collectionView.postsFrameChangedNotifications = false
        self.collectionView.postsBoundsChangedNotifications = false
        
        self.collectionView.isQuicklookPreviewable = Item.self is QuicklookPreviewable.Type
        self.collectionView.registerForDraggedTypes([.itemID])
        self.collectionView.setDraggingSourceOperationMask(.move, forLocal: true)
        
        self.delegateBridge = DelegateBridge(self)
    }
    
    /**
     A closure that configures and returns an item for a collection view from its diffable data source.
     
     A non-`nil` configured item object. The item provider must return a valid item object to the collection view.
     
     - Parameters:
        - collectionView: The collection view to configure this cell for.
        -  indexpath: The index path that specifies the location of the item in the collection view.
        - item: An object, with a type that implements the Hashable protocol, the data source uses to uniquely identify the item for this cell.
     
     - Returns: A non-`nil` configured collection view item object. The item provider must return a valid item object to the collection view.
     */
    public typealias ItemProvider = (_ collectionView: NSCollectionView, _ indexPath: IndexPath, _ item: Item) -> NSCollectionViewItem?
    
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
    public convenience init<CollectionViewItem: NSCollectionViewItem>(collectionView: NSCollectionView, itemRegistration: NSCollectionView.ItemRegistration<CollectionViewItem, Item>) {
        self.init(collectionView: collectionView, itemProvider: { collectionView,indePath,item in
            return collectionView.makeItem(using: itemRegistration, for: indePath, element: item) })
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
    
    // MARK: - Items
        
    /// All current items in the collection view.
    public var items: [Item] {
        return self.currentSnapshot.itemIdentifiers
    }
    
    /// An array of the selected items.
    public var selectedItems: [Item] {
        return self.collectionView.selectionIndexPaths.compactMap({item(for: $0)})
    }
    
    /**
     Returns the item at the specified index path in the collection view.
     
     - Parameter indexPath: The indexPath
     - Returns: The item at the index path or nil if there isn't any item at the index path.
     */
    public func item(for indexPath: IndexPath) ->  Item? {
        if let itemId = self.dataSource.itemIdentifier(for: indexPath) {
            return self.currentSnapshot.itemIdentifiers[id: itemId]
        }
        return nil
    }
    
    /// Returns the index path for the specified item in the collection view.
    public func indexPath(for item: Item) -> IndexPath? {
        return dataSource.indexPath(for: item.id)
    }
    
    /**
     Returns the item at the specified point.
     
     - Parameter point: The point in the collection view’s bounds that you want to test.
     - Returns: The item at the specified point or `nil` if no item was found at that point.
     */
    public func item(at point: CGPoint) -> Item? {
        if let indexPath = self.collectionView.indexPathForItem(at: point) {
            return item(for: indexPath)
        }
        return nil
    }
    
    /// Updates the data for the items you specify, preserving the existing collection view items for the items.
    public func reconfigureItems(_ items: [Item]) {
        let indexPaths = items.compactMap({self.indexPath(for:$0)})
        self.collectionView.reconfigureItems(at: indexPaths)
    }
    
    /// Reloads the specified items.
    public func reloadItems(_ items: [Item], animated: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(items.ids)
        dataSource.apply(snapshot, animated ? .animated: .withoutAnimation)
    }
    
    /// Selects all collection view items of the specified items.
    public func selectItems(_ items: [Item], scrollPosition: NSCollectionView.ScrollPosition, addSpacing: CGFloat? = nil) {
        let indexPaths = Set(items.compactMap({indexPath(for: $0)}))
        self.collectionView.selectItems(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    /// Deselects all collection view items of the specified items.
    public func deselectItems(_ items: [Item]) {
        let indexPaths = Set(items.compactMap({indexPath(for: $0)}))
        self.collectionView.deselectItems(at: indexPaths)
    }
    
    /// Selects all collection view items of the items in the specified sections.
    public func selectItems(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let items = self.items(for: sections)
        self.selectItems(items, scrollPosition: scrollPosition)
    }
    
    /// Deselects all collection view items of the items in the specified sections.
    public func deselectItems(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let indexPaths = sections.flatMap({self.indexPaths(for: $0)})
        self.collectionView.deselectItems(at: Set(indexPaths))
    }
    
    /// Scrolls the collection view to the specified items.
    public func scrollToItems(_ items: [Item], scrollPosition: NSCollectionView.ScrollPosition = []) {
        let indexPaths = Set(self.indexPaths(for: items))
        self.collectionView.scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    /// An array of items that are displaying (currently visible).
    var displayingItems: [Item] {
        self.collectionView.displayingIndexPaths().compactMap({self.item(for: $0)})
    }
    
    /// The collection view item for the specified item.
    func collectionTtem(for item: Item) -> NSCollectionViewItem? {
        if let indexPath = indexPath(for: item) {
            return self.collectionView.item(at: indexPath)
        }
        return nil
    }
    
    /// The frame of the collection view item for the specified item.
    func itemFrame(for item: Item) -> CGRect? {
        if let indexPath = indexPath(for: item) {
            return self.collectionView.frameForItem(at: indexPath)
        }
        return nil
    }
    
    func indexPaths(for items: [Item]) -> [IndexPath] {
        return items.compactMap({indexPath(for: $0)})
    }
    
    func indexPaths(for section: Section) -> [IndexPath] {
        let items = self.currentSnapshot.itemIdentifiers(inSection: section)
        return self.indexPaths(for: items)
    }
    
    func indexPaths(for sections: [Section]) -> [IndexPath] {
        return sections.flatMap({self.indexPaths(for: $0)})
    }
    
    func items(for sections: [Section]) -> [Item] {
        let currentSnapshot = self.currentSnapshot
        return sections.flatMap({currentSnapshot.itemIdentifiers(inSection: $0)})
    }
    
    func isSelected(at indexPath: IndexPath) -> Bool {
        self.collectionView.selectionIndexPaths.contains(indexPath)
    }
    
    func isSelected(for item: Item) -> Bool {
        if let indexPath = indexPath(for: item) {
            return isSelected(at: indexPath)
        }
        return false
    }
    
    func removeItems( _ items: [Item]) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(items)
        self.apply(snapshot, .animated)
    }
    
    func deletionTransaction(_ items: [Item]) -> NSDiffableDataSourceTransaction<Section, Item> {
        let initalSnapshot = self.currentSnapshot
        var finalSnapshot = self.snapshot()
        finalSnapshot.deleteItems(items)
        let difference = initalSnapshot.itemIdentifiers.difference(from: finalSnapshot.itemIdentifiers)
        return NSDiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: finalSnapshot, difference: difference)
    }
    
    func movingTransaction(at indexPaths: [IndexPath], to toIndexPath: IndexPath) -> NSDiffableDataSourceTransaction<Section, Item>? {
        let items = indexPaths.compactMap({self.item(for: $0)})
        var toIndexPath = toIndexPath
        var isLast = false
        if let section = currentSnapshot.sectionIdentifiers[safe: toIndexPath.section], toIndexPath.item >= currentSnapshot.numberOfItems(inSection: section) {
            toIndexPath.item -= 1
            isLast = true
        }
        guard let toItem = self.item(for: toIndexPath), items.isEmpty == false else { return nil }
        
        var snapshot = self.snapshot()
        if isLast {
            items.reversed().forEach({snapshot.moveItem($0, afterItem: toItem)})
        } else {
            items.forEach({snapshot.moveItem($0, beforeItem: toItem)})
        }
        items.forEach({snapshot.moveItem($0, beforeItem: toItem)})

        let initalSnapshot = self.currentSnapshot
        let difference = initalSnapshot.itemIdentifiers.difference(from: snapshot.itemIdentifiers)
        return NSDiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: snapshot, difference: difference)
    }
    
    // MARK: - Sections
    
    /// All current sections in the collection view.
    public var sections: [Section] { currentSnapshot.sectionIdentifiers }
    
    /// Returns the index for the section in the collection view.
    public func index(for section: Section) -> Int? {
        return sections.firstIndex(of: section)
    }
    
    /// Returns the section at the index in the collection view.
    public func section(for index: Int) -> Section? {
        return sections[safe: index]
    }
    
    func section(for item: Item) -> Section? {
        return self.currentSnapshot.sectionIdentifier(containingItem: item)
    }
    
    func section(at indexPath: IndexPath) -> Section? {
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
        didSet { self.observeHoveredItem() } }
    
    /// Handlers for selection of items.
    public var selectionHandlers = SelectionHandlers()
    
    /// Handlers for deletion of items.
    public var deletionHandlers = DeletionHandlers()
    
    /// Handlers for reordering of items.
    public var reorderingHandlers = ReorderingHandlers()
    
    ///Handlers for the displayed items. The handlers get called whenever the collection view is displaying new items (e.g. when the enclosing scrollview scrolls to new items).
    public var displayHandlers = DisplayHandlers() {
        didSet {  self.observeDisplayingItems() } }
    
    /// Handlers for prefetching items.
    public var prefetchHandlers = PrefetchHandlers()
    
    /// Handlers for drag and drop of files from and to the collection view.
    public var dragDropHandlers = DragdropHandlers()
    
    /// Handlers for the highlight state of items.
    public var highlightHandlers = HighlightHandlers()
    
    /// Handlers for prefetching items.
    public struct PrefetchHandlers {
        /// The Handler that tells you to begin preparing data for the items.
        public var willPrefetch: ((_ items: [Item]) -> ())? = nil
        /// Cancels a previously triggered data prefetch request.
        public var didCancelPrefetching: ((_ items: [Item]) -> ())? = nil
    }
    
    /// Handlers for selection of items.
    public struct SelectionHandlers {
        /// The Handler that determines whether items should get selected.
        public var shouldSelect: ((_ items: [Item]) -> [Item])? = nil
        /// The Handler that determines whether items should get deselected.
        public var shouldDeselect: ((_ items: [Item]) -> [Item])? = nil
        /// The Handler that gets called whenever items get selected.
        public var didSelect: ((_ items: [Item]) -> ())? = nil
        /// The Handler that gets called whenever items get deselected.
        public var didDeselect: ((_ items: [Item]) -> ())? = nil
    }
    
    /// Handlers for deletion of items.
    public struct DeletionHandlers {
        /// The Handler that determines which items can be be deleted.
        public var canDelete: ((_ items: [Item]) -> [Item])? = nil
        /// The Handler that that gets called before deleting items.
        public var willDelete: ((_ items: [Item], _ transaction: NSDiffableDataSourceTransaction<Section, Item>) -> ())? = nil
        /// The Handler that that gets called after deleting items.
        public var didDelete: ((_ items: [Item], _ transaction: NSDiffableDataSourceTransaction<Section, Item>) -> ())? = nil
    }
    
    /// Handlers for reordering items.
    public struct ReorderingHandlers {
        /// The Handler that determines whether you can reorder a particular item.
        public var canReorder: ((_ items: [Item]) -> Bool)? = nil
        /// The Handler that prepares the diffable data source for reordering its items.
        public var willReorder: ((NSDiffableDataSourceTransaction<Section, Item>) -> ())? = nil
        /// The Handler that processes a reordering transaction.
        public var didReorder: ((NSDiffableDataSourceTransaction<Section, Item>) -> ())? = nil
    }
    
    /// Handlers for the highlight state of items.
    public struct HighlightHandlers {
        /// The Handler that determines which items should change to a highlight state.
        public var shouldChange: ((_ items: [Item], NSCollectionViewItem.HighlightState) -> [Item])? = nil    
        /// The Handler that gets called whenever items changed their highlight state.
        public var didChange: ((_ items: [Item], NSCollectionViewItem.HighlightState) -> ())? = nil
    }
    
    /**
     Handlers for the displayed items.
     
     The handlers get called whenever the collection view is displaying new items (e.g. when the enclosing scrollview scrolls to new items).
     */
    public struct DisplayHandlers {
        /// The Handler that gets called whenever items start getting displayed.
        public var isDisplaying: ((_ items: [Item]) -> ())?
        /// The Handler that gets called whenever items end getting displayed.
        public var didEndDisplaying: ((_ items: [Item]) -> ())?
    }
    
    /// Handlers that get called whenever the mouse is hovering an item.
    public struct HoverHandlers {
        /// The handler that gets called whenever the mouse is hovering an item.
        public var isHovering: ((_ item: Item) -> ())?
        /// The handler that gets called whenever the mouse did end hovering an item.
        public var didEndHovering: ((_ item: Item) -> ())?
    }
    
    /// Handlers for drag and drop of files from and to the collection view.
    public struct DragdropHandlers {
        /// The handler that determines which items can be dragged outside the collection view.
        public var canDragOutside: ((_ items: [Item]) -> [Item])? = nil
        /// The handler that gets called whenever items did drag ouside the collection view.
        public var didDragOutside: (([Item]) -> ())? = nil
        /// The handler that determines the pasteboard value of an item when dragged outside the collection view.
        public var pasteboardValue: ((_ item: Item) -> PasteboardWriting)? = nil
        /// The handler that determines whenever pasteboard items can be dragged inside the collection view.
        public var canDragInside: (([PasteboardWriting]) -> [PasteboardWriting])? = nil
        /// The handler that gets called whenever pasteboard items did drag inside the collection view.
        public var didDragInside: (([PasteboardWriting]) -> ())? = nil
        /// The handler that determines the image when dragging items.
        public var draggingImage: ((_ items: [Item], NSEvent, NSPointPointer) -> NSImage?)? = nil
        
        var acceptsDragInside: Bool {
            canDragInside != nil && didDragInside != nil
        }
        
        var acceptsDragOutside: Bool {
            canDragOutside != nil
        }
    }
}

// MARK: - Quicklook

extension CollectionViewDiffableDataSource: NSCollectionViewQuicklookProvider {
    public func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let item = collectionView.item(at: indexPath), let previewable = self.item(for: indexPath) as? QuicklookPreviewable {
            return QuicklookPreviewItem(previewable, view: item.view)
        } else if let item = collectionView.item(at: indexPath), let preview = item.quicklookPreview {
            return QuicklookPreviewItem(preview, view: item.view)
        }
        return nil
    }
}
