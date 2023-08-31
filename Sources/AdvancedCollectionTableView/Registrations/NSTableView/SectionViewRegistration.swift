//
//  SectionViewRegistration.swift
//
//
//  Created by Florian Zand on 27.04.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableView {
    /**
     Dequeues a configured reusable cell object.
     
     - Parameters:
        - registration: The cell registration for configuring the cell object. See `NSTableView.SectionViewRegistration.
        - column: The table column in which the cell gets displayed in the table view.
        - row: The index path specifying the row of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the row to perform additional configuration based on the cell’s position in the table view.
        - element: The element that provides data for the cell.
     
     - returns:A configured reusable cell object.
     */
    func makeSectionView<View, Section>(using registration: SectionViewRegistration<View, Section>, row: Int, section: Section) -> View? where View: NSView {
        return registration.makeView(self, row, section)
    }
}

public extension NSTableView {
    /**
     A registration for the table view’s cells.
     
     Use a cell registration to register cells with your table view and configure each cell for display. You create a cell registration with your cell type and data cell type as the registration’s generic parameters, passing in a registration handler to configure the cell. In the registration handler, you specify how to configure the content and appearance of that type of cell.
     
     The following example creates a cell registration for cells of type `NSTableViewCell`. Each cells textfield displays its element.
     
     ```swift
     let cellRegistration = NSTableView.SectionViewRegistration<NSTableViewCell, String> { cell, indexPath, string in
     cell.textField.stringValue = string
     }
     ```
     
     After you create a cell registration, you pass it in to ``AppKit/NSTableView/makeCell(using:forColumn:row:element:)``, which you call from your data source’s cell provider.
     
     ```swift
     dataSource = NSAdvancedAdvanceTableViewDiffableDataSource<Section, String>(tableView: tableView) {
     (tableView: NSTableView, indexPath: IndexPath, cellIdentifier: String) -> NSTableViewCell? in
     
     return tableView.makeCell(using: cellRegistration,
     for: indexPath,
     cell: cellIdentifier)
     }
     ```
     
     `NSTableViewDiffableDataSource` provides a convenient initalizer:
     
     ```swift
     dataSource = NSTableViewDiffableDataSource<Section, String>(collectionView: collectionView, cellRegistration: cellRegistration)
     ```
     
     You don’t need to call  ``AppKit/NSTableView/register(_:forIdentifier:)``, `register(_:nib:)` or `register(_:forCellWithIdentifier:)`. The table view registers yo
     ur cell automatically when you pass the cell registration to ``AppKit/NSTableView/makeCell(using:forColumn:row:element:)``.
          
     - Important: Do not create your cell registration inside a `NSAdvancedAdvanceTableViewDiffableDataSource.CellProvider` closure; doing so prevents cell reuse.
     */
    class SectionViewRegistration<View, Section> where View: NSView  {
        
        internal let identifier: NSUserInterfaceItemIdentifier
        private let nib: NSNib?
        private let handler: Handler
        
        // MARK: Creating a cell registration
        
        /**
         Creates a cell registration with the specified registration handler.
         
         - Parameters:
            - identifier: The identifier of the cell registration.
            - columnIdentifier: The identifier of the table column.
            - handler: The handler to configurate the cell.
         */
        public init(identifier: NSUserInterfaceItemIdentifier? = nil, handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
            self.identifier = identifier ?? NSUserInterfaceItemIdentifier(UUID().uuidString)
        }
        
        /**
         Creates a cell registration with the specified registration handler and nib file.
         
         - Parameters:
            - nib: The nib of the cell.
            - identifier: The identifier of the cell registration.
            - columnIdentifier: The identifier of the table column.
            - handler: The handler to configurate the cell.
         */
        public init(nib: NSNib, identifier: NSUserInterfaceItemIdentifier? = nil, handler: @escaping Handler) {
            self.nib = nib
            self.handler = handler
            self.identifier = identifier ?? NSUserInterfaceItemIdentifier(UUID().uuidString)
        }
        
        /// A closure that handles the cell registration and configuration.
        public typealias Handler = ((_ view: View, _ row: Int, _ sectionIdentifier: Section)->(Void))
        
        internal func makeView(_ tableView: NSTableView, _ row: Int, _ section: Section) -> View? {
            self.registerIfNeeded(for: tableView)
            if viewIsTableCellView {
                if let sectionView = tableView.makeView(withIdentifier: self.identifier, owner: nil) as? View {
                    self.handler(sectionView, row, section)
                    return sectionView
                }
            } else {
                let sectionView = View()
                self.handler(sectionView, row, section)
                return sectionView
            }
            return nil
        }
        
        internal var viewIsTableCellView: Bool {
            View.self is NSTableCellView.Type
        }
        
        internal var sectionViewTableCellType: NSTableCellView.Type? {
            (View.self as? NSTableCellView.Type)
        }
        
        internal func registerIfNeeded(for tableView: NSTableView) {
            guard let sectionViewTableCellType = sectionViewTableCellType else { return }
            if let nib = nib {
                if (tableView.registeredNibsByIdentifier?[self.identifier] != self.nib) {
                    tableView.register(nib, forIdentifier: self.identifier)
                }
            } else {
                if (tableView.registeredCellsByIdentifier?[self.identifier] != View.self) {
                    tableView.register(sectionViewTableCellType, forIdentifier: self.identifier)
                }
            }
        }
        
        internal func unregister(for tableView: NSTableView) {
            tableView.register(nil, forIdentifier: self.identifier)
        }
    }
}
