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
    typealias SectionHeaderRegistration = NSTableView.SectionHeaderRegistration<SectionHeaderCell, Section>

    
    @IBOutlet weak var tableView: NSTableView!
    
    lazy var dataSource: DataSource = DataSource(tableView: self.tableView, cellRegistration: self.cellRegistration)
    
    let cellRegistration = CellRegistration() { cell, column, row, sidebarItem in
        // defaultContentConfiguration returns a list content configuration with default styling based on the table view it's displayed at (in this case a sidebar table).
        var configuration = cell.defaultContentConfiguration()
        configuration.text = sidebarItem.title
        configuration.image = NSImage(systemSymbolName: sidebarItem.symbolName)
        
        cell.contentConfiguration = configuration
    }
    
    let sectionHeaderRegistration = SectionHeaderRegistration() { rowView, row, section in
        var sidebarConfiguration: NSListContentConfiguration = .sidebarHeader()
        sidebarConfiguration.text = section.rawValue

        rowView.contentConfiguration = sidebarConfiguration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self.dataSource
        
        // Enables reordering of rows via drag and drop.
        dataSource.allowsReordering = true
        // Enables deleting of selected rows via backspace.
        dataSource.allowsDeleting = true
        
        dataSource.sectionHeaderViewRegistration(sectionHeaderRegistration)
        
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
        snapshot.appendSections([.main, .more])
        snapshot.appendItems(SidebarItem.sampleItems, toSection: .main)
        snapshot.appendItems(SidebarItem.moreSampleItems, toSection: .more)
        dataSource.apply(snapshot, .usingReloadData)
    }
}
