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

    @IBOutlet var tableView: NSTableView!

    lazy var dataSource = DataSource(tableView: tableView, cellRegistration: cellRegistration)

    let cellRegistration = CellRegistration { tableCell, _, _, sidebarItem in
        // `defaultContentConfiguration` returns a table cell content configuration with default styling based on the table view it's displayed at (in this case a sidebar table).
        var configuration = tableCell.defaultContentConfiguration()
        configuration.text = sidebarItem.title
        configuration.image = NSImage(systemSymbolName: sidebarItem.symbolName)
        if sidebarItem.isFavorite {
            configuration.badge = .symbolImage("star.fill", color: .systemYellow, backgroundColor: nil)
        }
        tableCell.contentConfiguration = configuration
    }

    let sectionHeaderRegistration = SectionHeaderRegistration { sectionHeaderView, _, section in
        var configuration = sectionHeaderView.defaultContentConfiguration()
        configuration.text = section.rawValue
        sectionHeaderView.contentConfiguration = configuration
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource
        tableView.floatsGroupRows = false

        // Enables reordering selected rows by dragging them.
        dataSource.reorderingHandlers.canReorder = { selectedItem in return true }
        
        // Enables deleting selected rows via backspace key.
        dataSource.deletingHandlers.canDelete = { selectedItem in return selectedItem }

        // Swipe row actions for deleting and favoriting an item.
        dataSource.rowActionProvider = { swippedItem, edge in
            if edge == .leading {
                // Left swipe
                return [NSTableViewRowAction(
                    style: .regular, title: "",
                    symbolName: swippedItem.isFavorite ? "star" : "star.fill",
                    color: swippedItem.isFavorite ? .systemGray : .systemYellow
                ) { _, _ in
                    swippedItem.isFavorite = !swippedItem.isFavorite
                    self.dataSource.reloadItems([swippedItem])
                    self.tableView.rowActionsVisible = false
                }]
            } else {
                // Right swipe
                return [NSTableViewRowAction(
                    style: .destructive, title: "", symbolName: "trash.fill"
                ) { _, _ in
                    var currentSnapshot = self.dataSource.snapshot()
                    currentSnapshot.deleteItems([swippedItem])
                    self.dataSource.apply(currentSnapshot, .animated)
                }]
            }
        }

        dataSource.applySectionHeaderViewRegistration(sectionHeaderRegistration)
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot: NSDiffableDataSourceSnapshot<Section, SidebarItem> = .init()
        snapshot.appendSections([.main, .section2, .section3])
        snapshot.appendItems(SidebarItem.sampleItems1, toSection: .main)
        snapshot.appendItems(SidebarItem.sampleItems2, toSection: .section2)
        snapshot.appendItems(SidebarItem.sampleItems3, toSection: .section3)
        dataSource.apply(snapshot, .usingReloadData)
    }
}
