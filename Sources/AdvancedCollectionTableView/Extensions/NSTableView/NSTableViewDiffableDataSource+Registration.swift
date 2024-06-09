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
        self.init(tableView: tableView, cellProvider: {
            _tableView, column, row, item in
            _tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, item: item)!
        })
    }

    /**
     Creates a diffable data source with the specified cell and section view registration, and connects it to the specified table view.

     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistration: A cell registration that creates, configurates and returns each of the cells for the table view from the data the diffable data source provides.
        - sectionHeaderRegistration: A section view registration that creates, configurates and returns each of the section header views for the table view from the data the diffable data source provides.
     */
    convenience init<I: NSTableCellView, S: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<I, ItemIdentifierType>, sectionHeaderRegistration: NSTableView.CellRegistration<S, SectionIdentifierType>) {
        self.init(tableView: tableView, cellProvider: {
            _tableView, column, row, item in
            _tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, item: item)!
        })
        useSectionHeaderViewRegistration(sectionHeaderRegistration)
    }

    /**
     Creates a diffable data source with the specified cell registrations, and connects it to the specified table view.

     - Parameters:
        - tableView: The initialized table view object to connect to the diffable data source.
        - cellRegistrations: Cell registrations that create, configurate and return each of the cells for the table view from the data the diffable data source provides.

     - Important: Each of the cell registrations need to have a column identifier.
     */
    convenience init(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration]) {
        self.init(tableView: tableView, cellProvider: {
            _, column, row, element in
            if let cellRegistration = cellRegistrations.first(where: { $0.columnIdentifiers?.contains(column.identifier) == true }) ?? cellRegistrations.first(where: { $0.columnIdentifiers == nil }) {
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
        - sectionHeaderRegistration: A section view registration that creates, configurates and returns each of the section header views for the table view from the data the diffable data source provides.

     - Important: Each of the cell registrations need to have a column identifier.
     */
    convenience init<S: NSTableCellView>(tableView: NSTableView, cellRegistrations: [NSTableViewCellRegistration], sectionHeaderRegistration: NSTableView.CellRegistration<S, SectionIdentifierType>) {
        self.init(tableView: tableView, cellProvider: {
            _, column, row, element in
            if let cellRegistration = cellRegistrations.first(where: { $0.columnIdentifiers?.contains(column.identifier) == true }) ?? cellRegistrations.first(where: { $0.columnIdentifiers == nil }) {
                return (cellRegistration as! _NSTableViewCellRegistration).makeView(tableView, column, row, element)!
            }
            return NSTableCellView()
        })
        useSectionHeaderViewRegistration(sectionHeaderRegistration)
    }

    /// Uses the specified cell registration to configure and return section header views.
    func useSectionHeaderViewRegistration<HeaderView: NSTableCellView>(_ registration: NSTableView.CellRegistration<HeaderView, SectionIdentifierType>) {
        sectionHeaderViewProvider = { tableView, row, section in
            if let column = tableView.tableColumns.first, let cellView = tableView.makeCellView(using: registration, forColumn: column, row: row, item: section) {
                return NSTableSectionHeaderView(cellView: cellView)
            }
            return NSTableSectionHeaderView()
        }
    }
}
