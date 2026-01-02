//
//  TableViewDiffableDataSource+Delegate.swift
//
//
//  Created by Florian Zand on 31.08.23.
//

import AppKit
import FZUIKit

extension TableViewDiffableDataSource {
    class Delegate: NSObject, NSTableViewDelegate {
        weak var dataSource: TableViewDiffableDataSource!
        var previousSelectedIDs: [Item.ID] = []

        init(_ dataSource: TableViewDiffableDataSource) {
            self.dataSource = dataSource
            super.init()
            dataSource.tableView.delegate = self
        }
        
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

        public func tableView(_ tableView: NSTableView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
            var proposedSelectionIndexes = proposedSelectionIndexes
            let isEmpty = proposedSelectionIndexes.isEmpty
            dataSource.sectionRowIndexes.forEach { proposedSelectionIndexes.remove($0) }
            if !isEmpty, proposedSelectionIndexes.isEmpty {
                return dataSource.tableView.selectedRowIndexes
            }
            guard dataSource.selectionHandlers.shouldSelect != nil || dataSource.selectionHandlers.shouldDeselect != nil else {
                return proposedSelectionIndexes
            }
            let diff = dataSource.tableView.selectedRowIndexes.difference(to: proposedSelectionIndexes)

            let selectedItems = diff.added.compactMap({ dataSource.indexedItem(forRow: $0) })
            let deselectedItems = diff.added.compactMap({ dataSource.indexedItem(forRow: $0) })
            var selection = selectedItems
            if !selectedItems.isEmpty, let shouldSelectRows = dataSource.selectionHandlers.shouldSelect?(selectedItems.map(\.item))  {
                selection = selection.filter({ shouldSelectRows.contains($0.item) })
            }
            if !deselectedItems.isEmpty, let shouldDeselectRows = dataSource.selectionHandlers.shouldDeselect?(deselectedItems.map(\.item)) {
                selection += deselectedItems.filter({ !shouldDeselectRows.contains($0.item) })
            }
            return IndexSet(selection.map(\.row))
        }
        
        // MARK: - View

        public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            dataSource.dataSource.tableView(tableView, viewFor: tableColumn, row: row)
        }

        public func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
            dataSource.dataSource.tableView(tableView, isGroupRow: row)
        }

        public func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
            dataSource.dataSource.tableView(tableView, rowViewForRow: row)
        }
        
        // MARK: - Row Action

        public func tableView(_: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
            if let rowActionProvider = dataSource.rowActionProvider, let item = dataSource.item(forRow: row) {
                return rowActionProvider(item, edge)
            }
            return []
        }
        
        // MARK: - Column
        
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
        
        /*
         // MARK: - TypeSelect

         
        /// Matching type select strings by row.
        var matchingTypeSelectStrings: [Int: [String: [String]]] = [:]
        var previousSearchString = ""
        
        public func tableView(_ tableView: NSTableView, shouldTypeSelectFor event: NSEvent,
            withCurrentSearch searchString: String?) -> Bool {
            if searchString == nil {
                matchingTypeSelectStrings = [:]
                previousSearchString = ""
            }
            return true
        }
        
        public func tableView(_ tableView: NSTableView, nextTypeSelectMatchFromRow startRow: Int, toRow endRow: Int, for searchString: String) -> Int {
            let searchString = searchString.lowercased()
            var rows: [Int] = []
            if endRow >= startRow {
                rows = (startRow...endRow).map({$0})
            } else {
                rows = (endRow..<tableView.numberOfRows).map({$0}) + (0...startRow).map({$0})
            }
            for row in rows {
                if var rowMatches = matchingTypeSelectStrings[row] {
                    if let matchedStrings = rowMatches[searchString] {
                        if !matchedStrings.isEmpty {
                            return row
                        }
                    } else if var matchedStrings = rowMatches[previousSearchString], !matchedStrings.isEmpty {
                        matchedStrings = matchedStrings.filter({ $0.hasPrefix(searchString) })
                        rowMatches[searchString] = matchedStrings
                        matchingTypeSelectStrings[row] = rowMatches
                        if !matchedStrings.isEmpty {
                            return row
                        }
                    }
                    
                    if !rowMatch.strings.isEmpty, rowMatch.searchString != searchString {
                        rowMatch = (searchString, rowMatch.strings.filter({ $0.hasPrefix(searchString)}))
                        matchingTypeSelectStrings[row] = rowMatch
                    }
                    if !rowMatch.strings.isEmpty {
                        return row
                    }
                } else {
                    let rowMatch = matchingTypeSelectStrings(for: tableView, row: row, searchString: searchString)
                    matchingTypeSelectStrings[row] = rowMatch
                    if !rowMatch.strings.isEmpty {
                        return row
                    }
                }
            }
            return tableView.selectedRow
        }
        
        func matchingTypeSelectStrings(for tableView: NSTableView, row: Int, searchString: String) -> [String] {
            guard !self.tableView(tableView, isGroupRow: row) else { return (searchString, []) }
            var matchingStrings: [String] = []
            let columns = tableView.selectedColumnIndexes.isEmpty ? IndexSet(integersIn: 0..<tableView.numberOfColumns) : tableView.selectedColumnIndexes
            for column in columns {
                let strings = tableView.view(atColumn: column, row: row, makeIfNecessary: true)?.subviews(depth: .max).compactMap({ ($0 as? TextSearchableView)?.searchableText }) ?? []
                matchingStrings += strings.filter({ $0.hasPrefix(searchString) })
            }
            return matchingStrings
        }
        */
        
        /*
        public func tableView(_ tableView: NSTableView, shouldTypeSelectFor event: NSEvent,
            withCurrentSearch searchString: String?) -> Bool {
            Swift.print("shouldTypeSelect", event.type.description, event.charactersIgnoringModifiers, searchString ?? "")
            return true
        }
        
        public func tableView(_ tableView: NSTableView, nextTypeSelectMatchFromRow startRow: Int, toRow endRow: Int, for searchString: String) -> Int {
            Swift.print("nextTypeSelect", searchString, startRow, endRow)
            return startRow
        }
        
        public func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String?
            
            
            if let tableColumn = tableColumn {
                if let column = tableView.tableColumns.firstIndex(where: { $0 === tableColumn }), let view = tableView.view(atColumn: column, row: row, makeIfNecessary: false) {
                    return view.subviews(type: NSTextField.self, depth: .max).map({$0.stringValue}).joined(separator: " ")
                }
            } else if let view = dataSource.tableView.rowView(atRow: row, makeIfNecessary: false) {
                return view.subviews(type: NSTextField.self, depth: .max).map({$0.stringValue}).joined(separator: " ")
            }
return nil
            
        }
        */
    }
}

/*
 protocol TextSearchableView: NSView {
     var searchableText: String? { get }
 }

 extension NSTextField: TextSearchableView {
     var searchableText: String? {
       guard !isHidden && alphaValue > 0 else { return nil }
       return stringValue.lowercased()
     }
 }

 extension NSTextView: TextSearchableView {
     var searchableText: String? {
       guard !isHidden && alphaValue > 0 else { return nil }
       return string.lowercased()
     }
 }
 */
