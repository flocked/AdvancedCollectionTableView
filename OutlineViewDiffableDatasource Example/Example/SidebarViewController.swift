//
//  SidebarViewController.swift
//
//
//  Created by Florian Zand on 19.01.23.
//

import AppKit
import AdvancedCollectionTableView

class SidebarViewController: NSViewController {
    typealias DataSource = OutlineViewDiffableDataSource<OutlineItem>
    typealias CellRegistration = NSTableView.CellRegistration<NSTableCellView, OutlineItem>

    @IBOutlet var outlineView: NSOutlineView!
    
    lazy var dataSource = DataSource(outlineView: outlineView, cellRegistration: cellRegistration)

    let cellRegistration = CellRegistration { tableCell, _, _, outlineItem in
        /// `defaultContentConfiguration` returns a table cell content configuration with default styling based on the table view it's displayed at (in this case a sidebar table).
        var configuration = tableCell.defaultContentConfiguration()
        configuration.text = outlineItem.title
        tableCell.contentConfiguration = configuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        outlineView.dataSource = dataSource
        dataSource.reorderingHandlers.canReorder = { _, _ in return true }
        applySnapshot()
    }
        
    func applySnapshot() {
        var snapshot = dataSource.emptySnapshot()
        let rootItems: [OutlineItem] = ["Root 1", "Root 2", "Root 3", "Root 4", "Root 5"]
        snapshot.append(rootItems)
        for item in rootItems {
            var children: [OutlineItem] = []
            for i in 0..<5 {
                children.append(.init("\(item.title).\(i+1)"))
            }
            snapshot.append(children, to: item)
            for child in children {
                var childs: [OutlineItem] = []
                for a in 0..<5 {
                    childs.append(.init("\(child.title).\(a+1)"))
                }
                snapshot.append(childs, to: child)
            }
        }
        dataSource.apply(snapshot, .withoutAnimation)
    }
}
