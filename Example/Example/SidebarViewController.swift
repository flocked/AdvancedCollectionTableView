//
//  SidebarViewController.swift
//
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import AdvancedCollectionTableView

class SidebarViewController: NSViewController {
    typealias DataSource = TableViewDiffableDataSource<Section, SidebarItem>
    typealias CellRegistration = NSTableView.CellRegistration<NSTableCellView, SidebarItem>
    typealias SectionHeaderRegistration = NSTableView.CellRegistration<NSTableCellView, Section>

    @IBOutlet var tableView: NSTableView!
    
    lazy var dataSource = DataSource(tableView: tableView, cellRegistration: cellRegistration, sectionHeaderRegistration: sectionHeaderRegistration)

    let cellRegistration = CellRegistration { tableCell, _, _, sidebarItem in
        /// `defaultContentConfiguration` returns a table cell content configuration with default styling based on the table view it's displayed at (in this case a sidebar table).
        var configuration = tableCell.defaultContentConfiguration()
        configuration.text = sidebarItem.title
        configuration.image = NSImage(systemSymbolName: sidebarItem.symbolName)
        if sidebarItem.isFavorite {
            configuration.badge = .symbolImage("star.fill", color: .systemYellow, backgroundColor: nil)
        }
        tableCell.contentConfiguration = configuration
    }
    
    let sectionHeaderRegistration = SectionHeaderRegistration { sectionHeaderCell, _, _, section in
        var configuration = sectionHeaderCell.defaultContentConfiguration()
        configuration.text = section.title
        sectionHeaderCell.contentConfiguration = configuration
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource

        /// Enables reordering selected rows by dragging them.
        dataSource.reorderingHandlers.canReorder = { selectedItems in return selectedItems }
        
        /// Enables deleting selected rows via backspace key.
        dataSource.deletingHandlers.canDelete = { selectedItems in return selectedItems  }

        /// Swipe row actions for deleting and favoriting an item.
        dataSource.rowActionProvider = { swippedItem, edge in
            if edge == .leading {
                /// Left swipe
                return [NSTableViewRowAction.regular(symbolName: swippedItem.isFavorite ? "star" : "star.fill") { _,_ in
                        swippedItem.isFavorite = !swippedItem.isFavorite
                        self.dataSource.reconfigureItems([swippedItem])
                        self.tableView.rowActionsVisible = false
                    }]
            } else {
                /// Right swipe
                return [NSTableViewRowAction.destructive(symbolName: "trash.fill") { _,_ in
                    var snapshot = self.dataSource.snapshot()
                    snapshot.deleteItems([swippedItem])
                    self.dataSource.apply(snapshot)
                }]
            }
        }
        
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
