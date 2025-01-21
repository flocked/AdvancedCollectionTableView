//
//  OutlineViewDiffableDataSourceSnapshot+OutlineItem.swift
//  
//
//  Created by Florian Zand on 09.01.25.
//

/*
import AppKit
import FZSwiftUtils


extension OutlineViewDiffableDataSourceSnapshot where ItemIdentifierType: ExpandingOutlineItem {
    public mutating func append(_ items: [ItemIdentifierType], to parent: ItemIdentifierType? = nil) {
        validateItems(items + items.flatMap({ $0.descendants() }))
        if let parent = parent {
            validateItem(parent, "Parent item does not exist in section snapshot: ")
            nodes[parent]?.children.append(contentsOf: items)
        } else {
            rootItems.append(contentsOf: items)
        }
        items.forEach({ nodes[$0] = Node(parent: parent) })
        items.forEach({ nodes.merge($0.nodes()) })
        updateOrderedItems()
    }
    
    private mutating func insert(_ items: [ItemIdentifierType], to item: ItemIdentifierType, before: Bool) {
        validateItem(item, "ItemIdentifierType to insert \(before ? "before" : "after") does not exist in section snapshot: ")
        validateItems(items + items.flatMap({ $0.descendants() }))
        if let rootIndex = rootItems.firstIndex(of: item) {
            rootItems.insert(contentsOf: items, at: before ? rootIndex : rootIndex + 1)
            items.forEach { nodes[$0] = .init() }
        } else if let parent = parent(of: item), let childIndex = nodes[parent]?.children.firstIndex(of: item) {
            nodes[parent]?.children.insert(contentsOf: items, at: before ? childIndex : childIndex + 1)
            items.forEach { nodes[$0] = .init(parent: parent) }
        }
        items.forEach({ nodes.merge($0.nodes()) })
        updateOrderedItems()
    }
    
    private mutating func insert(_ snapshot: OutlineViewDiffableDataSourceSnapshot, to item: ItemIdentifierType, before: Bool) {
        validateItem(item, "ItemIdentifierType to insert \(before ? "before" : "after") does not exist in section snapshot: ")
        validateItems(snapshot.items + snapshot.items.flatMap({ $0.descendants() }))
        if let rootIndex = rootItems.firstIndex(of: item) {
            rootItems.insert(contentsOf: snapshot.rootItems, at: before ? rootIndex : rootIndex + 1)
            nodes.merge(snapshot.nodes)
        } else if let parentItem = parent(of: item),
                  let childIndex = nodes[parentItem]?.children.firstIndex(of: item) {
            nodes[parentItem]?.children.insert(contentsOf: snapshot.rootItems, at: before ? childIndex : childIndex + 1)
            nodes.merge(snapshot.nodes)
            snapshot.rootItems.forEach({ nodes[$0]?.parent = parentItem })
        }
        items.forEach({ nodes.merge($0.nodes()) })
        updateOrderedItems()
    }
}

extension ExpandingOutlineItem {
    func descendants() -> [Self] {
        var items: [Self] = []
        for child in children {
            items.append(child)
            items.append(contentsOf: child.descendants())
        }
        return items
    }

    
    func nodes() -> [Self: OutlineViewDiffableDataSourceSnapshot<Self>.Node] {
        var nodes: [Self: OutlineViewDiffableDataSourceSnapshot<Self>.Node] = [:]
        func setup(for child: Self, parent: Self?) {
            nodes[child] = OutlineViewDiffableDataSourceSnapshot<Self>.Node(parent: parent, children: child.children, isExpanded: child.isExpanded)
            for _child in child.children {
                setup(for: _child, parent: child)
            }
        }
        setup(for: self, parent: nil)
        return nodes
    }
}
*/
