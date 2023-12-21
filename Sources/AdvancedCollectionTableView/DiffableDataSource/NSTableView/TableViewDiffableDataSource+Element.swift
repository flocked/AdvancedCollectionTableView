//
//  File.swift
//  
//
//  Created by Florian Zand on 02.08.23.
//

import AppKit
import FZUIKit

extension TableViewDiffableDataSource {
    /// All current sections in the collection view.
    internal var sections: [Section] { currentSnapshot.sectionIdentifiers }
    
    /// All current items in the collection view.
    internal var items: [Item] { currentSnapshot.itemIdentifiers }
    
    /// An array of the selected items.
    public var selectedItems: [Item] {
        return self.tableView.selectedRowIndexes.compactMap({item(forRow: $0)})
    }
    
    /**     
     Returns the item at the specified row in the table view.
     
     - Parameter row: The row of the item in the table view.
     - Returns: The item, or `nil` if the method doesn’t find an item at the provided row.
     */
    public func item(forRow row: Int) -> Item? {
        if let itemID = dataSource.itemIdentifier(forRow: row) {
            return items[id: itemID]
        }
        return nil
    }
    
    /// Returns the row for the specified item.
    public func row(for item: Item) -> Int? {
        return self.dataSource.row(forItemIdentifier: item.id)
    }
    
    /**
     Returns the section for the specified row in the table view.
     
     - Parameter row: The row of the section in the table view.
     - Returns: The section, or `nil if the method doesn’t find the section for the row.
     */
    public func section(forRow row: Int) -> Section? {
        if let sectionID = dataSource.sectionIdentifier(forRow: row) {
            return sections[id: sectionID]
        }
        return nil
    }
    
    /// Returns the row for the specified section.
    public func row(for section: Section) -> Int? {
        return self.dataSource.row(forSectionIdentifier: section.id)
    }
    
    /**
     Returns the item of the specified index path.
     
     - Parameter indexPath: The indexPath
     - Returns: The item at the index path or nil if there isn't any item at the index path.
     */
    public func item(at point: CGPoint) -> Item? {
        let row = self.tableView.row(at: point)
        if row != -1 {
            return item(forRow: row)
        }
        return nil
    }
    
    /// Selects all table rows of the specified items.
    public func selectItems(_ items: [Item], byExtendingSelection: Bool = false) {
        self.selectItems(at: rows(for: items), byExtendingSelection: byExtendingSelection)
    }
    
    /// Deselects all table rows of the specified items.
    public func deselectItems(_ items: [Item]) {
        items.compactMap({row(for: $0)}).forEach({ self.tableView.deselectRow($0) })
        // self.deselectItems(at: rows(for: items))
    }
    
    /// Selects all table rows of the items in the specified sections.
    public func selectItems(in sections: [Section], byExtendingSelection: Bool = false) {
        let rows = sections.flatMap({self.rows(for: $0)})
        self.selectItems(at: rows, byExtendingSelection: byExtendingSelection)
    }
    
    /// Deselects all table rows of the items in the specified sections.
    public func deselectItems(in sections: [Section]) {
        let rows = sections.flatMap({self.rows(for: $0)})
        self.deselectItems(at: rows)
    }
    
    /// Scrolls the table view to the specified item.
    public func scrollToItem(_ item: Item, scrollPosition: NSCollectionView.ScrollPosition = []) {
        if let row = self.row(for: item) {
            self.tableView.scrollRowToVisible(row)
        }
    }
    
    /// Scrolls the table view to the specified section.
    public func scrollToSection(_ section: Section, scrollPosition: NSCollectionView.ScrollPosition = []) {
        if let row = self.row(for: section) {
            self.tableView.scrollRowToVisible(row)
        }
    }
    
    /// An array of items that are visible.
    internal func visibleItems() -> [Item] {
        self.tableView.visibleRowIndexes().compactMap({ item(forRow: $0) })
    }
    
    internal func rowView(for item: Item) -> NSTableRowView? {
        if let row = row(for: item) {
            return self.tableView.rowView(atRow: row, makeIfNecessary: false)
        }
        return nil
    }
    
    internal func rows(for items: [Item]) -> [Int] {
        return items.compactMap({row(for: $0)})
    }
    
    internal func rows(for section: Section) -> [Int] {
        let items = self.currentSnapshot.itemIdentifiers(inSection: section)
        return self.rows(for: items)
    }
    
