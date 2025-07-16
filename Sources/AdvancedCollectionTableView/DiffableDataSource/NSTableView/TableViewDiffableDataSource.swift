//
//  TableViewDiffableDataSource.swift
//
//
//  Created by Florian Zand on 01.08.23.
//

import AppKit
import FZQuicklook
import FZSwiftUtils
import FZUIKit

/**
 A `NSTableViewDiffableDataSource` with additional functionality.

 The diffable data source provides:
 - Reordering items via ``ReorderingHandlers-swift.struct``.
 - Deleting items via  ``DeletingHandlers-swift.struct``.
 - Quicklook previews of items via spacebar by providing items conforming to `QuicklookPreviewable`.
 - Right click menu provider for selected items via ``menuProvider``.
 - Row action provider via ``rowActionProvider``.

 __It includes handlers for:__

 - Selecting items via ``selectionHandlers-swift.property``.
 - Hovering items by mouse via ``hoverHandlers-swift.property``.
 - Table column handlers via ``columnHandlers-swift.property``.

 ### Configurating the data source

 To connect a diffable data source to a table view, you create the diffable data source using its ``init(tableView:cellProvider:)`` or ``init(tableView:cellRegistration:)`` initializer, passing in the table view you want to associate with that data source.

 ```swift
 tableView.dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellRegistration: cellRegistration)
 ```

 Then, you generate the current state of the data and display the data in the UI by constructing and applying a snapshot. For more information, see `NSDiffableDataSourceSnapshot`.
 
 - Note: Each of your sections and items must have unique identifiers.

 - Note: Don’t change the `dataSource` or `delegate` on the table view after you configure it with a diffable data source. If the table view needs a new data source after you configure it initially, create and configure a new table view and diffable data source.
 */
open class TableViewDiffableDataSource<Section, Item>: NSObject, NSTableViewDataSource where Section: Hashable & Identifiable, Item: Hashable & Identifiable {

    weak var tableView: NSTableView!
    var dataSource: NSTableViewDiffableDataSource<Section.ID, Item.ID>!
    var cellProvider: CellProvider!
    var delegate: Delegate!
    var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    var dropValidationRow: Int? = nil
    enum ColumnItemSortingStrategy: Int, Hashable {
        case reset
        /// Updates the item order
        case update
    }
    var dragDeleteItems: [Item] = []
    var dragDeleteObservation: KeyValueObservation?
    var dragDistanceIsMatched = false
    var dragingRowIndexes: [Int] = [] {
        didSet {
            guard oldValue != dragingRowIndexes else { return }
            oldValue.forEach({ tableView?.rowView(atRow: $0, makeIfNecessary: false)?.isReordering = false })
            dragingRowIndexes.forEach({ tableView?.rowView(atRow: $0, makeIfNecessary: false)?.isReordering = true })
        }
    }
    var dropTargetRow: Int? = nil {
        didSet {
            guard oldValue != dropTargetRow else { return }
            if let row = oldValue {
                tableView?.rowView(atRow: row, makeIfNecessary: false)?.isDropTarget = false
            }
            if let row = dropTargetRow {
                tableView?.rowView(atRow: row, makeIfNecessary: false)?.isDropTarget = true
            }
        }
    }
    var reorderingSectionRow: Int? {
        didSet {
            if let row = oldValue {
                tableView?.rowView(atRow: row, makeIfNecessary: false)?.isReordering = false
            }
            if let row = reorderingSectionRow {
                tableView?.rowView(atRow: row, makeIfNecessary: false)?.isReordering = true
            }
        }
    }
    var sectionRowIndexes: [Int] = []
    var hoveredRowObserver: KeyValueObservation?
    var keyDownMonitor: NSEvent.Monitor?
    var canDragItems = false
    var canDrop = false
    var immediatelyReorderRowView: NSTableRowView?
    
    /// The closure that configures and returns the table view’s row views from the diffable data source.
    open var rowViewProvider: RowViewProvider? {
        didSet {
            if let rowViewProvider = rowViewProvider {
                dataSource.rowViewProvider = { [weak self] tableview, row, identifier in
                    guard let self = self, let item = self.currentSnapshot.itemIdentifiers[id: identifier as! Item.ID] else { return NSTableRowView() }
                    let rowView = rowViewProvider(tableview, row, item)
                    return rowView
                }
            } else {
                dataSource.rowViewProvider = nil
            }
        }
    }
    
    /**
     A closure that configures and returns a row view for a table view from its diffable data source.
     
     - Parameters:
        - tableView: The table view to configure this row view for.
        - row: The row of the row view.
        - item: The item of the row.
     
     - Returns: A configured row view object.
     */
    public typealias RowViewProvider = (_ tableView: NSTableView, _ row: Int, _ item: Item) -> NSTableRowView
    
    /// Applies the row view registration to configure and return table row views.
    open func applyRowViewRegistration<Row: NSTableRowView>(_ registration: NSTableView.RowRegistration<Row, Item>) {
        rowViewProvider = { tableView, row, item in
            registration.makeView(tableView, row, item)
        }
    }
    
    /// The closure that configures and returns the table view’s section header views from the diffable data source.
    open var sectionHeaderCellProvider: SectionHeaderCellProvider? {
        didSet {
            if let sectionHeaderCellProvider = sectionHeaderCellProvider {
                dataSource.sectionHeaderViewProvider = { [weak self] tableView, row, sectionID in
                    guard let self = self, let section = self.sections[id: sectionID] else { return NSTableCellView() }
                    var view: NSTableCellView?
                    NSAnimationContext.performWithoutAnimation {
                        view = sectionHeaderCellProvider(tableView, row, section)
                    }
                    return view ?? NSTableCellView()
                }
            } else {
                dataSource.sectionHeaderViewProvider = nil
            }
        }
    }
    
    /**
     A closure that configures and returns a section header cell for a table view from its diffable data source.
     
     - Parameters:
        - tableView: The table view to configure this section header cell view for.
        - row: The row of the section.
        - section: The section.
     
     - Returns: A configured section header cell view object.
     */
    public typealias SectionHeaderCellProvider = (_ tableView: NSTableView, _ row: Int, _ section: Section) -> NSTableCellView
    
    /// Uses the specified cell registration to configure and return section header cell views.
    open func applySectionHeaderRegistration<Cell: NSTableCellView>(_ registration: NSTableView.CellRegistration<Cell, Section>) {
        sectionHeaderCellProvider = { tableView, row, section in
            if let column = tableView.tableColumns.first, let cellView = registration.makeCellView(tableView, column, row, section) {
                return cellView
            }
            return NSTableCellView()
        }
    }
        
    /**
     The right click menu provider.
     
     The provided menu is displayed when the user right-clicks the table view. If you don't want to display a menu, return `nil`.
     
     `items` provides:
     - if right-click on a **selected item**, all selected items,
     - else if right-click on a **non-selected item**, that item,
     - else an empty array.
     */
    open var menuProvider: ((_ items: [Item]) -> NSMenu?)? = nil {
        didSet {
            if menuProvider != nil {
                tableView.menuProvider = { [weak self] location in
                    guard let self = self else { return nil }
                    return self.menuProvider?(self.items(for: location))
                }
            } else if oldValue != nil {
                tableView.menuProvider = nil
            }
        }
    }
    
