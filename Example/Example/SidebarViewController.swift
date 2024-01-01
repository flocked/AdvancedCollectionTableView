//
//  SidebarViewController.swift
//
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import AdvancedCollectionTableView

class SidebarViewController: NSViewController {
    
    lazy var itemRegistration: NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem> = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem>(handler: { collectionViewItem, indexPath, galleryItem in
        
    })
    
    typealias CellRegistration = NSTableView.CellRegistration<NSTableCellView, SidebarItem>
    typealias DataSource = TableViewDiffableDataSource<Section, SidebarItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SidebarItem>
    typealias SectionHeaderRegistration = NSTableView.SectionHeaderRegistration<NSTableSectionHeaderView, Section>

    
    @IBOutlet weak var tableView: NSTableView!
    
    lazy var dataSource: DataSource = DataSource(tableView: tableView, cellRegistration: cellRegistration)
    
    let cellRegistration = CellRegistration() { cell, column, row, sidebarItem in
        // `defaultContentConfiguration()` returns a table cell content configuration with default styling based on the table view it's displayed at.
        var configuration = cell.defaultContentConfiguration()
        configuration.text = sidebarItem.title
        configuration.image = NSImage(systemSymbolName: sidebarItem.symbolName)
        
        cell.contentConfiguration = configuration
    }
    
    let sectionHeaderRegistration = SectionHeaderRegistration() { headerView, row, section in
        var configuration = headerView.defaultContentConfiguration()
        configuration.text = section.rawValue
        headerView.contentConfiguration = configuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        
        // Enables reordering of rows via drag and drop.
        dataSource.allowsReordering = true
        // Enables deleting of selected rows via backspace.
        dataSource.allowsDeleting = true
        
        dataSource.applySectionHeaderViewRegistration(sectionHeaderRegistration)
        
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
        snapshot.appendSections([.main, .more, .empty])
        snapshot.appendItems(SidebarItem.sampleItems, toSection: .main)
        snapshot.appendItems(SidebarItem.moreSampleItems, toSection: .more)
        dataSource.apply(snapshot, .usingReloadData)
    }
}
