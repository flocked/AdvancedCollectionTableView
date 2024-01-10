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
     A registration for the table view’s section header views.
     
     Use a section header view registration to register views with your table view and configure each view for display. You create a section header view registration with your view type and section type as the registration’s generic parameters, passing in a registration handler to configure the view. In the registration handler, you specify how to configure the content and appearance of that type of view.
     
     The following example creates a section view registration for views of type `NSTableSectionHeaderView`. Each section header views defautl content configuration text displays its string.
     
     ```swift
     let sectionViewRegistration = NSTableView.SectionHeaderRegistration<NSTableSectionHeaderView, String> {
     sectionHeaderView, indexPath, string in
        var configuration = sectionHeaderView.defaultContentConfiguration()
        configuration.text = string
     
        sectionHeaderView.contentConfiguration = configuration
     }
     ```
     
     After you create a section view registration, you pass it in to ``AppKit/NSTableView/makeSectionHeaderView(using:row:section:)``, which you call from your data source’s section header view provider.
     
     ```swift
     dataSource.sectionHeaderViewProvider = { tableView, row, section in
        return tableView.makeSectionHeaderView(using: sectionViewRegistration, row: row, section: section)
     }
     ```
     */
    struct SectionHeaderRegistration<SectionHeader, Section> where SectionHeader: NSTableSectionHeaderView {

        let identifier: NSUserInterfaceItemIdentifier
        let nib: NSNib?
        let handler: Handler

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
            self.identifier = .init(UUID().uuidString)
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
            self.identifier = .init(UUID().uuidString)
        }

        /// A closure that handles the section view registration and configuration.
        public typealias Handler = ((_ sectionHeaderView: SectionHeader, _ row: Int, _ section: Section) -> Void)

        func makeView(_ tableView: NSTableView, _ row: Int, _ section: Section) -> SectionHeader {
            let sectionView = SectionHeader()
            self.handler(sectionView, row, section)
            return sectionView
        }
    }
}

public extension NSTableView {
    /**
     Dequeues a configured reusable section view object.
     
     - Parameters:
        - registration: The section header view registration for configuring the section header view object. See ``AppKit/NSTableView/SectionHeaderRegistration``.
        - row: The index path specifying the row of the section view. The data source receives this information when it is asked for the section header view and should just pass it along. This method uses the row to perform additional configuration based on the section header view’s position in the table view.
        - section: The section element that provides data for the section header view.
     
     - Returns: A configured reusable section view object.
     */
    func makeSectionHeaderView<SectionHeaderView, Section>(using registration: SectionHeaderRegistration<SectionHeaderView, Section>, row: Int, section: Section) -> SectionHeaderView {
        return registration.makeView(self, row, section)
    }
}
