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
    func setItemSorting(_ sorting: ItemSorting?, forColumn tableColumn: NSTableColumn) {
        if let sorting = sorting {
            tableColumn.sortDescriptorPrototype = ItemSortDescriptor([sorting])
        } else {
            tableColumn.sortDescriptorPrototype = nil
        }
    }
    
    func setItemSortings(_ sortings: [ItemSorting], for tableColumn: NSTableColumn) {
        guard !sortings.isEmpty else { return }
        tableColumn.sortDescriptorPrototype = ItemSortDescriptor(sortings)
    }
    
    func sort(_ items: [Item], using sortings: [ItemSorting]) -> [Item] {
        items.sorted(by: { (elm1, elm2) -> Bool in
            for sorting in sortings {
                switch sorting.compare(elm1, elm2) {
                case .orderedSame:
                    break
                case .orderedAscending:
                    return true
                case .orderedDescending:
                    return false
                }
            }
            return false
        })
    }
    
    class ItemSortDescriptor: NSSortDescriptor {
        var itemSortings: [ItemSorting]
        init(_ itemSortings: [ItemSorting]) {
            self.itemSortings = itemSortings
            super.init(key: UUID().uuidString, ascending: itemSortings.first?.ascending ?? true)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    struct ItemSorting {
        let compare: (Item, Item, Bool) -> ComparisonResult
        public var ascending: Bool
        public let keyPath: PartialKeyPath<Item>?
        
        var elementSorting: ElementSorting<Item> {
            .compare{ compare($0, $1, ascending) }
        }
        
        public func compare(_ lhs: Item, _ rhs: Item) -> ComparisonResult {
            compare(lhs, rhs, ascending)
        }
        
        static func ascending() -> ItemSorting where Item: Comparable {
            ItemSorting(compare: { lhs, rhs, ascending -> ComparisonResult in
                return sort(lhs, rhs, ascending: ascending)
            }, ascending: true, keyPath: nil)
        }
        
        /// Sorts the elements of a sequence by the specified key path in an ascending order.
        public static func ascending<T: Comparable>(_ keyPath: KeyPath<Item, T>) -> ItemSorting {
            return ItemSorting(compare: { lhs, rhs, ascending -> ComparisonResult in
                let (x, y) = (lhs[keyPath: keyPath], rhs[keyPath: keyPath])
                return sort(x, y, ascending: ascending)
            }, ascending: true, keyPath: keyPath)
        }
        
        /// Sorts the elements of a sequence by the specified key path in an ascending order.
        public static func ascending<T: Comparable>(_ keyPath: KeyPath<Item, T?>) -> ItemSorting {
            return ItemSorting(compare: { lhs, rhs, ascending -> ComparisonResult in
                let (x, y) = (lhs[keyPath: keyPath], rhs[keyPath: keyPath])
                guard let y = y else { return .orderedDescending }
                guard let x = x else { return .orderedAscending }
                return sort(x, y, ascending: ascending)
            }, ascending: true, keyPath: keyPath)
        }
        
        static func descending() -> ItemSorting where Item: Comparable {
            ItemSorting(compare: { lhs, rhs, ascending -> ComparisonResult in
                return sort(lhs, rhs, ascending: ascending)
            }, ascending: false, keyPath: nil)
        }
        
        /// Sorts the elements of a sequence by the specified key path in an descending order.
        public static func descending<T: Comparable>(_ keyPath: KeyPath<Item, T>) -> ItemSorting {
            return ItemSorting(compare: { lhs, rhs, ascending -> ComparisonResult in
                let (x, y) = (lhs[keyPath: keyPath], rhs[keyPath: keyPath])
                return sort(x, y, ascending: ascending)
            }, ascending: false, keyPath: keyPath)
        }
        
        /// Sorts the elements of a sequence by the specified key path in an descending order.
        public static func descending<T: Comparable>(_ keyPath: KeyPath<Item, T?>) -> ItemSorting {
            return ItemSorting(compare: { lhs, rhs, ascending -> ComparisonResult in
                let (x, y) = (lhs[keyPath: keyPath], rhs[keyPath: keyPath])
                guard let y = y else { return .orderedAscending }
                guard let x = x else { return .orderedDescending }
                return sort(x, y, ascending: ascending)
            }, ascending: false, keyPath: keyPath)
        }
        
        static func sort<T: Comparable>(_ x: T, _ y: T, ascending: Bool) -> ComparisonResult {
            if x == y {
                return .orderedSame
            } else if x < y {
                return ascending ? .orderedAscending : .orderedDescending
            } else {
                return ascending ? .orderedDescending : .orderedAscending
            }
        }
    }
}
