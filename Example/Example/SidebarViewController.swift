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
    
    @IBOutlet weak var tableView: NSTableView!
    
    lazy var dataSource: DataSource = DataSource(tableView: self.tableView, cellRegistration: self.cellRegistration)
    
    /// Sample items.
    var items: [SidebarItem] = SidebarItem.sampleItems
    
    let cellRegistration: CellRegistration = CellRegistration() { cell, column, row, sidebarItem in
        // defaultContentConfiguration returns a list content configuration with default styling based on the table view it's displayed at (in this case a sidebar table).
        var configuration = cell.defaultContentConfiguration()
        configuration.text = sidebarItem.title
        configuration.image = NSImage(systemSymbolName: sidebarItem.symbolName, accessibilityDescription: nil)
        cell.contentConfiguration = configuration
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
        
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, .usingReloadData)
    }
}
