//
//  File.swift
//  
//
//  Created by Florian Zand on 10.12.22.
//

import AppKit
import FZExtensions

/*
@available(macOS 11.0, *)
open class TableViewDiffableDataSource<Section: HashIdentifiable, Element: HashIdentifiable>: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    public typealias CollectionSnapshot = NSDiffableDataSourceSnapshot<Section,  Element>
    public typealias CellProvider = (_ tableView: NSTableView, NSTableColumn, _ row: Int, _ element: Element) -> NSTableCellView?
    public typealias RowViewProvider = (_ tableView: NSTableView, _ row: Int, _ element: Element) -> NSTableRowView?
    
    internal typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Element.ID>
    internal typealias DataSoure = NSTableViewDiffableDataSource<Section.ID,  Element.ID>
    
    open var supplementaryViewProvider: SupplementaryViewProvider? = nil
    
    internal weak var tableView: NSTableView!
    internal var dataSource: DataSoure!
    internal var cellProvider: CellProvider
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
    open var allowsMultipleSelection: Bool {
        get { self.tableView.allowsMultipleSelection }
        set { self.tableView.allowsMultipleSelection = newValue } }
    open var allowsEmptySelection: Bool {
        get { self.tableView.allowsEmptySelection }
        set { self.tableView.allowsEmptySelection = newValue } }
    
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
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.numberOfRows(in: tableView)
    }
    
    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let element = dataSource.itemIdentifier(forRow: row)
        return dataSource.rowViewProvider(self.tableView, row, element)
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let element = dataSource.itemIdentifier(forRow: row)
        return dataSource.view
    }
        
    public init(tableView: NSTableView, cellProvider: @escaping CellProvider) {
        self.tableView = tableView
        self.cellProvider = cellProvider
        super.init()
        sharedInit()
    }
    
    public init<Item: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<Item, Element>) {
        self.tableView = tableView
        self.cellProvider = { tableView, column, row, element in
            return tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element) }
        super.init()
        sharedInit()
    }
    
    internal func sharedInit() {
        self.configurateDataSource()
        
        self.tableView.postsFrameChangedNotifications = false
        self.tableView.postsBoundsChangedNotifications = false
        
        self.allowsReordering = false
        self.allowsDeleting = false
        self.collectionView.registerForDraggedTypes([pasteboardType])
        self.collectionView.setDraggingSourceOperationMask(.move, forLocal: true)
        
        self.responder = Responder(self)
        let collectionViewNextResponder = self.collectionView.nextResponder
        self.tableView.nextResponder = self.responder
        self.responder.nextResponder = collectionViewNextResponder
        
        self.delegateBridge = DelegateBridge(self)
        self.tableView.delegate = self.delegateBridge
    }
    
    internal func configurateDataSource() {
        self.dataSource = DataSoure(tableView: self.tableView, cellProvider: {
            [weak self] tableView, column, row, elementID in
            guard let self = self, let element = self.allElements[id: elementID] else { return nil }
            return self.cellProvider(tableView, column, row, element)
        })
        self.dataSource.rowViewProvider = { [weak self] tableView, row, element in
            
        }
        self.dataSource.supplementaryViewProvider = { [weak self] collectionView, elementKind, indePath in
            guard let self = self else { return nil }
            return self.supplementaryViewProvider?(collectionView, elementKind, indePath)
        }
    }
}
*/
