//
//  OutlineViewDiffableDataSourceSnapshot.swift
//
//
//  Created by Florian Zand on 21.12.24.
//

import AppKit
import FZSwiftUtils

/**
 A representation of the state of the data in a outline view at a specific point in time.
 
 ``OutlineViewDiffableDataSource`` uses snapshots to provide data for outline views. You use a snapshot to set up the initial state of the data that a view displays, and you use snapshots to reflect changes to the data that the view displays.
   
 The following example creates a snapshot with one root item that contains three child items:

 ```swift
// Create a snapshot
 var snapshot = OutlineViewDiffableDataSourceSnapshot<String>()
     
// Populate the snapshot
 snapshot.append(["Food", "Drinks"])
 snapshot.append(["🍏", "🍓", "🥐"], to: "Food")
     
// Apply the snapshot
dataSource.apply(snapshot)
 ```
 */
public struct OutlineViewDiffableDataSourceSnapshot<Item: Hashable> {
    
    struct Node {
        var parent: Item?
        var children: [Item] = []
        var isExpanded = false
    }
    
    // MARK: - Creating a snapshot
    
    /// Creates an empty snapshot.
    public init() { }
    
    /// Internal storage for the hierarchy of items.
    var nodes: [Item: Node] = [:]
    
    /// The items ordered.
    var orderedItems: OrderedSet<Item> = []
    
    /// The identifiers of the items at the top level of the snapshot’s hierarchy.
    public internal(set) var rootItems: [Item] = []
    
    /// A Boolean value indicating that the root items are displayed as group items.
    var usesGroupItems: Bool = false
    
    /// A Boolean value indicating whether the snapshot is currently used to calculate the diff to another snapshot.
    var isCalculatingDiff = false
    
    /// The identifiers of all items in the snapshot.
    public var items: [Item] {
        Array(orderedItems)
    }
        
    /// The identifiers of the currently visible items in the snapshot.
    public var visibleItems: [Item] {
        func visibleChilds(for parent: Item) -> [Item] {
            var visibleItems = children(of: parent).filter({ isExpanded($0) })
            visibleItems += visibleItems.flatMap({ visibleChilds(for: $0) })
            return visibleItems
        }
        return rootItems + rootItems.flatMap({ visibleChilds(for: $0) })
    }
    
    // MARK: - Adding Items
    
    /// Adds the specified items as child items of the specified parent item in the snapshot.
    public mutating func append(_ items: [Item], to parent: Item? = nil) {
        validateItems(items)
        if let parent = parent {
            validateItem(parent, "Parent item does not exist in snapshot: ")
            nodes[parent]?.children.append(contentsOf: items)
        } else {
            rootItems.append(contentsOf: items)
        }
        items.forEach({ nodes[$0] = Node(parent: parent) })
        updateOrderedItems()
    }
    
    // MARK: - Inserting items
    
    /// Inserts the provided items immediately after the item with the specified identifier in the snapshot.
    public mutating func insert(_ items: [Item], after item: Item) {
        insert(items, to: item, before: false)
    }

    /// Inserts the provided items immediately before the item with the specified identifier in the snapshot.
    public mutating func insert(_ items: [Item], before item: Item) {
        insert(items, to: item, before: true)
    }
  
    private mutating func insert(_ items: [Item], to item: Item, before: Bool) {
        validateItem(item, "Item to insert \(before ? "before" : "after") does not exist in snapshot: ")
        validateItems(items)
        if let rootIndex = rootItems.firstIndex(of: item) {
            rootItems.insert(contentsOf: items, at: before ? rootIndex : rootIndex + 1)
            items.forEach { nodes[$0] = .init() }
        } else if let parent = parent(of: item), let childIndex = nodes[parent]?.children.firstIndex(of: item) {
            nodes[parent]?.children.insert(contentsOf: items, at: before ? childIndex : childIndex + 1)
            items.forEach { nodes[$0] = .init(parent: parent) }
        }
        updateOrderedItems()
    }
    
    /// Inserts the provided items to the specified parent.
    public mutating func insert(_ items: [Item], atIndex index: Int, of parent: Item? = nil) {
        validateItems(items)
        if let parent = parent {
            validateItem(parent, "Parent item does not exist in snapshot: ")
            if index > children(of: parent).count {
                NSException(name: .internalInconsistencyException, reason: "Index is to large", userInfo: nil).raise()
            }
            nodes[parent]?.children.insert(contentsOf: items, at: index)
        } else if index > rootItems.count {
            NSException(name: .internalInconsistencyException, reason: "Index is to large", userInfo: nil).raise()
            rootItems.insert(contentsOf: items, at: index)
        }
        items.forEach({ nodes[$0] = .init(parent: parent) })
    }
    
