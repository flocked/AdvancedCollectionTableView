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
    var delegate: Delegate!
    var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    var dragingRowIndexes = IndexSet()
    var sectionRowIndexes: [Int] = []
    var hoveredRowObserver: KeyValueObservation?
    var keyDownMonitor: NSEvent.Monitor?

    
    /// The closure that configures and returns the table view’s row views from the diffable data source.
    open var rowViewProvider: RowProvider? {
        didSet {
            if let rowViewProvider = rowViewProvider {
                dataSource.rowViewProvider = { [weak self] tableview, row, identifier in
                    guard let self = self, let item = self.currentSnapshot.itemIdentifiers[id: identifier as! Item.ID] else { return NSTableRowView() }
                    return rowViewProvider(tableview, row, item)
                }
            } else {
                dataSource.rowViewProvider = nil
            }
        }
    }
    
    /**
     A closure that configures and returns a row view for a table view from its diffable data source.
     
     - Parameters
        - tableView: The table view to configure this row view for.
        - row: The row of the row view.
        - item: The item of the row.
     
     - Returns: A configured row view object.
     */
    public typealias RowProvider = (_ tableView: NSTableView, _ row: Int, _ item: Item) -> NSTableRowView
    
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
                    let cellView = sectionHeaderCellProvider(tableView, row, section)
                    if var configuration = cellView.contentConfiguration as? NSListContentConfiguration, configuration.type == .automatic {
                        configuration.type = .automaticHeader
                        cellView.contentConfiguration = configuration
                    }
                    return cellView
                }
            } else {
                dataSource.sectionHeaderViewProvider = nil
            }
        }
    }
    
    /**
     A closure that configures and returns a section header cell for a table view from its diffable data source.
     
     - Parameters
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
            } else {
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
                    let location = event.location(in: self.tableView)
                    handler(self.items(for: location))
                }
            } else {
                tableView.mouseHandlers.rightDown = nil
            }
        }
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
    
    func setupHoverObserving() {
        if hoverHandlers.shouldSetup {
            tableView.setupObservation()
            if hoveredRowObserver == nil {
                hoveredRowObserver = tableView.observeChanges(for: \.hoveredRow, handler: { old, new in
                    guard old != new else { return }
                    if let didEndHovering = self.hoverHandlers.didEndHovering, old != -1, let item = self.item(forRow: old) {
                        didEndHovering(item)
                    }
                    if let isHovering = self.hoverHandlers.isHovering, new != -1, let item = self.item(forRow: new) {
                        isHovering(item)
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
                guard let self = self, event.charactersIgnoringModifiers == String(UnicodeScalar(NSDeleteCharacter)!), self.tableView.isFirstResponder else { return event }
                let itemsToDelete = canDelete(self.selectedItems)
                guard !itemsToDelete.isEmpty else { return event }
                var section: Section? = nil
                var selectionItem: Item? = nil
                if let item = itemsToDelete.first {
                    if let row = self.row(for: item), self.section(forRow: row - 1) == nil, let item = self.item(forRow: row - 1), !itemsToDelete.contains(item) {
                        selectionItem = item
                    } else {
                        section = self.section(for: item)
                    }
                }
                let transaction = self.deletingTransaction(itemsToDelete)
                self.deletingHandlers.willDelete?(itemsToDelete, transaction)
                QuicklookPanel.shared.close()
                self.apply(transaction.finalSnapshot, self.deletingHandlers.animates ? .animated : .withoutAnimation)
                self.deletingHandlers.didDelete?(itemsToDelete, transaction)
                
                if !self.tableView.allowsEmptySelection, self.tableView.selectedRowIndexes.isEmpty {
                    var selectionRow: Int? = nil
                    if let item = selectionItem, let row = self.row(for: item) {
                        selectionRow = row
                    } else if let section = section, let item = self.items(for: section).first, let row = self.row(for: item) {
                        selectionRow = row
                    } else if let item = self.currentSnapshot.itemIdentifiers.first, let row = self.row(for: item) {
                        selectionRow = row
                    }
                    if let row = selectionRow {
                        self.tableView.selectRowIndexes([row], byExtendingSelection: false)
                    }
                }
                return nil
            }
        } else {
            tableView.keyHandlers.keyDown = nil
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
    
    /**
     Creates a diffable data source with the specified cell registration, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellRegistration: cellRegistration)
     ```
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistration: A cell registration which returns each of the cells for the table view from the data the diffable data source provides.
        - sectionRegistration: A cell registration which returns each of the table view’s section header views from the data the diffable data source provides.
     */
    public convenience init<Cell: NSTableCellView, SectionCell: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<Cell, Item>, sectionHeaderRegistration: NSTableView.CellRegistration<SectionCell, Section>) {
        self.init(tableView: tableView, cellProvider: {
            tableView, column, row, item in
            return tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, item: item)!
        })
        applySectionHeaderRegistration(sectionHeaderRegistration)
        }
    /**
     Creates a diffable data source with the specified cell registrations, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.
     
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
        
        dataSource = .init(tableView: tableView, cellProvider: {
            [weak self] tableview, tablecolumn, row, itemID in
            guard let self = self, let item = self.items[id: itemID] else { return NSTableCellView() }
            return cellProvider(tableview, tablecolumn, row, item)
        })
        
        delegate = Delegate(self)
        tableView.registerForDraggedTypes([.itemID, .fileURL, .tiff, .png, .string])
        tableView.isQuicklookPreviewable = Item.self is QuicklookPreviewable.Type
        // tableView.setDraggingSourceOperationMask(.move, forLocal: true)
    }
    
    /**
     A closure that configures and returns a cell view for a table view from its diffable data source.
     
     - Parameters
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
    
    public func tableView(_ tableView: NSTableView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
        if let draggingImage = draggingHandlers.draggingImage {
            draggingInfo.enumerateDraggingItems(for: tableView, classes: [IdentifiablePasteboardItem<Item>.self], using: { draggingItem,_,_ in
                if let item = (draggingItem.item as? IdentifiablePasteboardItem<Item>)?.element {
                    if let image = draggingImage(item) {
                        draggingItem.imageComponentsProvider = {
                            return [.init(image: image.0, frame: image.1)]
                        }
                    }
                }
            })
        }
    }
    
    open func tableView(_: NSTableView, acceptDrop draggingInfo: NSDraggingInfo, row: Int, dropOperation _: NSTableView.DropOperation) -> Bool {
        if !dragingRowIndexes.isEmpty {
            if let transaction = movingTransaction(at: dragingRowIndexes, to: row) {
                let selectedItems = selectedItems
                reorderingHandlers.willReorder?(transaction)
                apply(transaction.finalSnapshot, reorderingHandlers.animates ? .animated :  .withoutAnimation)
                selectItems(selectedItems)
                reorderingHandlers.didReorder?(transaction)
                return true
            }
        }
        let elements = droppingHandlers.canDrop?(draggingInfo.draggingPasteboard.content()) ?? []
        if !elements.isEmpty {
            var snapshot = snapshot()
            if let item = item(forRow: row) {
                snapshot.insertItems(elements, beforeItem: item)
            } else if let section = section(forRow: row) {
                if let item = item(forRow: row - 1) {
                    snapshot.insertItems(elements, afterItem: item)
                } else {
                    snapshot.appendItems(elements, toSection: section)
                }
            } else if let section = sections.last {
                snapshot.appendItems(elements, toSection: section)
            }

            var transaction: DiffableDataSourceTransaction<Section, Item>?
            if droppingHandlers.needsTransaction {
                transaction = .init(initial: self.snapshot(), final: snapshot)
                droppingHandlers.willDrop?(transaction!)
            }
            let selectedItems = selectedItems
            apply(snapshot, droppingHandlers.animates ? .animated : .withoutAnimation)
            selectItems(selectedItems)
            droppingHandlers.didDrop?(transaction!)
            return true
        }
        return true
    }
    
    open func tableView(_: NSTableView, validateDrop draggingInfo: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if !dragingRowIndexes.isEmpty, dropOperation == .on {
            return []
        }
        if !dragingRowIndexes.isEmpty, dropOperation == .above {
            if row >= (sectionHeaderCellProvider != nil ? 1 : 0) {
                return .move
            }
            return []
        }
        if let draggingSource = draggingInfo.draggingSource as? NSTableView, draggingSource == tableView {
            return NSDragOperation.move
        } else if !draggingInfo.draggingPasteboard.content().isEmpty {
            return NSDragOperation.copy
        }
        return []
    }
    
    open func tableView(_: NSTableView, draggingSession _: NSDraggingSession, willBeginAt _: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        var items = rowIndexes.compactMap({item(forRow: $0)})
        items = reorderingHandlers.canReorder?(items) ?? []
        dragingRowIndexes = .init(items.compactMap({row(for: $0)}))
    }
    
    open func tableView(_: NSTableView, draggingSession _: NSDraggingSession, endedAt _: NSPoint, operation _: NSDragOperation) {
        dragingRowIndexes = []
    }
    
    open func tableView(_: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if let item = item(forRow: row) {
            let pasteboardItem = IdentifiablePasteboardItem(item)
            pasteboardItem.contents = draggingHandlers.pasteboardContent?(item) ?? []
            return pasteboardItem
        }
        return nil
    }
    
    open func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        columnHandlers.sortDescriptorsChanged?(oldDescriptors, tableView.sortDescriptors)
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
    
    // MARK: - Empty Collection View
    
    /**
     The view that is displayed when the datasource doesn't contain any items.
     
     When using this property, ``emptyContentConfiguration`` is set to `nil`.
     */
    open var emptyView: NSView? = nil {
        didSet {
            guard oldValue != emptyView else { return }
            oldValue?.removeFromSuperview()
            scrollViewContentViewObservation = nil
            if emptyView != nil {
                emptyContentConfiguration = nil
                updateEmptyView()
            }
        }
    }
    
    /**
     The content configuration that content view is displayed when the datasource doesn't contain any items.
     
     When using this property, ``emptyView`` is set to `nil`.
     */
    open var emptyContentConfiguration: NSContentConfiguration? {
        get { emptyContentView?.contentConfiguration }
        set {
            if let configuration = newValue {
                if let emptyContentView = self.emptyContentView {
                    emptyContentView.contentConfiguration = configuration
                } else {
                    emptyContentView = .init(configuration: configuration)
                }
                emptyView = nil
                updateEmptyView()
            } else {
                scrollViewContentViewObservation = nil
                emptyContentView = nil
            }
        }
    }
    
    var emptyContentView: ContentConfigurationView?
    
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
    
    var scrollViewContentViewObservation: KeyValueObservation?
    
    func updateEmptyView(previousIsEmpty: Bool? = nil) {
        if !currentSnapshot.isEmpty {
            emptyView?.removeFromSuperview()
            emptyContentView?.removeFromSuperview()
            scrollViewContentViewObservation = nil
        } else if let emptyView = emptyView ?? emptyContentView, emptyView.superview != tableView?.enclosingScrollView ?? tableView {
            (tableView?.enclosingScrollView ?? tableView)?.addSubview(withConstraint: emptyView)
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
    
    /// The handlers for dragging pasteboard items inside the table view.
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
        /// The handler that determines if items can be reordered. The default value is `nil` which indicates that the items can't be reordered.
        public var canReorder: (([Item]) -> [Item])?

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
        
        /// A Boolean value that indicates whether reordering items is animated.
        public var animates: Bool = false
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
        public var pasteboardContent: ((_ item: Item)->([PasteboardContent]))?
        /// The handler that determines the image when dragging elements outside the table view.
        public var draggingImage: ((_ item: Item) -> (NSImage, CGRect?)?)?
    }
    
    /// Handlers for dragging pasteboard items inside the table view.
    public struct DroppingHandlers {
        /// The handler that determines whenever pasteboard elements can be dragged inside the table view.
        public var canDrop: ((_ contents: [PasteboardContent]) -> ([Item]))?
        /// The handler that gets called when the handler will drag pasteboard items inside the table view.
        public var willDrop: ((_ transaction: DiffableDataSourceTransaction<Section, Item>) -> ())?
        /// The handler that gets called when the handler did drag pasteboard inside the table view.
        public var didDrop: ((_ transaction: DiffableDataSourceTransaction<Section, Item>) -> ())?
        /// A Boolean value that indicates whether dropping items is animated.
        public var animates: Bool = true
        
        var needsTransaction: Bool {
            willDrop != nil || didDrop != nil
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
