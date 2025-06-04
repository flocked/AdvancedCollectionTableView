//
//  CellRegistration.swift
//
//
//  Created by Florian Zand on 27.04.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableView {
    /**
     A registration for the table view’s cells.

     Use a cell registration to register table cell views with your table view and configure each cell for display. You create a cell registration with your cell type and data cell type as the registration’s generic parameters, passing in a registration handler to configure the cell. In the registration handler, you specify how to configure the content and appearance of that type of cell.

     The following example creates a cell registration for cells of type [NSTableCellView](https://developer.apple.com/documentation/appkit/nstablecellview). Each cells textfield displays its item.

     ```swift
     let cellRegistration = NSTableView.CellRegistration<NSTableCellView, String> { cell, column, row, string in

        var contentConfiguration = cell.defaultContentConfiguration()

        contentConfiguration.text = string
        contentConfiguration.textProperties.color = .lightGray

        cell.contentConfiguration = contentConfiguration
     }
     ```

     After you create a cell registration, you pass it in to ``AppKit/NSTableView/makeCellView(using:forColumn:row:item:)``, which you call from your data source’s cell provider.

     ```swift
     dataSource = NSTableViewDiffableDataSource<Section, String>(tableView: tableView) {
     tableView, column, row, item in
        return tableView.makeCellView(using: cellRegistration, forColumn: column, row: row, item: item)
     }
     ```

     `NSTableViewDiffableDataSource` provides a convenient initalizer:

     ```swift
     dataSource = NSTableViewDiffableDataSource(collectionView: collectionView, cellRegistration: cellRegistration)
     ```

     You don’t need to call table views  [register(_:forIdentifier:)](https://developer.apple.com/documentation/appkit/nstableview/1524297-register). The table view registers your cell automatically when you pass the cell registration to ``makeCellView(using:forColumn:row:item:)``.

     ## Column Identifiers

     With `columnIdentifiers` you can restrict the cell to specific table columns when used with ``TableViewDiffableDataSource`` using ``TableViewDiffableDataSource/init(tableView:cellRegistrations:)``. You only have to provide column identifiers when your table view has multiple columns and the columns should use different types of table cells. The data source will use the matching cell registration for each column.
     
     ## Section Header View
     
     You can use a cell registration to configurate and return the table view’s section header views in diffable data source using ``TableViewDiffableDataSource/applySectionHeaderRegistration(_:)``:
          
     ```swift
     diffableDataSource.applySectionHeaderRegistration(cellRegistration)
     ```
     
     - Important: Do not create your cell registration inside a [NSTableViewDiffableDataSource.CellProvider](https://developer.apple.com/documentation/appkit/nstableviewdiffabledatasource/cellprovider) closure; doing so prevents cell reuse.
     */
    struct CellRegistration<Cell, Item>: NSTableViewCellRegistration, _NSTableViewCellRegistration where Cell: NSTableCellView {
        let identifier: NSUserInterfaceItemIdentifier = .init(UUID().uuidString)
        let nib: NSNib?
        let handler: Handler

        /**
         The identifiers of the table columns,
         
         An empty array indicates that the cell isn't restricted to any specific columns.

         The identifiers are used when the registration is applied to ``TableViewDiffableDataSource``. If the value isn't `nil`, the table cell is displayed for the columns with the same identifiers.
         */
        public let columnIdentifiers: [NSUserInterfaceItemIdentifier]

        // MARK: Creating a cell registration

        /**
         Creates a cell registration with the specified registration handler.

         - Parameters:
            - columnIdentifiers: The identifiers of the table columns. The identifiers of the table columns. The default value is `[]`, which indicates that the cell isn't restricted to specific columns.
            - handler: The handler to configurate the cell.
         */
        public init(columnIdentifiers: [NSUserInterfaceItemIdentifier] = [], handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
            self.columnIdentifiers = columnIdentifiers
        }

        /**
         Creates a cell registration with the specified registration handler and nib file.

         - Parameters:
            - nib: The nib of the cell.
            - columnIdentifiers: The identifiers of the table columns. The default value is `[]`, which indicates that the cell isn't restricted to specific columns.
            - handler: The handler to configurate the cell.
         */
        public init(nib: NSNib, columnIdentifiers: [NSUserInterfaceItemIdentifier] = [], handler: @escaping Handler) {
            self.handler = handler
            self.nib = nib
            self.columnIdentifiers = columnIdentifiers
        }

        /// A closure that handles the cell registration and configuration.
        public typealias Handler = (_ cellView: Cell, _ tableColumn: NSTableColumn, _ row: Int, _ item: Item) -> Void

        func makeCellView(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ item: Item) -> Cell? {
            let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? Cell ?? Cell()
            cell.identifier = identifier
            handler(cell, tableColumn, row, item)
            return cell
        }

        func makeView(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ item: Any) -> NSTableCellView? {
            guard let item = item as? Item else { return nil }
            return makeCellView(tableView, tableColumn, row, item)
        }

        func register(_ tableView: NSTableView) {
            if let nib = nib {
                if tableView.registeredNibsByIdentifier?[identifier] != self.nib {
                    tableView.register(nib, forIdentifier: identifier)
                }
            } else {
                if tableView.registeredClassesByIdentifier[identifier] != Cell.self {
                    tableView.register(Cell.self, forIdentifier: identifier)
                }
            }
        }

        func unregister(_ tableView: NSTableView) {
            tableView.register(nil, forIdentifier: identifier)
        }
    }
}

extension NSTableView {
    /**
     Dequeues a configured reusable cell object.

     - Parameters:
        - registration: The cell registration for configuring the cell object. See ``CellRegistration``.
        - column: The table column in which the cell gets displayed in the table view.
        - row: The index path specifying the row of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the row to perform additional configuration based on the cell’s position in the table view.
        - item: The item that provides data for the cell.

     - Returns: A configured reusable cell object.
     */
    public func makeCellView<CellView, Item>(using registration: CellRegistration<CellView, Item>, forColumn column: NSTableColumn, row: Int, item: Item) -> CellView? where CellView: NSTableCellView {
        registration.makeCellView(self, column, row, item)
    }
}

/// A registration for table view’s cells.
public protocol NSTableViewCellRegistration {
    /// The identifiers of the table columns.
    var columnIdentifiers: [NSUserInterfaceItemIdentifier] { get }
}

protocol _NSTableViewCellRegistration {
    func makeView(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ item: Any) -> NSTableCellView?
}
