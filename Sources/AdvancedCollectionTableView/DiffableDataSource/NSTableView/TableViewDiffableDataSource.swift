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
    let tableView: NSTableView
    var dataSource: NSTableViewDiffableDataSource<Section.ID, Item.ID>!
    var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    var dragingRowIndexes = IndexSet()
    var sectionRowIndexes: [Int] = []
    var keyDownMonitor: NSEvent.Monitor?
    var rightDownMonitor: NSEvent.Monitor?
    var hoveredRowObserver: NSKeyValueObservation?
    var delegateBridge: DelegateBridge!
    
    /// The closure that configures and returns the table view’s row views from the diffable data source.
    open var rowViewProvider: RowViewProvider? {
        didSet {
            if let rowViewProvider = rowViewProvider {
                dataSource.rowViewProvider = { tableview, row, identifier in
                    let item = self.currentSnapshot.itemIdentifiers[id: identifier as! Item.ID]!
                    return rowViewProvider(tableview, row, item)
                }
            } else {
                dataSource.rowViewProvider = nil
            }
        }
    }
    
    /// A closure that configures and returns a row view for a table view from its diffable data source.
    public typealias RowViewProvider = (_ tableView: NSTableView, _ row: Int, _ identifier: Item) -> NSTableRowView
    
    /// Applies the row view registration to configure and return table row views.
    open func applyRowViewRegistration<Row: NSTableRowView>(_ registration: NSTableView.RowRegistration<Row, Item>) {
        rowViewProvider = { tableView, row, item in
            registration.makeView(tableView, row, item)
        }
    }
    
    /// The closure that configures and returns the table view’s section header views from the diffable data source.
    open var sectionHeaderViewProvider: SectionHeaderViewProvider? {
        didSet {
            if let sectionHeaderViewProvider = sectionHeaderViewProvider {
                dataSource.sectionHeaderViewProvider = { tableView, row, sectionID in
                    sectionHeaderViewProvider(tableView, row, self.sections[id: sectionID]!)
                }
            } else {
                dataSource.sectionHeaderViewProvider = nil
            }
        }
    }
    
    /// A closure that configures and returns a section header view for a table view from its diffable data source.
    public typealias SectionHeaderViewProvider = (_ tableView: NSTableView, _ row: Int, _ section: Section) -> NSTableSectionHeaderView
    
    /// Applies the section header view registration to configure and return section header views.
    open func applySectionHeaderViewRegistration<HeaderView: NSTableSectionHeaderView>(_ registration: NSTableView.SectionHeaderRegistration<HeaderView, Section>) {
        sectionHeaderViewProvider = { tableView, row, section in
            registration.makeView(tableView, row, section)
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
        didSet { setupRightDownMonitor() }
    }
    
    /**
     The handler that gets called when the user right-clicks the table view.

     `items` provides:
     - if right-click on a **selected item**, all selected items,
     - else if right-click on a **non-selected item**, that item,
     - else an empty array.
     */
    open var rightClickHandler: ((_ items: [Item]) -> ())? = nil {
        didSet { setupRightDownMonitor() }
    }
    
    /// Provides an array of row actions to be attached to the specified edge of a table row and displayed when the user swipes horizontally across the row.
    open var rowActionProvider: ((_ item: Item, _ edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction])? = nil
    
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
    
    func setupRightDownMonitor() {
        if (menuProvider != nil || rightClickHandler != nil), rightDownMonitor == nil {
            rightDownMonitor = NSEvent.localMonitor(for: [.rightMouseDown]) { event in
                self.tableView.menu = nil
                if let contentView = self.tableView.window?.contentView {
                    let location = event.location(in: contentView)
                    if let view = contentView.hitTest(location), view.isDescendant(of: self.tableView) {
                        let location = event.location(in: self.tableView)
                        if self.tableView.bounds.contains(location) {
                            self.setupMenu(for: location)
                            self.setupRightClick(for: location)
                        }
                    }
                }
                return event
            }
        } else if menuProvider == nil && rightClickHandler == nil {
            rightDownMonitor = nil
        }
    }
    
    func setupRightClick(for location: CGPoint) {
        guard let rightClick = rightClickHandler else { return }
        if let item = item(at: location) {
            var items: [Item] = [item]
            let selectedItems = selectedItems
            if selectedItems.contains(item) {
                items = selectedItems
            }
            rightClick(items)
        } else {
            rightClick([])
        }
    }
    
    func setupMenu(for location: CGPoint) {
        if let menuProvider = menuProvider {
            if let item = item(at: location) {
                var items: [Item] = [item]
                let selectedItems = selectedItems
                if selectedItems.contains(item) {
                    items = selectedItems
                }
                tableView.menu = menuProvider(items)
            } else {
                tableView.menu = menuProvider([])
            }
        }
    }
    
    func setupHoverObserving() {
        if hoverHandlers.shouldSetup {
            tableView.setupObservation()
            if hoveredRowObserver == nil {
                hoveredRowObserver = tableView.observeChanges(for: \.hoveredRow, handler: { old, new in
                    guard old != new else { return }
                    if let didEndHovering = self.hoverHandlers.didEndHovering, let oldRow = old?.item {
                        if oldRow != -1, let item = self.item(forRow: oldRow) {
                            didEndHovering(item)
                        }
                    }
                    if let isHovering = self.hoverHandlers.isHovering, let newRow = new?.item {
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
    
    func setupKeyDownMonitor() {
        if let canDelete = deletingHandlers.canDelete {
            keyDownMonitor = NSEvent.localMonitor(for: .keyDown) { [weak self] event in
                guard let self = self, self.tableView.isFirstResponder else { return event }
                if event.keyCode == 51 {
                    let itemsToDelete = canDelete(self.selectedItems)
                    if itemsToDelete.isEmpty == false {
                        var section: Section? = nil
                        var selectionItem: Item? = nil
                        if let item = itemsToDelete.first {
                            if let row = row(for: item), self.section(forRow: row - 1) == nil, let item = self.item(forRow: row - 1), !itemsToDelete.contains(item) {
                                selectionItem = item
                            } else {
                                section = self.section(for: item)
                            }
                        }
                        let transaction = self.deletingTransaction(itemsToDelete)
                        self.deletingHandlers.willDelete?(itemsToDelete, transaction)
                        if QuicklookPanel.shared.isVisible {
                            QuicklookPanel.shared.close()
                        }
                        self.apply(transaction.finalSnapshot, .animated)
                        deletingHandlers.didDelete?(itemsToDelete, transaction)
                        
                        if tableView.allowsEmptySelection == false, tableView.selectedRowIndexes.isEmpty {
                            var selectionRow: Int? = nil
                            if let item = selectionItem, let row = row(for: item) {
                                selectionRow = row
                            } else if let section = section, let item = items(for: section).first, let row = row(for: item) {
                                selectionRow = row
                            } else if let item = currentSnapshot.itemIdentifiers.first,  let row = row(for: item) {
                                selectionRow = row
                            }
                            if let row = selectionRow {
                                tableView.selectRowIndexes([row], byExtendingSelection: false)
                            }
                        }
                        
                        return nil
                    }
                }
                return event
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
     - completion: An optional completion handler which gets called after applying the snapshot.
     */
    open func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>, _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        let internalSnapshot = snapshot.toIdentifiableSnapshot()
        currentSnapshot = snapshot
        updateSectionRowIndexes()
        dataSource.apply(internalSnapshot, option, completion: completion)
    }
    
    func updateSectionRowIndexes() {
        sectionRowIndexes.removeAll()
        guard sectionHeaderViewProvider != nil else { return }
        var row = 0
        for section in sections {
            sectionRowIndexes.append(row)
            row = row + 1 + currentSnapshot.numberOfItems(inSection: section)
        }
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
     - cellRegistration: A rell registration which returns each of the cells for the table view from the data the diffable data source provides.
     */
    public convenience init<Cell: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<Cell, Item>) {
        self.init(tableView: tableView, cellProvider: {
            _tableView, column, row, item in
            _tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, item: item)!
        })
    }
    
    /**
     Creates a diffable data source with the specified cell registrations, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellRegistrations: cellRegistrations)
     ```
     
     - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistrations: Cell registratiosn which returns each of the cells for the table view from the data the diffable data source provides.
     */
    public convenience init(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration]) {
        self.init(tableView: tableView, cellProvider: {
            _, column, row, item in
            if let cellRegistration = cellRegistrations.first(where: { $0.columnIdentifiers?.contains(column.identifier) == true }) ?? cellRegistrations.first(where: { $0.columnIdentifiers == nil }) {
                return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, item)!
            }
            return NSTableCellView()
        })
    }
    
    /**
     Creates a diffable data source with the specified cell provider, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a item provider, where you configure each of your cells to determine how to display your data in the UI.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, itemProvider: {
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
        
        dataSource = .init(tableView: self.tableView, cellProvider: {
            [weak self] tableview, tablecolumn, row, itemID in
            guard let self = self, let item = self.items[id: itemID] else { return NSTableCellView() }
            return cellProvider(tableview, tablecolumn, row, item)
        })
        
        delegateBridge = DelegateBridge(self)
        tableView.registerForDraggedTypes([.itemID])
        // tableView.setDraggingSourceOperationMask(.move, forLocal: true)
        // tableView.setDraggingSourceOperationMask(.move, forLocal: true)
        tableView.isQuicklookPreviewable = Item.self is QuicklookPreviewable.Type
    }
    
    /// A closure that configures and returns a cell view for a table view from its diffable data source.
    public typealias CellProvider = (_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ identifier: Item) -> NSView
    
    // MARK: - DataSource conformance
    
    open func numberOfRows(in tableView: NSTableView) -> Int {
        dataSource.numberOfRows(in: tableView)
    }
    
    open func tableView(_: NSTableView, acceptDrop _: NSDraggingInfo, row: Int, dropOperation _: NSTableView.DropOperation) -> Bool {
        if dragingRowIndexes.isEmpty == false {
            if let transaction = movingTransaction(at: dragingRowIndexes, to: row) {
                let selectedItems = selectedItems
                reorderingHandlers.willReorder?(transaction)
                apply(transaction.finalSnapshot, .withoutAnimation)
                selectItems(selectedItems)
                reorderingHandlers.didReorder?(transaction)
            } else {
                return false
            }
        }
        return true
    }
    
    open func tableView(_: NSTableView, validateDrop _: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        guard dragingRowIndexes.isEmpty == false, dropOperation == .above else { return [] }
        
        if row >= (sectionHeaderViewProvider != nil ? 1 : 0) {
            return .move
        }
        
        return []
    }
    
    open func tableView(_: NSTableView, draggingSession _: NSDraggingSession, willBeginAt _: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        let items = dragingRowIndexes.compactMap({item(forRow: $0)})
        if reorderingHandlers.canReorder?(items) == true {
            dragingRowIndexes = rowIndexes
        } else {
            dragingRowIndexes.removeAll()
        }
    }
    
    open func tableView(_: NSTableView, draggingSession _: NSDraggingSession, endedAt _: NSPoint, operation _: NSDragOperation) {
        dragingRowIndexes.removeAll()
    }
    
    open func tableView(_: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if let itemId = item(forRow: row)?.id.hashValue {
            let pasteboardItem = NSPasteboardItem()
            pasteboardItem.setString(String(itemId), forType: .itemID)
            return pasteboardItem
        }
        return nil
    }
    
    // MARK: - Items
    
    /// All current items in the table view.
    open var items: [Item] { currentSnapshot.itemIdentifiers }
    
    /// The selected items.
    open var selectedItems: [Item] {
        tableView.selectedRowIndexes.compactMap { item(forRow: $0) }
    }
    
    /**
     Returns the item at the specified row in the table view.
     
     - Parameter row: The row of the item in the table view.
     - Returns: The item, or `nil` if the method doesn’t find an item at the provided row.
     */
    open func item(forRow row: Int) -> Item? {
        if let itemID = dataSource.itemIdentifier(forRow: row) {
            return items[id: itemID]
        }
        return nil
    }
    
    func items(for section: Section) -> [Item] {
        currentSnapshot.itemIdentifiers(inSection: section)
    }
    
    /// Returns the row for the specified item.
    open func row(for item: Item) -> Int? {
        dataSource.row(forItemIdentifier: item.id)
    }
    
    /**
     Returns the item of the specified index path.
     
     - Parameter indexPath: The indexPath
     - Returns: The item at the index path or nil if there isn't any item at the index path.
     */
    open func item(at point: CGPoint) -> Item? {
        let row = tableView.row(at: point)
        if row != -1 {
            return item(forRow: row)
        }
        return nil
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
    
    /// Reloads the table view cells for the specified items.
    open func reloadItems(_ items: [Item], animated: Bool = false) {
        var snapshot = snapshot()
        snapshot.reloadItems(items)
        apply(snapshot, animated ? .animated : .withoutAnimation)
    }
    
    /// Updates the data for the specified items, preserving the existing table view cells for the items.
    open func reconfigureItems(_ items: [Item]) {
        let rows = IndexSet(items.compactMap { row(for: $0) })
        tableView.reconfigureRows(at: rows)
    }
    
    /// An array of items that are visible.
    func visibleItems() -> [Item] {
        tableView.visibleRowIndexes().compactMap { item(forRow: $0) }
    }
    
    func rowView(for item: Item) -> NSTableRowView? {
        if let row = row(for: item) {
            return tableView.rowView(atRow: row, makeIfNecessary: false)
        }
        return nil
    }
    
    func isSelected(at row: Int) -> Bool {
        tableView.selectedRowIndexes.contains(row)
    }
    
    func isSelected(for item: Item) -> Bool {
        if let row = row(for: item) {
            return isSelected(at: row)
        }
        return false
    }
    
    @discardableResult
    func removeItems(_ items: [Item]) -> DiffableDataSourceTransaction<Section, Item> {
        deletingTransaction(items)
    }
    
    func deletingTransaction(_ deletionItems: [Item]) -> DiffableDataSourceTransaction<Section, Item> {
        var newNnapshot = snapshot()
        newNnapshot.deleteItems(deletionItems)
        return DiffableDataSourceTransaction(initial: currentSnapshot, final: newNnapshot)
    }
    
    func movingTransaction(at rowIndexes: IndexSet, to row: Int) -> DiffableDataSourceTransaction<Section, Item>? {
        var newSnapshot = snapshot()
        let newItems = rowIndexes.compactMap { item(forRow: $0) }
        if let item = item(forRow: row) {
            newSnapshot.insertItems(newItems, beforeItem: item)
        } else if let section = section(forRow: row) {
            if let item = item(forRow: row - 1) {
                newSnapshot.insertItems(newItems, afterItem: item)
            } else {
                newSnapshot.appendItems(newItems, toSection: section)
            }
        } else if let section = sections.last {
            newSnapshot.appendItems(newItems, toSection: section)
        }
        return DiffableDataSourceTransaction(initial: currentSnapshot, final: newSnapshot)
    }
    
    // MARK: - Sections
    
    /// All current sections in the table view.
    open var sections: [Section] { currentSnapshot.sectionIdentifiers }
    
    /// Returns the row for the specified section.
    open func row(for section: Section) -> Int? {
        dataSource.row(forSectionIdentifier: section.id)
    }
    
    /*
    /// Returns the section at the index in the table view.
    open func section(for index: Int) -> Section? {
        sections[safe: index]
    }
     */
    
    /**
     Returns the section for the specified row in the table view.
     
     - Parameter row: The row of the section in the table view.
     - Returns: The section, or `nil` if the method doesn’t find the section for the row.
     */
    func section(forRow row: Int) -> Section? {
        if let sectionID = dataSource.sectionIdentifier(forRow: row) {
            return sections[id: sectionID]
        }
        return nil
    }
    
    /**
     Returns the section for the specified item.
     
     - Parameter item: The item in your table view.
     - Returns: The section, or `nil` if the item isn't in any section.
     */
    open func section(for item: Item) -> Section? {
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

    func rows(for sections: [Section]) -> [Int] {
        sections.flatMap { rows(for: $0) }
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

    /// The handlers for drag and drop of files from and to the table view.
    var dragDropHandlers = DragDropHandlers()

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
        /// The handler that determines if items can be reordered. The default value is `nil` which indicates that the items can be reordered.
        public var canReorder: (([Item]) -> Bool)?

        /// The handler that that gets called before reordering items.
        public var willReorder: ((DiffableDataSourceTransaction<Section, Item>) -> Void)?

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
        public var didReorder: ((DiffableDataSourceTransaction<Section, Item>) -> Void)?
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
        /// The handler that gets called whenever a column did resize.
        public var didResize: ((_ column: NSTableColumn, _ oldWidth: CGFloat) -> Void)?

        /// The handler that determines whenever a column can be reordered to a new index.
        public var shouldReorder: ((_ column: NSTableColumn, _ newIndex: Int) -> Bool)?

        /// The handler that gets called whenever a column did reorder.
        public var didReorder: ((_ column: NSTableColumn, _ oldIndex: Int, _ newIndex: Int) -> Void)?
    }

    /// Handlers for drag and drop of files from and to the table view.
    struct DragDropHandlers {
        /// The handler that determines which items can be dragged outside the table view.
        public var canDragOutside: ((_ items: [Item]) -> [Item])?

        /// The handler that gets called whenever items did drag ouside the table view.
        public var didDragOutside: (([Item]) -> Void)?

        /// The handler that determines the pasteboard value of an item when dragged outside the table view.
        public var pasteboardValue: ((_ item: Item) -> PasteboardReadWriting)?

        /// The handler that determines whenever pasteboard items can be dragged inside the table view.
        public var canDragInside: (([PasteboardReadWriting]) -> [PasteboardReadWriting])?

        /// The handler that gets called whenever pasteboard items did drag inside the table view.
        public var didDragInside: (([PasteboardReadWriting]) -> Void)?

        /// The handler that determines the image when dragging items.
        public var draggingImage: ((_ items: [Item], NSEvent, NSPointPointer) -> NSImage?)?

        var acceptsDragInside: Bool {
            canDragInside != nil && didDragInside != nil
        }

        var acceptsDragOutside: Bool {
            canDragOutside != nil
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
    public func quicklookItems(_ items: [Item], current: Item? = nil) where Item: QuicklookPreviewable {
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

/*
 public func section(for item: Item) -> Section? {
 return self.currentSnapshot.sectionIdentifier(containingItem: item)
 }

 public func frame(for item: Item) -> CGRect? {
 self.tableView.fram
 if let index = row(for: item)?.item {
 return self.collectionView.frameForItem(at: index)
 }
 return nil
 }

 public func reconfigurateItems(_ items: [Item]) {
 let indexPaths = items.compactMap({self.indexPath(for:$0)})
 self.reconfigureItems(at: indexPaths)
 }

 public func reconfigureItems(at indexPaths: [IndexPath]) {
 self.collectionView.reconfigureItems(at: indexPaths)
 }

 public func reloadItems(at rows: [Int], animated: Bool = false) {
 let items = rows.compactMap({self.item(forRow: $0)})
 self.reloadItems(items, animated: animated)
 }

 public func reloadItems(_ items: [Item], animated: Bool = false) {
 var snapshot = dataSource.snapshot()
 snapshot.reloadItems(items.ids)
 dataSource.apply(snapshot, animated ? .animated: .withoutAnimation)
 }

 public func reloadAllItems(animated: Bool = false, complection: (() -> Void)? = nil) {
 var snapshot = snapshot()
 snapshot.reloadItems(snapshot.itemIdentifiers)
 self.apply(snapshot, animated ? .animated : .usingReloadData)
 }

 public func selectAll() {
 self.tableView.selectAll(nil)
 }

 public func deselectAll() {
 self.tableView.deselectAll(nil)
 }

 func moveItems( _ items: [Item], before beforeItem: Item) {
 var snapshot = self.snapshot()
 items.forEach({snapshot.moveItem($0, beforeItem: beforeItem)})
 self.apply(snapshot)
 }

 func moveItems( _ items: [Item], after afterItem: Item) {
 var snapshot = self.snapshot()
 items.forEach({snapshot.moveItem($0, afterItem: afterItem)})
 self.apply(snapshot)
 }

 func moveItems(at rows: [Int], to toRow: Int) {
 let items = rows.compactMap({self.item(forRow: $0)})
 if let toItem = self.item(forRow: toRow), items.isEmpty == false {
 var snapshot = self.snapshot()
 items.forEach({snapshot.moveItem($0, beforeItem: toItem)})
 self.apply(snapshot)
 //  self.moveItems(items, before: toItem)
 }
 }
 */

/*
 /**
  Creates a diffable data source with the specified cell and row registration, and connects it to the specified table view.

  To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.

  ```swift
  dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellRegistration: cellRegistration, rowRegistration: rowRegistration)
  ```

  - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistration: A rell registration which returns each of the cells for the table view from the data the diffable data source provides.
     - rowRegistration: A row registration which returns each of the row view for the table view from the data the diffable data source provides.
  */
 public convenience init<I: NSTableCellView, R: NSTableRowView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, Item>, rowRegistration: NSTableView.RowRegistration<R, Item>) {
     self.init(tableView: tableView, cellProvider:  {
         _tableView, column, row, element in
         return _tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, element: element)!
     })
     self.applyRowViewRegistration(rowRegistration)
 }

 /**
  Creates a diffable data source with the specified cell and section header view registration, and connects it to the specified table view.

  To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.

  ```swift
  dataSource = TableViewDiffableDataSource<Section, Element>(tableView: tableView, cellRegistration: cellRegistration, sectionHeaderRegistration: sectionHeaderRegistration)
  ```

  - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistration: A rell registration which returns each of the cells for the table view from the data the diffable data source provides.
     - sectionHeaderRegistration: A section header view registration which returns each of the section header view for the table view from the data the diffable data source provides.
  */
 public convenience init<I: NSTableCellView, H: NSView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, Item>, sectionHeaderRegistration: NSTableView.SectionHeaderRegistration<H, Section>) {
     self.init(tableView: tableView, cellProvider:  {
         _tableView, column, row, element in
         return _tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, element: element)!
     })
     self.applySectionHeaderViewRegistration(sectionHeaderRegistration)
 }

 /**
  Creates a diffable data source with the specified cell,  section header view and row registration, and connects it to the specified table view.

  To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.

  ```swift
  dataSource = TableViewDiffableDataSource<Section, Element>(tableView: tableView, cellRegistration: cellRegistration, sectionHeaderRegistration: sectionHeaderRegistration, rowRegistration: rowRegistration)
  ```

  - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistration: A rell registration which returns each of the cells for the table view from the data the diffable data source provides.
     - sectionHeaderRegistration: A section header view registration which returns each of the section header view for the table view from the data the diffable data source provides.
     - rowRegistration: A row registration which returns each of the row view for the table view from the data the diffable data source provides.
  */
 public convenience init<I: NSTableCellView, H: NSView,  R: NSTableRowView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, Item>, sectionHeaderRegistration: NSTableView.SectionHeaderRegistration<H, Section>, rowRegistration: NSTableView.RowRegistration<R, Item>) {
     self.init(tableView: tableView, cellProvider:  {
         _tableView, column, row, element in
         return _tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, element: element)!
     })
     self.applySectionHeaderViewRegistration(sectionHeaderRegistration)
     self.applyRowViewRegistration(rowRegistration)
 }

 /**
  Creates a diffable data source with the specified cell and row registrations, and connects it to the specified table view.

  To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.

  ```swift
  dataSource = TableViewDiffableDataSource<Section, Element>(tableView: tableView, cellRegistrations: cellRegistrations)
  ```

  - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistrations: Cell registratiosn which returns each of the cells for the table view from the data the diffable data source provides.
     - rowRegistration: A row registration which returns each of the row view for the table view from the data the diffable data source provides.
  */
 public convenience init<R: NSTableRowView>(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration], rowRegistration: NSTableView.RowRegistration<R, Item>) {
     self.init(tableView: tableView, cellProvider:  {
         _tableView, column, row, element in
         if let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifiers?.contains(column.identifier) == true}) ?? cellRegistrations.first(where: {$0.columnIdentifiers == nil }) {
             return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
         }
         return NSTableCellView()
     })
 }

 /**
  Creates a diffable data source with the specified cell and section header viewregistrations, and connects it to the specified table view.

  To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.

  ```swift
  dataSource = TableViewDiffableDataSource<Section, Element>(tableView: tableView, cellRegistrations: cellRegistrations)
  ```

  - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistrations: Cell registratiosn which returns each of the cells for the table view from the data the diffable data source provides.
     - sectionHeaderRegistration: A section header view registration which returns each of the section header view for the table view from the data the diffable data source provides.
  */
 public convenience init<H: NSView>(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration], sectionHeaderRegistration: NSTableView.SectionHeaderRegistration<H, Section>) {
     self.init(tableView: tableView, cellProvider:  {
         _tableView, column, row, element in
         if let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifiers?.contains(column.identifier) == true}) ?? cellRegistrations.first(where: {$0.columnIdentifiers == nil }) {
             return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
         }
         return NSTableCellView()
     })
 }

 /**
  Creates a diffable data source with the specified cell, section header view and row registrations, and connects it to the specified table view.

  To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.

  ```swift
  dataSource = TableViewDiffableDataSource<Section, Element>(tableView: tableView, cellRegistrations: cellRegistrations)
  ```

  - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistrations: Cell registratiosn which returns each of the cells for the table view from the data the diffable data source provides.
     - sectionHeaderRegistration: A section header view registration which returns each of the section header view for the table view from the data the diffable data source provides.
     - rowRegistration: A row registration which returns each of the row view for the table view from the data the diffable data source provides.
  */
 public convenience init<H: NSView, R: NSTableRowView>(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration], sectionHeaderRegistration: NSTableView.SectionHeaderRegistration<H, Section>, rowRegistration: NSTableView.RowRegistration<R, Item>) {
     self.init(tableView: tableView, cellProvider:  {
         _tableView, column, row, element in
         if let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifiers?.contains(column.identifier) == true}) ?? cellRegistrations.first(where: {$0.columnIdentifiers == nil }) {
             return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
         }
         return NSTableCellView()
     })
 }
 */
