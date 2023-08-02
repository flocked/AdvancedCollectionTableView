//
//  AdvanceTableViewDiffableDataSourceNew+.swift
//  TableDelegate
//
//  Created by Florian Zand on 01.08.23.
//

import AppKit
import FZUIKit

public class AdvanceTableViewDiffableDataSource<Section, Item> : NSObject, NSTableViewDelegate, NSTableViewDataSource  where Section : Hashable & Identifiable, Item : Hashable & Identifiable {
    public typealias CellProvider = (_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ identifier: Item) -> NSView
    public typealias RowProvider = (_ tableView: NSTableView, _ row: Int, _ identifier: Item) -> NSTableRowView
    
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<Section,  Item>
    internal typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Item.ID>
    internal typealias DataSoure = NSTableViewDiffableDataSource<Section.ID,  Item.ID>
    
    internal let tableView: NSTableView
    internal var dataSource: DataSoure!
    internal var cellProvider: CellProvider
    internal var dragingRowIndexes = IndexSet()
    internal let pasteboardType = NSPasteboard.PasteboardType("DiffableCollection.Pasteboard")
    internal var currentSnapshot: Snapshot = Snapshot()
    internal var sections: [Section] { currentSnapshot.sectionIdentifiers }
    internal var scrollView: NSScrollView? { return tableView.enclosingScrollView }
    internal var keyDownMonitor: Any? = nil

    /// Handlers that get called whenever the table view receives mouse click events of rows.
    public var mouseHandlers = MouseHandlers<Item>()
    
    /// Handlers that get called whenever the mouse is hovering a row.
    public var hoverHandlers = HoverHandlers<Item>() {
        didSet { self.setupHoverObserving()} }
    
    /// Handlers for selection of rows.
    public var selectionHandlers = SelectionHandlers<Item>()
    
    /// Handlers for deletion of rows.
    public var deletionHandlers = DeletionHandlers<Item>()
    
    /// Handlers for reordering of rows.
    public var reorderHandlers = ReorderHandlers<Item>()
    
    ///Handlers for displaying of rows. The handlers get called whenever the table view is displaying new rows (e.g. when the enclosing scrollview gets scrolled to new rows).
    public var displayHandlers = DisplayHandlers<Item>() {
        didSet {  self.ensureTrackingDisplayingRows() } }
        
    /// Handlers for drag and drop of files from and to the table view.
    public var dragDropHandlers = DragdropHandlers<Item>()
    
    /// Handlers for table columns.
    public var columnHandlers = ColumnHandlers<Item>()
    
    /**
    Right click menu provider for selected rows.
     
    When returning a menu to the `menuProvider`, the table view will display a menu on right click of selected rows.
     */
    public var menuProvider: ((_ elements: [Item]) -> NSMenu?)? = nil
    
    /**
     A Boolean value that indicates whether users can delete items either via keyboard shortcut or right click menu.
     
     If the value of this property is true (the default is false), users can delete items.
     */
    public var allowsDeleting: Bool = false {
        didSet { self.setupKeyDownMonitor() }
    }
    
    /**
    Provides an array of row actions to be attached to the specified edge of a table row and displayed when the user swipes horizontally across the row.
     */
    public var rowActionProvider: ((_ element: Item, _ edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction])? = nil
    
