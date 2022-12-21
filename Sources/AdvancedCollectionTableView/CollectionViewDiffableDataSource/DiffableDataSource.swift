//
//  CollectionViewDiffableDataSource.swift
//  Coll
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZExtensions


/**
 The object you use to manage data and provide items for a collection view.

 A diffable data source object is a specialized type of data source that works together with your collection view object. It provides the behavior you need to manage updates to your collection view’s data and UI in a simple, efficient way. It also conforms to the NSCollectionViewDataSource and NSCollectionViewDelegate protocol and provides implementations and handlers for all of the protocol’s methods.
 
 To fill a collection view with data:
 1. Connect a diffable data source to your collection view.
 2. Implement a cell provider to configure your collection view’s items.
 3. Generate the current state of the data.
 4. Display the data in the UI.
 
 To connect a diffable data source to a collection view, you create the diffable data source using its init(collectionView:itemProvider:) or init(collectionView:itemRegistration:) initializer, passing in the collection view you want to associate with that data source. You also pass in a cell provider, where you configure each of your items to determine how to display your data in the UI.

 ```
 dataSource = DiffableDataSource<Int, UUID>(collectionView: collectionView) {
     (collectionView: NSCollectionView, indexPath: IndexPath, element: UUID) -> NSCollectionViewItem? in
     // configure and return cell
 }
 ```

 Then, you generate the current state of the data and display the data in the UI by constructing and applying a snapshot. For more information, see NSDiffableDataSourceSnapshot.
 
 - Important: Don’t change the dataSource or delegate on the collection view after you configure it with a diffable data source. If the collection view needs a new data source after you configure it initially, create and configure a new collection view and diffable data source.
 */
open class CollectionViewDiffableDataSource<Section: HashIdentifiable, Element: HashIdentifiable>: NSObject, NSCollectionViewDataSource {
    
    public typealias CollectionSnapshot = NSDiffableDataSourceSnapshot<Section,  Element>
    public typealias ItemProvider = (NSCollectionView, IndexPath, Element) -> NSCollectionViewItem?
    public typealias SupplementaryViewProvider = (_ collectionView: NSCollectionView, _ elementKind: String, _ indexPath: IndexPath) -> (NSView & NSCollectionViewElement)?

    internal typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Element.ID>
    internal typealias DataSoure = NSCollectionViewDiffableDataSource<Section.ID,  Element.ID>
    
    open var supplementaryViewProvider: SupplementaryViewProvider? = nil

    internal weak var collectionView: NSCollectionView!
    internal var dataSource: DataSoure!
    internal var itemProvider: ItemProvider
    internal var delegateBridge: DelegateBridge<Section, Element>!
    internal var responder: Responder<Section, Element>!
    internal var scrollView: NSScrollView? { return collectionView.enclosingScrollView }
    internal var magnifyGestureRecognizer: NSMagnificationGestureRecognizer?
    internal var currentSnapshot: CollectionSnapshot = CollectionSnapshot()
    internal var sections: [Section] { currentSnapshot.sectionIdentifiers }
    internal var draggingIndexPaths = Set<IndexPath>()
    internal let pasteboardType = NSPasteboard.PasteboardType("DiffableCollection.Pasteboard")
    internal var trackingArea: NSTrackingArea? = nil
    internal var hoverElement: Element? = nil {
        didSet {
            if let hoverElement = hoverElement, hoverElement.id != oldValue?.id {
                hoverHandlers.isHovering?(hoverElement)
            }
            if let oldValue = oldValue, oldValue.id != hoverElement?.id {
                hoverHandlers.didEndHovering?(oldValue)
            }
        }
    }
    
    open var allowsDeleting: Bool = false
    open var allowsReordering: Bool = false
    open var allowsSectionCollapsing: Bool = true
    open override var isSelectable: Bool {
        get { self.collectionView.isSelectable }
        set { self.collectionView.isSelectable = newValue } }
    open var allowsMultipleSelection: Bool {
        get { self.collectionView.allowsMultipleSelection }
        set { self.collectionView.allowsMultipleSelection = newValue } }
    open var allowsEmptySelection: Bool {
        get { self.collectionView.allowsEmptySelection }
        set { self.collectionView.allowsEmptySelection = newValue } }
    open var collectionViewLayout: NSCollectionViewLayout? {
        get { self.collectionView.collectionViewLayout }
        set { self.collectionView.collectionViewLayout = newValue } }
    
