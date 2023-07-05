//
//  File.swift
//  
//
//  Created by Florian Zand on 21.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import FZQuicklook

extension AdvanceTableViewDiffableDataSource {
    public var allElements: [Element] {
        return self.currentSnapshot.itemIdentifiers
    }
    
    public var selectionIndexes: [Int] {
        return Array(self.tableView.selectedRowIndexes).sorted()
    }
    
    public var selectedElements: [Element] {
        return self.selectionIndexes.compactMap({element(for: $0)})
    }

    
    public var visibleRowIndexes: [Int] {
        return self.tableView.visibleRowIndexes()
    }
    
    public var visibleElements: [Element] {
        let rowIndexes = self.visibleRowIndexes
        return rowIndexes.compactMap({self.element(for: $0)})
    }
    
    
    
    public func element(for row: Int) ->  Element? {
        if let itemId = self.dataSource.itemIdentifier(forRow: row) {
            return self.currentSnapshot.itemIdentifiers[id: itemId]
        }
        return nil
    }
    
    public func element(at point: CGPoint) -> Element? {
        let row = self.tableView.row(at: point)
            return element(for: row)
    }
    
    public func frame(for element: Element) -> CGRect? {
        if let index = rowIndex(for: element) {
            return self.tableView.rect(ofRow: index)
        }
        return nil
    }
    
    public func rowIndex(for element: Element) -> Int? {
        return dataSource.rows(for: [element.id]).first
    }
    
    public func rowIndexes(for elements: [Element]) -> [Int] {
        return dataSource.rows(for: elements.ids)
    }
        
    public func rowIndexes(for section: Section) -> [Int] {
        let elements = self.currentSnapshot.itemIdentifiers(inSection: section)
       return self.rowIndexes(for: elements)
    }
    
    public func rowIndexes(for sections: [Section]) -> [Int] {
        return sections.flatMap({self.rowIndexes(for: $0)})
    }
    
    public func section(for element: Element) -> Section? {
        return self.currentSnapshot.sectionIdentifier(containingItem: element)
    }
    
    public func section(for indexPath: IndexPath) -> Section? {
        if (indexPath.section <= self.sections.count-1) {
            return sections[indexPath.section]
        }
        return nil
    }

    public func rowView(for element: Element, makeIfNecessary: Bool) -> NSTableRowView? {
        if let rowIndex = rowIndex(for: element) {
           return self.tableView.rowView(atRow: rowIndex, makeIfNecessary: makeIfNecessary)
        }
        return nil
    }
    
    public func isRowSelected(at row: Int) -> Bool {
        self.tableView.selectedRowIndexes.contains(row)
    }
    
    public func isRowSelected(_ element: Element) -> Bool {
        if let rowIndex = rowIndex(for: element) {
            return isRowSelected(at: rowIndex)
        }
        return false
    }
    
    public func reloadItems(at rows: [Int], animated: Bool = false) {
        let elements = rows.compactMap({self.element(for: $0)})
        self.reloadItems(elements, animated: animated)
    }
    
    public func reloadItems(_ elements: [Element], animated: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(elements.ids)
        dataSource.apply(snapshot, animated ? .animated : .non)
    }
    
    public func reloadAllItems(complection: (() -> Void)? = nil) {
        var snapshot = snapshot()
        snapshot.reloadItems(snapshot.itemIdentifiers)
        self.apply(snapshot, .usingReloadData)
    }
    
    public func selectAll() {
        self.tableView.selectAll(nil)
    }
    
    
    public func deselectAll() {
        self.tableView.deselectAll(nil)
    }
    
    public func selectItems(in sections: [Section], byExtendingSelection: Bool = true) {
        let indexes = rowIndexes(for: sections)
        self.selectItems(at: indexes,  byExtendingSelection: byExtendingSelection)
    }
    
    public func deselectItems(in sections: [Section]) {
        let indexes = rowIndexes(for: sections)
        for row in indexes {
            self.tableView.deselectRow(row)
        }
    }
    
    public func selectItems(at rowIndexes: [Int], byExtendingSelection: Bool = true) {
        self.tableView.selectRowIndexes(IndexSet(rowIndexes), byExtendingSelection: byExtendingSelection)
    }
    
    public func selectElements(_ elements: [Element], byExtendingSelection: Bool = true) {
        self.selectItems(at: rowIndexes(for: elements), byExtendingSelection: byExtendingSelection)
    }
    
    public func deselectItems(at rows: [Int]) {
        for row in rows {
            self.tableView.deselectRow(row)
        }
    }
    
    public func deselectElements(_ elements: [Element]) {
        self.deselectItems(at: rowIndexes(for: elements))
    }
        
    public func scrollToItems(at rows: [Int]) {
        let rows = rows.sorted()
        if let firstRow = rows.first {
            self.tableView.scrollRowToVisible(firstRow)
        }
    }
    
    public func scrollTo(_ element: Element) {
        self.scrollTo([element])
    }
    
    public func scrollTo(_ elements: [Element]) {
        let rowIndexes = self.rowIndexes(for: elements)
        self.scrollToItems(at: rowIndexes)
    }
    
    public func moveElement( _ element: Element, before beforeElement: Element) {
        var snapshot = self.snapshot()
        snapshot.moveItem(element, beforeItem: beforeElement)
        self.apply(snapshot)
    }
    
    public func moveElement( _ element: Element, after afterElement: Element) {
        var snapshot = self.snapshot()
        snapshot.moveItem(element, afterItem: afterElement)
        self.apply(snapshot)
    }
    
    public func moveElements( _ elements: [Element], before beforeElement: Element) {
        var snapshot = self.snapshot()
        elements.forEach({snapshot.moveItem($0, beforeItem: beforeElement)})
        self.apply(snapshot)
    }
    
    public func moveElements( _ elements: [Element], after afterElement: Element) {
        var snapshot = self.snapshot()
        elements.forEach({snapshot.moveItem($0, afterItem: afterElement)})
        self.apply(snapshot)
    }
    
    public func moveElements(at rows: [Int], to toRow: Int) {
        let elements = rows.compactMap({self.element(for: $0)})
        if let toElement = self.element(for: toRow), elements.isEmpty == false {
            self.moveElements(elements, before: toElement)
        }
    }
    
    public func removeElements( _ elements: [Element]) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(elements)
        self.apply(snapshot)
    }
}

/*
extension AdvanceTableViewDiffableDataSource: PreviewableDataSource where Element: QLPreviewable {
    public func qlPreviewable(for indexPath: IndexPath) -> QLPreviewable? {
        self.element(for: indexPath.item)
    }
}
 */

    
    /*
     internal func supplementaryHeaderView(for section: Section) -> (NSView & NSCollectionViewElement)? {
         if let sectionIndex = currentSnapshot.indexOfSection(section) {
             let sectionIndexPath = IndexPath(item: 0, section: sectionIndex)
            return collectionView.supplementaryView(forElementKind: NSCollectionView.ElementKind.sectionHeader, at: sectionIndexPath)
         }
         return nil
     }
     
      public func reconfigurateItems(for elements: [Element]) {
         let indexPaths = elements.compactMap({self.indexPath(for:$0)})
         self.reconfigurateItems(at: indexPaths)
     }
     
     public func reconfigurateItems(at indexPaths: [IndexPath]) {
         self.collectionView.reconfigurateItems(at: indexPaths)
     }
     */
