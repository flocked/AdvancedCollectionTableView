//
//  OutlineViewDiffableDataSourceSnapshot.swift
//
//
//  Created by Florian Zand on 21.12.24.
//

import AppKit
import FZSwiftUtils

/**
 A representation of the state of the data in a outlineview at a specific point in time.
 
 A section snapshot represents the data for a single section in a collection view. Through a section snapshot, you set up the initial state of the data that displays in an individual section of your view, and later update that data.
 
 You can use section snapshots with or instead of an NSDiffableDataSourceSnapshot, which represents the data in the entire view. Use a section snapshot when you need precise management of the data in a section of your layout, such as when the sections of your layout acquire their data from different sources. You can also use a section snapshot to represent data with a hierarchical structure, such as an outline with expandable items.
 
 The following example creates a section snapshot with one root item that contains three child items:

 ```swift
// Create a section snapshot
var sectionSnapshot = NSOutlineViewDiffableDataSourceSnapshot<String>()
     
// Populate the section snapshot
sectionSnapshot.append(["Food", "Drinks"])
 sectionSnapshot.append(["🍏", "🍓", "🥐"], to: "Food")
     
// Apply the section snapshot
dataSource.apply(sectionSnapshot)
 ```
 */
public struct OutlineViewDiffableDataSourceSnapshot<ItemIdentifierType: Hashable> {
    // MARK: - Creating a section snapshot
    
    struct Node {
        var parent: ItemIdentifierType?
        var children: [ItemIdentifierType] = []
        var isExpanded: Bool = false
    }
    
    /// Creates an empty section snapshot.
    public init() { }
    
    /// Internal storage for the hierarchy of items.
    var nodes: [ItemIdentifierType: Node] = [:]
    
    /// The items ordered.
    private var orderedItems: OrderedSet<ItemIdentifierType> = []
    
    /// The identifiers of the items at the top level of the section snapshot’s hierarchy.
    public internal(set) var rootItems: [ItemIdentifierType] = []
    
    /// The identifiers of all items in the section snapshot.
    public var items: [ItemIdentifierType] {
        Array(orderedItems)
    }
        
    /// The identifiers of the currently visible items in the section snapshot.
    public var visibleItems: [ItemIdentifierType] {
        func visibleChilds(for parent: ItemIdentifierType) -> [ItemIdentifierType] {
            var visibleItems = children(of: parent).filter({ isExpanded($0) })
            visibleItems += visibleItems.flatMap({ visibleChilds(for: $0) })
            return visibleItems
        }
        return rootItems + rootItems.flatMap({ visibleChilds(for: $0) })
    }
    
    // MARK: - Adding ItemIdentifierTypes
    
    /// Adds the specified items as child items of the specified parent item in the section snapshot.
    public mutating func append(_ items: [ItemIdentifierType], to parent: ItemIdentifierType? = nil) {
        validateItems(items)
        if let parent = parent {
            validateItem(parent, "Parent item does not exist in section snapshot: ")
            nodes[parent]?.children.append(contentsOf: items)
        } else {
            rootItems.append(contentsOf: items)
        }
        items.forEach({ nodes[$0] = Node(parent: parent) })
        updateOrderedItems()
    }
    
    // MARK: - Inserting items
    
    /// Inserts the provided items immediately after the item with the specified identifier in the section snapshot.
    public mutating func insert(_ items: [ItemIdentifierType], after item: ItemIdentifierType) {
        insert(items, to: item, before: false)
    }

    /// Inserts the provided items immediately before the item with the specified identifier in the section snapshot.
    public mutating func insert(_ items: [ItemIdentifierType], before item: ItemIdentifierType) {
        insert(items, to: item, before: true)
    }
  
