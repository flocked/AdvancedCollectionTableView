//
//  File.swift
//  
//
//  Created by Florian Zand on 10.12.22.
//

import AppKit

@available(macOS 11.0, *)
public extension NSTableViewDiffableDataSource {
    /**
     Creates a diffable data source with the specified cell provider, and connects it to the specified table view.
     
     - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistration: A cell registration that creates, configurate and returns each of the cells for the table view from the data the diffable data source provides.
     */
    convenience init<I: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, ItemIdentifierType>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            return _tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)!
        })
    }
    
    convenience init<I: NSTableCellView, R: NSTableRowView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, ItemIdentifierType>, rowRegistration: NSTableView.RowViewRegistration<R, ItemIdentifierType>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            return _tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)!
        })
        self.rowViewProvider = { _tableView, row, element in
            let element = element as! ItemIdentifierType
            return _tableView.makeRowView(using: rowRegistration, forRow: row, element: element)
        }
    }
    
    convenience init<I: NSTableView.CellRegistration<NSTableCellView, ItemIdentifierType>>(tableView: NSTableView, cellRegistrations: [I]) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            let cellRegistration = cellRegistrations.first(where: {$0.identifier == column.identifier})!
            return _tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)!
        })
    }
    
    convenience init<I: NSTableView.CellRegistration<NSTableCellView, ItemIdentifierType>, R: NSTableRowView>(tableView: NSTableView, cellRegistrations: [I], rowRegistration: NSTableView.RowViewRegistration<R, ItemIdentifierType>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            let cellRegistration = cellRegistrations.first(where: {$0.identifier == column.identifier})!
            return _tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)!
        })
        self.rowViewProvider = { _tableView, row, element in
            let element = element as! ItemIdentifierType
            return _tableView.makeRowView(using: rowRegistration, forRow: row, element: element)
        }
    }
}
