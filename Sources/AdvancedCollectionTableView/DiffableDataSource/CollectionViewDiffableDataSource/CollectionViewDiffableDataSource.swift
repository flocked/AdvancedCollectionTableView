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
 2. Implement a item provider to configure your collection view’s items.
 3. Generate the current state of the data.
 4. Display the data in the UI.
 
 To connect a diffable data source to a collection view, you create the diffable data source using its init(collectionView:itemProvider:) or init(collectionView:itemRegistration:) initializer, passing in the collection view you want to associate with that data source. You also pass in a item provider, where you configure each of your items to determine how to display your data in the UI.

 ```
 dataSource = DiffableDataSource<Int, UUID>(collectionView: collectionView) {
     (collectionView: NSCollectionView, indexPath: IndexPath, element: UUID) -> NSCollectionViewItem? in
     // configure and return item
 }
 ```

 Then, you generate the current state of the data and display the data in the UI by constructing and applying a snapshot. For more information, see NSDiffableDataSourceSnapshot.
 
 - Important: Don’t change the dataSource or delegate on the collection view after you configure it with a diffable data source. If the collection view needs a new data source after you configure it initially, create and configure a new collection view and diffable data source.
 */
public class CollectionViewDiffableDataSource<Section: Identifiable & Hashable, Element: Identifiable & Hashable>: NSObject, NSCollectionViewDataSource {
    /**
     Representation of a state for the data in the collection view.
     */
    public typealias CollectionSnapshot = NSDiffableDataSourceSnapshot<Section,  Element>
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

    internal typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Element.ID>
    internal typealias DataSoure = NSCollectionViewDiffableDataSource<Section.ID,  Element.ID>
    
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
    internal let quicklookPanel = QuicklookPanel.shared
    internal var delegateBridge: DelegateBridge<Section, Element>!
    internal var responder: Responder<Section, Element>!
    internal var scrollView: NSScrollView? { return collectionView.enclosingScrollView }
    internal var magnifyGestureRecognizer: NSMagnificationGestureRecognizer?
    internal var currentSnapshot: CollectionSnapshot = CollectionSnapshot()
    internal var sections: [Section] { currentSnapshot.sectionIdentifiers }
    internal var draggingIndexPaths = Set<IndexPath>()
    internal var draggingElements: [Element] {
        self.draggingIndexPaths.compactMap({self.element(for: $0)})
    }
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
    
    /**
     A Boolean value that indicates whether users can delete items either via keyboard shortcut or right click menu.

     If the value of this property is true (the default is false), users can delete items.
     */
    public var allowsDeleting: Bool = false
    /**
     A Boolean value that indicates whether users can reorder items in the collection view when dragging them via mouse.

     If the value of this property is true (the default is false), users can reorder items in the collection view.
     */
    public var allowsReordering: Bool = false
    /**
     A Boolean value that indicates whether users can select items while an section is collapsed in the collection view.

     If the value of this property is true (the default), users can select items while an section is collapsed.
     */
    public var allowsSectionCollapsing: Bool = true
    /**
     A Boolean value that indicates whether users can select items in the collection view.

     If the value of this property is true (the default), users can select items.
     */
    public var allowsSelectable: Bool {
        get { self.collectionView.isSelectable }
        set { self.collectionView.isSelectable = newValue } }
    /**
     A Boolean value that determines whether users can select more than one item in the collection view.

     This property controls whether multiple items can be selected simultaneously. The default value of this property is false.
     When the value of this property is true, tapping a cell adds it to the current selection (assuming the delegate permits the cell to be selected). Tapping the item again removes it from the selection.
     */
    public var allowsMultipleSelection: Bool {
        get { self.collectionView.allowsMultipleSelection }
        set { self.collectionView.allowsMultipleSelection = newValue } }
    /**
     A Boolean value indicating whether the collection view may have no selected items.

     The default value of this property is true, which allows the collection view to have no selected items. Setting this property to false causes the collection view to always leave at least one item selected.
     */
    public var allowsEmptySelection: Bool {
        get { self.collectionView.allowsEmptySelection }
        set { self.collectionView.allowsEmptySelection = newValue } }
    /**
     The layout object used to organize the collection view’s content.

     Typically, you specify the layout object at design time in Interface Builder. The layout object works with your data source object to generate the needed items and views to display. The collection view uses the NSCollectionViewGridLayout object by default.
     Assigning a new value to this property changes the layout object and causes the collection view to update its contents immediately and without animations. If you want to animate a layout change, use an animator object to set the layout object as follows:
     
     ```
     // Insert example
     ```
     You can use the completion handler of the associated NSAnimationContext object to perform additional tasks when the animations finish.
     */
    public var collectionViewLayout: NSCollectionViewLayout? {
        get { self.collectionView.collectionViewLayout }
        set { self.collectionView.collectionViewLayout = newValue } }
    
