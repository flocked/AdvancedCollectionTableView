//
//  RowRegistration.swift
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

     The following example creates a row registration for row views of type [NSTableRowView](https://developer.apple.com/documentation/appkit/nstablerowview).

     ```swift
     let rowRegistration = NSTableView.RowRegistration<NSTableRowView, String> { row, indexPath, string in

     }
     ```

     After you create a row registration, you pass it in to ``makeRowView(using:forRow:item:)``, which you call from your data source’s row provider.

     ```swift
     dataSource.rowProvider = { tableView, row, item in
     return tableView.makeRowView(using: rowRegistration, forRow: row, item)
     }
     ```
     */
    struct RowRegistration<RowView, Item> where RowView: NSTableRowView {
        let identifier: NSUserInterfaceItemIdentifier = .init(UUID().uuidString)
        let nib: NSNib?
        let handler: Handler

        // MARK: Creating a row registration

        /**
         Creates a row registration with the specified registration handler.

         - Parameters:
            - handler: The handler to configurate the row view.
         */
        public init(handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
        }

        /**
         Creates a row registration with the specified registration handler and nib file.

         - Parameters:
            - nib: The nib of the row view.
            - handler: The handler to configurate the row view.
         */
        public init(nib: NSNib, handler: @escaping Handler) {
            self.handler = handler
            self.nib = nib
        }

        /// A closure that handles the row registration and configuration.
        public typealias Handler = (_ rowView: RowView, _ row: Int, _ item: Item) -> Void

        func makeView(_ tableView: NSTableView, _ row: Int, _ item: Item) -> RowView {
            let rowView = (tableView.rowView(atRow: row, makeIfNecessary: false) as? RowView) ?? RowView(frame: .zero)
            rowView.identifier = identifier
            handler(rowView, row, item)
            return rowView
        }
    }
}

extension NSTableView {
    /**
     Dequeues a configured reusable row view object.

     - Parameters:
        - registration: The row view registration for configuring the rowview object. See ``RowRegistration``.
        - row: The index path specifying the row of the row. The data source receives this information when it is asked for the row and should just pass it along. This method uses the row to perform additional configuration based on the row’s position in the table view.
        - item: The item that provides data for the row.

     - Returns:A configured reusable row view object.
     */
    public func makeRowView<RowView, Item>(using registration: RowRegistration<RowView, Item>, forRow row: Int, item: Item) -> RowView where RowView: NSTableRowView {
        registration.makeView(self, row, item)
    }
}
