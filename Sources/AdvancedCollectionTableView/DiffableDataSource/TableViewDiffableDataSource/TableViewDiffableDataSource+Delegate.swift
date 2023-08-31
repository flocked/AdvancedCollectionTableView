//
//  TableViewDiffableDataSource+Delegate.swift
//  
//
//  Created by Florian Zand on 31.08.23.
//

import AppKit
import FZUIKit

extension AdvanceTableViewDiffableDataSource {
    internal class DelegateBridge: NSObject, NSTableViewDelegate {
        
        weak var dataSource: AdvanceTableViewDiffableDataSource!
        
        init(_ dataSource: AdvanceTableViewDiffableDataSource) {
            self.dataSource = dataSource
            super.init()
            self.dataSource.tableView.delegate = self
        }
        
        internal var previousSelectedIDs: [Item.ID] = []
        public func tableViewSelectionDidChange(_ notification: Notification) {
            guard dataSource.selectionHandlers.didSelect != nil || dataSource.selectionHandlers.didDeselect != nil else {
                previousSelectedIDs = dataSource.selectedItems.ids
                return
            }
            let selectedIDs = dataSource.selectedItems.ids
            let deselected = previousSelectedIDs.filter({ selectedIDs.contains($0) == false })
            let selected = selectedIDs.filter({ previousSelectedIDs.contains($0) == false })
            
            if selected.isEmpty == false, let didSelect = dataSource.selectionHandlers.didSelect {
                let selectedItems = dataSource.allItems[ids: selected]
                didSelect(selectedItems)
            }
            
            if deselected.isEmpty == false, let didDeselect = dataSource.selectionHandlers.didDeselect {
                let deselectedItems = dataSource.allItems[ids: deselected]
                if deselectedItems.isEmpty == false {
                    didDeselect(deselectedItems)
                }
            }
            previousSelectedIDs = selectedIDs
        }
        
        public func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
            var proposedSelectionIndexes = proposedSelectionIndexes
            dataSource.sectionRows.forEach({ proposedSelectionIndexes.remove($0) })
            guard dataSource.selectionHandlers.shouldSelect != nil || dataSource.selectionHandlers.shouldDeselect != nil  else {
                return proposedSelectionIndexes
            }
            let selectedRows = Array(dataSource.tableView.selectedRowIndexes)
            let proposedRows = Array(proposedSelectionIndexes)
            
            let deselected = selectedRows.filter({ proposedRows.contains($0) == false })
            let selected = proposedRows.filter({ selectedRows.contains($0) == false })
            
            var selections: [Item] = []
            let selectedItems = selected.compactMap({dataSource.item(forRow: $0)})
            let deselectedItems = deselected.compactMap({dataSource.item(forRow: $0)})
            if selectedItems.isEmpty == false, let shouldSelect = dataSource.selectionHandlers.shouldSelect {
                selections.append(contentsOf: shouldSelect(selectedItems))
            } else {
                selections.append(contentsOf: selectedItems)
            }
            
            if deselectedItems.isEmpty == false, let shouldDeselect = dataSource.selectionHandlers.shouldDeselect {
                selections.append(contentsOf: shouldDeselect(deselectedItems))
            } else {
                selections.append(contentsOf: deselectedItems)
            }
            
            return IndexSet(selections.compactMap({dataSource.row(for: $0)}))
        }
        
        public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            return self.dataSource.tableView(tableView, viewFor: tableColumn, row: row)
        }
        
        public func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
            return self.dataSource.tableView(tableView, isGroupRow: row)
        }
        
        public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
            return self.dataSource.tableView(tableView, rowViewForRow: row)
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
