//
//  SidebarViewController.swift
//
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import AdvancedCollectionTableView

class SidebarViewController: NSViewController {
    
    typealias CellRegistration = NSTableView.CellRegistration<NSTableCellView, SidebarItem>
    typealias DataSource = TableViewDiffableDataSource<Section, SidebarItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SidebarItem>
    typealias SectionHeaderRegistration = NSTableView.SectionHeaderRegistration<NSTableSectionHeaderView, Section>

    @IBOutlet weak var tableView: NSTableView!
    
    lazy var dataSource: DataSource = DataSource(tableView: tableView, cellRegistration: cellRegistration)
    
    let cellRegistration = CellRegistration() { tableCell, column, row, sidebarItem in
        // `defaultContentConfiguration` returns a table cell content configuration with default styling based on the table view it's displayed at (in this case a sidebar table).
        var configuration = tableCell.defaultContentConfiguration()
        configuration.text = sidebarItem.title
        configuration.image = NSImage(systemSymbolName: sidebarItem.symbolName)
        tableCell.contentConfiguration = configuration
    }
    
    let sectionHeaderRegistration = SectionHeaderRegistration() { sectionHeaderView, row, section in
        var configuration = sectionHeaderView.defaultContentConfiguration()
        configuration.text = section.rawValue
        sectionHeaderView.contentConfiguration = configuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
        
        // Enables reordering of rows via drag and drop.
        dataSource.allowsReordering = true
        // Enables deleting of selected rows via backspace.
        dataSource.allowsDeleting = true
        
        dataSource.rowActionProvider = { item, edge in
           let action =  NSTableViewRowAction(style: .destructive, title: "Delete", handler: { rowedge, value in
                var currentSnapshot = self.dataSource.snapshot()
                currentSnapshot.deleteItems([item])
                self.dataSource.apply(currentSnapshot, .animated)
            })
            return [action]
        }
        
        dataSource.applySectionHeaderViewRegistration(sectionHeaderRegistration)
                
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main, .more, .empty])
        snapshot.appendItems(SidebarItem.sampleItems, toSection: .main)
        snapshot.appendItems(SidebarItem.moreSampleItems, toSection: .more)
        dataSource.apply(snapshot, .usingReloadData)
    }
}
