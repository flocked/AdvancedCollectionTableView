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
    typealias DataSource = AdvanceTableViewDiffableDataSource<Section, SidebarItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SidebarItem>

    @IBOutlet weak var tableView: NSTableView!
    
    lazy var dataSource: DataSource = DataSource(tableView: self.tableView, cellRegistration: self.cellRegistration)
    
    /// Sample items.
    var items: [SidebarItem] = SidebarItem.sampleItems
    
    let cellRegistration: CellRegistration = CellRegistration(identifier: "SidebarCell") { cell, column, row, sidebarItem in
        var configuration = NSTableCellContentConfiguration.sidebar()
        configuration.text = sidebarItem.title
        configuration.image = NSImage(systemSymbolName: sidebarItem.symbolName, accessibilityDescription: nil)
        cell.contentConfiguration = configuration
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self.dataSource
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, .non)
    }
}
