//
//  AdvanceColllectionViewDiffableDataSource.swift
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
 This object is an advanced version of `NSCollectionViewDiffableDataSource. It provides:

 - Reordering of items by enabling ``allowsReordering`` and optionally providing blocks to ``reorderingHandlers``.
 - Deleting of items by enabling  ``allowsDeleting`` and optionally providing blocks to ``deletionHandlers``.
 - Quicklooking of items via spacebar by providing elements conforming to ``QuicklookPreviewable``.
 - Handlers for selection of items ``selectionHandlers``.
 - Handlers for items that get hovered by mouse ``hoverHandlers``.
 - Providing a right click menu for selected items via ``menuProvider`` block.
 - Handler for pinching of the collection view via ``pinchHandler``.
 
 ```swift
 dataSource = AdvanceColllectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, itemRegistration: itemRegistration)
 ```
 
 Then, you generate the current state of the data and display the data in the UI by constructing and applying a snapshot. For more information, see `NSDiffableDataSourceSnapshot`.
 
 - Important: Don’t change the dataSource or delegate on the collection view after you configure it with a diffable data source. If the collection view needs a new data source after you configure it initially, create and configure a new collection view and diffable data source.
 */
public class AdvanceColllectionViewDiffableDataSource<Section: Identifiable & Hashable, Element: Identifiable & Hashable>: NSObject, NSCollectionViewDataSource {
    /// A snapshot of the section and element ids.
    internal typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Element.ID>
    /// A snapshot of the sections and elements.
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Element>
    internal typealias DataSoure = NSCollectionViewDiffableDataSource<Section.ID,  Element.ID>
    
    /**
     A closure that configures and returns a item for a collection view from its diffable data source.
     
     A non-nil configured item object. The item provider must return a valid item object to the collection view.
     
     - Parameters:
        - collectionView: The collection view to configure this cell for.
        -  indexpath: The index path that specifies the location of the item in the collection view.
        - element: An object, with a type that implements the Hashable protocol, the data source uses to uniquely identify the item for this cell.
     
     - Returns: A non-nil configured item object. The item provider must return a valid cell object to the collection view.
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
     
     - Returns: A non-nil configured supplementary view object. The supplementary view provider must return a valid view object to the collection view.
     */
    public typealias SupplementaryViewProvider = (_ collectionView: NSCollectionView, _ elementKind: String, _ indexPath: IndexPath) -> (NSView & NSCollectionViewElement)?
    
    internal weak var collectionView: NSCollectionView!
    internal var dataSource: DataSoure!
    internal var itemProvider: ItemProvider
    internal var delegateBridge: DelegateBridge!
    internal var responder: Responder<Section, Element>!
    internal var scrollView: NSScrollView? { return collectionView.enclosingScrollView }
    internal var magnifyGestureRecognizer: NSMagnificationGestureRecognizer?
    internal var currentSnapshot: Snapshot = Snapshot()
    internal var sections: [Section] { currentSnapshot.sectionIdentifiers }
    internal var draggingIndexPaths = Set<IndexPath>()
    internal var draggingElements: [Element] {
        self.draggingIndexPaths.compactMap({self.element(for: $0)})
    }
    internal let pasteboardType = NSPasteboard.PasteboardType("DiffableCollection.Pasteboard")
    internal var hoverElement: Element? = nil {
        didSet {
            guard oldValue != self.hoverElement else { return }
            if let hoverElement = hoverElement, hoverElement.id != oldValue?.id {
                hoverHandlers.isHovering?(hoverElement)
            }
            if let oldValue = oldValue, oldValue.id != hoverElement?.id {
                hoverHandlers.didEndHovering?(oldValue)
            }
        }
    }
    
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
    
    /// Handlers for highlight of elements.
    public var highlightHandlers = HighlightHandlers()
    
    /**
     Right click menu provider for selected items.
     
     When returning a menu to the `menuProvider`, the collection view will display a menu on right click of selected items.
     */
    public var menuProvider: ((_ elements: [Element]) -> NSMenu?)? = nil
    
    /// A handler that gets called whenever collection view magnifies.
    public var pinchHandler: ((_ mouseLocation: CGPoint, _ magnification: CGFloat, _ state: NSMagnificationGestureRecognizer.State) -> ())? = nil { didSet { self.setupMagnificationHandler() } }
    
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
    
    internal func isHovering(_ item: NSCollectionViewItem) {
        if let indexPath = self.collectionView.indexPath(for: item), let element = element(for: indexPath) {
            self.hoverHandlers.isHovering?(element)
        }
    }
    
    internal func didEndHovering(_ item: NSCollectionViewItem) {
        if let indexPath = self.collectionView.indexPath(for: item), let element = element(for: indexPath) {
            self.hoverHandlers.didEndHovering?(element)
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
    
    internal func ensureTrackingDisplayingItems() {
        if (self.displayHandlers.isDisplaying != nil || self.displayHandlers.didEndDisplaying != nil) {
            scrollView?.contentView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(scrollViewContentBoundsDidChange(_:)),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: scrollView?.contentView)
        } else {
            scrollView?.contentView.postsBoundsChangedNotifications = false
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    internal func setupHoverObserving() {
        if self.hoverHandlers.isHovering != nil || self.hoverHandlers.didEndHovering != nil {
            self.collectionView.setupObservingView()
        }
    }
    
    internal var previousDisplayingElements = [Element]()
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
    
    internal func configurateDataSource() {
        self.dataSource = DataSoure(collectionView: self.collectionView, itemProvider: {
            [weak self] collectionView, indePath, elementID in
            
            guard let self = self, let element = self.allElements[id: elementID] else { return nil }
            return self.itemProvider(collectionView, indePath, element)
        })
        self.dataSource.supplementaryViewProvider = { [weak self] collectionView, elementKind, indePath in
            guard let self = self else { return nil }
            return self.supplementaryViewProvider?(collectionView, elementKind, indePath)
        }
    }
    
    /**
     Creates a diffable data source with the specified item provider, and connects it to the specified collection view.
     
     To connect a diffable data source to a collection view, you create the diffable data source using this initializer, passing in the collection view you want to associate with that data source. You also pass in a item provider, where you configure each of your items to determine how to display your data in the UI.
     
     ```swift
     dataSource = DiffableDataSource<Section, Element>(collectionView: collectionView, itemProvider: {
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
        self.itemProvider = itemProvider
        super.init()
        sharedInit()
    }
    /**
     Creates a diffable data source with the specified item registration, and connects it to the specified collection view.
     
     To connect a diffable data source to a collection view, you create the diffable data source using this initializer, passing in the collection view you want to associate with that data source. You also pass in a item registration, where each of your items gets determine how to display your data in the UI.
     
     ```swift
     dataSource = AdvanceColllectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, itemRegistration: itemRegistration)
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
        self.configurateDataSource()
        
        self.collectionView.postsFrameChangedNotifications = false
        self.collectionView.postsBoundsChangedNotifications = false
        
        self.collectionView.setupCollectionViewFirstResponderObserver()
        
        if Element.self is QuicklookPreviewable.Type {
            self.collectionView.isQuicklookPreviewable = true
        }
        
        self.allowsReordering = false
        self.allowsDeleting = false
        self.collectionView.registerForDraggedTypes([pasteboardType])
        self.collectionView.setDraggingSourceOperationMask(.move, forLocal: true)
        
        self.responder = Responder(self)
        let collectionViewNextResponder = self.collectionView.nextResponder
        self.collectionView.nextResponder = self.responder
        self.responder.nextResponder = collectionViewNextResponder
        
        self.delegateBridge = DelegateBridge(self)
    }
}

extension AdvanceColllectionViewDiffableDataSource: NSCollectionViewQuicklookProvider {
    public func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
        if let item = collectionView.item(at: indexPath), let previewable = element(for: indexPath) as? QuicklookPreviewable {
            return QuicklookPreviewItem(previewable, view: item.view)
        } else if let item = collectionView.item(at: indexPath), let preview = item.quicklookPreview {
            return QuicklookPreviewItem(preview, view: item.view)
        }
        return nil
    }
}

internal class QuicklookPreviewItem: NSObject, QLPreviewItem, QuicklookPreviewable {
    let preview: QuicklookPreviewable
    var view: NSView?
    
    public var previewItemURL: URL? {
        preview.previewItemURL
    }
    public var previewItemFrame: CGRect? {
        view?.frameOnScreen ?? preview.previewItemFrame
    }
    public var previewItemTitle: String? {
        preview.previewItemTitle
    }
    public var previewItemTransitionImage: NSImage? {
        view?.renderedImage ?? preview.previewItemTransitionImage
    }
    
    internal init(_ preview: QuicklookPreviewable, view: NSView? = nil) {
        self.preview = preview
        self.view = view
    }
}
