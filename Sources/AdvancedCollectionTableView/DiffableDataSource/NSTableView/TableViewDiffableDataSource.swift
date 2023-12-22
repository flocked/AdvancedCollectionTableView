//
//  TableViewDiffableDataSourceNew+.swift
//  TableDelegate
//
//  Created by Florian Zand on 01.08.23.
//

import AppKit
import FZUIKit
import FZQuicklook
import FZSwiftUtils
/**
 A`NSTableViewDiffableDataSource` with additional functionality.
 
 The diffable data source provides:
 - Reordering of items by enabling ``allowsReordering``.
 - Deleting of items by enabling  ``allowsDeleting``.
 - Quicklooking of items via spacebar by providing elements conforming to ``QuicklookPreviewable``.
 - Right click menu provider for selected items via ``menuProvider``.
 - Row action provider via ``rowActionProvider``.
 
 ### Handlers

 It includes handlers for:
 - Reordering of items via ``reorderingHandlers-swift.property``.
 - Deleting of items via ``deletionHandlers-swift.property``.
 - Selecting of items via ``selectionHandlers-swift.property``.
 - Items that are hovered by mouse via ``hoverHandlers-swift.property``.
 - Drag and drop of files from and to the table view via ``dragDropHandlers-swift.property``.
 - Table column handlers via ``columnHandlers-swift.property``.

 ### Configurating the data source
 
 To connect a diffable data source to a table view, you create the diffable data source using its ``init(tableView:cellProvider:)`` or ``init(tableView:cellRegistration:)`` initializer, passing in the table view you want to associate with that data source.

 ```swift
 tableView.dataSource = TableViewDiffableDataSource<Section, Element>(tableView: tableView, cellRegistration: cellRegistration)
 ```
 
 Then, you generate the current state of the data and display the data in the UI by constructing and applying a snapshot. For more information, see `NSDiffableDataSourceSnapshot`.
 
 - Note: Don’t change the dataSource or delegate on the table view after you configure it with a diffable data source. If the table view needs a new data source after you configure it initially, create and configure a new table view and diffable data source.
 */
public class TableViewDiffableDataSource<Section, Item> : NSObject, NSTableViewDataSource where Section : Hashable & Identifiable, Item : Hashable & Identifiable {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section,  Item>
    typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Item.ID>
    typealias DataSoure = NSTableViewDiffableDataSource<Section.ID,  Item.ID>
    
    let tableView: NSTableView
    var dataSource: DataSoure!
    var currentSnapshot: Snapshot = Snapshot()
    var dragingRowIndexes = IndexSet()
    var sectionRowIndexes: [Int] = []
    var previousSelectedIDs: [Item.ID] = []
    var keyDownMonitor: Any? = nil
    var rightDownMonitor: NSEvent.Monitor? = nil
    var hoveredRowObserver: NSKeyValueObservation? = nil
    lazy var delegateBridge = DelegateBridge(self)
    
    /// The closure that configures and returns the table view’s row views from the diffable data source.
    public var rowViewProvider: RowViewProvider? = nil {
        didSet {
            if let rowViewProvider = self.rowViewProvider {
                self.dataSource.rowViewProvider = { tableview, row, identifier in
                    let item = self.currentSnapshot.itemIdentifiers[id: identifier as! Item.ID]!
                    return rowViewProvider(tableview, row, item)
                }
            } else {
                self.dataSource.rowViewProvider = nil
            }
        }
    }
    
    /// A closure that configures and returns a row view for a table view from its diffable data source.
    public typealias RowViewProvider = (_ tableView: NSTableView, _ row: Int, _ identifier: Item) -> NSTableRowView

    
    /// Applies the row view registration to configure and return table row views.
    public func rowViewRegistration<Row: NSTableRowView>(_ registration: NSTableView.RowRegistration<Row, Item>) {
        rowViewProvider = { tableView, row, item in
            return registration.makeView(tableView, row, item)
        }
    }
    
