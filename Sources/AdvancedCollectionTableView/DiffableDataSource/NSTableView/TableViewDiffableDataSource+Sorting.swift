//
//  Collection+Sorting.swift
//  Example
//
//  Created by Florian Zand on 03.08.24.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import AdvancedCollectionTableView

extension TableViewDiffableDataSource {
    func setSortComparator(_ comparator: ElementSortComparator<Item>?, forColumn tableColumn: NSTableColumn, activate: Bool = false) {
        if let comparator = comparator {
            tableColumn.sortDescriptorPrototype = ItemSortDescriptor([comparator])
        } else if tableColumn.sortDescriptorPrototype is ItemSortDescriptor {
            tableColumn.sortDescriptorPrototype = nil
        }
    }
    
    func setSortComparators(_ comparators: [ElementSortComparator<Item>], forColumn tableColumn: NSTableColumn) {
        guard !comparators.isEmpty else { return }
        tableColumn.sortDescriptorPrototype = ItemSortDescriptor(comparators)
    }
    
    func setSortComparators(_ comparators: ElementSortComparator<Item>..., forColumn tableColumn: NSTableColumn) {
        setSortComparators(comparators, forColumn: tableColumn)
    }
    
    class ItemSortDescriptor: NSSortDescriptor {
        var comparators: [ElementSortComparator<Item>] = []
        
        override init(key: String?, ascending: Bool, selector: Selector?) {
            super.init(key: key, ascending: ascending, selector: selector)
        }
        
        public init(_ comparators: [ElementSortComparator<Item>]) {
            super.init(key: UUID().uuidString, ascending: true, selector: nil)
            self.comparators = comparators
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @discardableResult
        func comparators(_ comparators: [ElementSortComparator<Item>]) -> Self {
            self.comparators = comparators
            return self
        }
                
        func updateOrder() {
            comparators.editEach({$0.order = ascending ? .forward : .reverse})
        }
    }
}
