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
     Creates a diffable data source with the specified cell and section view registration, and connects it to the specified table view.
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistration: A cell registration that creates, configurates and returns each of the cells for the table view from the data the diffable data source provides.
        - sectionViewRegistration: A section view registration that creates, configurates and returns each of the section header views for the table view from the data the diffable data source provides.
     */
    convenience init<I: NSTableCellView, S: NSView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, ItemIdentifierType>, sectionViewRegistration: NSTableView.SectionHeaderRegistration<S, SectionIdentifierType>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            return _tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)!
        })
        self.sectionHeaderViewProvider = { tableView, row, section in
            tableView.makeSectionView(using: sectionViewRegistration, row: row, section: section)
        }
    }
    
    /**
     Creates a diffable data source with the specified cell registrations, and connects it to the specified table view.
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistrations: Cell registrations that create, configurate and return each of the cells for the table view from the data the diffable data source provides.
     
     - Important: Each of the cell registrations need to have a column identifier.
     */
    convenience init(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration]) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            if let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifiers?.contains(column.identifier) == true}) ?? cellRegistrations.first(where: {$0.columnIdentifiers == nil }) {
                return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
            }
            return NSTableCellView()
        })
    }
    
    /**
     Creates a diffable data source with the specified cell registrations, and connects it to the specified table view.
     
     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistrations: Cell registrations that create, configurate and return each of the cells for the table view from the data the diffable data source provides.
        - sectionViewRegistration: A section view registration that creates, configurates and returns each of the section header views for the table view from the data the diffable data source provides.
     
     - Important: Each of the cell registrations need to have a column identifier.
     */
    convenience init<S: NSView>(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration], sectionViewRegistration: NSTableView.SectionHeaderRegistration<S, SectionIdentifierType>) {
        self.init(tableView: tableView, cellProvider:  {
            _tableView, column, row, element in
            if let cellRegistration = cellRegistrations.first(where: {$0.columnIdentifiers?.contains(column.identifier) == true}) ?? cellRegistrations.first(where: {$0.columnIdentifiers == nil }) {
                return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
            }
            return NSTableCellView()
        })
    }
    
    /// Applies the section header view registration to configure and return section header views.
    func sectionHeaderViewRegistration<HeaderView: NSView>(_ registration: NSTableView.SectionHeaderRegistration<HeaderView, SectionIdentifierType>) {
        sectionHeaderViewProvider = { tableView, row, section in
            return registration.makeView(tableView, row, section)
        }
    }
}
