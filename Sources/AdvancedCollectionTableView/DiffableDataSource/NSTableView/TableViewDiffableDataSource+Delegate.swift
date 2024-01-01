//
//  TableViewDiffableDataSource+Delegate.swift
//  
//
//  Created by Florian Zand on 31.08.23.
//

import AppKit
import FZUIKit

extension TableViewDiffableDataSource {
    class DelegateBridge: NSObject, NSTableViewDelegate {
        
        weak var dataSource: TableViewDiffableDataSource!
        
        init(_ dataSource: TableViewDiffableDataSource) {
            self.dataSource = dataSource
            super.init()
            self.dataSource.tableView.delegate = self
        }
        
        var previousSelectedIDs: [Item.ID] = []
        public func tableViewSelectionDidChange(_ notification: Notification) {
            guard dataSource.selectionHandlers.didSelect != nil || dataSource.selectionHandlers.didDeselect != nil else {
                previousSelectedIDs = dataSource.selectedItems.ids
                return
            }
            let selectedIDs = dataSource.selectedItems.ids
            let diff = previousSelectedIDs.difference(to: selectedIDs)
                        
            if diff.added.isEmpty == false, let didSelect = dataSource.selectionHandlers.didSelect {
                let selectedItems = dataSource.items[ids: diff.added]
                didSelect(selectedItems)
            }
            
            if diff.removed.isEmpty == false, let didDeselect = dataSource.selectionHandlers.didDeselect {
                let deselectedItems = dataSource.items[ids: diff.removed]
                if deselectedItems.isEmpty == false {
                    didDeselect(deselectedItems)
                }
            }
            previousSelectedIDs = selectedIDs
        }
        
        public func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
            var proposedSelectionIndexes = proposedSelectionIndexes
            dataSource.sectionRowIndexes.forEach({ proposedSelectionIndexes.remove($0) })
            guard dataSource.selectionHandlers.shouldSelect != nil || dataSource.selectionHandlers.shouldDeselect != nil  else {
                return proposedSelectionIndexes
            }
            let selectedRows = Array(dataSource.tableView.selectedRowIndexes)
            let proposedRows = Array(proposedSelectionIndexes)
        
            let diff = selectedRows.difference(to: proposedRows)
            let selectedItems = diff.added.compactMap({dataSource.item(forRow: $0)})
            let deselectedItems = diff.removed.compactMap({dataSource.item(forRow: $0)})

            var selections: [Item] = []
            if !selectedItems.isEmpty {
                selections = dataSource.selectionHandlers.shouldSelect?(selectedItems) ?? selectedItems
            }
            
            if !deselectedItems.isEmpty {
                selections += dataSource.selectionHandlers.shouldDeselect?(deselectedItems) ?? deselectedItems
            }
            
            return IndexSet(selections.compactMap({dataSource.row(for: $0)}))
        }
        
        public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            self.dataSource.dataSource.tableView(tableView, viewFor: tableColumn, row: row)
        }
        
        public func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
            self.dataSource.dataSource.tableView(tableView, isGroupRow: row)
        }
        
        public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
            self.dataSource.dataSource.tableView(tableView, rowViewForRow: row)
        }
        
        public func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
            if let item = dataSource.item(forRow: row), let rowActionProvider = dataSource.rowActionProvider {
                return rowActionProvider(item, edge)
            }
            return []
        }
        
        public func tableViewColumnDidMove(_ notification: Notification) {
            guard let oldPos = notification.userInfo?["NSOldColumn"] as? Int,
                  let newPos = notification.userInfo?["NSNewColumn"] as? Int,
                  let tableColumn = dataSource.tableView.tableColumns[safe: newPos] else { return }
            dataSource.columnHandlers.didReorder?(tableColumn, oldPos, newPos)
        }
        
        public func tableViewColumnDidResize(_ notification: Notification) {
            guard let tableColumn = notification.userInfo?["NSTableColumn"] as? NSTableColumn, let oldWidth = notification.userInfo?["NSOldWidth"] as? CGFloat else { return }
            dataSource.columnHandlers.didResize?(tableColumn, oldWidth)
        }
        
        public func tableView(_ tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
            guard let tableColumn = dataSource.tableView.tableColumns[safe: columnIndex] else { return true }
            return dataSource.columnHandlers.shouldReorder?(tableColumn, newColumnIndex) ?? true
        }
    }
}
