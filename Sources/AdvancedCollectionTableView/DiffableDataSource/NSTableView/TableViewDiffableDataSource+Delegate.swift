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
            dataSource.tableView.delegate = self
        }

        var previousSelectedIDs: [Item.ID] = []
        public func tableViewSelectionDidChange(_: Notification) {
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

        public func tableView(_: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
            var proposedSelectionIndexes = proposedSelectionIndexes
            dataSource.sectionRowIndexes.forEach { proposedSelectionIndexes.remove($0) }
            guard dataSource.selectionHandlers.shouldSelect != nil || dataSource.selectionHandlers.shouldDeselect != nil else {
                return proposedSelectionIndexes
            }
            let selectedRows = Array(dataSource.tableView.selectedRowIndexes)
            let proposedRows = Array(proposedSelectionIndexes)

            let diff = selectedRows.difference(to: proposedRows)
            let selectedItems = diff.added.compactMap { dataSource.item(forRow: $0) }
            let deselectedItems = diff.removed.compactMap { dataSource.item(forRow: $0) }

            var selections: [Item] = selectedItems
            if !selectedItems.isEmpty, let shouldSelectRows = dataSource.selectionHandlers.shouldSelect?(selectedItems)  {
                selections = selectedItems.filter({ shouldSelectRows.contains($0) })
            }

            if !deselectedItems.isEmpty, let shouldDeselectRows = dataSource.selectionHandlers.shouldDeselect?(deselectedItems) {
                    selections += deselectedItems.filter({ !shouldDeselectRows.contains($0) })
            }

            return IndexSet(selections.compactMap { dataSource.row(for: $0) })
        }

        public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            dataSource.dataSource.tableView(tableView, viewFor: tableColumn, row: row)
        }

        public func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
            dataSource.dataSource.tableView(tableView, isGroupRow: row)
        }

        public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
            dataSource.dataSource.tableView(tableView, rowViewForRow: row)
        }

        public func tableView(_: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
            if let rowActionProvider = dataSource.rowActionProvider, let item = dataSource.item(forRow: row) {
                return rowActionProvider(item, edge)
            }
            return []
        }
        
        func tableView(_ tableView: NSTableView, userCanChangeVisibilityOf column: NSTableColumn) -> Bool {
            dataSource.columnHandlers.userCanChangeVisibility?(column) ?? false
        }
        
        func tableView(_ tableView: NSTableView, userDidChangeVisibilityOf columns: [NSTableColumn]) {
            dataSource.columnHandlers.userDidChangeVisibility?(columns)
        }

        public func tableViewColumnDidMove(_ notification: Notification) {
            guard let didReorder = dataSource.columnHandlers.didReorder else { return }
            guard let oldPos = notification.userInfo?["NSOldColumn"] as? Int,
                  let newPos = notification.userInfo?["NSNewColumn"] as? Int,
                  let tableColumn = dataSource.tableView.tableColumns[safe: newPos] else { return }
            didReorder(tableColumn, oldPos, newPos)
        }

        public func tableViewColumnDidResize(_ notification: Notification) {
            guard let didResize = dataSource.columnHandlers.didResize else { return }
            guard let tableColumn = notification.userInfo?["NSTableColumn"] as? NSTableColumn, let oldWidth = notification.userInfo?["NSOldWidth"] as? CGFloat else { return }
            didResize(tableColumn, oldWidth)
        }

        public func tableView(_: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
            guard let tableColumn = dataSource.tableView.tableColumns[safe: columnIndex] else { return true }
            return dataSource.columnHandlers.shouldReorder?(tableColumn, newColumnIndex) ?? true
        }
        
        func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
            dataSource.columnHandlers.didClick?(tableColumn)
        }
        
        func tableView(_ tableView: NSTableView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
            dataSource.columnHandlers.didClickHeader?(tableColumn)
        }
    }
}