    private mutating func insert(_ items: [ItemIdentifierType], to item: ItemIdentifierType, before: Bool) {
        validateItem(item, "ItemIdentifierType to insert \(before ? "before" : "after") does not exist in section snapshot: ")
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
    
    /// Inserts the provided section snapshot immediately after the item with the specified identifier in the section snapshot.
    public mutating func insert(_ snapshot: OutlineViewDiffableDataSourceSnapshot, after item: ItemIdentifierType) {
       insert(snapshot, to: item, before: false)
    }
    
    /// Inserts the provided section snapshot immediately before the item with the specified identifier in the section snapshot.
    public mutating func insert(_ snapshot: OutlineViewDiffableDataSourceSnapshot, before item: ItemIdentifierType) {
       insert(snapshot, to: item, before: true)
    }
    
    private mutating func insert(_ snapshot: OutlineViewDiffableDataSourceSnapshot, to item: ItemIdentifierType, before: Bool) {
        validateItem(item, "ItemIdentifierType to insert \(before ? "before" : "after") does not exist in section snapshot: ")
        validateItems(snapshot.items)
        if let rootIndex = rootItems.firstIndex(of: item) {
            rootItems.insert(contentsOf: snapshot.rootItems, at: before ? rootIndex : rootIndex + 1)
            nodes.merge(snapshot.nodes)
        } else if let parentItem = parent(of: item),
                  let childIndex = nodes[parentItem]?.children.firstIndex(of: item) {
            nodes[parentItem]?.children.insert(contentsOf: snapshot.rootItems, at: before ? childIndex : childIndex + 1)
            nodes.merge(snapshot.nodes)
            snapshot.rootItems.forEach({ nodes[$0]?.parent = parentItem })
        }
        updateOrderedItems()
    }
    
    /// Moves the item from its current position in the snapshot to the position immediately before the specified item.
    public mutating func move(_ item: ItemIdentifierType, before: ItemIdentifierType) {
        move(item, to: before, before: true)
    }
    
    public mutating func move(_ item: ItemIdentifierType, after: ItemIdentifierType) {
        move(item, to: after, before: false)
    }
    
    /// Moves the item from its current position in the snapshot to the position immediately after the specified item.
    private mutating func move(_ item: ItemIdentifierType, to toItem: ItemIdentifierType, before: Bool) {
        validateItem(item, "ItemIdentifierType to move does not exist in section snapshot: \(String(describing: item))")
        validateItem(toItem, "ItemIdentifierType to move \(before ? "before" : "after") does not exist in section snapshot: \(String(describing: toItem))")
        if let index = rootItems.firstIndex(of: toItem) {
            deleteItemFromParent(item)
            rootItems.insert(item, at: before ? index : index + 1)
            nodes[item]?.parent = nil
        } else if let parent = parent(of: toItem), let index = nodes[parent]?.children.firstIndex(of: item) {
            deleteItemFromParent(item)
            nodes[parent]?.children.insert(item, at: before ? index : index + 1)
            nodes[item]?.parent = parent
        }
        updateOrderedItems()
    }
    
    /// Creates a section snapshot that contains the child items of the specified parent item, optionally including the parent item.
    public func snapshot(of parent: ItemIdentifierType, includingParent: Bool = false) -> OutlineViewDiffableDataSourceSnapshot {
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
    
    /// Finds the index of the specified item in the section snapshot.
    public func index(of item: ItemIdentifierType) -> Int? {
        return orderedItems.firstIndex(of: item)
    }
    
    /// Finds the hierarchical level of the specified item in the section snapshot.
    public func level(of item: ItemIdentifierType) -> Int? {
        guard contains(item) else { return nil }
        var level = 0
        var item = item
        while let parent = parent(of: item) {
            item = parent
            level += 1
        }
        return level
    }
    
    /// Finds the parent item of the specified item in the section snapshot.
    public func parent(of item: ItemIdentifierType) -> ItemIdentifierType? {
        nodes[item]?.parent
    }
    
    /// Returns the children items of the specified item in the section snapshot.
    public func children(of parent: ItemIdentifierType, recursive: Bool = false) -> [ItemIdentifierType] {
        if !recursive {
            return nodes[parent]?.children ?? []
        }
        return descendants(of: parent)
    }
    
    /// Indicates whether the section snapshot contains the specified item.
    public func contains(_ item: ItemIdentifierType) -> Bool {
        nodes[item] != nil
    }
    
    /// Indicates whether the specified item is currently visible onscreen.
    public func isVisible(_ item: ItemIdentifierType) -> Bool {
        var item = item
        while let parent = parent(of: item) {
            if nodes[parent]?.isExpanded == false {
                return false
            }
            item = parent
        }
        return true
    }

    // MARK: - Removing items

    /// Deletes the items with the specified identifiers, and any of their child items, from the section snapshot.
    public mutating func delete(_ items: [ItemIdentifierType]) {
        for item in items {
            validateItem(item, "ItemIdentifierType to delete does not exist in section snapshot: ")
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
        
    /// Replaces all child items of the specified parent item with the provided section snapshot.
    public mutating func replace(childrenOf parent: ItemIdentifierType, using snapshot: OutlineViewDiffableDataSourceSnapshot) {
        validateItem(parent, "Parent item does not exist in section snapshot: ")
        validateItems(Array(snapshot.orderedItems), removing: descendants(of: parent))
        guard let previousChildren = nodes[parent]?.children else { return }
        previousChildren.forEach({ deleteItemAndDescendants($0) })
        nodes[parent]?.children = snapshot.rootItems
        nodes.merge(snapshot.nodes)
        snapshot.rootItems.forEach({ nodes[$0]?.parent = parent })
        updateOrderedItems()
    }
    
    // MARK: - Expanding and collapsing items
    
    /// Indicates whether the item with the specified identifier is in an expanded state.
    public func isExpanded(_ item: ItemIdentifierType) -> Bool {
        nodes[item]?.isExpanded == true
    }
    
    /// Expands the specified items in the section snapshot.
    public mutating func expand(_ items: [ItemIdentifierType]) {
        items.forEach({ nodes[$0]?.isExpanded = true })
    }
    
    /// Collapses the specified items in the section snapshot.
    public mutating func collapse(_ items: [ItemIdentifierType]) {
        items.forEach({ nodes[$0]?.isExpanded = false })
    }
    
    /// Returns a string with an ASCII representation of the section snapshot.
    public func visualDescription() -> String {
        var result = "OutlineViewDiffableDataSourceSnapshot<\(String(describing: ItemIdentifierType.self))>\n"
        
        func buildDescription(for item: ItemIdentifierType, level: Int) {
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
    private func descendants(of parent: ItemIdentifierType) -> [ItemIdentifierType] {
        var result: [ItemIdentifierType] = []
        var stack: [ItemIdentifierType] = [parent]
        
        while !stack.isEmpty {
            let currentItem = stack.removeLast()
            let children = children(of: currentItem)
            result.append(contentsOf: children)
            stack.append(contentsOf: children)
        }
        return result
    }
    
    private mutating func deleteItemAndDescendants(_ item: ItemIdentifierType) {
        let descendants = descendants(of: item)
        let itemsToDelete = descendants + item
        itemsToDelete.forEach({ nodes[$0] = nil })
        orderedItems.removeAll { itemsToDelete.contains($0) }
    }
    
    private mutating func deleteItemFromParent(_ item: ItemIdentifierType) {
        if let parent = parent(of: item), let index = nodes[parent]?.children.firstIndex(of: item) {
            nodes[parent]?.children.remove(at: index)
        }
    }
    
    func validateItems(_ items: [ItemIdentifierType], removing: [ItemIdentifierType] = [], _ message: String = "ItemIdentifierTypes in a section snapshot must be unique. Duplicate items:\n") {
        var orderedItems = orderedItems
        orderedItems.remove(removing)
        var duplicates: OrderedSet<ItemIdentifierType> = []
        for item in items {
            if orderedItems.contains(item) {
                duplicates.append(item)
            }
            orderedItems.append(item)
        }
        if !duplicates.isEmpty {
            let duplicateItemIdentifierTypesString = duplicates.compactMap({String(describing: $0)}).joined(separator: "\n")
            NSException(name: .internalInconsistencyException, reason: "\(message)\(duplicateItemIdentifierTypesString)", userInfo: nil).raise()
        }
    }
    
    func validateItem(_ item: ItemIdentifierType, _ message: String) {
        if !contains(item) {
            NSException(name: .internalInconsistencyException, reason: message + String(describing: item), userInfo: nil).raise()
        }
    }
    
    mutating func updateOrderedItems() {
        orderedItems = []
        for root in rootItems {
            orderedItems.append(root)
            orderedItems.append(contentsOf: descendants(of: root))
        }
    }
    
    func isExpandable(_ item: ItemIdentifierType) -> Bool {
        !children(of: item).isEmpty
    }
}
