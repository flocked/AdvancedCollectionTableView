//
//  CellRegistration.swift
//
//
//  Created by Florian Zand on 27.04.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public protocol TableCellViewRegistration {
    associatedtype Element
    func makeView(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ element: Element) -> NSView?
}

public extension NSTableView {
    /**
     Dequeues a configured reusable cell object.
     
     - Parameters:
     - registration: The cell registration for configuring the cell object. See NSTableView.CellRegistration.
     - column: The table column in which the cell gets displayed in the table view.
     - row: The index path specifying the row of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the row to perform additional configuration based on the cell’s position in the table view.
     - element: The element that provides data for the cell.
     
     - returns:A configured reusable cell object.
     */
    func makeCell<I: NSTableCellView, E: Any>(using registration: CellRegistration<I, E>, forColumn column: NSTableColumn, row: Int, element: E) -> I? {
        return registration.makeCell(self, column, row, element)
    }
}

public extension NSTableView {
    /**
     A registration for the table view’s cells.
     
     Use a cell registration to register cells with your table view and configure each cell for display. You create a cell registration with your cell type and data cell type as the registration’s generic parameters, passing in a registration handler to configure the cell. In the registration handler, you specify how to configure the content and appearance of that type of cell.
     
     The following example creates a cell registration for cells of type NSTableViewCell. Each cells textfield displays its element.
     
     ```
     let cellRegistration = NSTableView.CellRegistration<NSTableViewCell, String> { cell, indexPath, string in
     cell.textField.stringValue = string
     }
     ```
     
     After you create a cell registration, you pass it in to makeCell(using:for:element:), which you cell from your data source’s cell provider.
     
     ```
     dataSource = NSAdvancedAdvanceTableViewDiffableDataSource<Section, String>(tableView: tableView) {
     (tableView: NSTableView, indexPath: IndexPath, cellIdentifier: String) -> NSTableViewCell? in
     
     return tableView.makeCell(using: cellRegistration,
     for: indexPath,
     cell: cellIdentifier)
     }
     ```
     
     `NSTableViewDiffableDataSource` provides a convenient initalizer:
     
     ```
     dataSource = NSTableViewDiffableDataSource<Section, String>(collectionView: collectionView, cellRegistration: cellRegistration)
     ```
     
     You don’t need to cell *register(_:)*, *register(_:nib:)* or *register(_:forCellWithIdentifier:)*. The table view registers your cell automatically when you pass the cell registration to makeCell(using:for:element:).
     
     - Important: Do not create your cell registration inside a *NSAdvancedAdvanceTableViewDiffableDataSource.CellProvider* closure; doing so prevents cell reuse.
     */
    class CellRegistration<Cell, Element>: TableCellViewRegistration where Cell: NSTableCellView  {
        public func makeView(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ element: Element) -> NSView? {
            self.registerIfNeeded(for: tableView)
            if let cell = tableView.makeView(withIdentifier: self.identifier, owner: nil) as? Cell {
                self.handler(cell, tableColumn, row, element)
                return cell
            }
            return nil
        }
        
        internal let identifier: NSUserInterfaceItemIdentifier
        private let nib: NSNib?
        private let handler: Handler
        
        // MARK: Creating a cell registration
        
        /**
         Creates a cell registration with the specified registration handler.
         */
        public init(identifier: NSUserInterfaceItemIdentifier? = nil, handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
            self.identifier = identifier ?? NSUserInterfaceItemIdentifier(UUID().uuidString)
        }
        
        /**
         Creates a cell registration with the specified registration handler and nib file.
         */
        public init(nib: NSNib, identifier: NSUserInterfaceItemIdentifier? = nil, handler: @escaping Handler) {
            self.nib = nib
            self.handler = handler
            self.identifier = identifier ?? NSUserInterfaceItemIdentifier(UUID().uuidString)
        }
        
        /// A closure that handles the cell registration and configuration.
        public typealias Handler = ((_ cell: Cell, _ tableColumn: NSTableColumn, _ row: Int, _ cellIdentifier: Element)->(Void))
        
        internal func makeCell(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ element: Element) -> Cell? {
            self.registerIfNeeded(for: tableView)
            if let cell = tableView.makeView(withIdentifier: self.identifier, owner: nil) as? Cell {
                self.handler(cell, tableColumn, row, element)
                return cell
            }
            return nil
        }
        
        internal func registerIfNeeded(for tableView: NSTableView) {
            if let nib = nib {
                if (tableView.registeredNibsByIdentifier?[self.identifier] != self.nib) {
                    tableView.register(nib, forIdentifier: self.identifier)
                }
            } else {
                if (tableView.registeredCellsByIdentifier?[self.identifier] != Cell.self) {
                    tableView.register(Cell.self, forIdentifier: self.identifier)
                }
            }
        }
        
        internal func unregister(for tableView: NSTableView) {
            tableView.register(nil, forIdentifier: self.identifier)
        }
    }
}
