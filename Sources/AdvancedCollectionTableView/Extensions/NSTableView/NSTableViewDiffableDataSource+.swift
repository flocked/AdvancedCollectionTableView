//
//  NSTableViewDiffableDataSource+.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit
import FZSwiftUtils

// NSTableViewDiffableDataSource hides these tableview delegate functions
public extension NSTableViewDiffableDataSource {
    /**
     Asks the datasource for a view to display the specified row and column.

     - Parameters:
        - tableView: The table view that sent the message.
        - tableColumn: The table column. If the row is a group row, `tableColumn` is `nil`.
        - row: The row index.

     - Returns: The view to display the specified column and row.
     */
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let selector = NSSelectorFromString("_tableView:viewForTableColumn:row:")
        if let meth = class_getInstanceMethod(object_getClass(self), selector) {
            let imp = method_getImplementation(meth)
            typealias ClosureType = @convention(c) (AnyObject, Selector, NSTableView, NSTableColumn?, Int) -> NSView?
            let method: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            let view = method(self, selector, tableView, tableColumn, row)
            return view
        }
        return nil
    }

    /**
     Asks the delegate for a view to display the specified row.

     - Parameters:
        - tableView: The table view that sent the message.
        - row: The row index.

     - Returns: An instance or subclass of `NSTableRowView`. If `nil` is returned, an `NSTableRowView` instance will be created and used.
     */
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let selector = NSSelectorFromString("_tableView:rowViewForRow:")
        if let meth = class_getInstanceMethod(object_getClass(self), selector) {
            let imp = method_getImplementation(meth)
            typealias ClosureType = @convention(c) (AnyObject, Selector, NSTableView, Int) -> NSTableRowView?
            let method: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            let view = method(self, selector, tableView, row)
            return view
        }
        return nil
    }

    /**
     Returns whether the specified row is a group row.

     - Parameters:
        - tableView: The table view that sent the message.
        - row: The row index.

     - Returns: `true` if the specified row should have the group row style drawn, `false` otherwise.
     */
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        let selector = NSSelectorFromString("_tableView:isGroupRow:")
        if let meth = class_getInstanceMethod(object_getClass(self), selector) {
            let imp = method_getImplementation(meth)
            typealias ClosureType = @convention(c) (AnyObject, Selector, NSTableView, Int) -> Bool
            let method: ClosureType = unsafeBitCast(imp, to: ClosureType.self)
            let value = method(self, selector, tableView, row)
            return value
        }
        return false
    }
    
    /// The cell provider of the datasource.
    public var cellProvider: ((NSTableView, NSTableColumn, Int, ItemIdentifierType)->(NSView)) {
        typealias CellProviderBlock = @convention(block) (_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ identifier: Any) -> NSView
        guard let cellProvider: CellProviderBlock = getIvarValue(for: "_cellProvider") else { return { _,_,_,_ in return NSTableCellView() } }
        return cellProvider
    }
    
    /// Creates a new table cell view for the specified item using the cell provider.
    public func createCellView(for item: ItemIdentifierType, tableColumn: NSTableColumn? = nil, tableView: NSTableView) -> NSView? {
        guard let tableColumn = tableColumn ?? tableView.tableColumns.first, tableView.tableColumns.contains(tableColumn) else { return nil }
        return cellProvider(tableView, tableColumn, 0, item)
    }
        
    /// Returns a preview image of the table cell for the specified item and table column.
    public func previewImage(for item: ItemIdentifierType, tableView: NSTableView) -> NSImage? {
        let columns = tableView.tableColumns
        guard !columns.isEmpty else { return nil }
        return NSImage(combineHorizontal: columns.compactMap({ _previewImage(for: item, tableColumn: $0, tableView: tableView, useColumnWidth: $0 !== columns.last!) }), alignment: .top)
    }
    
    /// Returns a preview image of the table row for the specified item.
    public func previewImage(for item: ItemIdentifierType, tableColumn: NSTableColumn, tableView: NSTableView) -> NSImage? {
        _previewImage(for: item, tableColumn: tableColumn, tableView: tableView)
    }
    
    /// Returns a preview image of the table rows for the specified items.
    public func previewImage(for items: [ItemIdentifierType], tableView: NSTableView) -> NSImage? {
        return NSImage(combineVertical: items.compactMap({ previewImage(for: $0, tableView: tableView)}).reversed(), alignment: .left)
    }
    
    private func _previewImage(for item: ItemIdentifierType, tableColumn: NSTableColumn, tableView: NSTableView, useColumnWidth: Bool = true) -> NSImage? {
        guard let index = tableView.tableColumns.firstIndex(of: tableColumn) else { return nil }
        let view: NSView
        if let row = row(forItemIdentifier: item), let _view = tableView.view(atColumn: index, row: row, makeIfNecessary: true) {
            view = _view
        } else {
            view = cellProvider(tableView, tableColumn, 0, item) as! NSView
        }
        view.frame.size = view.systemLayoutSizeFitting(width: tableColumn.width)
        view.frame.size.width = useColumnWidth ? tableColumn.width : view.frame.size.width
        return view.renderedImage
    }
}