    mutating func insert(_ item: Item, at index: Int, of parent: Item?) {
        if let parent = parent {
            nodes[parent]?.children.insert(item, at: index)
        } else {
            rootItems.insert(item, at: index)
        }
        nodes[item] = .init(parent: parent)
        updateOrderedItems()
    }
    
    /// Inserts the provided snapshot immediately after the item with the specified identifier in the snapshot.
    public mutating func insert(_ snapshot: OutlineViewDiffableDataSourceSnapshot, after item: Item) {
       insert(snapshot, to: item, before: false)
    }
    
    /// Inserts the provided snapshot immediately before the item with the specified identifier in the snapshot.
    public mutating func insert(_ snapshot: OutlineViewDiffableDataSourceSnapshot, before item: Item) {
       insert(snapshot, to: item, before: true)
    }
    
    private mutating func insert(_ snapshot: OutlineViewDiffableDataSourceSnapshot, to item: Item, before: Bool) {
        validateItem(item, "Item to insert \(before ? "before" : "after") does not exist in snapshot: ")
        validateItems(snapshot.items)
        if let rootIndex = rootItems.firstIndex(of: item) {
            rootItems.insert(contentsOf: snapshot.rootItems, at: before ? rootIndex : rootIndex + 1)
            nodes.merge(with: snapshot.nodes)
        } else if let parentItem = parent(of: item),
                  let childIndex = nodes[parentItem]?.children.firstIndex(of: item) {
            nodes[parentItem]?.children.insert(contentsOf: snapshot.rootItems, at: before ? childIndex : childIndex + 1)
            nodes.merge(with: snapshot.nodes)
            snapshot.rootItems.forEach({ nodes[$0]?.parent = parentItem })
        }
        updateOrderedItems()
    }
    
    /// Moves the items from their current position in the snapshot to the position immediately before the specified item.
    public mutating func move(_ items: [Item], before: Item) {
        move(items, to: before, before: true)
    }
    
    /// Moves the items from their current position in the snapshot to the position immediately after the specified item.
    public mutating func move(_ items: [Item], after: Item) {
        move(items, to: after, before: false)
    }
    
    private mutating func move(_ items: [Item], to toItem: Item, before: Bool) {
        validateMoveItems(items)
        validateItem(toItem, "Item to move \(before ? "before" : "after") does not exist in snapshot: \(String(describing: toItem))")
        
        let parent = parent(of: toItem)
        items.forEach({
            deleteItemFromParent($0)
            nodes[$0]?.parent = parent
        })
        if let parent = parent, let index = nodes[parent]?.children.firstIndex(of: toItem) {
            nodes[parent]?.children.insert(contentsOf: items, at: before ? index : index + 1)
        } else if let index = rootItems.firstIndex(of: toItem) {
            rootItems.insert(contentsOf: items, at: before ? index : index + 1)
        }
        
        updateOrderedItems()
    }
    
    /// Moves the items from their current position in the snapshot to the specified index of the specified parent.
    public mutating func move(_ items: [Item], toIndex index: Int, of parent: Item?) {
        validateMoveItems(items)
        if let parent = parent {
            validateItem(parent, "Parent item does not exist in snapshot: ")
            if index > children(of: parent).count {
                NSException(name: .internalInconsistencyException, reason: "Index is to large", userInfo: nil).raise()
            }
        } else if index > rootItems.count {
            NSException(name: .internalInconsistencyException, reason: "Index is to large", userInfo: nil).raise()
        }
        items.forEach({
            if self.parent(of: $0) != parent {
                deleteItemFromParent($0)
                nodes[$0]?.parent = parent
            }
        })
        if let parent = parent {
            nodes[parent]?.children._insert(items, at: index)
        } else {
            rootItems._insert(items, at: index)
        }
        updateOrderedItems()
    }
    
