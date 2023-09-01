//
//  File.swift
//  
//
//  Created by Florian Zand on 02.08.23.
//

import AppKit
import FZUIKit

extension AdvanceTableViewDiffableDataSource {    
    public var allItems: [Item] {
        return self.currentSnapshot.itemIdentifiers
    }
    
    /// An array of the selected items.
    public var selectedItems: [Item] {
        return self.tableView.selectedRowIndexes.compactMap({item(forRow: $0)})
    }
    
    /*
    /// An array of items that are displaying (currently visible).
    public var displayingItems: [Item] {
        self.tableView.display
        self.collectionView.displayingIndexPaths().compactMap({self.item(for: $0)})
    }
     */
    
    /// An array of items that are visible.
    public func visibleItems() -> [Item] {
        self.tableView.visibleRowIndexes().compactMap({ item(forRow: $0) })
    }
    
    /**
     Returns the item at the specified row in the table view.
     
     - Parameters row: The row of the item in the table view.
     - Returns: The item, or `nil` if the method doesn’t find an item at the provided row.
     */
    public func item(forRow row: Int) -> Item? {
        if let itemID = dataSource.itemIdentifier(forRow: row) {
            return allItems[id: itemID]
        }
        return nil
    }
    
    /// Returns the row for the specified item.
    public func row(for item: Item) -> Int? {
        return self.dataSource.row(forItemIdentifier: item.id)
    }
    
    /**
     Returns the section at the specified row in the table view.
     
     - Parameters row: The row of the section in the table view.
     - Returns: The section, or `nil if the method doesn’t find an item with the provided item identifier.
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
     
     - Parameters indexPath: The indexPath
     - Returns: The item at the index path or nil if there isn't any item at the index path.
     */
    public func item(at point: CGPoint) -> Item? {
        let row = self.tableView.row(at: point)
        if row != -1 {
            return item(forRow: row)
        }
        return nil
    }
    
    /*
    public func frame(for item: Item) -> CGRect? {
        
        self.tableView.fram
        if let index = row(for: item)?.item {
            return self.collectionView.frameForItem(at: index)
        }
        return nil
    }
    */
    
    
    public func rowView(for item: Item) -> NSTableRowView? {
        if let row = row(for: item) {
            return self.tableView.rowView(atRow: row, makeIfNecessary: false)
        }
        return nil
    }
    
    public func rows(for items: [Item]) -> [Int] {
        return items.compactMap({row(for: $0)})
    }
    
    public func rows(for section: Section) -> [Int] {
        let items = self.currentSnapshot.itemIdentifiers(inSection: section)
        return self.rows(for: items)
    }
    
    public func rows(for sections: [Section]) -> [Int] {
        return sections.flatMap({self.rows(for: $0)})
    }
    
    public func section(for item: Item) -> Section? {
        return self.currentSnapshot.sectionIdentifier(containingItem: item)
    }
    
    public func isSelected(at row: Int) -> Bool {
        return self.tableView.selectedRowIndexes.contains(row)
    }
    
    public func isSelected(for item: Item) -> Bool {
        if let row = row(for: item) {
            return isSelected(at: row)
        }
        return false
    }
    
    /*
    public func reconfigurateItems(_ items: [Item]) {
        let indexPaths = items.compactMap({self.indexPath(for:$0)})
        self.reconfigureItems(at: indexPaths)
    }
    
    public func reconfigureItems(at indexPaths: [IndexPath]) {
        self.collectionView.reconfigureItems(at: indexPaths)
    }
     */
    
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
    
    public func selectItems(in sections: [Section]) {
        let rows = sections.flatMap({self.rows(for: $0)})
        self.selectItems(at: rows)
    }
    
    public func selectItems(at rows: [Int]) {
        self.tableView.selectRowIndexes(IndexSet(rows), byExtendingSelection: true)
    }
    
    public func selectItems(_ items: [Item]) {
        self.selectItems(at: rows(for: items))
    }
    
    public func deselectItems(in sections: [Section]) {
        let rows = sections.flatMap({self.rows(for: $0)})
        self.deselectItems(at: rows)
    }
    
    public func deselectItems(at rows: [Int]) {
        rows.forEach({self.tableView.deselectRow($0)})
    }
    
    public func deselectItems(_ items: [Item]) {
        self.deselectItems(at: rows(for: items))
    }
    
    public func scrollTo(_ item: Item, scrollPosition: NSCollectionView.ScrollPosition = []) {
        if let row = self.row(for: item) {
            self.tableView.scrollRowToVisible(row)
        }
    }
    
    public func moveItems( _ items: [Item], before beforeItem: Item) {
        var snapshot = self.snapshot()
        items.forEach({snapshot.moveItem($0, beforeItem: beforeItem)})
        self.apply(snapshot)
    }
    
    public func moveItems( _ items: [Item], after afterItem: Item) {
        var snapshot = self.snapshot()
        items.forEach({snapshot.moveItem($0, afterItem: afterItem)})
        self.apply(snapshot)
    }
    
    public func moveItems(at rows: [Int], to toRow: Int) {
        let items = rows.compactMap({self.item(forRow: $0)})
        if let toItem = self.item(forRow: toRow), items.isEmpty == false {
            self.moveItems(items, before: toItem)
        }
    }
    
    public func removeItems( _ items: [Item]) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(items)
        self.apply(snapshot, .animated)
    }
}