    /// The closure that configures and returns the table view’s section header views from the diffable data source.
    public var sectionHeaderViewProvider: SectionHeaderViewProvider? = nil {
        didSet {
            if let sectionHeaderViewProvider = self.sectionHeaderViewProvider {
                dataSource.sectionHeaderViewProvider = { tableView, row, sectionID in
                    return sectionHeaderViewProvider(tableView, row, self.sections[id: sectionID]!)
                }
            } else {
                dataSource.sectionHeaderViewProvider = nil
            }
        }
    }
    
    /// A closure that configures and returns a section header view for a table view from its diffable data source.
    public typealias SectionHeaderViewProvider = (_ tableView: NSTableView, _ row: Int, _ section: Section) -> NSView
    
    
    /// Applies the section header view registration to configure and return section header views.
    public func sectionHeaderViewRegistration<HeaderView: NSView>(_ registration: NSTableView.SectionHeaderRegistration<HeaderView, Section>) {
        sectionHeaderViewProvider = { tableView, row, section in
            return registration.makeView(tableView, row, section)
        }
    }

    /**     
     Right click menu provider.
     
     `items` provides:
     - if right-click on a selected item, all selected items,
     - or else if right-click on a non selected item, that item,
     - or else an empty array.
     
     When returning a menu to the `menuProvider`, the table view will display a menu on right click.
     */
    public var menuProvider: ((_ items: [Item]) -> NSMenu?)? = nil {
        didSet { setupRightDownMonitor() } }
    
    /**
     Provides an array of row actions to be attached to the specified edge of a table row and displayed when the user swipes horizontally across the row.
     */
    public var rowActionProvider: ((_ element: Item, _ edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction])? = nil
    
    /**
     A Boolean value that indicates whether users can reorder items in the table view when dragging them via mouse.
     
     If the value of this property is true (the default is false), users can reorder items in the table view.
     */
    public var allowsReordering: Bool = false
    
    /**
     A Boolean value that indicates whether users can delete items either via keyboard shortcut or right click menu.
     
     If the value of this property is true (the default is false), users can delete items.
     */
    public var allowsDeleting: Bool = false {
        didSet { self.setupKeyDownMonitor() }
    }
    
    /**
     The default animation the UI uses to show differences between rows.
     
     The default value of this property is `effectFade`.
     
     If you set the value of this property, the new value becomes the default row animation for the next update that uses ``apply(_:_:completion:)``.
     */
    public var defaultRowAnimation: NSTableView.AnimationOptions {
        get { self.dataSource.defaultRowAnimation }
        set { self.dataSource.defaultRowAnimation = newValue }
    }
    
    @objc dynamic var _defaultRowAnimation: UInt {
        return self.dataSource.defaultRowAnimation.rawValue
    }
    
    func setupRightDownMonitor() {
        if menuProvider != nil, rightDownMonitor == nil {
            self.rightDownMonitor = NSEvent.localMonitor(for: [.rightMouseDown]) { event in
                self.tableView.menu = nil
                if let contentView = self.tableView.window?.contentView {
                    let location = event.location(in: contentView)
                    if let view = contentView.hitTest(location), view.isDescendant(of: self.tableView) {
                        let location = event.location(in: self.tableView)
                        if self.tableView.bounds.contains(location) {
                            self.setupMenu(for: location)
                        }
                    }
                }
                return event
            }
        } else if menuProvider == nil, rightDownMonitor != nil {
            rightDownMonitor = nil
        }
    }
    
    func setupMenu(for location: CGPoint) {
        if let menuProvider = self.menuProvider {
            if let item = self.item(at: location) {
                var menuItems: [Item] = [item]
                let selectedItems = self.selectedItems
                if selectedItems.contains(item) {
                    menuItems = selectedItems
                }
                self.tableView.menu = menuProvider(menuItems)
            } else {
                self.tableView.menu = menuProvider([])
            }
        }
    }
    