    public convenience init<I: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, Item>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            return _tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)!
        })
    }
    
    public convenience init<I: NSTableCellView, R: NSTableRowView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, Item>, rowRegistration: NSTableView.RowViewRegistration<R, Item>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            return _tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)!
        })
        self.rowViewProvider = { _tableView, row, element in
            return _tableView.makeRowView(using: rowRegistration, forRow: row, element: element)
        }
    }
    
    convenience init(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration]) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifier == column.identifier})!
            return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
        })
    }
    
    convenience init<R: NSTableRowView>(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration], rowRegistration: NSTableView.RowViewRegistration<R, Item>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifier == column.identifier})!
            return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
        })
        
        self.rowViewProvider = { _tableView, row, element in
            return _tableView.makeRowView(using: rowRegistration, forRow: row, element: element)
        }
    }
    
    public init(tableView: NSTableView, cellProvider: @escaping CellProvider) {
        self.tableView = tableView
        self.cellProvider = cellProvider
        super.init()
        self.sharedInit()
    }
    
    internal func sharedInit() {
        self.configurateDataSource()
        self.tableView.registerForDraggedTypes([pasteboardType])
        self.tableView.setDraggingSourceOperationMask(.move, forLocal: true)
        self.tableView.delegate = self
    }
    
    public var rowViewProvider: RowProvider? = nil
    
    /*
    internal func setupRowViewProvider() {
        if let rowViewProvider = self.rowViewProvider {
            self.dataSource.rowViewProvider = { [weak self] tableview, row, itemID in
                guard let self = self, let itemID = itemID as? Item.ID, let item = self.allItems[id: itemID] else {
                    return tableview.rowView(atRow: row, makeIfNecessary: true)!
                }
                return rowViewProvider(tableview, row, item)
            }
        } else {
            self.dataSource.rowViewProvider = nil
        }
    }
    */
    
    internal var rowAnimation: NSTableView.AnimationOptions = .effectFade
    
    @objc internal dynamic var _defaultRowAnimation: Int {
        return Int(rowAnimation.rawValue)
       // return self.dataSource.value(forKeyPath: "_defaultRowAnimation") as! Int
    }
    
    @objc internal dynamic var defaultRowAnimation: Int {
        return Int(rowAnimation.rawValue)
      //  return self.dataSource.value(forKeyPath: "defaultRowAnimation") as! Int
    }
    
    public func snapshot() -> NSDiffableDataSourceSnapshot<Section,  Item> {
        var snapshot = Snapshot()
        snapshot.appendSections(currentSnapshot.sectionIdentifiers)
        for section in currentSnapshot.sectionIdentifiers {
            snapshot.appendItems(currentSnapshot.itemIdentifiers(inSection: section), toSection: section)
        }
        return snapshot
    }
    
    public func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>,_ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        let internalSnapshot = convertSnapshot(snapshot)
        self.currentSnapshot = snapshot
        dataSource.apply(internalSnapshot, option, completion: completion)
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
       return dataSource.numberOfRows(in: tableView)
    }
    
    var previousSelectedRows: [Int] = []
    public func tableViewSelectionDidChange(_ notification: Notification) {
        guard selectionHandlers.didSelect != nil || selectionHandlers.didDeselect != nil else {
            previousSelectedRows = Array(self.tableView.selectedRowIndexes)
            return
        }
        let selectedRows = Array(self.tableView.selectedRowIndexes)
        let diff = diff(old: previousSelectedRows, new: selectedRows)
        if diff.selected.isEmpty == false, let didSelect = selectionHandlers.didSelect {
            let selectedItems = diff.selected.compactMap({item(forRow: $0)})
            didSelect(selectedItems)
        }
        
        if diff.deselected.isEmpty == false, let didDeselect = selectionHandlers.didDeselect {
            let deselectedItems = diff.deselected.compactMap({item(forRow: $0)})
            didDeselect(deselectedItems)
        }
        previousSelectedRows = selectedRows
    }
    
    internal func diff(old: [Int], new: [Int]) -> (deselected: [Int], selected: [Int]) {
        let selectedRows = new
        let previousSelectedRows = old
        var selected: [Int] = []
        var deselected: [Int] = []
        for selectedRow in selectedRows {
            if previousSelectedRows.contains(selectedRow) == false {
                selected.append(selectedRow)
            }
        }
        for previousSelectedRow in previousSelectedRows {
            if selectedRows.contains(previousSelectedRow) == false {
                deselected.append(previousSelectedRow)
            }
        }
        return (deselected, selected)
    }
    
    public func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        guard self.selectionHandlers.shouldSelect != nil || self.selectionHandlers.shouldDeselect != nil  else {
            return proposedSelectionIndexes
        }
        let selectedRows = Array(self.tableView.selectedRowIndexes)
        let diff = diff(old: selectedRows, new: Array(proposedSelectionIndexes))
        var selections: [Item] = []
        let selectedItems = diff.selected.compactMap({item(forRow: $0)})
        let deselectedItems = diff.deselected.compactMap({item(forRow: $0)})
        if selectedItems.isEmpty == false, let shouldSelect = selectionHandlers.shouldSelect {
            selections.append(contentsOf: shouldSelect(selectedItems))
        } else {
            selections.append(contentsOf: selectedItems)
        }
        
        if deselectedItems.isEmpty == false, let shouldDeselect = selectionHandlers.shouldDeselect {
            selections.append(contentsOf: shouldDeselect(deselectedItems))
        } else {
            selections.append(contentsOf: deselectedItems)
        }
        
        return IndexSet(selections.compactMap({row(for: $0)}))
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return self.dataSource.tableView(tableView, viewFor: tableColumn, row: row)
    }
    
    public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var rowView: NSTableRowView? = nil
        DispatchQueue.main.async {
            if let item = self.item(forRow: row), let rowViewProvider = self.rowViewProvider {
                rowView = rowViewProvider(tableView, row, item)
            } else {
                rowView = self.tableView.rowView(atRow: row, makeIfNecessary: true)
            }
        }
        return rowView
    }
    
    public func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        if self.dragingRowIndexes.isEmpty == false {
        let dragingItems = self.dragingRowIndexes.compactMap({item(forRow: $0)})
        guard self.reorderHandlers.canReorder?(dragingItems) ?? true else {
            return false
        }
            if let willReorder = self.reorderHandlers.willReorder {
                willReorder(dragingItems)
            }
            var snapshot = self.snapshot()
            if let toItem = self.item(forRow: row) {
                for index in dragingRowIndexes {
                    if let item = self.item(forRow: index) {
                        snapshot.moveItem(item, beforeItem: toItem)
                    }
                }
                self.apply(snapshot, .usingReloadData)
            }
        }
        
        return true
    }
    
    public func tableView( _ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        return NSDragOperation.move
    }
    
    public func tableView( _ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        self.dragingRowIndexes = rowIndexes
    }
    
    public func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        if self.dragingRowIndexes.isEmpty == false, let didReorder = self.reorderHandlers.didReorder {
            let dragingItems = self.dragingRowIndexes.compactMap({item(forRow: $0)})
            didReorder(dragingItems)
        }
        self.dragingRowIndexes.removeAll()
    }
        
    
    public func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if let element = self.item(forRow: row) {
            let item = NSPasteboardItem()
            item.setString(String(element.hashValue), forType: self.pasteboardType)
            return item
        }
        return nil
    }
    
    public func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        if let item = item(forRow: row), let rowActionProvider = self.rowActionProvider {
            return rowActionProvider(item, edge)
        }
        return []
    }
    
    internal func configurateDataSource() {
        self.dataSource = DataSoure(tableView: self.tableView, cellProvider: {
            [weak self] tableview, tablecolumn, row, itemID in
            guard let self = self, let item = self.allItems[id: itemID] else { return NSTableCellView() }
            return self.cellProvider(tableview, tablecolumn, row, item)
        })
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
    
    internal func isHovering(_ rowView: NSTableRowView) {
        let row = self.tableView.row(for: rowView)
        if row != -1, let item = item(forRow: row) {
            self.hoverHandlers.isHovering?(item)
        }
    }
    
    internal func didEndHovering(_ rowView: NSTableRowView) {
        let row = self.tableView.row(for: rowView)
        if row != -1, let item = item(forRow: row) {
            self.hoverHandlers.didEndHovering?(item)
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
    
    internal var hoveredRowObserver: NSKeyValueObservation? = nil
    internal func setupHoverObserving() {
        if self.hoverHandlers.isHovering != nil || self.hoverHandlers.didEndHovering != nil {
            self.tableView.setupObservingView()
            if hoveredRowObserver == nil {
                hoveredRowObserver = self.tableView.observeChanges(for: \.hoveredRowView, handler: { old, new in
                    guard old != new else { return }
                    if let didEndHovering = self.hoverHandlers.didEndHovering,  let old = old {
                      let oldRow = self.tableView.row(for: old)
                        if oldRow != -1, let item = self.item(forRow: oldRow) {
                            didEndHovering(item)
                        }
                    }
                    if let isHovering = self.hoverHandlers.isHovering,  let new = new {
                      let newRow = self.tableView.row(for: new)
                        if newRow != -1, let item = self.item(forRow: newRow) {
                            isHovering(item)
                        }
                    }
                })
            }
        } else {
            hoveredRowObserver = nil
        }
    }
    
    internal var previousDisplayingElements = [Item]()
    @objc internal func scrollViewContentBoundsDidChange(_ notification: Notification) {
        /*
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
         */
    }
}
