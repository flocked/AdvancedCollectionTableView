//
//  CollectionViewDiffableDataSource.swift
//  Coll
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZExtensions

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
    open var menuProvider: (([Element]) -> NSMenu?)? = nil
    open var keydownHandler: ((Int, NSEvent.ModifierFlags) -> Void)? = nil
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
    
    open func apply(_ snapshot: CollectionSnapshot, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        let internalSnapshot = convertSnapshot(snapshot)
        self.currentSnapshot = snapshot

        dataSource.apply(internalSnapshot, animatingDifferences ? .animated : .non, completion: completion)
    }
    
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
    
    public init(collectionView: NSCollectionView, itemProvider: @escaping ItemProvider) {
        self.collectionView = collectionView
        self.itemProvider = itemProvider
        super.init()
        sharedInit()
    }
    
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
    
    func snapshot() -> CollectionSnapshot {
        var snapshot = CollectionSnapshot()
        snapshot.appendSections(currentSnapshot.sectionIdentifiers)
        for section in currentSnapshot.sectionIdentifiers {
            snapshot.appendItems(currentSnapshot.itemIdentifiers(inSection: section), toSection: section)
        }
        return snapshot
    }
}

