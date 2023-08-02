//
//  NSTableViewDiffableDataSource+.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit

public extension NSTableViewDiffableDataSource {
    /**
     Returns the item identifiers for the specified row indexes.
     
     - Parameters rows: The row indexes.
     - Returns: An array of item identifiers for row indexes.
     */
    func itemIdentifiers(for rows: [Int]) -> [ItemIdentifierType] {
        return rows.compactMap({self.itemIdentifier(forRow:$0)})
    }
    
    /**
     Returns the row indexes for the specified item identifiers.
     
     - Parameters identifiers: The item identifiers.
     - Returns: An array of row index for the item identifiers.
     */
    func rows(for identifiers: [ItemIdentifierType]) -> [Int] {
        return identifiers.compactMap({self.row(forItemIdentifier: $0)})
    }
    
    /**
     Asks the datasource for a view to display the specified row and column.
     
     - Parameters tableView: The table view that sent the message.
     - Parameters tableColumn: The table column. (If the row is a group row, tableColumn is nil.)
     - Parameters row: The row index.

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
}
