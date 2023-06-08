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

public class TableViewDiffableDataSource<Section: Identifiable & Hashable, Element: Identifiable & Hashable>: NSObject, NSTableViewDataSource {
    public typealias CollectionSnapshot = NSDiffableDataSourceSnapshot<Section,  Element>
    public typealias CellProvider = (NSTableView, NSTableColumn, Int, Element) -> NSTableCellView
    public typealias RowProvider = (NSTableView, Int, Element) -> NSTableRowView?
    
    internal typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Element.ID>
    internal typealias DataSoure = NSTableViewDiffableDataSource<Section.ID,  Element.ID>

    public var rowProvider: RowProvider = {tableView, row, element in
        return nil
    }
    
    public var cellProvider: CellProvider
    
    public let tableView: NSTableView
    internal var dataSource: DataSoure!
    internal var draggingRows = Set<Int>()
    internal let quicklookPanel = QuicklookPanel.shared
    internal var delegateBridge: DelegateBridge<Section, Element>!
    internal var responder: Responder<Section, Element>!
    internal var scrollView: NSScrollView? { return tableView.enclosingScrollView }
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
    
    public var mouseHandlers = MouseHandlers<Element>()
    public var hoverHandlers = HoverHandlers<Element>() {
        didSet { self.setupHoverObserving()} }
    public var selectionHandlers = SelectionHandlers<Element>()
    public var reorderHandlers = ReorderHandlers<Element>()
    public var displayHandlers = DisplayHandlers<Element>() {
        didSet {  self.ensureTrackingDisplayingRows() } }
    public var prefetchHandlers = PrefetchHandlers<Element>()
    public var dragDropHandlers = DragdropHandlers<Element>()
    public var quicklookHandlers = QuicklookHandlers<Element>()
    public var columnHandlers = ColumnHandlers<Element>()
    public var menuProvider: ((_ elements: [Element]) -> NSMenu?)? = nil
    public var keydownHandler: ((_ keyCode: Int, _ modifierFlags: NSEvent.ModifierFlags) -> Bool)? = nil
    
    /**
     A Boolean value that indicates whether users can delete items either via keyboard shortcut or right click menu.

     If the value of this property is true (the default is false), users can delete items.
     */
    public var allowsDeleting: Bool = false
    /**
     A Boolean value that indicates whether users can reorder items in the table view when dragging them via mouse.

     If the value of this property is true (the default is false), users can reorder items in the table view.
     */
    public var allowsReordering: Bool = false
    /**
     A Boolean value that indicates whether users can select items while an section is collapsed in the table view.

     If the value of this property is true (the default), users can select items while an section is collapsed.
     */
    public var allowsSectionCollapsing: Bool = true
    /**
     A Boolean value that indicates whether users can select items in the table view.

     If the value of this property is true (the default), users can select items.
     */
    public var allowsSelectable: Bool {
        get { self.tableView.isEnabled }
        set { self.tableView.isEnabled = newValue } }
    /**
     A Boolean value that determines whether users can select more than one item in the table view.

     This property controls whether multiple items can be selected simultaneously. The default value of this property is false.
     When the value of this property is true, tapping a cell adds it to the current selection (assuming the delegate permits the cell to be selected). Tapping the item again removes it from the selection.
     */
    public var allowsMultipleSelection: Bool {
        get { self.tableView.allowsMultipleSelection }
        set { self.tableView.allowsMultipleSelection = newValue } }
    /**
     A Boolean value indicating whether the table view may have no selected items.

     The default value of this property is true, which allows the table view to have no selected items. Setting this property to false causes the table view to always leave at least one item selected.
     */
    public var allowsEmptySelection: Bool {
        get { self.tableView.allowsEmptySelection }
        set { self.tableView.allowsEmptySelection = newValue } }
    
    internal func isHovering(_ row: NSTableRowView) {
        
    }
    
    internal func didEndHovering(_ row: NSTableRowView) {
        
    }
    
