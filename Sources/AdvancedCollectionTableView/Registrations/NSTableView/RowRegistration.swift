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
    Dequeues a configured reusable rowview object.
     
     - Parameters:
        - registration: The rowview registration for configuring the rowview object. See NSTableView.RowViewRegistration.
        - column: The table column in which the cell gets displayed in the table view.
        - row: The index path specifying the row of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the row to perform additional configuration based on the cell’s position in the table view.
        - element: The element that provides data for the cell.

     - returns:A configured reusable cell object.
     */
    func makeRowView<I: NSTableRowView, E: Any>(using registration: RowViewRegistration<I, E>, forRow row: Int, element: E) -> I {
        return registration.makeView(self, row, element)
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
     
     You don’t need to call *register(_:)*, *register(_:nib:)* or *register(_:forCellWithIdentifier:)*. The table view registers your cell automatically when you pass the cell registration to makeCell(using:for:element:).
     
     - Important: Do not create your cell registration inside a *NSAdvancedAdvanceTableViewDiffableDataSource.CellProvider* closure; doing so prevents cell reuse.
    */
    class RowViewRegistration<RowView, Element> where RowView: NSTableRowView  {
        /**
         A closure that handles the cell registration and configuration.
         */
        public typealias Handler = ((_ rowView: RowView, _ row: Int, _ rowViewIdentifier: Element)->(Void))
        
        public let identifier: NSUserInterfaceItemIdentifier
        private let nib: NSNib?
        private let handler: Handler
        
        /**
         Creates a item registration with the specified registration handler.
         */
        public init(handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
            self.identifier = NSUserInterfaceItemIdentifier(String(describing: RowView.self))
        }
                
        /**
         Creates a cell registration with the specified registration handler and nib file.
         */
        public init(nib: NSNib, handler: @escaping Handler) {
            self.nib = nib
            self.handler = handler
            self.identifier = NSUserInterfaceItemIdentifier(String(describing: RowView.self))
        }
        
        internal func makeView(_ tableView: NSTableView, _ row: Int, _ element: Element) -> RowView {
           let rowView = (tableView.rowView(atRow: row, makeIfNecessary: false) as? RowView) ?? RowView(frame: .zero)
            rowView.identifier = identifier
                self.handler(rowView, row, element)
                return rowView
        }
    }
}

internal extension NSTableView {
    var registeredRowRegistrations: [NSUserInterfaceItemIdentifier] {
         get { getAssociatedValue(key: "NSTableView_registeredRowRegistrations", object: self, initialValue: []) }
         set { set(associatedValue: newValue, key: "NSTableView_registeredRowRegistrations", object: self)
         }
     }
}
