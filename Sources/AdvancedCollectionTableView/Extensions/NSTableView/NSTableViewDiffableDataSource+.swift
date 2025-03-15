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
    private var cellProvider: ((NSTableView, NSTableColumn, Int, ItemIdentifierType)->(Any)) {
        guard let cellProvider: ((NSTableView, NSTableColumn, Int, ItemIdentifierType)->(NSView?)) = getIvarValue(for: "cellProvider") else { return { _,_,_,_ in return NSTableCellView() } }
        return cellProvider
    }
    
    private func previewImage(for item: ItemIdentifierType, tableView: NSTableView) -> NSImage? {
        let columns = tableView.tableColumns
        guard !columns.isEmpty else { return nil }
        return NSImage(combining: columns.compactMap({ _previewImage(for: item, tableColumn: $0, tableView: tableView, useColumnWidth: $0 !== columns.last!) }))
    }
    
    private func previewImage(for item: ItemIdentifierType, tableColumn: NSTableColumn, tableView: NSTableView) -> NSImage? {
        _previewImage(for: item, tableColumn: tableColumn, tableView: tableView)
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

extension NSImage {
    convenience init?(combining images: [NSImage]) {
        guard !images.isEmpty else { return nil }
        
        let totalWidth = images.reduce(0) { $0 + $1.size.width }
        let maxHeight = images.map { $0.size.height }.max() ?? 0
        
        let newSize = NSSize(width: totalWidth, height: maxHeight)
        let newImage = NSImage(size: newSize)
        
        newImage.lockFocus()
        
        var xOffset: CGFloat = 0
        for image in images {
            let imageRect = NSRect(x: xOffset, y: maxHeight - image.size.height, width: image.size.width, height: image.size.height)
            image.draw(in: imageRect)
            xOffset += image.size.width
        }
        
        newImage.unlockFocus()
        
        self.init(data: newImage.tiffRepresentation!)
    }
}