    func setupHoverObserving() {
        if self.hoverHandlers.isHovering != nil || self.hoverHandlers.didEndHovering != nil {
            self.tableView.setupObservingView()
            if hoveredRowObserver == nil {
                hoveredRowObserver = self.tableView.observeChanges(for: \.hoveredRow, handler: { old, new in
                    guard old != new else { return }
                    if let didEndHovering = self.hoverHandlers.didEndHovering,  let oldRow = old?.item {
                        if oldRow != -1, let item = self.item(forRow: oldRow) {
                            didEndHovering(item)
                        }
                    }
                    if let isHovering = self.hoverHandlers.isHovering,  let newRow = new?.item {
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
    
    // MARK: - Snapshot
    
    /**
     Returns a representation of the current state of the data in the table view.
     
     A snapshot containing section and item identifiers in the order that they appear in the UI.
     */
    public func snapshot() -> NSDiffableDataSourceSnapshot<Section,  Item> {
        return currentSnapshot
    }
    
    /**
     Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes.
     
     The system interrupts any ongoing item animations and immediately reloads the table view’s content.
     
     - Parameters:
        - snapshot: The snapshot that reflects the new state of the data in the table view.
        - option: Option how to apply the snapshot to the table view. The default value is `animated`.
        - completion: An optional completion handler which gets called after applying the snapshot.
     */
    public func apply(_ snapshot: NSDiffableDataSourceSnapshot<Section, Item>,_ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        let internalSnapshot = convertSnapshot(snapshot)
        self.currentSnapshot = snapshot
        self.updateSectionHeaderRows()
        dataSource.apply(internalSnapshot, option, completion: completion)
    }
    
    func convertSnapshot(_ snapshot: Snapshot) -> InternalSnapshot {
        var internalSnapshot = InternalSnapshot()
        let sections = snapshot.sectionIdentifiers
        internalSnapshot.appendSections(sections.ids)
        for section in sections {
            let elements = snapshot.itemIdentifiers(inSection: section)
            internalSnapshot.appendItems(elements.ids, toSection: section.id)
        }
        return internalSnapshot
    }
    
    func updateSectionHeaderRows() {
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
     dataSource = TableViewDiffableDataSource<Section, Element>(tableView: tableView, cellRegistration: cellRegistration)
     ```
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistration: A rell registration which returns each of the cells for the table view from the data the diffable data source provides.
     */
    public convenience init<I: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, Item>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            return _tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)!
        })
    }
    
    /**
     Creates a diffable data source with the specified cell registrations, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a cell registration, where each of your cells gets determine how to display your data in the UI.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Element>(tableView: tableView, cellRegistrations: cellRegistrations)
     ```
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistrations: Cell registratiosn which returns each of the cells for the table view from the data the diffable data source provides.
     */
    public convenience init(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration]) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            if let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifiers?.contains(column.identifier) == true}) ?? cellRegistrations.first(where: {$0.columnIdentifiers == nil }) {
                return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
            }
            return NSTableCellView()
        })
    }
    
    /**
     Creates a diffable data source with the specified cell provider, and connects it to the specified table view.
     
     To connect a diffable data source to a table view, you create the diffable data source using this initializer, passing in the table view you want to associate with that data source. You also pass in a item provider, where you configure each of your cells to determine how to display your data in the UI.
     
     ```swift
     dataSource = TableViewDiffableDataSource<Section, Element>(tableView: tableView, itemProvider: {
     (tableView, tableColumn, row, element) in
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
        
        self.dataSource = DataSoure(tableView: self.tableView, cellProvider: {
            [weak self] tableview, tablecolumn, row, itemID in
            guard let self = self, let item = self.items[id: itemID] else { return NSTableCellView() }
            return cellProvider(tableview, tablecolumn, row, item)
        })
        
        self.tableView.registerForDraggedTypes([.itemID])
        self.tableView.setDraggingSourceOperationMask(.move, forLocal: true)
        _ = delegateBridge
        self.tableView.isQuicklookPreviewable = Item.self is QuicklookPreviewable.Type
        
    }
    
    /// A closure that configures and returns a cell for a table view from its diffable data source.
    public typealias CellProvider = (_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ identifier: Item) -> NSView
    
    // MARK: - DataSource conformance
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.numberOfRows(in: tableView)
    }
    
    public func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        if self.dragingRowIndexes.isEmpty == false {
            if let transaction = self.movingTransaction(at: dragingRowIndexes, to: row) {
                let selectedItems = self.selectedItems
                self.reorderingHandlers.willReorder?(transaction)
                self.apply(transaction.finalSnapshot, .withoutAnimation)
                self.selectItems(selectedItems)
                self.reorderingHandlers.didReorder?(transaction)
            } else {
                return false
            }
        }
        return true
    }
    
    public func tableView( _ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    public func tableView( _ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        self.dragingRowIndexes = rowIndexes
    }
    
    public func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        self.dragingRowIndexes.removeAll()
    }
    
    public func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if let element = self.item(forRow: row) {
            let item = NSPasteboardItem()
            item.setString(String(element.id.hashValue), forType: .itemID)
            return item
        }
        return nil
    }
            
    // MARK: - Elements
    
    /// All current items in the collection view.
    var items: [Item] { currentSnapshot.itemIdentifiers }
    
    /// An array of the selected items.
    public var selectedItems: [Item] {
        return self.tableView.selectedRowIndexes.compactMap({item(forRow: $0)})
    }
    
    /**
     Returns the item at the specified row in the table view.
     
     - Parameter row: The row of the item in the table view.
     - Returns: The item, or `nil` if the method doesn’t find an item at the provided row.
     */
    public func item(forRow row: Int) -> Item? {
        if let itemID = dataSource.itemIdentifier(forRow: row) {
            return items[id: itemID]
        }
        return nil
    }
    
    /// Returns the row for the specified item.
    public func row(for item: Item) -> Int? {
        return self.dataSource.row(forItemIdentifier: item.id)
    }
    
    /**
     Returns the section for the specified row in the table view.
     
     - Parameter row: The row of the section in the table view.
     - Returns: The section, or `nil if the method doesn’t find the section for the row.
     */
    public func section(forRow row: Int) -> Section? {
        if let sectionID = dataSource.sectionIdentifier(forRow: row) {
            return sections[id: sectionID]
        }
        return nil
    }
    
    /**
     Returns the item of the specified index path.
     
     - Parameter indexPath: The indexPath
     - Returns: The item at the index path or nil if there isn't any item at the index path.
     */
    public func item(at point: CGPoint) -> Item? {
        let row = self.tableView.row(at: point)
        if row != -1 {
            return item(forRow: row)
        }
        return nil
    }
    
    /// Selects all table rows of the specified items.
    public func selectItems(_ items: [Item], byExtendingSelection: Bool = false) {
        self.selectItems(at: rows(for: items), byExtendingSelection: byExtendingSelection)
    }
    
    /// Deselects all table rows of the specified items.
    public func deselectItems(_ items: [Item]) {
        items.compactMap({row(for: $0)}).forEach({ self.tableView.deselectRow($0) })
        // self.deselectItems(at: rows(for: items))
    }
    
    /// Selects all table rows of the items in the specified sections.
    public func selectItems(in sections: [Section], byExtendingSelection: Bool = false) {
        let rows = sections.flatMap({self.rows(for: $0)})
        self.selectItems(at: rows, byExtendingSelection: byExtendingSelection)
    }
    
    /// Deselects all table rows of the items in the specified sections.
    public func deselectItems(in sections: [Section]) {
        let rows = sections.flatMap({self.rows(for: $0)})
        self.deselectItems(at: rows)
    }
    
    /// Scrolls the table view to the specified item.
    public func scrollToItem(_ item: Item, scrollPosition: NSCollectionView.ScrollPosition = []) {
        if let row = self.row(for: item) {
            self.tableView.scrollRowToVisible(row)
        }
    }
    
    /// An array of items that are visible.
    func visibleItems() -> [Item] {
        self.tableView.visibleRowIndexes().compactMap({ item(forRow: $0) })
    }
    
    func rowView(for item: Item) -> NSTableRowView? {
        if let row = row(for: item) {
            return self.tableView.rowView(atRow: row, makeIfNecessary: false)
        }
        return nil
    }
    
    func rows(for items: [Item]) -> [Int] {
        return items.compactMap({row(for: $0)})
    }
    
    func isSelected(at row: Int) -> Bool {
        return self.tableView.selectedRowIndexes.contains(row)
    }
    
    func isSelected(for item: Item) -> Bool {
        if let row = row(for: item) {
            return isSelected(at: row)
        }
        return false
    }
    
    func selectItems(at rows: [Int], byExtendingSelection: Bool = false) {
        self.tableView.selectRowIndexes(IndexSet(rows), byExtendingSelection: byExtendingSelection)
    }
    
    func deselectItems(at rows: [Int]) {
        rows.forEach({self.tableView.deselectRow($0)})
    }
    
    @discardableResult
    func removeItems( _ items: [Item]) -> DiffableDataSourceTransaction<Section, Item>  {
        deletingTransaction(items)
    }
    
    func deletingTransaction(_ deletionItems: [Item]) -> DiffableDataSourceTransaction<Section, Item> {
        let initalSnapshot = self.currentSnapshot
        var newNnapshot = self.snapshot()
        newNnapshot.deleteItems(deletionItems)
        let difference = initalSnapshot.itemIdentifiers.difference(from: newNnapshot.itemIdentifiers)
        return DiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: newNnapshot, difference: difference)
    }
    