    /**
     The handler that gets called when the user right-clicks the table view.

     `items` provides:
     - if right-click on a **selected item**, all selected items,
     - else if right-click on a **non-selected item**, that item,
     - else an empty array.
     */
    open var rightClickHandler: ((_ items: [Item]) -> ())? = nil {
        didSet {
            if rightClickHandler != nil {
                tableView.mouseHandlers.rightDown = { [weak self] event in
                    guard let self = self, let handler = self.rightClickHandler else { return }
                    handler(self.tableView.rightClickRowIndexes(for: event).compactMap({ self.item(forRow: $0) }))
                }
            } else if oldValue != nil {
                tableView.mouseHandlers.rightDown = nil
            }
        }
    }
    
    /// Provides an array of row actions to be attached to the specified edge of a table row and displayed when the user swipes horizontally across the row.
    open var rowActionProvider: ((_ item: Item, _ edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction])? = nil
    
    /// The handler that gets called when the table view gets double clicked.
    open var doubleClickHandler: ((_ item: Item?)->())? {
        didSet {
            doubleClickGesture?.removeFromView()
            doubleClickGesture = nil
            if let handler = doubleClickHandler {
                doubleClickGesture = .init { [weak self] gesture in
                    guard let self = self, let tableView = self.tableView else { return }
                    handler(self.item(forRow: tableView.selectedRow))
                }
                tableView?.addGestureRecognizer(doubleClickGesture!)
            }
        }
    }
    
    var doubleClickGesture: DoubleClickGestureRecognizer?
    
    /**
     The default animation the UI uses to show differences between rows.
     
     The default value of this property is `effectFade`.
     
     If you set the value of this property, the new value becomes the default row animation for the next update that uses ``apply(_:_:completion:)``.
     */
    open var defaultRowAnimation: NSTableView.AnimationOptions {
        get { dataSource.defaultRowAnimation }
        set { dataSource.defaultRowAnimation = newValue }
    }
    
    @objc dynamic var _defaultRowAnimation: UInt {
        dataSource.defaultRowAnimation.rawValue
    }
    
    func setupHoverObserving() {
        if hoverHandlers.shouldSetup {
            guard hoveredRowObserver == nil else { return }
            tableView.setupObservation()
            hoveredRowObserver = tableView.observeChanges(for: \.hoveredRow, handler: { [weak self] old, new in
                guard let self = self, old != new else { return }
                if let didEndHovering = self.hoverHandlers.didEndHovering, old != -1, let item = self.item(forRow: old) {
                    didEndHovering(item)
                }
                if let isHovering = self.hoverHandlers.isHovering, new != -1, let item = self.item(forRow: new) {
                    isHovering(item)
                }
            })
        } else {
            hoveredRowObserver = nil
        }
    }
    
    func setupKeyDownMonitor() {
        if let canDelete = deletingHandlers.canDelete {
            keyDownMonitor = NSEvent.localMonitor(for: .keyDown) { [weak self] event in
                guard let self = self, event.charactersIgnoringModifiers == String(UnicodeScalar(NSDeleteCharacter)!), self.tableView.isFirstResponder else { return event }
                let itemsToDelete = canDelete(self.selectedItems)
                guard !itemsToDelete.isEmpty else { return event }
                
                let transaction = self.currentSnapshot.deleteTransaction(itemsToDelete)
                self.deletingHandlers.willDelete?(itemsToDelete, transaction)
                QuicklookPanel.shared.close()
                self.apply(transaction.finalSnapshot, self.deletingHandlers.animates ? .animated : .withoutAnimation)
                self.deletingHandlers.didDelete?(itemsToDelete, transaction)
                
                if !self.tableView.allowsEmptySelection, self.tableView.selectedRowIndexes.isEmpty {
                    if let item = transaction.initialSnapshot.nextItemForDeleting(itemsToDelete) ?? self.items.first {
                        self.selectItems([item])
                    }
                }
                return nil
            }
        } else {
            keyDownMonitor = nil
        }
    }
    
    // MARK: - Snapshot
    
