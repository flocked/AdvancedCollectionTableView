//
//  CellRegistration.swift
//
//
//  Created by Florian Zand on 27.04.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public protocol NSTableViewCellRegistration {
    var columnIdentifier: NSUserInterfaceItemIdentifier? { get }
}

internal protocol _NSTableViewCellRegistration {
    func makeView(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ element: Any) ->NSTableCellView?
}

public extension NSTableView {
    /**
     Dequeues a configured reusable cell object.
     
     - Parameters:
        - registration: The cell registration for configuring the cell object. See ``AppKit/NSTableView/CellRegistration``.
        - column: The table column in which the cell gets displayed in the table view.
        - row: The index path specifying the row of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the row to perform additional configuration based on the cell’s position in the table view.
        - element: The element that provides data for the cell.
     
     - returns:A configured reusable cell object.
     */
    func makeCell<Cell, Element>(using registration: CellRegistration<Cell, Element>, forColumn column: NSTableColumn, row: Int, element: Element) -> Cell? where Cell: NSTableCellView {
        return registration.makeCell(self, column, row, element)
    }
}

public extension NSTableView {
    /**
     A registration for the table view’s cells.
     
     Use a cell registration to register cells with your table view and configure each cell for display. You create a cell registration with your cell type and data cell type as the registration’s generic parameters, passing in a registration handler to configure the cell. In the registration handler, you specify how to configure the content and appearance of that type of cell.
     
     The following example creates a cell registration for cells of type `NSTableViewCell`. Each cells textfield displays its element.
     
     ```swift
     let cellRegistration = NSTableView.CellRegistration<NSTableViewCell, String> { cell, column, row, string in
     cell.textField.stringValue = string
     }
     ```
     
     After you create a cell registration, you pass it in to ``AppKit/NSTableView/makeCell(using:forColumn:row:element:)``, which you call from your data source’s cell provider.
     
     ```swift
     dataSource = NSTableViewDiffableDataSource<Section, String>(tableView: tableView) {
     tableView, column, row, element in
     return tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: element)
     }
     ```
     
     `NSTableViewDiffableDataSource` provides a convenient initalizer:
     
     ```swift
     dataSource = NSTableViewDiffableDataSource<Section, String>(collectionView: collectionView, cellRegistration: cellRegistration)
     ```
     
     You don’t need to call table views  `register(_:forIdentifier:)`. The table view registers your cell automatically when you pass the cell registration to ``AppKit/NSTableView/makeCell(using:forColumn:row:element:)``.
          
     - Important: Do not create your cell registration inside a `NSTableViewDiffableDataSource.CellProvider` closure; doing so prevents cell reuse.
     */
    struct CellRegistration<Cell, Element>: NSTableViewCellRegistration, _NSTableViewCellRegistration where Cell: NSTableCellView  {
        
        internal let identifier: NSUserInterfaceItemIdentifier
        private let nib: NSNib?
        private let handler: Handler
        public let columnIdentifier: NSUserInterfaceItemIdentifier?
        
        // MARK: Creating a cell registration
        
        /**
         Creates a cell registration with the specified registration handler.
         
         - Parameters:
            - columnIdentifier: The identifier of the table column.
            - handler: The handler to configurate the cell.
         */
        public init(columnIdentifier: NSUserInterfaceItemIdentifier? = nil, handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
            self.identifier = NSUserInterfaceItemIdentifier(UUID().uuidString)
            self.columnIdentifier = columnIdentifier
        }
        
        /**
         Creates a cell registration with the specified registration handler and nib file.
         
         - Parameters:
            - nib: The nib of the cell.
            - columnIdentifier: The identifier of the table column.
            - handler: The handler to configurate the cell.
         */
        public init(nib: NSNib, columnIdentifier: NSUserInterfaceItemIdentifier? = nil, handler: @escaping Handler) {
            self.nib = nib
            self.handler = handler
            self.identifier = NSUserInterfaceItemIdentifier(UUID().uuidString)
            self.columnIdentifier = columnIdentifier
        }
        
        /// A closure that handles the cell registration and configuration.
        public typealias Handler = ((_ cell: Cell, _ tableColumn: NSTableColumn, _ row: Int, _ element: Element)->(Void))
        
        internal func makeCell(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ element: Element) -> Cell? {
            self.registerIfNeeded(for: tableView)
            if let columnIdentifier = self.columnIdentifier, tableColumn.identifier != columnIdentifier {
                return nil
            }
            if let cell = tableView.makeView(withIdentifier: self.identifier, owner: nil) as? Cell {
                self.handler(cell, tableColumn, row, element)
                return cell
            }
            return nil
        }
        
        internal func makeView(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ element: Any) ->NSTableCellView? {
            self.registerIfNeeded(for: tableView)
            if let columnIdentifier = self.columnIdentifier, tableColumn.identifier != columnIdentifier {
                return nil
            }
            let element = element as! Element
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
                if (tableView.registeredCellsByIdentifier[self.identifier] != Cell.self) {
                    tableView.register(Cell.self, forIdentifier: self.identifier)
                }
            }
        }
        
        internal func unregister(for tableView: NSTableView) {
            tableView.register(nil, forIdentifier: self.identifier)
        }
    }
}