    /// Creates a snapshot that contains the child items of the specified parent item, optionally including the parent item.
    public func snapshot(of parent: Item, includingParent: Bool = false) -> OutlineViewDiffableDataSourceSnapshot {
        var snapshot = OutlineViewDiffableDataSourceSnapshot()
        snapshot.rootItems = includingParent ? [parent] : children(of: parent)
        for rootItem in snapshot.rootItems {
            snapshot.nodes[rootItem] = nodes[rootItem]
            snapshot.nodes[rootItem]?.parent = nil
            descendants(of: rootItem).forEach({ snapshot.nodes[$0] = nodes[$0] })
        }
        snapshot.updateOrderedItems()
        return snapshot
    }
    
    // MARK: - Getting item metrics
    
    /// Finds the index of the specified item in the snapshot.
    public func index(of item: Item) -> Int? {
        return orderedItems.firstIndex(of: item)
    }
    
    /// Finds the hierarchical level of the specified item in the snapshot.
    public func level(of item: Item) -> Int? {
        guard contains(item) else { return nil }
        var level = 0
        var item = item
        while let parent = parent(of: item) {
            item = parent
            level += 1
        }
        return level
    }
    
    /// Finds the parent item of the specified item in the snapshot.
    public func parent(of item: Item) -> Item? {
        nodes[item]?.parent
    }
    
    /// Returns the children items of the specified item in the snapshot.
    public func children(of parent: Item, recursive: Bool = false) -> [Item] {
        if !recursive {
            return nodes[parent]?.children ?? []
        }
        return descendants(of: parent)
    }
    
    /// Indicates whether the snapshot contains the specified item.
    public func contains(_ item: Item) -> Bool {
        nodes[item] != nil
    }
    
    /// Indicates whether the specified item is currently visible onscreen.
    public func isVisible(_ item: Item) -> Bool {
        var item = item
        while let parent = parent(of: item) {
            if nodes[parent]?.isExpanded == false {
                return false
            }
            item = parent
        }
        return true
    }
    
    /// A Boolean value indicating whether the item is a descendant of the specified parent.
    public func isDescendant(_ item: Item, of parent: Item) -> Bool {
        let children = children(of: parent)
        return children.contains(item) || children.contains(where: { isDescendant(item, of: $0) })
    }

    // MARK: - Removing items

    /// Deletes the items with the specified identifiers, and any of their child items, from the snapshot.
    public mutating func delete(_ items: [Item]) {
        for item in items {
            validateItem(item, "Item to delete does not exist in snapshot: ")
            if let index = rootItems.firstIndex(of: item) {
                rootItems.remove(at: index)
                deleteItemAndDescendants(item)
            } else if let parent = nodes[item]?.parent, let index = nodes[parent]?.children.firstIndex(of: item) {
                nodes[parent]?.children.remove(at: index)
                deleteItemAndDescendants(item)
            }
        }
    }

    /// Resets the snapshot to an empty state.
    public mutating func deleteAll() {
        nodes.removeAll()
        rootItems.removeAll()
    }
        
    /// Replaces all child items of the specified parent item with the provided snapshot.
    public mutating func replace(childrenOf parent: Item, using snapshot: OutlineViewDiffableDataSourceSnapshot) {
        validateItem(parent, "Parent item does not exist in snapshot: ")
        validateItems(Array(snapshot.items), removing: descendants(of: parent))
        guard let previousChildren = nodes[parent]?.children else { return }
        previousChildren.forEach({ deleteItemAndDescendants($0) })
        nodes[parent]?.children = snapshot.rootItems
        nodes.merge(with: snapshot.nodes)
        snapshot.rootItems.forEach({ nodes[$0]?.parent = parent })
        updateOrderedItems()
    }
    
    // MARK: - Expanding and collapsing items
    
    /// Indicates whether the item with the specified identifier is in an expanded state.
    public func isExpanded(_ item: Item) -> Bool {
        nodes[item]?.isExpanded == true
    }
    
    /// Expands the specified items in the snapshot.
    public mutating func expand(_ items: [Item]) {
        items.forEach({ nodes[$0]?.isExpanded = true })
    }
    
    /// Collapses the specified items in the snapshot.
    public mutating func collapse(_ items: [Item]) {
        items.forEach({ nodes[$0]?.isExpanded = false })
    }
    
    // MARK: - Debugging snapshots
        