    /**
     Returns a representation of the current state of the data in the table view.
     
     A snapshot containing section and item identifiers in the order that they appear in the UI.
     */
    open func snapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        currentSnapshot
    }
    
    /// Returns an empty snapshot.
    open func emptySnapshot() -> NSDiffableDataSourceSnapshot<Section, Item> {
        .init()
    }
    
    /**
     Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes.
     
     The system interrupts any ongoing item animations and immediately reloads the table view’s content.
     
     - Parameters:
        - snapshot: The snapshot that reflects the new state of the data in the table view.
        - option: Option how to apply the snapshot to the table view. The default value is `animated`.
        - completion: An optional completion handler which gets called after applying the snapshot. The system calls this closure from the main queue.
     */
    open func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>, _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        let previousIsEmpty = currentSnapshot.isEmpty
        let internalSnapshot = snapshot.toIdentifiableSnapshot()
        currentSnapshot = snapshot
        updateSectionRowIndexes()
        tableView.hoveredRow = -1
        dataSource.apply(internalSnapshot, option, completion: completion)
        updateEmptyView(previousIsEmpty: previousIsEmpty)
    }
    
    func updateSectionRowIndexes() {
        sectionRowIndexes.removeAll()
        guard sectionHeaderCellProvider != nil else { return }
        var row = 0
        for section in sections {
            sectionRowIndexes.append(row)
            row = row + 1 + currentSnapshot.numberOfItems(inSection: section)
        }
    }
    
    /// Returns a preview image of the table row for the specified item.
    public func previewImage(for item: Item) -> NSImage? {
        let columns = tableView.tableColumns
        guard !columns.isEmpty else { return nil }
        return NSImage(combineHorizontal: columns.compactMap({ previewImage(for: item, tableColumn: $0, useColumnWidth: $0 !== columns.last!) }), alignment: .top)
    }
    
    /// Returns a preview image of the table cell for the specified item and table column.
    public func previewImage(for item: Item, tableColumn: NSTableColumn) -> NSImage? {
        previewImage(for: item, tableColumn: tableColumn, useColumnWidth: true)
    }
    
    /// Returns a preview image of the table row for the specified items.
    public func previewImage(for items: [Item]) -> NSImage? {
        return NSImage(combineVertical: items.compactMap({ previewImage(for: $0)}).reversed(), alignment: .left)
    }
    
    private func previewImage(for item: Item, tableColumn: NSTableColumn, useColumnWidth: Bool) -> NSImage? {
        guard tableView.tableColumns.contains(tableColumn) else { return nil }
        let view = cellProvider(tableView, tableColumn, 0, item)
        view.frame.size = view.systemLayoutSizeFitting(width: tableColumn.width)
        view.frame.size.width = useColumnWidth ? tableColumn.width : view.frame.size.width
        return view.renderedImage
    }
    
    // MARK: - Init
    
    /**
     Creates a diffable data source with the specified cell registration, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellRegistration: cellRegistration)
     ```
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistration: A cell registration which returns each of the cells for the table view from the data the diffable data source provides.
     */
    public convenience init<Cell: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<Cell, Item>) {
        self.init(tableView: tableView, cellProvider: {
            tableView, column, row, item in
            return tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, item: item)!
        })
    }
    
    /*
    /**
     Creates a diffable data source with the specified cell registration, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellRegistration: cellRegistration)
     ```
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistration: A cell registration which returns each of the cells for the table view from the data the diffable data source provides.
        - sectionHeaderRegistration: A cell registration which returns each of the table view’s section header views from the data the diffable data source provides.
     */
    public convenience init<Cell: NSTableCellView, SectionCell: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<Cell, Item>, sectionHeaderRegistration: NSTableView.CellRegistration<SectionCell, Section>) {
        self.init(tableView: tableView, cellProvider: {
            tableView, column, row, item in
            return tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, item: item)!
        })
        applySectionHeaderRegistration(sectionHeaderRegistration)
    }
    */
    
    /**
     Creates a diffable data source with the specified cell registrations, and connects it to the specified table view.
     
     Specify column identifiers for each of the cell registrations using: ``AppKit/NSTableView/CellRegistration/init(columnIdentifiers:handler:)``
     
     The column identifiers are used to create the cells for each column with the coresponding column identifier.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellRegistrations: cellRegistrations)
     ```
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistrations: Cell registrations which returns each of the cells for the table view from the data the diffable data source provides.
     */
    public convenience init(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration]) {
        self.init(tableView: tableView, cellProvider: {
            _, column, row, item in
            if let cellRegistration = (cellRegistrations.first(where: { $0.columnIdentifiers.contains(column.identifier) }) ?? cellRegistrations.first(where: { $0.columnIdentifiers.isEmpty })) as? _NSTableViewCellRegistration {
                return cellRegistration.makeView(tableView, column, row, item) ?? NSTableCellView()
            }
            return NSTableCellView()
        })
    }
    
    /*
    /**
     Creates a diffable data source with the specified cell registrations, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellRegistrations: cellRegistrations)
     ```
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistrations: Cell registrations which returns each of the cells for the table view from the data the diffable data source provides.
        - sectionHeaderRegistration: A cell registration which returns each of the table view’s section header views from the data the diffable data source provides.
     */
    public convenience init<SectionCell: NSTableCellView>(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration], sectionHeaderRegistration: NSTableView.CellRegistration<SectionCell, Section>) {
        self.init(tableView: tableView, cellRegistrations: cellRegistrations)
        applySectionHeaderRegistration(sectionHeaderRegistration)
    }
    */
    
    /**
     Creates a diffable data source with the specified cell provider, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a item provider, where you configure each of your cells to determine how to display your data in the UI.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellProvider: {
     (tableView, tableColumn, row, item) in
     // configure and return cell
     })
     ```
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellProvider: A closure that creates and returns each of the cells for the table view from the data the diffable data source provides.
     */
    public init(tableView: NSTableView, cellProvider: @escaping CellProvider) {
        self.tableView = tableView
        super.init()
        self.cellProvider = cellProvider
        dataSource = .init(tableView: tableView, cellProvider: {
            [weak self] tableview, tablecolumn, row, itemID in
            guard let self = self, let item = self.items[id: itemID] else { return NSTableCellView() }
            var view: NSView?
            NSAnimationContext.performWithoutAnimation {
                view = cellProvider(tableview, tablecolumn, row, item)
            }
            return view ?? NSTableCellView()
        })
        delegate = Delegate(self)
        tableView.registerForDraggedTypes([.itemID, .fileURL, .tiff, .png, .string, .URL])
        tableView.isQuicklookPreviewable = Item.self is QuicklookPreviewable.Type
        tableView.setDraggingSourceOperationMask(.copy, forLocal: false)
        tableView.setDraggingSourceOperationMask(.copy, forLocal: true)
    }
    
    /**
     A closure that configures and returns a cell view for a table view from its diffable data source.
     
     - Parameters:
        - tableView: The table view to configure this cell for.
        - tableColumn: The table column of the cell.
        - row: The row of the cell in the table view.
        - item: The item for this cell.
     
     - Returns: A configured cell object.
     */
    public typealias CellProvider = (_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ item: Item) -> NSView
    
    // MARK: - DataSource conformance
    
    open func numberOfRows(in tableView: NSTableView) -> Int {
        dataSource.numberOfRows(in: tableView)
    }
    
    // MARK: Dropping
            
    open func tableView(_ tableView: NSTableView, validateDrop draggingInfo: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        Swift.print("validateDrop")
        canDrop = false
        dropTargetRow = nil
        if !dragingRowIndexes.isEmpty {
            if reorderingHandlers.droppable, let canDrop = reorderingHandlers.canDrop, dropOperation == .on {
                if dragingRowIndexes.count == 1, dragingRowIndexes.first == row {
                    dropTargetRow = nil
                    return []
                } else if let target = item(forRow: row) {
                    if dropValidationRow == row {
                        dropTargetRow = nil
                        dropValidationRow = nil
                        return []
                    }
                    dropTargetRow = canDrop(dragingRowIndexes.compactMap({ item(forRow: $0) }), target) ? row : nil
                    return dropTargetRow != nil ? .move : []
                } else {
                    dropTargetRow = nil
                    return []
                }
            }
            dropValidationRow = dropOperation == .above ? row : nil
        
            if reorderingHandlers.canReorder != nil, dropOperation == .above {
                guard row >= (sectionHeaderCellProvider != nil ? 1 : 0) else { return [] }
                if let last = dragingRowIndexes.last, (dragingRowIndexes + [last+1]).contains(row), dragingRowIndexes.compactMap({ item(forRow: $0) }).compactMap({ section(for: $0) }).uniqued().count == 1 {
                    return []
                }
                /*
                if immediatelyReorderRowView != nil, let fromRow = dragingRowIndexes.first  {
                    let items = dragingRowIndexes.compactMap { item(forRow: $0) }
                    let transaction = moveItemsTransaction(items, to: row)
                    reorderingHandlers.willReorder?(transaction)
                    /*
                    NSView.animate {
                        tableView.beginUpdates()
                        tableView.moveRow(at: fromRow, to: row)
                        tableView.endUpdates()
                    }
                     */
                    tableView.sortDescriptors = []
                    dragingRowIndexes = [row]
                    apply(transaction.finalSnapshot, reorderingHandlers.animates ? .animated :  .withoutAnimation)
                    selectItems(items)
                    reorderingHandlers.didReorder?(transaction)
                    return []
                }
                */
                return .move
            }
        }
        if reorderingSectionRow != nil, dropOperation == .above {
            return moveSectionTransaction(to: row) != nil ? .move : []
        }
        if draggingInfo.draggingSource as? NSTableView !== tableView, !(row == 0 && sectionRowIndexes.contains(row) && dropOperation == .above), (!sectionRowIndexes.contains(row) || (!sectionRowIndexes.contains(row+1) && dropOperation == .above) ) {
            if dropOperation == .on, droppingHandlers.isDroppableInto, let canDropInto = droppingHandlers.canDropInto, let item = item(forRow: row) {
                canDrop = canDropInto(draggingInfo.dropInfo(for: tableView), item)
                return canDrop ? .copy : []
            } else if dropOperation == .above, let canDrop = droppingHandlers.canDrop {
                self.canDrop = canDrop(draggingInfo.dropInfo(for: tableView))
                return self.canDrop ? .copy : []
            }
        }
        return []
    }
    
    open func tableView(_ tableView: NSTableView, acceptDrop draggingInfo: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        if !dragingRowIndexes.isEmpty {
            let items = dragingRowIndexes.compactMap { item(forRow: $0) }
            dragingRowIndexes = []
            if dropTargetRow != nil, let target = item(forRow: row) {
                dropTargetRow = nil
                var snapshot = currentSnapshot
                snapshot.deleteItems(items)
                let transaction = DiffableDataSourceTransaction(initial: currentSnapshot, final: snapshot)
                reorderingHandlers.willDrop?(items, target, transaction)
                apply(transaction.finalSnapshot, reorderingHandlers.animates ? .animated :  .withoutAnimation)
                reorderingHandlers.didDrop?(items, target, transaction)
            } else {
                let transaction = moveItemsTransaction(items, to: row)
                reorderingHandlers.willReorder?(transaction)
                tableView.sortDescriptors = []
                apply(transaction.finalSnapshot, reorderingHandlers.animates ? .animated :  .withoutAnimation)
                selectItems(items)
                reorderingHandlers.didReorder?(transaction)
            }
            return true
        }
        if draggingInfo.draggingSource as? NSTableView !== tableView, canDrop {
            if dropOperation == .on, let didDropInto = droppingHandlers.didDropInto, let item = item(forRow: row) {
                didDropInto(draggingInfo.dropInfo(for: tableView), item)
                return true
            } else if dropOperation == .above {
                let dropInfo = draggingInfo.dropInfo(for: tableView)
                let items = droppingHandlers.items?(dropInfo) ?? []
                if !items.isEmpty {
                    let transaction = dropItemsTransaction(items, row: row)
                    droppingHandlers.willDrop?(dropInfo, transaction)
                    apply(transaction.finalSnapshot, droppingHandlers.animates ? .animated : .withoutAnimation)
                    selectItems(items)
                    droppingHandlers.didDrop?(dropInfo, transaction)
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: Dragging
    
    open func tableView(_ tableView: NSTableView, draggingSession: NSDraggingSession, willBeginAt _: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        
        draggingSession.animatesToStartingPositionsOnCancelOrFail = false
        if deletingHandlers.isDeletableByDraggingOutside, let itemsToDelete = deletingHandlers.canDelete?(rowIndexes.compactMap({item(forRow: $0)})), !itemsToDelete.isEmpty {
            dragDeleteItems = itemsToDelete
            let view = tableView.enclosingScrollView ?? tableView
            let width = view.bounds.width*0.3
            
            dragDeleteObservation = NSApplication.shared.observeChanges(for: \.currentEvent) { [weak self] _, event in
                guard let self = self else { return }
                if let event = NSEvent.current, event.type == .leftMouseDragged {
                    let distance = view.bounds.distance(from: event.location(in: view))
                    self.dragDistanceIsMatched = distance > width
                    let cursor: NSCursor = self.dragDistanceIsMatched ? .disappearingItem : .arrow
                    if NSCursor.current != cursor {
                        cursor.set()
                    }
                } else {
                    self.dragDeleteObservation = nil
                }
            }
        }
        
        if sectionHeaderCellProvider != nil, let canReorderSection = reorderingHandlers.canReorderSection, rowIndexes.count == 1, let row = rowIndexes.first, let section = section(forRow: row) {
            reorderingSectionRow = canReorderSection(section) ? row : nil
        } else {
            var items = rowIndexes.compactMap({item(forRow: $0)})
            canDragItems = draggingHandlers.canDrag?(items) ?? false
            items = reorderingHandlers.canReorder?(items) ?? (reorderingHandlers.droppable ? items : [])
            dragingRowIndexes = items.compactMap({row(for: $0)})
            if dragingRowIndexes.count == 1, let row = dragingRowIndexes.first, !tableView.allowsMultipleSelection, reorderingHandlers.reorderImmediately {
                immediatelyReorderRowView = tableView.rowView(atRow: row, makeIfNecessary: false)
                immediatelyReorderRowView?.alphaValue = 0.0
            }
        }
        draggingSession.draggingPasteboard.declareTypes([.string, .fileURL, .itemID, .png, .tiff], owner: nil)
    }
        
    open func tableView(_: NSTableView, draggingSession _: NSDraggingSession, endedAt location: NSPoint, operation _: NSDragOperation) {
        immediatelyReorderRowView?.alphaValue = 1.0
        immediatelyReorderRowView = nil
        if !dragDeleteItems.isEmpty, dragDistanceIsMatched {
            let transaction = currentSnapshot.deleteTransaction(dragDeleteItems)
            deletingHandlers.willDelete?(dragDeleteItems, transaction)
            apply(transaction.finalSnapshot, deletingHandlers.animates ? .animated : .withoutAnimation)
            deletingHandlers.didDelete?(dragDeleteItems, transaction)
            if NSCursor.current == NSCursor.disappearingItem {
                NSCursor.arrow.set()
            }
        }
        
        dragDeleteObservation = nil
        dragDistanceIsMatched = false
        dragDeleteItems = []
        dragingRowIndexes = []
        dropTargetRow = nil
        reorderingSectionRow = nil
        dropValidationRow = nil
        canDragItems = false
        canDrop = false
    }
    
    open func tableView(_: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if let item = item(forRow: row) {
            let pasteboardItem = NSPasteboardItem(for: item, content: draggingHandlers.pasteboardContent?(item))
            return pasteboardItem
        } else if reorderingHandlers.canReorderSection != nil, let section = section(forRow: row) {
            let pasteboardItem = NSPasteboardItem(for: section)
            return pasteboardItem
        }
        return nil
    }
    
    public func tableView(_ tableView: NSTableView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
        if canDrop, droppingHandlers.previewItems, let items = droppingHandlers.items?(draggingInfo.dropInfo(for: tableView)), !items.isEmpty, let image = previewImage(for: items) {
            Swift.print("DraggingItems", tableView.frame.size, image.size)
            draggingInfo.setDraggedImage(image)
        }
        /*
        guard !(draggingInfo.draggingSource as? NSTableView === tableView) else { return }
        if canDrop {
            droppingHandlers.updateDragItems?(draggingInfo.dropInfo(for: tableView))
           /// if droppingHandlers.
           // let items = droppingHandlers.items?(draggingInfo.draggingPasteboard.content) ?? []
        } else if canDragItems, let draggingImage = draggingHandlers.draggingImage {
            draggingInfo.enumerateDraggingItems(for: tableView, classes: [IdentifiablePasteboardItem.self], using: { draggingItem,_,_ in
                if let row = (draggingItem.item as? IdentifiablePasteboardItem)?.row, let item = self.item(forRow: row) {
                    if let image = draggingImage(item) {
                        draggingItem.imageComponentsProvider = {
                            return [.init(image: image.0, frame: image.1)]
                        }
                    }
                }
            })
        }
         */
    }
    
    open func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        columnHandlers.sortDescriptorsChanged?(oldDescriptors, tableView.sortDescriptors)

        if let transaction = sortTransaction() {
            reorderingHandlers.willReorder?(transaction)
            apply(transaction.finalSnapshot, .withoutAnimation)
            reorderingHandlers.didReorder?(transaction)
        }
    }
        
    // MARK: - Items
    
    /// All current items in the table view.
    open var items: [Item] { currentSnapshot.itemIdentifiers }
    
    /// The selected items.
    open var selectedItems: [Item] {
        get { tableView.selectedRowIndexes.compactMap { item(forRow: $0) } }
        set {
            guard newValue != selectedItems else { return }
            selectItems(newValue)
        }
    }
    
    /// Returns the item at the specified row in the table view.
    open func item(forRow row: Int) -> Item? {
        if let itemID = dataSource.itemIdentifier(forRow: row) {
            return items[id: itemID]
        }
        return nil
    }
    
    /// Returns the row for the specified item.
    open func row(for item: Item) -> Int? {
        dataSource.row(forItemIdentifier: item.id)
    }
    
    /**
     Returns the item of the specified point in the table view.
     
     - Parameter point: The point in in the table view.
     - Returns: The item at the point or `nil` if there isn't any item.
     */
    open func item(at point: CGPoint) -> Item? {
        let row = tableView.row(at: point)
        if row != -1 {
            return item(forRow: row)
        }
        return nil
    }
    
    func items(for location: CGPoint) -> [Item] {
        if let item = item(at: location) {
            var items: [Item] = [item]
            let selectedItems = selectedItems
            if selectedItems.contains(item) {
                items = selectedItems
            }
            return items
        }
        return []
    }
    
    /// Selects all specified items.
    open func selectItems(_ items: [Item], byExtendingSelection: Bool = false) {
        let rows = IndexSet(items.compactMap{row(for: $0)})
        tableView.selectRowIndexes(rows, byExtendingSelection: byExtendingSelection)
    }
    
    /// Deselects all specified items.
    open func deselectItems(_ items: [Item]) {
        items.compactMap{row(for: $0)}.forEach { tableView.deselectRow($0) }
    }
    
    /// Selects all items in the specified sections.
    open func selectItems(in sections: [Section], byExtendingSelection: Bool = false) {
        let sectionRows = sections.flatMap { rows(for: $0) }
        tableView.selectRowIndexes(IndexSet(sectionRows), byExtendingSelection: byExtendingSelection)
    }
    
    /// Deselects all items in the specified sections.
    open func deselectItems(in sections: [Section]) {
        let sectionRows = sections.flatMap { rows(for: $0) }
        sectionRows.forEach { tableView.deselectRow($0) }
    }
    
    /// Scrolls the table view to the specified item.
    open func scrollToItem(_ item: Item) {
        if let row = row(for: item) {
            tableView.scrollRowToVisible(row)
        }
    }
    
    /// Reloads the table row views and cells for the specified items.
    open func reloadItems(_ items: [Item], animated: Bool = false) {
        var snapshot = snapshot()
        snapshot.reloadItems(items)
        apply(snapshot, animated ? .animated : .withoutAnimation)
    }
    
    /// Updates the data for the specified items, preserving the existing table row views and cells for the items.
    open func reconfigureItems(_ items: [Item]) {
        let rows = IndexSet(items.compactMap { row(for: $0) })
        tableView.reconfigureRows(at: rows)
    }
    
    /**
     Updates the section header data for the specified sections.
     
     This method only updates section headers and not items of the section. It only works, if you provided ``sectionHeaderCellProvider-swift.property`` or section header registration using ``applySectionHeaderRegistration(_:)``.
     */
    open func reloadSectionHeaders(_ sections: [Section]) {
        guard sectionHeaderCellProvider != nil else { return }
        let rows = IndexSet(sections.compactMap { row(for: $0) })
        tableView.reloadData(forRowIndexes: rows, columnIndexes: IndexSet([0]))
    }
    
    /**
     Updates the section header data for the specified sections, preserving existing headers.

     This method only updates section headers and not items of the section. It only works, if you provided ``sectionHeaderCellProvider-swift.property`` or section header registration using ``applySectionHeaderRegistration(_:)``.
     */
    open func reconfigureSectionHeaders(_ sections: [Section]) {
        guard sectionHeaderCellProvider != nil else { return }
        let rows = IndexSet(sections.compactMap { row(for: $0) })
        tableView.reconfigureRows(at: rows)

    }
    
    /// The items that are visible.
    open var visibleItems: [Item] {
        tableView.visibleRowIndexes().compactMap { item(forRow: $0) }
    }
    
    func rowView(for item: Item) -> NSTableRowView? {
        if let row = row(for: item) {
            return tableView.rowView(atRow: row, makeIfNecessary: false)
        }
        return nil
    }
    
    // MARK: - Sections
    
    /// All current sections in the table view.
    open var sections: [Section] { currentSnapshot.sectionIdentifiers }
    
    /// Returns the row for the specified section.
    open func row(for section: Section) -> Int? {
        dataSource.row(forSectionIdentifier: section.id)
    }
    
    /// Returns the section at the specified row in the table view.
    func section(forRow row: Int) -> Section? {
        if let sectionID = dataSource.sectionIdentifier(forRow: row) {
            return sections[id: sectionID]
        }
        return nil
    }
    
    func section(for item: Item) -> Section? {
        currentSnapshot.sectionIdentifier(containingItem: item)
    }

    /// Scrolls the table view to the specified section.
    open func scrollToSection(_ section: Section) {
        if let row = row(for: section) {
            tableView.scrollRowToVisible(row)
        }
    }

    func rows(for section: Section) -> [Int] {
        let items = currentSnapshot.itemIdentifiers(inSection: section)
        return items.compactMap({row(for: $0)})
    }
    
    // MARK: - Transactions
    
    func moveItemsTransaction(_ items: [Item], to row: Int) -> DiffableDataSourceTransaction<Section, Item> {
        var newSnapshot = snapshot()
        if let item = item(forRow: row) {
            newSnapshot.insertItemsSaftly(items, beforeItem: item)
        } else if let item = item(forRow: row - 1) {
            newSnapshot.insertItemsSaftly(items, afterItem: item)
        } else if let section = self.section(forRow: row - 1) {
            newSnapshot.appendItems(items, toSection: section)
        } else if let section = self.section(forRow: row) {
            newSnapshot.appendItems(items, toSection: section)
        } else if let section = sections.last {
            newSnapshot.appendItems(items, toSection: section)
        }
        return DiffableDataSourceTransaction(initial: currentSnapshot, final: newSnapshot)
    }
    
    func moveSectionTransaction(to row: Int) -> DiffableDataSourceTransaction<Section, Item>? {
        guard let sectionRow = reorderingSectionRow, let _section = section(forRow: sectionRow) else { return nil }
        if let index = sectionRowIndexes.firstIndex(of: row), let section = sections[safe: index-1], section != _section {
            return currentSnapshot.moveTransaction(_section, after: section)
        } else if row == 0, let section = sections.first {
            return currentSnapshot.moveTransaction(_section, before: section)
        } else if row == tableView.numberOfRows, let section = sections.last {
            return currentSnapshot.moveTransaction(_section, after: section)
        }
        return nil
    }
    
    func dropItemsTransaction(_ items: [Item], row: Int) -> DiffableDataSourceTransaction<Section, Item> {
        var snapshot = currentSnapshot
        if let item = item(forRow: row) {
            snapshot.insertItems(items, beforeItem: item)
        } else if let section = section(forRow: row) {
            if let item = item(forRow: row - 1) {
                snapshot.insertItems(items, afterItem: item)
            } else {
                snapshot.appendItems(items, toSection: section)
            }
        } else if let section = sections.last {
            snapshot.appendItems(items, toSection: section)
        }
        return DiffableDataSourceTransaction(initial: currentSnapshot, final: snapshot)
    }
    
    func sortTransaction(snapshot: NSDiffableDataSourceSnapshot<Section, Item>? = nil) -> DiffableDataSourceTransaction<Section, Item>? {
        guard let sortDescriptor = tableView.sortDescriptors.first as? ItemSortDescriptor else { return nil }
        let snapshot = snapshot ?? currentSnapshot
        var newSnapshot = emptySnapshot()
        var sortingChanged = false
        newSnapshot.appendSections(sections)
        for section in snapshot.sectionIdentifiers {
            let items = snapshot.itemIdentifiers(inSection: section)
            let sorted = items.sorted(by: sortDescriptor.comparators)
            newSnapshot.appendItems(sorted, toSection: section)
            if !sortingChanged, items != sorted {
                sortingChanged = true
            }
        }
        guard sortingChanged else { return nil }
        return .init(initial: currentSnapshot, final: newSnapshot)
    }
    
    // MARK: - Empty Collection View
    
    /**
     The view that is displayed when the datasource doesn't contain any items.
     
     When using this property, ``emptyContentConfiguration`` is set to `nil`.
     */
    open var emptyView: NSView? {
        get { emptyContentView?.view }
        set {
            if let newValue = newValue {
                if let emptyContentView = emptyContentView {
                    emptyContentView.view = newValue
                } else {
                    emptyContentView = EmptyView(view: newValue)
                }
                updateEmptyView()
            } else {
                emptyContentView?.removeFromSuperview()
                emptyContentView = nil
            }
        }
    }
    
    /**
     The content configuration that content view is displayed when the datasource doesn't contain any items.
     
     When using this property, ``emptyView`` is set to `nil`.
     */
    open var emptyContentConfiguration: NSContentConfiguration? {
        get { emptyContentView?.configuration }
        set {
            if let configuration = newValue {
                if let emptyContentView = emptyContentView {
                    emptyContentView.configuration = configuration
                } else {
                    emptyContentView = EmptyView(configuration: configuration)
                }
                updateEmptyView()
            } else {
                emptyContentView?.removeFromSuperview()
                emptyContentView = nil
            }
        }
    }
    
    var emptyContentView: EmptyView?

    /**
     The handler that gets called when the data source switches between an empty and non-empty snapshot or viceversa.
          
     You can use this handler e.g. if you want to update your empty content configuration or view.
     
     - Parameter isEmpty: A Boolean value indicating whether the current snapshot is empty.
     */
    open var emptyHandler: ((_ isEmpty: Bool)->())? {
        didSet {
            emptyHandler?(currentSnapshot.isEmpty)
        }
    }
        
    func updateEmptyView(previousIsEmpty: Bool? = nil) {
        if currentSnapshot.numberOfItems != 0 {
            emptyView?.removeFromSuperview()
            emptyContentView?.removeFromSuperview()
        } else if let emptyContentView = emptyContentView, emptyContentView.superview != tableView {
            tableView.addSubview(withConstraint: emptyContentView)
        }
        if let emptyHandler = self.emptyHandler, let previousIsEmpty = previousIsEmpty {
            if previousIsEmpty != currentSnapshot.isEmpty {
                emptyHandler(currentSnapshot.isEmpty)
            }
        }
     }


    // MARK: - Handlers

    /// The handlers for selecting items.
    open var selectionHandlers = SelectionHandlers()

    /**
     The handlers for deleting items.
     
     Provide ``DeletingHandlers-swift.struct/canDelete`` to support the deleting of items in your table view.
     
     The system calls the ``DeletingHandlers-swift.struct/didDelete`` handler after a deleting transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
     ```swift
     // Allow every item to be deleted
     dataSource.deletingHandlers.canDelete = { items in return items }
     
     // Option 1: Update the backing store from a CollectionDifference
     dataSource.deletingHandlers.didDelete = { [weak self] items, transaction in
         guard let self = self else { return }
         
         if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
             self.backingStore = updatedBackingStore
         }
     }

     // Option 2: Update the backing store from the final items
     dataSource.deletingHandlers.didDelete = { [weak self] items, transaction in
         guard let self = self else { return }
         
         self.backingStore = transaction.finalSnapshot.itemIdentifiers
     }
     ```
     */
    open var deletingHandlers = DeletingHandlers() {
        didSet { setupKeyDownMonitor() }
    }

    /**
     The handlers for reordering items.
     
     Provide ``ReorderingHandlers-swift.struct/canReorder`` to support the reordering of items in your table view.
     
     The system calls the ``ReorderingHandlers-swift.struct/didReorder`` handler after a reordering transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
     ```swift
     // Allow every item to be reordered
     dataSource.reorderingHandlers.canReorder = { items in return true }

     // Option 1: Update the backing store from a CollectionDifference
     dataSource.reorderingHandlers.didDelete = { [weak self] items, transaction in
         guard let self = self else { return }
         
         if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
             self.backingStore = updatedBackingStore
         }
     }
     
     // Option 1: Update the backing store from a CollectionDifference
     dataSource.reorderingHandlers.didDelete = { [weak self] items, transaction in
         guard let self = self else { return }
         
         if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
             self.backingStore = updatedBackingStore
         }
     }
     
     // Option 2: Update the backing store from the final items
     dataSource.reorderingHandlers.didReorder = { [weak self] items, transaction in
         guard let self = self else { return }
         
         self.backingStore = transaction.finalSnapshot.itemIdentifiers
     }
     ```
     */
    open var reorderingHandlers = ReorderingHandlers()

    /// The handlers for hovering items with the mouse.
    open var hoverHandlers = HoverHandlers() {
        didSet { setupHoverObserving() }
    }

    /// The handlers for table columns.
    open var columnHandlers = ColumnHandlers()
    
    /// The handlers for dropping items inside the table view.
    public var droppingHandlers = DroppingHandlers()
    
    /// The handlers for dragging elements outside the table view.
    public var draggingHandlers = DraggingHandlers()

    /// Handlers for selecting items.
    public struct SelectionHandlers {
        /// The handler that determines which items should get selected. The default value is `nil` which indicates that all items should get selected.
        public var shouldSelect: (([Item]) -> [Item])?

        /// The handler that gets called whenever items get selected.
        public var didSelect: (([Item]) -> Void)?

        /// The handler that determines which items should get deselected. The default value is `nil` which indicates that all items should get deselected.
        public var shouldDeselect: (([Item]) -> [Item])?

        /// The handler that gets called whenever items get deselected.
        public var didDeselect: (([Item]) -> Void)?
    }

    /**
     Handlers for reordering items.
     
     Take a look at ``reorderingHandlers-swift.property`` how to support reordering items.
     */
    public struct ReorderingHandlers {
        /// The handler that determines if items can be reordered. The default value is `nil` which indicates that items can't be reordered.
        public var canReorder: ((_ items: [Item]) -> [Item])?
        
        /// The handler that determines if a section can be reordered. The default value is `nil` which indicates that sections can't be reordered.
        public var canReorderSection: ((_ section: Section) -> Bool)?

        /// The handler that that gets called before reordering items.
        public var willReorder: ((_ transaction: DiffableDataSourceTransaction<Section, Item>) -> Void)?

        /**
         The handler that that gets called after reordering items.

         The system calls the `didReorder` handler after a reordering transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
         
         ```swift
         // Allow every item to be reordered
         dataSource.reorderingHandlers.canDelete = { items in return true }

         // Option 1: Update the backing store from a CollectionDifference
         dataSource.reorderingHandlers.didDelete = { [weak self] items, transaction in
             guard let self = self else { return }
             
             if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
                 self.backingStore = updatedBackingStore
             }
         }

         // Option 2: Update the backing store from the final items
         dataSource.reorderingHandlers.didReorder = { [weak self] items, transaction in
             guard let self = self else { return }
             
             self.backingStore = transaction.finalSnapshot.itemIdentifiers
         }
         ```
         */
        public var didReorder: ((_ transaction: DiffableDataSourceTransaction<Section, Item>) -> Void)?
        
        /**
         The handler that determines if items can be dropped to another item while reordering. The default value is `nil` which indicates that items can't be inserted.
         
         To enable dropping of items to another item while reordering, you also have  to provide ``didDrop``.
         */
        public var canDrop: ((_ items: [Item], _ target: Item) -> Bool)?
        
        /// The handler that that gets called before dropping items to another item.
        public var willDrop: ((_ items: [Item], _ target: Item, _ transaction: DiffableDataSourceTransaction<Section, Item>) -> Void)?
        
        /// The handler that that gets called after dropping items.
        public var didDrop: ((_ items: [Item], _ target: Item, _ transaction: DiffableDataSourceTransaction<Section, Item>) -> ())?
        
        /// A Boolean value that indicates whether reordering items is animated.
        public var animates: Bool = false
        
        var droppable: Bool {
            canDrop != nil && didDrop != nil
        }
        
        /// A Boolean value that indicates whether rows reorder immediately while the user drags them.
        var reorderImmediately: Bool = true
    }

    /**
     Handlers for deleting items.
     
     Take a look at ``deletingHandlers-swift.property`` how to support deleting items.
     */
    public struct DeletingHandlers {
        /// The handler that determines which items can be be deleted. The default value is `nil`, which indicates that all items can be deleted.
        public var canDelete: ((_ items: [Item]) -> [Item])?

        /// The handler that that gets called before deleting items.
        public var willDelete: ((_ items: [Item], _ transaction: DiffableDataSourceTransaction<Section, Item>) -> Void)?

        /**
         The handler that that gets called after deleting items.
         
         The system calls the `didDelete` handler after a deleting transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
         
         ```swift
         // Allow every item to be deleted
         dataSource.deletingHandlers.canDelete = { items in return items }

         // Option 1: Update the backing store from a CollectionDifference
         dataSource.deletingHandlers.didDelete = { [weak self] items, transaction in
             guard let self = self else { return }
             
             if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
                 self.backingStore = updatedBackingStore
             }
         }

         // Option 2: Update the backing store from the final items
         dataSource.deletingHandlers.didReorder = { [weak self] items, transaction in
             guard let self = self else { return }
             
             self.backingStore = transaction.finalSnapshot.itemIdentifiers
         }
         ```
         */
        public var didDelete: ((_ items: [Item], _ transaction: DiffableDataSourceTransaction<Section, Item>) -> Void)?
        
        /**
         A Boolean value that indicates whether items can be deleted by dragging them outside the table view.
         
         - Note: You still need to provide the items that can be deleted using ``canDelete``.
         */
        public var isDeletableByDraggingOutside = false
        
        /// A Boolean value that indicates whether deleting items is animated.
        public var animates: Bool = true
    }

    /// Handlers for hovering items with the mouse.
    public struct HoverHandlers {
        /// The handler that gets called whenever the mouse is hovering an item.
        public var isHovering: ((Item) -> Void)?

        /// The handler that gets called whenever the mouse did end hovering an item.
        public var didEndHovering: ((Item) -> Void)?

        var shouldSetup: Bool {
            isHovering != nil || didEndHovering != nil
        }
    }

    /// Handlers for table view columns.
    public struct ColumnHandlers {
        /// The handler that gets called whenever the  mouse button was clicked in the specified table column, but the column was not dragged.
        public var didClick: ((_ column: NSTableColumn) -> Void)?
        
        /// The handler that gets called whenever the mouse button was clicked in the specified table column’s header.
        public var didClickHeader: ((_ column: NSTableColumn) -> Void)?
        
        /// The handler that gets called whenever a column did resize.
        public var didResize: ((_ column: NSTableColumn, _ oldWidth: CGFloat) -> Void)?

        /// The handler that determines whenever a column can be reordered to a new index.
        public var shouldReorder: ((_ column: NSTableColumn, _ newIndex: Int) -> Bool)?

        /// The handler that gets called whenever a column did reorder.
        public var didReorder: ((_ column: NSTableColumn, _ oldIndex: Int, _ newIndex: Int) -> Void)?
        
        /// The handler that determines whenever the user can change the given column’s visibility.
        public var userCanChangeVisibility: ((_ column: NSTableColumn) -> Bool)?
        
        /// The handler that gets called whenever the user did change the visibility of the given columns.
        public var userDidChangeVisibility: ((_ columns: [NSTableColumn]) -> Void)?
        
        /// The handler that gets called whenever the sort descriptors of the columns changed.
        public var sortDescriptorsChanged: ((_ old: [NSSortDescriptor], _ new: [NSSortDescriptor]) -> Void)?

    }
    
    /// Handlers for dragging items outside the table view.
    public struct DraggingHandlers {
        /// The handler that determines whenever items can be dragged outside the table view.
        public var canDrag: ((_ items: [Item])->(Bool))?
        /// The handler that gets called when the handler did drag items outside the table view.
        public var didDrag: ((_ items: [Item]) -> ())?
        /// The handler that provides the pasteboard content for an item that can be dragged outside the table view.
        public var pasteboardContent: ((_ item: Item)->([PasteboardWriting]))?
        /// The handler that determines the image when dragging elements outside the table view.
        public var draggingImage: ((_ item: Item) -> (NSImage, CGRect?)?)?
    }
    
    /// Handlers for dropping items inside the table view.
    public struct DroppingHandlers {
        /**
         The handler that determines whether the pasteboard content can be dropped to the collection view.
         
         - Parameter dropInfo: The information about the proposed drop.
         */
        public var canDrop: ((_ dropInfo: DropInfo) -> Bool)?
        
        /// The handler that determinates the items for the proposed drop.
        public var items: ((_ dropInfo: DropInfo) -> ([Item]))?
        
        /**
         The handler that gets called when pasteboard content is about to drop inside the collection view.
         
         - Parameters:
            - dropInfo: The information about the drop.
            - transaction: The transaction for the drop.
         */
        public var willDrop: ((_ dropInfo: DropInfo, _ transaction: DiffableDataSourceTransaction<Section, Item>) -> ())?
        
        /**
         The handler that gets called when pasteboard content was dropped inside the collection view.
         
         - Parameters:
            - dropInfo: The information about the drop.
            - transaction: The transaction for the drop.
         */
        public var didDrop: ((_ dropInfo: DropInfo, _ transaction: DiffableDataSourceTransaction<Section, Item>) -> ())?
        
        public var updateDragItems: ((_ dropInfo: DropInfo)->())?

        /// The handler that determines whether the proposed drop can be dropped to an item.
        public var canDropInto: ((_ dropInfo: DropInfo, _ item: Item) -> Bool)?
        
        /// The handler that gets called when pasteboard content is dropped to an item.
        public var didDropInto: ((_ dropInfo: DropInfo, _ item: Item)->())?
        
        /// A Boolean value that indicates whether new items are inserted animated.
        public var animates: Bool = true
        
        /// A Boolean value that indicates whether the rows for the proposed drop items are previewed.
        public var previewItems = false
        
        var isDroppableInto: Bool {
            canDropInto != nil && didDropInto != nil
        }
    }
}

// MARK: - Quicklook

extension TableViewDiffableDataSource where Item: QuicklookPreviewable {
    /**
     A Boolean value that indicates whether the user can open a quicklook preview of selected items by pressing space bar.
     
     Any item conforming to `QuicklookPreviewable` can be previewed by providing a preview file url.
     */
    public var isQuicklookPreviewable: Bool {
        get { tableView.isQuicklookPreviewable }
        set { tableView.isQuicklookPreviewable = newValue }
    }

    /**
     Opens `QuicklookPanel` that presents quicklook previews of the specified items.

     To quicklook the selected items, use table view's `quicklookSelectedRows()`.

     - Parameters:
        - items: The items to preview.
        - current: The item that starts the preview. The default value is `nil`.
     */
    public func quicklookItems(_ items: [Item], current: Item? = nil) {
        let rows = items.compactMap { row(for: $0) }
        if let current = current, let currentRow = row(for: current) {
            tableView.quicklookRows(at: rows, current: currentRow)
        } else {
            tableView.quicklookRows(at: rows)
        }
    }
}

extension TableViewDiffableDataSource: NSTableViewQuicklookProvider {
    public func tableView(_: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable? {
        if let item = item(forRow: row), let rowView = rowView(for: item) {
            if let previewable = item as? QuicklookPreviewable {
                return QuicklookPreviewItem(previewable, view: rowView)
            } else if let previewable = rowView.cellViews.compactMap(\.quicklookPreview).first {
                return QuicklookPreviewItem(previewable, view: rowView)
            }
        }
        return nil
    }
}

extension TableViewDiffableDataSource {
    /**
     Sets the specified item sort comperator to the table column.
     
     - Parameters:
        - comparator: The item sorting comperator, or `nil` to remove any sorting comperators from the table column.
        - tableColumn: The table column.
     */
    public func setSortComparator(_ comparator: SortingComparator<Item>?, forColumn tableColumn: NSTableColumn, activate: Bool = false) {
        if activate, comparator != nil, let key = tableColumn.sortDescriptorPrototype?.key {
            tableView.sortDescriptors.removeAll(where: { $0.key == key })
        }
        if let comparator = comparator {
            tableColumn.sortDescriptorPrototype = ItemSortDescriptor([comparator])
            if activate {
                tableView.sortDescriptors = [tableColumn.sortDescriptorPrototype!] + tableView.sortDescriptors
            }
        } else if tableColumn.sortDescriptorPrototype is ItemSortDescriptor {
            tableColumn.sortDescriptorPrototype = nil
        }
    }
    
    /**
     Sets the specified item sort comperators to the table column.
     
     - Parameters:
        - comparators: The item sorting comperators.
        - tableColumn: The table column.
     */
    public func setSortComparators(_ comparators: [SortingComparator<Item>], forColumn tableColumn: NSTableColumn, activate: Bool = false) {
        if activate, !comparators.isEmpty, let key = tableColumn.sortDescriptorPrototype?.key {
            tableView.sortDescriptors.removeAll(where: { $0.key == key })
        }
        if comparators.isEmpty {
            setSortComparator(nil, forColumn: tableColumn)
        } else {
            tableColumn.sortDescriptorPrototype = ItemSortDescriptor(comparators)
            if activate {
                tableView.sortDescriptors = [tableColumn.sortDescriptorPrototype!] + tableView.sortDescriptors
            }
        }
    }
    
    class ItemSortDescriptor: NSSortDescriptor {
        
        var comparators: [SortingComparator<Item>] = []
        
        init(_ comparators: [SortingComparator<Item>], ascending: Bool = true, key: String? = nil) {
            super.init(key: key ?? UUID().uuidString, ascending: ascending, selector: nil)
            self.comparators = comparators
        }
        
        override var reversedSortDescriptor: Any {
            var comparators = comparators
            comparators.editEach({$0.order.toggle() })
            return ItemSortDescriptor(comparators, ascending: !ascending, key: key)
        }
        
        override func copy() -> Any {
            ItemSortDescriptor(comparators, ascending: ascending, key: key)
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? ItemSortDescriptor else { return false }
            return object.key == key && object.ascending == ascending && object.comparators == comparators
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}


extension CGRect {
    func distance(from point: CGPoint) -> CGFloat {
        if contains(point) {
          return 0
        }
        let dx = max(0, max(origin.x - point.x, point.x - maxX))
        let dy = max(0, max(origin.y - point.y, point.y - maxY))
        return sqrt(dx * dx + dy * dy)
    }
}
