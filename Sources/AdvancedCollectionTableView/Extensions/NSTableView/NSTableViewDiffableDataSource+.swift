//
//  NSTableViewDiffableDataSource+.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit

extension NSTableViewDiffableDataSource {
    /**
     Asks the datasource for a view to display the specified row and column.
     
     - Parameters:
        - tableView: The table view that sent the message.
        - tableColumn: The table column. (If the row is a group row, tableColumn is nil.)
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
     
     - Returns: An instance or subclass of NSTableRowView. If nil is returned, an NSTableRowView instance will be created and used.
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
     
     - Returns: `true` if the specified row should have the group row style drawn, `false otherwise.
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
}