    /// Returns a string with an ASCII representation of the snapshot.
    public func visualDescription() -> String {
        var result = "OutlineViewDiffableDataSourceSnapshot<\(String(describing: Item.self))>\n"
        
        func buildDescription(for item: Item, level: Int) {
            let isVisible = isVisible(item) ? "*" : ""
            let isExpanded = isExpanded(item) ? "+" : "-"
            let annotation = "\(isVisible)\(isExpanded)"
            let itemDescription = String(describing: item)
            result += String(repeating: "  ", count: level) + annotation + " \(itemDescription)\n"
            
            for child in children(of: item) {
                buildDescription(for: child, level: level + 1)
            }
        }
        for root in rootItems {
            buildDescription(for: root, level: 0)
        }
        return result
    }
    
    /// All descendants of a given item in depth-first order.
    func descendants(of parent: Item) -> [Item] {
        var result: [Item] = []
        var stack: [Item] = [parent]
        
        while !stack.isEmpty {
            let currentItem = stack.removeLast()
            let children = children(of: currentItem)
            result.append(contentsOf: children)
            stack.append(contentsOf: children)
        }
        return result
    }
    
    private mutating func deleteItemAndDescendants(_ item: Item) {
        let descendants = descendants(of: item)
        let itemsToDelete = descendants + item
        itemsToDelete.forEach({ nodes[$0] = nil })
        orderedItems.remove(itemsToDelete)
    }
    
    mutating func deleteItemFromParent(_ item: Item) {
        if let parent = parent(of: item), let index = nodes[parent]?.children.firstIndex(of: item) {
            nodes[parent]?.children.remove(at: index)
        } else if let index = rootItems.firstIndex(of: item) {
            rootItems.remove(at: index)
        }
    }
    
    func childIndex(of item: Item) -> Int? {
        if let parent = parent(of: item) {
            return children(of: parent).firstIndex(of: item)
        }
        return rootItems.firstIndex(of: item)
    }
    
    func validateItems(_ items: [Item], removing: [Item] = [], _ message: String = "Items in a snapshot must be unique. Duplicate items:\n") {
        guard !isCalculatingDiff else { return }
        var orderedItems = orderedItems
        orderedItems.remove(removing)
        var duplicates: OrderedSet<Item> = []
        for item in items {
            if orderedItems.contains(item) {
                duplicates.append(item)
            }
            orderedItems.append(item)
        }
        if !duplicates.isEmpty {
            let duplicateItemsString = duplicates.compactMap({String(describing: $0)}).joined(separator: "\n")
            NSException(name: .internalInconsistencyException, reason: "\(message)\(duplicateItemsString)", userInfo: nil).raise()
        }
    }
        
    func validateMoveItems(_ items: [Item]) {
        guard !isCalculatingDiff else { return }
        let items = items.filter({ nodes[$0] == nil })
        if !items.isEmpty {
            if items.count == 1 {
                NSException(name: .internalInconsistencyException, reason: "Item to move doesn't exist: \(items[0]) ", userInfo: nil).raise()
            } else {
                NSException(name: .internalInconsistencyException, reason: "Items to move don't exists: \(items.compactMap({ "\($0)" }).joined(separator: "\n")) ", userInfo: nil).raise()
            }
        }
    }
    
    func validateItem(_ item: Item, _ message: String) {
        guard !isCalculatingDiff else { return }
        if !contains(item) {
            NSException(name: .internalInconsistencyException, reason: message + String(describing: item), userInfo: nil).raise()
        }
    }
    
    mutating func updateOrderedItems() {
        guard !isCalculatingDiff else { return }
        orderedItems = []
        for root in rootItems {
            orderedItems.append(root)
            orderedItems.append(contentsOf: descendants(of: root))
        }
    }
    
    var expandedItems: Set<Item> {
        var items = Set(nodes.filter({ $0.value.isExpanded }).keys)
        if usesGroupItems {
            items += rootItems
        }
        return items
    }
}

fileprivate extension Array where Element: Equatable {
    mutating func _insert(_ items: [Element], at index: Int) {
        var adjustedIndex = index
        let filteredItems = items.filter { item in
            if let existingIndex = firstIndex(of: item) {
                if existingIndex < adjustedIndex {
                    adjustedIndex -= 1
                }
                remove(at: existingIndex)
                return true
            }
            return true
        }
        insert(contentsOf: filteredItems, at: adjustedIndex)
    }
}

/*
 /**
  The items that can't be collapsed.
  
  Only items that are inserted to the snapshot can be provided.
  */
 public var nonCollapsableItems: Set<Item> = []
 */
