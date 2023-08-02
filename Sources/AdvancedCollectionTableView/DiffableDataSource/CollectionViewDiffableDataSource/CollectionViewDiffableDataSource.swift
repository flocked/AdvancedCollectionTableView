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
 This object is an advanced version or NSCollectionViewDiffableDataSource. It provides:
 
 - Reordering of items by enabling `allowsReording`and optionally providing blocks to `reorderingHandlers`.
 - Deleting of items by enabling `allowsDeleting`and optionally providing blocks to `DeletionHandlers`.
 - Quicklooking of items via spacebar by providing elements conforming to `QuicklookPreviewable`.
 - Handlers for selection of items `selectionHandlers`.
 - Handlers for items that get hovered by mouse `hoverHandlers`.
 - Providing a right click menu for selected items via `menuProvider` block.
 - Handler for pinching of the collection view via `pinchHandler`.
 
 ```
 dataSource = AdvanceColllectionViewDiffableDataSource<Int, UUID>(collectionView: collectionView) {
 (collectionView: NSCollectionView, indexPath: IndexPath, element: UUID) -> NSCollectionViewItem? in
 // configure and return item
 }
 ```
 
 Then, you generate the current state of the data and display the data in the UI by constructing and applying a snapshot. For more information, see NSDiffableDataSourceSnapshot.
 
 - Important: Don’t change the dataSource or delegate on the collection view after you configure it with a diffable data source. If the collection view needs a new data source after you configure it initially, create and configure a new collection view and diffable data source.
 */
public class AdvanceColllectionViewDiffableDataSource<Section: Identifiable & Hashable, Element: Identifiable & Hashable>: NSObject, NSCollectionViewDataSource {
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
    
    /// Handlers that get called whenever the collection view receives mouse click events of items.
    public var mouseHandlers = MouseHandlers<Element>()
    
    /// Handlers that get called whenever the mouse is hovering an item.
    public var hoverHandlers = HoverHandlers<Element>() {
        didSet { self.setupHoverObserving()} }
    
    /// Handlers for selection of items.
    public var selectionHandlers = SelectionHandlers<Element>()
    
    /// Handlers for deletion of items.
    public var deletionHandlers = DeletionHandlers<Element>()
    
    /// Handlers for reordering of items.
    public var reorderingHandlers = ReorderingHandlers<Element>()
    
    ///Handlers for the displayed items. The handlers get called whenever the collection view is displaying new items (e.g. when the enclosing scrollview scrolls to new items).
    public var displayHandlers = DisplayHandlers<Element>() {
        didSet {  self.ensureTrackingDisplayingItems() } }
    
    /// Handlers for prefetching elements.
    public var prefetchHandlers = PrefetchHandlers<Element>()
    
    /// Handlers for drag and drop of files from and to the collection view.
    public var dragDropHandlers = DragdropHandlers<Element>()
    
    /// Handlers for highlight of elements.
    public var highlightHandlers = HighlightHandlers<Element>()
    
    /**
     Right click menu provider for selected items.
     
     When returning a menu to the `menuProvider`, the collection view will display a menu on right click of selected items.
     */
    public var menuProvider: ((_ elements: [Element]) -> NSMenu?)? = nil
    
    /// A handler that gets called whenever collection view receives a keydown event.
    public var keydownHandler: ((_ event: NSEvent) -> Bool)? = nil
    
    /// A handler that gets called whenever collection view magnifies.
    public var pinchHandler: ((_ mouseLocation: CGPoint, _ magnification: CGFloat, _ state: NSMagnificationGestureRecognizer.State) -> ())? = nil { didSet { self.setupMagnificationHandler() } }
    //   public var sectionHandlers = SectionHandlers<Section>() {
    //      didSet { self.ensureTrackingArea()} }
    
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
    public func apply(_ snapshot: CollectionSnapshot, _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        let internalSnapshot = convertSnapshot(snapshot)
        self.currentSnapshot = snapshot
        self.dataSource.apply(internalSnapshot, option, completion: completion)
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
            /*
             if self.collectionView.hoverHandlers == nil {
             let hoverHandlers = NSCollectionView.HoverHandlers()
             hoverHandlers.isHovering = { [weak self] item in
             guard let self = self else { return }
             self.isHovering(item)
             }
             hoverHandlers.didEndHovering = { [weak self] item in
             guard let self = self else { return }
             self.didEndHovering(item)
             }
             self.collectionView.hoverHandlers = hoverHandlers
             }
             */
        } else {
            //   self.collectionView.hoverHandlers = nil
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

/*
 private struct ItemIdentifierType: Hashable, Identifiable {
 let value: any Identifiable
 let id: AnyHashable
 
 init<V: Identifiable>(_ value: V) {
 self.value = value
 self.id = value.id
 }
 
 static func == (_ a: ItemIdentifierType, _ b: ItemIdentifierType) -> Bool {
 return a.id == b.id
 }
 
 func hash(into hasher: inout Hasher) {
 hasher.combine(id)
 }
 }
 */

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
