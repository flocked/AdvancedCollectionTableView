//
//  Collection+Sorting.swift
//  Example
//
//  Created by Florian Zand on 03.08.24.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension TableViewDiffableDataSource {
    /**
     Sets the specified item sort comperator to the table column.
     
     - Parameters:
        - comparator: The item sorting comperator, or `nil` to remove any sorting comperators from the table column.
        - tableColumn: The table column.
     */
    func setSortComparator(_ comparator: SortingComparator<Item>?, forColumn tableColumn: NSTableColumn, activate: Bool = false) {
        if let comparator = comparator {
            tableColumn.sortDescriptorPrototype = ItemSortDescriptor([comparator])
        } else if tableColumn.sortDescriptorPrototype is ItemSortDescriptor {
            tableColumn.sortDescriptorPrototype = nil
        }
    }
    
    /**
     Sets the specified item sort comperators to the table column.
     
     - Parameters:
        - comparators: The item sorting comperators.
        - tableColumn: The table column.
     */
    func setSortComparators(_ comparators: [SortingComparator<Item>], forColumn tableColumn: NSTableColumn) {
        if comparators.isEmpty {
            setSortComparator(nil, forColumn: tableColumn)
        } else {
            tableColumn.sortDescriptorPrototype = ItemSortDescriptor(comparators)
        }
    }
    
    class ItemSortDescriptor: NSSortDescriptor {
        
        var comparators: [SortingComparator<Item>] = []
        
        @discardableResult
        func comparators(_ comparators: [SortingComparator<Item>]) -> Self {
            self.comparators = comparators
            return self
        }
        
        init(_ comparators: [SortingComparator<Item>], ascending: Bool = true, key: String? = nil) {
            super.init(key: key ?? UUID().uuidString, ascending: ascending, selector: nil)
            self.comparators = comparators
        }
        
        override var reversedSortDescriptor: Any {
            var comparators = comparators
            comparators.editEach({$0.order = $0.order == .forward ? .reverse : .forward})
            return ItemSortDescriptor(comparators, ascending: !ascending, key: key)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
