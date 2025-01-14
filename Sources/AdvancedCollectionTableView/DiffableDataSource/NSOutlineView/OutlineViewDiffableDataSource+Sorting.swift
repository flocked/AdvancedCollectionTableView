//
//  OutlineViewDiffableDataSource+Sorting.swift
//  
//
//  Created by Florian Zand on 03.08.24.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension OutlineViewDiffableDataSource {
    /**
     Sets the specified item sort comperator to the table column.
     
     - Parameters:
        - comparator: The item sorting comperator, or `nil` to remove any sorting comperators from the table column.
        - tableColumn: The table column.
     */
    public func setSortComparator(_ comparator: SortingComparator<ItemIdentifierType>?, forColumn tableColumn: NSTableColumn, activate: Bool = false) {
        if activate, comparator != nil, let key = tableColumn.sortDescriptorPrototype?.key {
            outlineView.sortDescriptors.removeAll(where: { $0.key == key })
        }
        if let comparator = comparator {
            tableColumn.sortDescriptorPrototype = ItemIdentifierTypeSortDescriptor([comparator])
            if activate {
                outlineView.sortDescriptors = [tableColumn.sortDescriptorPrototype!] + outlineView.sortDescriptors
            }
        } else if tableColumn.sortDescriptorPrototype is ItemIdentifierTypeSortDescriptor {
            tableColumn.sortDescriptorPrototype = nil
        }
    }
    
    /**
     Sets the specified item sort comperators to the table column.
     
     - Parameters:
        - comparators: The item sorting comperators.
        - tableColumn: The table column.
     */
    public func setSortComparators(_ comparators: [SortingComparator<ItemIdentifierType>], forColumn tableColumn: NSTableColumn, activate: Bool = false) {
        if activate, !comparators.isEmpty, let key = tableColumn.sortDescriptorPrototype?.key {
            outlineView.sortDescriptors.removeAll(where: { $0.key == key })
        }
        if comparators.isEmpty {
            setSortComparator(nil, forColumn: tableColumn)
        } else {
            tableColumn.sortDescriptorPrototype = ItemIdentifierTypeSortDescriptor(comparators)
            if activate {
                outlineView.sortDescriptors = [tableColumn.sortDescriptorPrototype!] + outlineView.sortDescriptors
            }
        }
    }
    
    class ItemIdentifierTypeSortDescriptor: NSSortDescriptor {
        
        var comparators: [SortingComparator<ItemIdentifierType>] = []
        
        init(_ comparators: [SortingComparator<ItemIdentifierType>], ascending: Bool = true, key: String? = nil) {
            super.init(key: key ?? UUID().uuidString, ascending: ascending, selector: nil)
            self.comparators = comparators
        }
        
        override var reversedSortDescriptor: Any {
            var comparators = comparators
            comparators.editEach({$0.order.toggle() })
            return ItemIdentifierTypeSortDescriptor(comparators, ascending: !ascending, key: key)
        }
        
        override func copy() -> Any {
            ItemIdentifierTypeSortDescriptor(comparators, ascending: ascending, key: key)
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let object = object as? ItemIdentifierTypeSortDescriptor else { return false }
            return object.key == key && object.ascending == ascending && object.comparators == comparators
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