    public var mouseHandlers = MouseHandlers<Element>()
    public var hoverHandlers = HoverHandlers<Element>() {
        didSet { self.ensureTrackingArea()} }
    public var selectionHandlers = SelectionHandlers<Element>()
    public var reorderingHandlers = ReorderingHandlers<Element>()
    public var displayHandlers = DisplayHandlers<Element>() {
        didSet {  self.ensureTrackingDisplayingItems() } }
    public var sectionHandlers = SectionHandlers<Section>() {
        didSet { self.ensureTrackingArea()} }
    public var prefetchHandlers = PrefetchHandlers<Element>()
    public var dragDropHandlers = DragdropHandlers<Element>()
    public var highlightHandlers = HighlightHandlers<Element>()
    public var quicklookHandlers = QuicklookHandlers<Element>()

    public var menuProvider: ((_ elements: [Element]) -> NSMenu?)? = nil
    public var keydownHandler: ((_ event: NSEvent) -> Bool)? = nil
    public var pinchHandler: ((_ mouseLocation: CGPoint, _ magnification: CGFloat, _ state: NSMagnificationGestureRecognizer.State) -> ())? = nil { didSet { (pinchHandler == nil) ? self.removeMagnificationRecognizer() : self.addMagnificationRecognizer() } }

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
        - completion: A optional completion handlers which gets called after applying the snapshot.
     */
    public func apply(_ snapshot: CollectionSnapshot, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
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
    public func applySnapshotUsingReloadData(_ snapshot: CollectionSnapshot, completion: (() -> Void)? = nil) {
        let internalSnapshot = convertSnapshot(snapshot)
        self.currentSnapshot = snapshot

        dataSource.apply(internalSnapshot, .reloadData, completion: completion)
    }
    
    /**
     Returns a representation of the current state of the data in the collection view.

     A snapshot containing section and item identifiers in the order that they appear in the UI.
     */
    public func snapshot() -> CollectionSnapshot {
        var snapshot = CollectionSnapshot()
        snapshot.appendSections(currentSnapshot.sectionIdentifiers)
        for section in currentSnapshot.sectionIdentifiers {
            snapshot.appendItems(currentSnapshot.itemIdentifiers(inSection: section), toSection: section)
        }
        return snapshot
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
    
    /*
    internal func openQuicklookPanel(for elements: [(element: Element, url: URL)]) {
            var previewItems: [QuicklookItem] = []
            for _element in elements {
                if let _elementRect = self.frame(for: _element.element) {
                    previewItems.append(QuicklookItem(url: _element.url, frame: _elementRect))
                }
            }
        
            if (previewItems.isEmpty == false) {
                self.quicklookPanel.keyDownResponder = self.collectionView
                self.quicklookPanel.present(previewItems)
            }
    }
    
    internal func closeQuicklookPanel(for elements: [(element: Element, url: URL)]) {
        var previewItems: [QuicklookItem] = []
            for _element in elements {
                if let _elementRect = self.frame(for: _element.element) {
                    previewItems.append(QuicklookItem(url: _element.url, frame: _elementRect))
                }
            }
            if (previewItems.isEmpty == false) {
                self.quicklookPanel.keyDownResponder = self.collectionView
                self.quicklookPanel.present(previewItems)
            }
        
        if (previewItems.isEmpty == false) {
            self.quicklookPanel.close(previewItems)
        } else {
            self.quicklookPanel.close()
        }
    }
     */
    
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
    }
}

public extension CollectionViewDiffableDataSource where Element: QLPreviewable {
    
    func quicklook(_ elements: [Element], current: Element? = nil) {
        var index: Int = 0
        var previewItems: [QLPreviewable] = []
        let current = current ?? elements.first
        var transitionImage: NSImage? = nil
        for element in self.selectedElements {
            guard let itemView = self.itemView(for: element) else { return }
            element.previewItemView = itemView.view
            let previewItem = QuicklookItem(url: element.previewItemURL, frame: itemView.view.frame, transitionImage: element.previewItemTransitionImage)
            previewItems.append(previewItem)
            if (element == current) {
                transitionImage = previewItem.previewItemTransitionImage ?? itemView.view.renderedImage
                index = previewItems.count - 1
            }
        }
        guard previewItems.isEmpty == false else { return }
        
        QuicklookPanel.shared.keyDownResponder = self.collectionView
        QuicklookPanel.shared.present(previewItems, currentItemIndex: index, image: transitionImage)
    }
    
    func quicklookSelectedItems() {
        self.quicklook(self.selectedElements)
    }
}


internal extension QLPreviewable {
    var previewItemView: NSView? {
        get { getAssociatedValue(key: "_previewItemView", object: self) }
        set { set(associatedValue: newValue, key: "_previewItemView", object: self) }
    }
}
