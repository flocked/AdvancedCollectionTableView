//
//  SectionHeaderRegistration.swift
//
//
//  Created by Florian Zand on 27.04.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableView {
    /**
     Dequeues a configured reusable section view object.
     
     - Parameters:
        - registration: The cell registration for configuring the cell object. See ``AppKit/NSTableView/SectionHeaderRegistration``.
        - row: The index path specifying the row of the section view. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the row to perform additional configuration based on the cell’s position in the table view.
        - section: The section element that provides data for the cell.
     
     - returns:A configured reusable section view object.
     */
    func makeSectionView<SectionHeaderView, Section>(using registration: SectionHeaderRegistration<SectionHeaderView, Section>, row: Int, section: Section) -> SectionHeaderView {
        return registration.makeView(self, row, section)
    }
}

public extension NSTableView {
    /**
     A registration for the table view’s section header views.
     
     Use a section view registration to register views with your table view and configure each view for display. You create a section view registration with your view type and section type as the registration’s generic parameters, passing in a registration handler to configure the view. In the registration handler, you specify how to configure the content and appearance of that type of view.
     
     The following example creates a section view registration for views of type `NSTableViewCell`. Each cells textfield displays its element.
     
     ```swift
     let sectionViewRegistration = NSTableView.SectionHeaderRegistration<NSTableViewCell, String> { cell, indexPath, string in
     cell.textField.stringValue = string
     }
     ```
     
     After you create a section view registration, you pass it in to ``AppKit/NSTableView/makeSectionView(using:row:section:)``, which you call from your data source’s section header view provider.
     
     ```swift
     dataSource.sectionHeaderViewProvider = { tableView, row, section in
     return tableView.makeSectionView(using: sectionViewRegistration, row: row, section: section)
     }
     ```
     */
    struct SectionHeaderRegistration<SectionHeaderView, Section> where SectionHeaderView: NSTableSectionHeaderView  {
        
        internal let identifier: NSUserInterfaceItemIdentifier
        private let nib: NSNib?
        private let handler: Handler
        
        // MARK: Creating a section view registration
        
        /**
         Creates a section view registration with the specified registration handler.
         
         - Parameters:
            - identifier: The identifier of the section view registration.
            - columnIdentifier: The identifier of the table column.
            - handler: The handler to configurate the view.
         */
        public init(handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
            self.identifier = NSUserInterfaceItemIdentifier(UUID().uuidString)
        }
        
        /**
         Creates a section view registration with the specified registration handler and nib file.
         
         - Parameters:
            - nib: The nib of the view.
            - handler: The handler to configurate the view.
         */
        public init(nib: NSNib, handler: @escaping Handler) {
            self.nib = nib
            self.handler = handler
            self.identifier = NSUserInterfaceItemIdentifier(UUID().uuidString)
        }
        
        /// A closure that handles the section view registration and configuration.
        public typealias Handler = ((_ view: SectionHeaderView, _ row: Int, _ sectionIdentifier: Section)->(Void))
        
        internal func makeView(_ tableView: NSTableView, _ row: Int, _ section: Section) -> SectionHeaderView {
            
            self.registerIfNeeded(for: tableView)
            if let sectionView = tableView.makeView(withIdentifier: self.identifier, owner: nil) as? SectionHeaderView {
                self.handler(sectionView, row, section)
                return sectionView
            } else {
                let sectionView = SectionHeaderView()
                self.handler(sectionView, row, section)
                return sectionView
            }
        
            let sectionView = SectionHeaderView()
            self.handler(sectionView, row, section)
            return sectionView
        }
        
        
        internal var viewIsTableCellView: Bool {
            SectionHeaderView.self is NSTableCellView.Type
        }
        
        internal var sectionViewTableCellType: NSTableCellView.Type? {
            SectionHeaderView.self as? NSTableCellView.Type
        }
         
        
        internal func registerIfNeeded(for tableView: NSTableView) {
            if let nib = nib {
                if (tableView.registeredNibsByIdentifier?[self.identifier] != self.nib) {
                    tableView.register(nib, forIdentifier: self.identifier)
                }
            } else {
                if (tableView.registeredCellsByIdentifier[self.identifier] != SectionHeaderView.self) {
                    tableView.register(SectionHeaderView.self, forIdentifier: self.identifier)
                }
            }
        }
        
        internal func unregister(for tableView: NSTableView) {
            tableView.register(nil, forIdentifier: self.identifier)
        }
    }
}
