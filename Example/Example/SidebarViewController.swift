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
    typealias SectionHeaderRegistration = NSTableView.SectionHeaderRegistration<NSTableSectionHeaderView, Section>

    @IBOutlet weak var tableView: NSTableView!
    
    lazy var dataSource = DataSource(tableView: tableView, cellRegistration: cellRegistration)
    
    let cellRegistration = CellRegistration() { tableCell, column, row, sidebarItem in
        // `defaultContentConfiguration` returns a table cell content configuration with default styling based on the table view it's displayed at (in this case a sidebar table).
        var configuration = tableCell.defaultContentConfiguration()
        configuration.text = sidebarItem.title
        configuration.image = NSImage(systemSymbolName: sidebarItem.symbolName)
        if sidebarItem.isFavorite {
            configuration.badge = .symbolImage("star.fill", color: .systemYellow, backgroundColor: nil)
        }
        tableCell.contentConfiguration = configuration
    }
    
    let sectionHeaderRegistration = SectionHeaderRegistration() { sectionHeaderView, row, section in
        var configuration = sectionHeaderView.defaultContentConfiguration()
        configuration.text = section.rawValue
        sectionHeaderView.contentConfiguration = configuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.floatsGroupRows = false
        tableView.dataSource = dataSource
        
        // Enables reordering of rows via drag and drop.
        dataSource.allowsReordering = true
        // Deleting of selected rows via backspace.
        dataSource.allowsDeleting = true
                
        /// Swipe row actions for deleting and favoriting items.
        dataSource.rowActionProvider = { item, edge in
            if edge == .leading {
                return [NSTableViewRowAction(
                    style: .regular, title: "",
                    symbolName: item.isFavorite ?  "star" : "star.fill",
                    color: item.isFavorite ? .systemGray : .systemYellow) { _,_ in
                    item.isFavorite = !item.isFavorite
                    self.dataSource.reloadItems([item])
                    self.tableView.rowActionsVisible = false
                 }]
            } else {
                return [NSTableViewRowAction(
                    style: .destructive, title: "", symbolName: "trash.fill") { _,_ in
                    var currentSnapshot = self.dataSource.snapshot()
                    currentSnapshot.deleteItems([item])
                    self.dataSource.apply(currentSnapshot, .animated)
                }]
            }
        }
        
        dataSource.applySectionHeaderViewRegistration(sectionHeaderRegistration)
                
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = dataSource.emptySnapshot()
        snapshot.appendSections([.main, .section2, .section3])
        snapshot.appendItems(SidebarItem.sampleItems1, toSection: .main)
        snapshot.appendItems(SidebarItem.sampleItems2, toSection: .section2)
        dataSource.apply(snapshot, .usingReloadData)
    }
}
