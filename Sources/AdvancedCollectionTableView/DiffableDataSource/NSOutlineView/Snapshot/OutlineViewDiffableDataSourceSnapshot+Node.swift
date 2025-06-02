//
//  OutlineViewDiffableDataSourceSnapshot+Node.swift
//  
//
//  Created by Florian Zand on 20.01.25.
//

import Foundation

/**
 A outline node that can be used to construct the items of a `OutlineViewDiffableDataSourceSnapshot`.
 
 Example usage:
 ```swift
 var snapshot = OutlineViewDiffableDataSourceSnapshot<String> {
    OutlineNode("Food") {
        OutlineNode("Root 1 Child 1")
        OutlineNode("Root 1 Child 2")
        OutlineNode("Root 1 Child 3")
    }.isExpanded(true)
    OutlineNode("Root 2")
    OutlineNode("Root 3") {
        OutlineNode("Root 3 Child 1")
        OutlineNode("Root 3 Child 2")
    }
 }
 ```
 */
public struct OutlineNode<Item: Hashable> {
    /// The item of the node.
    public let item: Item
    
    /// The children of the node.
    public let children: [OutlineNode]
        
    /// A Boolean value indicating whether the item of the node is expanded.
    public let isExpanded: Bool
    
    /// Sets the Boolean value indicating whether the item of the node is expanded.
    public func isExpanded(_ isExpanded: Bool) -> Self {
        .init(item, children: children, isExpanded: isExpanded)
    }
    
    /*
    /// A Boolean value indicating whether the node contains the item.
    public func contains(_ item: Item) -> Bool {
        children.contains(where: { $0.item == item || $0.contains(item) })
    }
     */
    
    /// Creates a node with the specified item.
    public init(_ item: Item) {
        self.item = item
        self.children = []
        self.isExpanded = false
    }
    
    /// Creates a node with the specified item and children.
    public init(_ item: Item, @Builder _ children: () -> [OutlineNode]) {
        self.item = item
        self.children = children()
        self.isExpanded = false
    }
    
    init(_ item: Item, children: [OutlineNode], isExpanded: Bool) {
        self.item = item
        self.children = children
        self.isExpanded = isExpanded
    }
}

extension OutlineViewDiffableDataSourceSnapshot {
    /**
     Creates a snapshot from the specified nodes.
     
     Example usage:
     ```swift
     var snapshot = OutlineViewDiffableDataSourceSnapshot<String> {
        OutlineNode("Food") {
            OutlineNode("Root 1 Child 1")
            OutlineNode("Root 1 Child 2")
            OutlineNode("Root 1 Child 3")
        }.isExpanded(true)
        OutlineNode("Root 2")
        OutlineNode("Root 3") {
            OutlineNode("Root 3 Child 1")
            OutlineNode("Root 3 Child 2")
        }
     }
     ```
     */
    public init(@OutlineNode<Item>.Builder nodes: () -> [OutlineNode<Item>]) {
        apply(nodes())
    }
    
    /// Adds the items of the specified nodes as child items of the specified parent item in the snapshot.
    public mutating func append(@OutlineNode<Item>.Builder _ nodes: () -> [OutlineNode<Item>], to parent: Item? = nil) {
        apply(nodes(), to: parent)
    }
    
    /// Inserts the items of the provided nodes immediately after the item with the specified identifier in the snapshot.
    public mutating func insert(@OutlineNode<Item>.Builder _ nodes: () -> [OutlineNode<Item>], after item: Item) {
        let nodes = nodes()
        insert(nodes.compactMap({$0.item}), after: item)
        nodes.forEach({ apply($0.children, to: $0.item) })
    }
    
    /// Inserts the items of the provided nodes immediately before the item with the specified identifier in the snapshot.
    public mutating func insert(@OutlineNode<Item>.Builder _ nodes: () -> [OutlineNode<Item>], before item: Item) {
        let nodes = nodes()
        insert(nodes.compactMap({$0.item}), before: item)
        nodes.forEach({ apply($0.children, to: $0.item) })
    }
    
    mutating func apply(_ nodes: [OutlineNode<Item>], to item: Item? = nil) {
        append(nodes.compactMap({$0.item}), to: item)
        nodes.forEach({ self.nodes[$0.item]?.isExpanded = $0.isExpanded })
        nodes.forEach({ apply($0.children, to: $0.item) })
    }
}

extension OutlineNode {
    /// A function builder type that produces an array of nodes.
    @resultBuilder
    public enum Builder {
        public static func buildBlock(_ block: [OutlineNode]...) -> [OutlineNode] {
            block.flatMap { $0 }
        }

        public static func buildOptional(_ item: [OutlineNode]?) -> [OutlineNode] {
            item ?? []
        }

        public static func buildEither(first: [OutlineNode]?) -> [OutlineNode] {
            first ?? []
        }

        public static func buildEither(second: [OutlineNode]?) -> [OutlineNode] {
            second ?? []
        }

        public static func buildArray(_ components: [[OutlineNode]]) -> [OutlineNode] {
            components.flatMap { $0 }
        }

        public static func buildExpression(_ expr: [OutlineNode]?) -> [OutlineNode] {
            expr ?? []
        }

        public static func buildExpression(_ expr: OutlineNode?) -> [OutlineNode] {
            expr.map { [$0] } ?? []
        }
        
        public static func buildExpression(_ expr: Item?) -> [OutlineNode] {
            if let item = expr {
                return [.init(item)]
            }
            return []
        }
        
        public static func buildExpression(_ expr: [Item]?) -> [OutlineNode] {
            expr?.compactMap({.init($0)}) ?? []
        }
    }
}