    internal func rows(for sections: [Section]) -> [Int] {
        return sections.flatMap({self.rows(for: $0)})
    }
    
    internal func isSelected(at row: Int) -> Bool {
        return self.tableView.selectedRowIndexes.contains(row)
    }
    
    internal func isSelected(for item: Item) -> Bool {
        if let row = row(for: item) {
            return isSelected(at: row)
        }
        return false
    }
    
    internal func selectItems(at rows: [Int], byExtendingSelection: Bool = false) {
        self.tableView.selectRowIndexes(IndexSet(rows), byExtendingSelection: byExtendingSelection)
    }
    
    internal func deselectItems(at rows: [Int]) {
        rows.forEach({self.tableView.deselectRow($0)})
    }
    
    internal func removeItems( _ items: [Item]) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(items)
        self.apply(snapshot, .animated)
    }
    
    internal func transactionForMovingItems(at rowIndexes: IndexSet, to row: Int) -> DiffableDataSourceTransaction<Section, Item>? {
        var row = row
        var isLast: Bool = false
        if row >= self.numberOfRows(in: tableView) {
            row = row - 1
            isLast = true
        }
        let dragingItems = rowIndexes.compactMap({item(forRow: $0)})
        guard self.reorderingHandlers.canReorder?(dragingItems) ?? self.allowsReordering, let toItem = self.item(forRow: row) else {
            return nil
        }
        var snapshot = self.snapshot()
        if isLast {
            for item in dragingItems.reversed() {
                snapshot.moveItem(item, afterItem: toItem)
            }
        } else {
            for item in dragingItems {
                snapshot.moveItem(item, beforeItem: toItem)
            }
        }
        let initalSnapshot = self.currentSnapshot
        let difference = initalSnapshot.itemIdentifiers.difference(from: snapshot.itemIdentifiers)
        return DiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: snapshot, difference: difference)
    }
    
    /*
     public func section(for item: Item) -> Section? {
     return self.currentSnapshot.sectionIdentifier(containingItem: item)
     }
     
     public func frame(for item: Item) -> CGRect? {
     self.tableView.fram
     if let index = row(for: item)?.item {
     return self.collectionView.frameForItem(at: index)
     }
     return nil
     }
     
     public func reconfigurateItems(_ items: [Item]) {
     let indexPaths = items.compactMap({self.indexPath(for:$0)})
     self.reconfigureItems(at: indexPaths)
     }
     
     public func reconfigureItems(at indexPaths: [IndexPath]) {
     self.collectionView.reconfigureItems(at: indexPaths)
     }
     
     public func reloadItems(at rows: [Int], animated: Bool = false) {
     let items = rows.compactMap({self.item(forRow: $0)})
     self.reloadItems(items, animated: animated)
     }
     
     public func reloadItems(_ items: [Item], animated: Bool = false) {
     var snapshot = dataSource.snapshot()
     snapshot.reloadItems(items.ids)
     dataSource.apply(snapshot, animated ? .animated: .withoutAnimation)
     }
     
     public func reloadAllItems(animated: Bool = false, complection: (() -> Void)? = nil) {
     var snapshot = snapshot()
     snapshot.reloadItems(snapshot.itemIdentifiers)
     self.apply(snapshot, animated ? .animated : .usingReloadData)
     }
     
     public func selectAll() {
     self.tableView.selectAll(nil)
     }
     
     public func deselectAll() {
     self.tableView.deselectAll(nil)
     }
     
     internal func moveItems( _ items: [Item], before beforeItem: Item) {
     var snapshot = self.snapshot()
     items.forEach({snapshot.moveItem($0, beforeItem: beforeItem)})
     self.apply(snapshot)
     }
     
     internal func moveItems( _ items: [Item], after afterItem: Item) {
     var snapshot = self.snapshot()
     items.forEach({snapshot.moveItem($0, afterItem: afterItem)})
     self.apply(snapshot)
     }
     
     internal func moveItems(at rows: [Int], to toRow: Int) {
     let items = rows.compactMap({self.item(forRow: $0)})
     if let toItem = self.item(forRow: toRow), items.isEmpty == false {
     var snapshot = self.snapshot()
     items.forEach({snapshot.moveItem($0, beforeItem: toItem)})
     self.apply(snapshot)
     //  self.moveItems(items, before: toItem)
     }
     }
     */
}
