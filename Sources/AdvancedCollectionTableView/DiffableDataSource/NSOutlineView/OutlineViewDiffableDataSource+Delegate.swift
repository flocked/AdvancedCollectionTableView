//
//  OutlineViewDiffableDataSource+Delegate.swift
//
//
//  Created by Florian Zand on 14.01.25.
//

import AppKit
import FZUIKit


extension OutlineViewDiffableDataSource {
    class Delegate: NSObject, NSOutlineViewDelegate {
        weak var dataSource: OutlineViewDiffableDataSource!
        var previousSelectedItems: [ItemIdentifierType] = []
        
        func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
            let isEmpty = proposedSelectionIndexes.isEmpty
            if !isEmpty, proposedSelectionIndexes.isEmpty {
                return outlineView.selectedRowIndexes
            }
            guard dataSource.selectionHandlers.shouldSelect != nil || dataSource.selectionHandlers.shouldDeselect != nil else {
                return proposedSelectionIndexes
            }
            let selectedRows = Array(outlineView.selectedRowIndexes)
            let proposedRows = Array(proposedSelectionIndexes)

            let diff = selectedRows.difference(to: proposedRows)
            let selectedItems = diff.added.compactMap { outlineView.item(atRow: $0) } as! [ItemIdentifierType]
            let deselectedItems = diff.removed.compactMap { outlineView.item(atRow: $0) } as! [ItemIdentifierType]

            var selections: [ItemIdentifierType] = selectedItems
            if !selectedItems.isEmpty, let shouldSelectRows = dataSource.selectionHandlers.shouldSelect?(selectedItems)  {
                selections = selectedItems.filter({ shouldSelectRows.contains($0) })
            }

            if !deselectedItems.isEmpty, let shouldDeselectRows = dataSource.selectionHandlers.shouldDeselect?(deselectedItems) {
                    selections += deselectedItems.filter({ !shouldDeselectRows.contains($0) })
            }

            return IndexSet(selections.compactMap { outlineView.row(for: $0 as! NSView) })
        }
        
        
        func outlineViewSelectionDidChange(_: Notification) {
            guard dataSource.selectionHandlers.didSelect != nil || dataSource.selectionHandlers.didDeselect != nil else {
                previousSelectedItems = (dataSource.outlineView.selectedItems) as! [ItemIdentifierType]
                return
            }
            let selectedItems = (dataSource.outlineView.selectedItems) as! [ItemIdentifierType]
            let diff = previousSelectedItems.difference(to: selectedItems)

            if !diff.added.isEmpty, let didSelect = dataSource.selectionHandlers.didSelect {
                didSelect(diff.added)
            }

            if !diff.removed.isEmpty, let didDeselect = dataSource.selectionHandlers.didDeselect {
                didDeselect(diff.removed)
            }
            previousSelectedItems = selectedItems
        }
        
        func outlineView(_ outlineView: NSOutlineView, userCanChangeVisibilityOf column: NSTableColumn) -> Bool {
            dataSource.columnHandlers.userCanChangeVisibility?(column) ?? false
        }
        
        func outlineView(_ outlineView: NSOutlineView, userDidChangeVisibilityOf columns: [NSTableColumn]) {
            dataSource.columnHandlers.userDidChangeVisibility?(columns)
        }
        
        func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
            dataSource.rowViewProvider?(outlineView, dataSource.row(for: item as! ItemIdentifierType)!, item as! ItemIdentifierType)
        }
        
        func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
            dataSource.expanionHandlers.shouldExpand?(item as! ItemIdentifierType) ?? true
        }
        
        func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
            dataSource.expanionHandlers.shouldCollapse?(item as! ItemIdentifierType) ?? true
        }
        
        func outlineViewItemDidExpand(_ notification: Notification) {
            guard let item = notification.userInfo?["NSObject"] as? ItemIdentifierType else { return }
            dataSource.expanionHandlers.didExpand?(item)
            dataSource.currentSnapshot.expand([item])
        }
        
        func outlineViewItemDidCollapse(_ notification: Notification) {
            guard let item = notification.userInfo?["NSObject"] as? ItemIdentifierType else { return }
            dataSource.expanionHandlers.didCollapse?(item)
            dataSource.currentSnapshot.collapse([item])
        }
        
        func outlineViewColumnDidMove(_ notification: Notification) {
            guard let didReorder = dataSource.columnHandlers.didReorder else { return }
            guard let oldPos = notification.userInfo?["NSOldColumn"] as? Int,
                  let newPos = notification.userInfo?["NSNewColumn"] as? Int,
                  let tableColumn = dataSource.outlineView.tableColumns[safe: newPos] else { return }
            didReorder(tableColumn, oldPos, newPos)
        }

        func outlineViewColumnDidResize(_ notification: Notification) {
            guard let didResize = dataSource.columnHandlers.didResize else { return }
            guard let tableColumn = notification.userInfo?["NSTableColumn"] as? NSTableColumn, let oldWidth = notification.userInfo?["NSOldWidth"] as? CGFloat else { return }
            didResize(tableColumn, oldWidth)
        }

        func outlineView(_ outlineView : NSOutlineView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
            guard let tableColumn = outlineView.tableColumns[safe: columnIndex] else { return true }
            return dataSource.columnHandlers.shouldReorder?(tableColumn, newColumnIndex) ?? true
        }
        
        func outlineView(_ outlineView: NSOutlineView, didClick tableColumn: NSTableColumn) {
            dataSource.columnHandlers.didClick?(tableColumn)
        }
        
        func outlineView(_ outlineView: NSOutlineView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
            dataSource.columnHandlers.didClickHeader?(tableColumn)
        }
        
        func outlineView(_ outlineView: NSOutlineView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
            dataSource.columnHandlers.sortDescriptorsChanged?(outlineView.sortDescriptors, oldDescriptors)
        }
    
        func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
            dataSource.cellProvider(outlineView, tableColumn, item as! ItemIdentifierType)
        }
        
        init(_ dataSource: OutlineViewDiffableDataSource!) {
            self.dataSource = dataSource
        }
    }
}