    internal func setupHoverObserving() {
        if self.hoverHandlers.isHovering != nil || self.hoverHandlers.didEndHovering != nil {
            self.tableView.setupObservingView()
            if self.tableView.hoverHandlers == nil {
                let hoverHandlers = NSTableView.HoverHandlers()
                hoverHandlers.isHovering = { [weak self] item in
                    guard let self = self else { return }
                    self.isHovering(item)
                }
                hoverHandlers.didEndHovering = { [weak self] item in
                    guard let self = self else { return }
                    self.didEndHovering(item)
                }
                self.tableView.hoverHandlers = hoverHandlers
            }
        }
    }
    
    internal func ensureTrackingDisplayingRows() {
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
    
    
    internal var previousDisplayingElements = [Element]()
    @objc internal func scrollViewContentBoundsDidChange(_ notification: Notification) {
        guard (notification.object as? NSClipView) != nil else { return }
        let displayingElements = self.visibleElements
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
    
    /**
     Returns a representation of the current state of the data in the table view.

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

     The system interrupts any ongoing item animations and immediately reloads the table view’s content.
     You can safely call this method from a background queue, but you must do so consistently in your app. Always call this method exclusively from the main queue or from a background queue.
     
     - Parameters:
        - snapshot: The snapshot that reflects the new state of the data in the table view.
        - completion: A optional completion handlers which gets called after applying the snapshot.
     */
    public func applySnapshotUsingReloadData(_ snapshot: CollectionSnapshot, completion: (() -> Void)? = nil) {
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
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.numberOfRows(in: tableView)
    }
    
    public func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        if (self.draggingRows.isEmpty == false) {
            self.moveElements(at: Array(self.draggingRows), to: row)
        }
        return true
    }
    
    public func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    public func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        self.draggingRows = Set(rowIndexes.compactMap({$0}))
    }
    
    public func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if let elementID = self.element(for: row)?.id {
            let item = NSPasteboardItem()
            item.setString(String(elementID.hashValue), forType: self.pasteboardType)
            return item
        } else {
            return nil
        }
    }
    
    public init(tableView: NSTableView, cellProvider: @escaping CellProvider) {
        self.tableView = tableView
        self.cellProvider = cellProvider
        super.init()
        sharedInit()
    }
    
    public init(tableView: NSTableView, cellProvider: @escaping CellProvider, rowProvider:  @escaping RowProvider) {
        self.tableView = tableView
        self.cellProvider = cellProvider
        self.rowProvider = rowProvider
        super.init()
        sharedInit()
    }
    
    public init<C: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<C, Element>) {
        self.tableView = tableView
        self.cellProvider = { tableView, column, row, elementID in
            tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: elementID)!
        }
        super.init()
        sharedInit()
    }
    
    public init<C: NSTableCellView, R: NSTableRowView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<C, Element>, rowRegistration: NSTableView.RowViewRegistration<R, Element>) {
        self.tableView = tableView
        self.cellProvider = { tableView, column, row, elementID in
            tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: elementID)!
        }
        self.rowProvider = { tableView, row, elementID in
            tableView.makeRowView(using: rowRegistration, forRow: row, element: elementID)
        }
        super.init()
        sharedInit()
    }
    
    internal func sharedInit() {
        self.configurateDataSource()
        
        self.tableView.postsFrameChangedNotifications = false
        self.tableView.postsBoundsChangedNotifications = false
        
        self.allowsReordering = false
        self.allowsDeleting = false
        self.tableView.registerForDraggedTypes([pasteboardType])
        self.tableView.setDraggingSourceOperationMask(.move, forLocal: true)
        
        self.responder = Responder(self)
        let tableViewNextResponder = self.tableView.nextResponder
        self.tableView.nextResponder = self.responder
        self.responder.nextResponder = tableViewNextResponder
        
        self.tableView.dataSource = self
        self.delegateBridge = DelegateBridge(self)
    }
    
    
    internal func configurateDataSource() {
        self.dataSource = DataSoure(tableView: self.tableView, cellProvider: {
            tableView, column, row, elementID in
            let element = self.allElements[id: elementID]!
                return self.cellProvider(tableView, column, row, element)
        })
    }
}
    


