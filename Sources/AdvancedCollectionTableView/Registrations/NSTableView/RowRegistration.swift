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
     A registration for the table view’s row views.
     
     Use a row registration to register row views with your table view and configure each row for display. You create a row registration with your row type and data row type as the registration’s generic parameters, passing in a registration handler to configure the row. In the registration handler, you specify how to configure the content and appearance of that type of row.
     
     The following example creates a row registration for row views of type `NSTableRowView`.
     
     ```swift
     let rowRegistration = NSTableView.RowRegistration<NSTableRowView, String> { row, indexPath, string in
     
     }
     ```
     
     After you create a row registration, you pass it in to ``AppKit/NSTableView/makeRowView(using:forRow:element:)``, which you call from your data source’s row provider.
     
     ```swift
     dataSource.rowProvider = { tableView, row, element in
     return tableView.makeRowView(using: rowRegistration, forRow: row, element)
     }
     ```
     */
    struct RowRegistration<RowView, Element> where RowView: NSTableRowView  {
        
        let identifier: NSUserInterfaceItemIdentifier
        let nib: NSNib?
        let handler: Handler
        
        // MARK: Creating a row registration
        
        /**
         Creates a row registration with the specified registration handler.
         
         - Parameters:
            - identifier: The identifier of the row registration.
            - handler: The handler to configurate the row view.
         */
        public init(handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
            self.identifier = NSUserInterfaceItemIdentifier(String(describing: RowView.self))
        }
        
        /**
         Creates a row registration with the specified registration handler and nib file.
         
         - Parameters:
            - nib: The nib of the row view.
            - identifier: The identifier of the row registration.
            - handler: The handler to configurate the row view.
         */
        public init(nib: NSNib, handler: @escaping Handler) {
            self.nib = nib
            self.handler = handler
            self.identifier = NSUserInterfaceItemIdentifier(String(describing: RowView.self))
        }
        
        /// A closure that handles the row registration and configuration.
        public typealias Handler = ((_ rowView: RowView, _ row: Int, _ rowViewIdentifier: Element)->(Void))
        
        func makeView(_ tableView: NSTableView, _ row: Int, _ element: Element) -> RowView {
            let rowView = (tableView.rowView(atRow: row, makeIfNecessary: false) as? RowView) ?? RowView(frame: .zero)
            rowView.identifier = identifier
            self.handler(rowView, row, element)
            return rowView
        }
    }
}

public extension NSTableView {
    /**
     Dequeues a configured reusable row view object.
     
     - Parameters:
        - registration: The row view registration for configuring the rowview object. See ``AppKit/NSTableView/RowRegistration``.
        - row: The index path specifying the row of the row. The data source receives this information when it is asked for the row and should just pass it along. This method uses the row to perform additional configuration based on the row’s position in the table view.
        - element: The element that provides data for the row.
     
     - returns:A configured reusable row view object.
     */
    func makeRowView<RowView, Element>(using registration: RowRegistration<RowView, Element>, forRow row: Int, element: Element) -> RowView where RowView: NSTableRowView {
        return registration.makeView(self, row, element)
    }
}
