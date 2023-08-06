//
//  NSTableViewDiffableDataSource+Registration.swift
//  
//
//  Created by Florian Zand on 10.12.22.
//

import AppKit

public extension NSTableViewDiffableDataSource {
    /**
     Creates a diffable data source with the specified cell registration, and connects it to the specified table view.
     
     - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistration: A cell registration that creates, configurates and returns each of the cells for the table view from the data the diffable data source provides.
     */
    convenience init<I: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, ItemIdentifierType>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            return _tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)!
        })
    }
    
    /**
     Creates a diffable data source with the specified cell and row registration, and connects it to the specified table view.
     
     - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistration: A cell registration that creates, configurates and returns each of the cells for the table view from the data the diffable data source provides.
     - rowRegistration: A row registration that creates, configurates and returns each of the rows for the table view from the data the diffable data source provides.
     */
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
    
    /**
     Creates a diffable data source with the specified cell registrations, and connects it to the specified table view.
     
     - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistrations: Cell registrations that create, configurate and return each of the cells for the table view from the data the diffable data source provides.
     
     - Important: Each of the cell registrations need to have column identifier.
     */
    convenience init(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration]) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifier == column.identifier})!
            return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
        })
    }
    
    /**
     Creates a diffable data source with the specified cell and row registrations, and connects it to the specified table view.
     
     - Parameters:
     - tableView: The initialized table view object to connect to the diffable data source.
     - cellRegistrations: Cell registrations that create, configurate and return each of the cells for the table view from the data the diffable data source provides.
     - rowRegistration: A row registration that creates, configurates and returns each of the rows for the table view from the data the diffable data source provides.
     
     - Important: Each of the cell registrations need to have column identifier.
     */
    convenience init<I: NSTableView.CellRegistration<NSTableCellView, ItemIdentifierType>, R: NSTableRowView>(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration], rowRegistration: NSTableView.RowViewRegistration<R, ItemIdentifierType>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifier == column.identifier})!
            return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
        })
        self.rowViewProvider = { _tableView, row, element in
            let element = element as! ItemIdentifierType
            return _tableView.makeRowView(using: rowRegistration, forRow: row, element: element)
        }
    }
}