    open var mouseHandlers = MouseHandlers<Element>()
    open var hoverHandlers = HoverHandlers<Element>() {
        didSet { self.ensureTrackingArea()} }
    open var selectionHandlers = SelectionHandlers<Element>()
    open var reorderHandlers = ReorderHandlers<Element>()
    open var displayHandlers = DisplayHandlers<Element>() {
        didSet {  self.ensureTrackingDisplayingItems() } }
    open var sectionHandlers = SectionHandlers<Section>() {
        didSet { self.ensureTrackingArea()} }
    open var prefetchHandlers = PrefetchHandlers<Element>()
    open var dragDropHandlers = DragdropHandlers<Element>()
    open var highlightHandlers = HighlightHandlers<Element>()

    open var menuProvider: (([Element]) -> NSMenu?)? = nil
    open var keydownHandler: ((Int, NSEvent.ModifierFlags) -> Bool)? = nil
    open var pinchHandler: ((CGPoint, CGFloat, NSMagnificationGestureRecognizer.State) -> ())? = nil { didSet { (pinchHandler == nil) ? self.removeMagnificationRecognizer() : self.addMagnificationRecognizer() } }
    
    open func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    open func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        return dataSource.collectionView(collectionView, itemForRepresentedObjectAt: indexPath)
    }
    
    open func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return dataSource.numberOfSections(in: collectionView)
    }
    
    open func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        return dataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    /**
     Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes.

     The system interrupts any ongoing item animations and immediately reloads the collection view’s content.
     
     - Parameters:
        - snapshot: The snapshot that reflects the new state of the data in the collection view.
        - completion: A optional completion handlers which gets called after applying the snapshot.
     */
    open func apply(_ snapshot: CollectionSnapshot, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        let internalSnapshot = convertSnapshot(snapshot)
        self.currentSnapshot = snapshot

        dataSource.apply(internalSnapshot, animatingDifferences ? .animated : .non, completion: completion)
    }
    
    /**
     Resets the UI to reflect the state of the data in the snapshot without computing a diff or animating the changes.

     The system interrupts any ongoing item animations and immediately reloads the collection view’s content.
     You can safely call this method from a background queue, but you must do so consistently in your app. Always call this method exclusively from the main queue or from a background queue.
     
     - Parameters:
        - snapshot: The snapshot that reflects the new state of the data in the collection view.
        - completion: A optional completion handlers which gets called after applying the snapshot.
     */
    open func applySnapshotUsingReloadData(_ snapshot: CollectionSnapshot, completion: (() -> Void)? = nil) {
        let internalSnapshot = convertSnapshot(snapshot)
        self.currentSnapshot = snapshot

        dataSource.apply(internalSnapshot, .reloadData, completion: completion)
    }
    
    internal func convertSnapshot(_ snapshot: CollectionSnapshot) -> InternalSnapshot {
        var internalSnapshot = InternalSnapshot()
        let sections = snapshot.sectionIdentifiers
        internalSnapshot.appendSections(sections.ids)
        for section in sections {
           let elements = snapshot.itemIdentifiers(inSection: section)
            internalSnapshot.appendItems(elements.ids, toSection: section.id)
        }
        return internalSnapshot
    }
    
    internal func addMagnificationRecognizer() {
        if (magnifyGestureRecognizer == nil) {
            self.magnifyGestureRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(didMagnify(_:)))
            self.collectionView.addGestureRecognizer(self.magnifyGestureRecognizer!)
        }
    }
    
    internal func removeMagnificationRecognizer() {
        if let magnifyGestureRecognizer = magnifyGestureRecognizer {
            self.collectionView.removeGestureRecognizer(magnifyGestureRecognizer)
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
    
    internal func ensureTrackingArea() {
        if let trackingArea = trackingArea {
            self.collectionView.removeTrackingArea(trackingArea)
            self.trackingArea = nil
        }
        
        if (self.needsTrackingArea) {
            trackingArea = NSTrackingArea(
                rect: self.collectionView.bounds,
                options: [
                    .mouseMoved,
                    .mouseEnteredAndExited,
                    .activeAlways,
                    .inVisibleRect],
                owner: self.responder)
            self.collectionView.addTrackingArea(self.trackingArea!)
        }
    }
    
    internal var previousDisplayingElements = [Element]()
    @objc internal func scrollViewContentBoundsDidChange(_ notification: Notification) {
        guard (notification.object as? NSClipView) != nil else { return }
        let displayingElements = self.displayingElements
        var added = [Element]()
        var removed = [Element]()
        for displayingElement in displayingElements {
            if (previousDisplayingElements.contains(displayingElement) == false) {
                added.append(displayingElement)
            }
        }
        for previousDisplayingElement in previousDisplayingElements {
            if (displayingElements.contains(previousDisplayingElement) == false) {
                removed.append(previousDisplayingElement)
            }
        }
        if (added.isEmpty == false) {
            self.displayHandlers.isDisplaying?(added)
        }
        if (removed.isEmpty == false) {
            self.displayHandlers.didEndDisplaying?(removed)
        }
        previousDisplayingElements = displayingElements
    }
    
    internal var needsTrackingArea: Bool {
        return  (hoverHandlers.didEndHovering != nil ||
                    hoverHandlers.isHovering != nil ||
             //       mouseHandlers.mouseEntered != nil ||
                 //   mouseHandlers.mouseMoved != nil ||
                 //       mouseHandlers.mouseExited != nil ||
                    mouseHandlers.mouseDragged != nil )
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

     ```
     dataSource = DiffableDataSource<Int, UUID>(collectionView: collectionView) {
         (collectionView: NSCollectionView, indexPath: IndexPath, element: UUID) -> NSCollectionViewItem? in
         // configure and return cell
     }
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
     Creates a diffable data source with the specified item provider, and connects it to the specified collection view.
     
     To connect a diffable data source to a collection view, you create the diffable data source using this initializer, passing in the collection view you want to associate with that data source. You also pass in a item registration, where each of your items gets determine how to display your data in the UI.

     ```
     dataSource = DiffableDataSource<Int, UUID>(collectionView: collectionView) {
         (collectionView: NSCollectionView, indexPath: IndexPath, element: UUID) -> NSCollectionViewItem? in
         // configure and return cell
     }
     ```
     
     - Parameters:
        - collectionView: The initialized collection view object to connect to the diffable data source.
        - itemRegistration: A item registration which returns each of the items for the collection view from the data the diffable data source provides.
     */
    public init<Item: NSCollectionViewItem>(collectionView: NSCollectionView, itemRegistration: NSCollectionView.ItemRegistration<Item, Element>) {
        self.collectionView = collectionView
        self.itemProvider = { collectionView,indePath,element in
            return collectionView.makeItem(using: itemRegistration, for: indePath, element: element) }
        super.init()
        sharedInit()
    }
    
    internal func sharedInit() {
        self.configurateDataSource()
        
        self.collectionView.postsFrameChangedNotifications = false
        self.collectionView.postsBoundsChangedNotifications = false
        
        self.allowsReordering = false
        self.allowsDeleting = false
        self.collectionView.registerForDraggedTypes([pasteboardType])
        self.collectionView.setDraggingSourceOperationMask(.move, forLocal: true)
        
        self.responder = Responder(self)
        let collectionViewNextResponder = self.collectionView.nextResponder
        self.collectionView.nextResponder = self.responder
        self.responder.nextResponder = collectionViewNextResponder
        
        self.delegateBridge = DelegateBridge(self)
        self.collectionView.delegate = self.delegateBridge
        self.collectionView.prefetchDataSource = self.delegateBridge
    }
    /**
     Returns a representation of the current state of the data in the collection view.

     A snapshot containing section and item identifiers in the order that they appear in the UI.
     */
    func snapshot() -> CollectionSnapshot {
        var snapshot = CollectionSnapshot()
        snapshot.appendSections(currentSnapshot.sectionIdentifiers)
        for section in currentSnapshot.sectionIdentifiers {
            snapshot.appendItems(currentSnapshot.itemIdentifiers(inSection: section), toSection: section)
        }
        return snapshot
    }
}