    func movingTransaction(at rowIndexes: IndexSet, to row: Int) -> DiffableDataSourceTransaction<Section, Item>? {
        var row = row
        var isLast: Bool = false
        if row >= self.numberOfRows(in: tableView) {
            row = row - 1
            isLast = true
        }
        let dragingItems = rowIndexes.compactMap({ item(forRow: $0) })
        guard self.reorderingHandlers.canReorder?(dragingItems) ?? self.allowsReordering, let toItem = self.item(forRow: row) else {
            return nil
        }
        var snapshot = self.snapshot()
        if isLast {
            dragingItems.reversed().forEach({ snapshot.moveItem($0, afterItem: toItem) })
        } else {
            dragingItems.forEach({ snapshot.moveItem($0, beforeItem: toItem) })
        }
        let initalSnapshot = self.currentSnapshot
        let difference = initalSnapshot.itemIdentifiers.difference(from: snapshot.itemIdentifiers)
        return DiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: snapshot, difference: difference)
    }
    
    // MARK: - Sections

    /// All current sections in the collection view.
    var sections: [Section] { currentSnapshot.sectionIdentifiers }
    
    /// Returns the row for the specified section.
    public func row(for section: Section) -> Int? {
        return self.dataSource.row(forSectionIdentifier: section.id)
    }
    
    /// Scrolls the table view to the specified section.
    public func scrollToSection(_ section: Section, scrollPosition: NSCollectionView.ScrollPosition = []) {
        if let row = self.row(for: section) {
            self.tableView.scrollRowToVisible(row)
        }
    }
    
    func rows(for section: Section) -> [Int] {
        let items = self.currentSnapshot.itemIdentifiers(inSection: section)
        return self.rows(for: items)
    }
    
    func rows(for sections: [Section]) -> [Int] {
        return sections.flatMap({self.rows(for: $0)})
    }
    
    // MARK: - Handlers
    
    /// Handlers for selection of rows.
    public var selectionHandlers = SelectionHandlers()
    
    /// Handlers for deletion of rows.
    public var deletionHandlers = DeletionHandlers()
    
    /// Handlers for reordering of rows.
    public var reorderingHandlers = ReorderingHandlers()
    
    /// Handlers that get called whenever the mouse is hovering a row.
    public var hoverHandlers = HoverHandlers() {
        didSet { self.setupHoverObserving()} }
    
    /// Handlers for drag and drop of files from and to the table view.
    public var dragDropHandlers = DragDropHandlers()
    
    /// Handlers for table columns.
    public var columnHandlers = ColumnHandlers()
    
    /// Handlers for selection of items.
    public struct SelectionHandlers {
        /// The Handler that determines whether items should get selected.
        public var shouldSelect: (([Item]) -> [Item])? = nil
        /// The Handler that determines whether items should get deselected.
        public var shouldDeselect: (([Item]) -> [Item])? = nil
        /// The Handler that gets called whenever items get selected.
        public var didSelect: (([Item]) -> Void)? = nil
        /// The Handler that gets called whenever items get deselected.
        public var didDeselect: (([Item]) -> Void)? = nil
    }
    
    /// Handlers for reordering items.
    public struct ReorderingHandlers {
        /// The handler that determines whether you can reorder a particular item.
        public var canReorder: (([Item]) -> Bool)? = nil
        /// The Handler that prepares the diffable data source for reordering its items.
        public var willReorder: ((DiffableDataSourceTransaction<Section, Item>) -> ())? = nil
        /// The Handler that processes a reordering transaction.
        public var didReorder: ((DiffableDataSourceTransaction<Section, Item>) -> ())? = nil
    }
    
    /// Handlers for deletion.
    public struct DeletionHandlers {
        /// The Handler that determines which items can be be deleted.
        public var canDelete: ((_ items: [Item]) -> [Item])? = nil
        /// The Handler that that gets called before deleting items.
        public var willDelete: ((_ items: [Item], _ transaction: DiffableDataSourceTransaction<Section, Item>) -> ())? = nil
        /// The Handler that gets called after deleting items.
        public var didDelete: ((_ items: [Item], _ transaction: DiffableDataSourceTransaction<Section, Item>) -> ())? = nil
    }
    
    /// Handlers for drag and drop of files from and to the table view.
    public struct DragDropHandlers {
        /// The handler that determines which items can be dragged outside the collection view.
        public var canDragOutside: ((_ elements: [Item]) -> [Item])? = nil
        /// The handler that gets called whenever items did drag ouside the collection view.
        public var didDragOutside: (([Item]) -> ())? = nil
        /// The handler that determines the pasteboard value of an item when dragged outside the collection view.
        public var pasteboardValue: ((_ element: Item) -> PasteboardWriting)? = nil
        /// The handler that determines whenever pasteboard items can be dragged inside the collection view.
        public var canDragInside: (([PasteboardWriting]) -> [PasteboardWriting])? = nil
        /// The handler that gets called whenever pasteboard items did drag inside the collection view.
        public var didDragInside: (([PasteboardWriting]) -> ())? = nil
        /// The handler that determines the image when dragging items.
        public var draggingImage: ((_ elements: [Item], NSEvent, NSPointPointer) -> NSImage?)? = nil
        
        var acceptsDragInside: Bool {
            canDragInside != nil && didDragInside != nil
        }
        
        var acceptsDragOutside: Bool {
            canDragOutside != nil
        }
    }
    
    /// Handlers that get called whenever the mouse is hovering an item.
    public struct HoverHandlers {
        /// The handler that gets called whenever the mouse is hovering an item.
        public var isHovering: ((Item) -> Void)?
        /// The handler that gets called whenever the mouse did end hovering an item.
        public var didEndHovering: ((Item) -> Void)?
    }
    
    /// Handlers for table view columns.
    public struct ColumnHandlers {
        /// The handler that gets called whenever a column did resize.
        public var didResize: ((_ column: NSTableColumn, _ oldWidth: CGFloat) -> ())?
        /// The handler that gets called whenever a column did reorder.
        public var didReorder: ((_ column: NSTableColumn, _ oldIndex: Int, _ newIndex: Int) -> ())?
        /// The handler that determines whenever a column can be reordered to a new index.
        public var shouldReorder: ((_ column: NSTableColumn, _ newIndex: Int) -> Bool)?
    }
}

// MARK: - Quicklook

extension TableViewDiffableDataSource: NSTableViewQuicklookProvider {
    public func tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable? {
        if let item = self.item(forRow: row), let rowView = self.rowView(for: item) {
            if let previewable = item as? QuicklookPreviewable {
                return QuicklookPreviewItem(previewable, view: rowView)
            } else if let previewable = rowView.cellViews.compactMap({$0.quicklookPreview}).first {
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
