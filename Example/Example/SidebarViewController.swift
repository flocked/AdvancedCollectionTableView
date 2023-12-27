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
    
    typealias SectionHeaderRegistration = NSTableView.SectionHeaderRegistration<NSTableCellView, Section>

    
    @IBOutlet weak var tableView: NSTableView!
    
    lazy var dataSource: DataSource = DataSource(tableView: self.tableView, cellRegistration: self.cellRegistration)
    
    let cellRegistration = CellRegistration() { cell, column, row, sidebarItem in
        // defaultContentConfiguration returns a list content configuration with default styling based on the table view it's displayed at (in this case a sidebar table).
        var configuration = cell.defaultContentConfiguration()
        
        configuration.text = sidebarItem.title
        configuration.secondaryText = nil
        configuration.image = NSImage(systemSymbolName: sidebarItem.symbolName, accessibilityDescription: nil)
        
        cell.contentConfiguration = configuration
    }
    
    let sectionHeaderRegistration = SectionHeaderRegistration() { cell, row, section in
        var sidebarConfiguration = NSListContentConfiguration.sidebarHeader()
        sidebarConfiguration.text = section.rawValue
        cell.contentConfiguration = sidebarConfiguration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self.dataSource
        
        // Enables reordering of rows via drag and drop.
        dataSource.allowsReordering = true
        // Enables deleting of selected rows via backspace.
        dataSource.allowsDeleting = true
        
        // Provides right click menu that displays the title of each selected sidebar item.
        dataSource.menuProvider = { sidebarItems in
            guard sidebarItems.isEmpty == false else { return nil }
            let menu = NSMenu()
            for sidebarItem in sidebarItems {
                menu.addItem(NSMenuItem(sidebarItem.title))
            }
            return menu
        }
        
        applySnapshot(with: SidebarItem.sampleItems)
    }
    
    func applySnapshot(with items: [SidebarItem]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, .usingReloadData)
    }
}
