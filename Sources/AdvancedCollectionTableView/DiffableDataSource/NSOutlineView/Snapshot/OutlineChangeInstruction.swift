//
//  OutlineChangeInstruction.swift
//  
//
//  Created by Florian Zand on 09.01.25.
//

import AppKit
import FZSwiftUtils

enum OutlineChangeInstruction: CustomStringConvertible, Hashable, Equatable {
    case insert(_ item: AnyHashable, at: Int, parent: AnyHashable?)
    case remove(_ item: AnyHashable, at: Int, parent: AnyHashable?)
    case move(_ item: AnyHashable, from: Int, _ fromParent: AnyHashable?, to: Int, _ toParent: AnyHashable?)

    var description: String {
        switch self {
        case .insert(let item, let index, let parent):
            let parent = "\(parent != nil ? "\(parent!)" : "Root")"
            return "insert \"\(item)\" in \"\(parent)\" at \(index)"
        case .remove(let item, let index, let parent):
            let parent = "\(parent != nil ? "\(parent!)" : "Root")"
            return "Remove \"\(item)\"from \"\(parent)\" at \(index)"
        case .move(let item, let from, let fromParent, let to, let toParent):
            let fromParent = "\(fromParent != nil ? "\(fromParent!)" : "Root")"
            let toParent = "\(toParent != nil ? "\(toParent!)" : "Root")"
            return "Move \"\(item)\" from \"\(fromParent)\" at \(from) to \"\(toParent)\" at \(to)"
        }
    }
}

extension OutlineViewDiffableDataSourceSnapshot {
    func instructions(forMorphingTo newSnapshot: OutlineViewDiffableDataSourceSnapshot) -> [OutlineChangeInstruction] {
        var movedItems: Set<ItemIdentifierType> = []
        var work = self
        func calculateSteps(from source: [ItemIdentifierType], to destination: [ItemIdentifierType], parent: ItemIdentifierType? = nil) -> [OutlineChangeInstruction] {
            var instructions: [OutlineChangeInstruction] = []
            for step in destination.difference(from: source).steps {
                switch step {
                case .insert(let item, let index):
                    if let fromIndex = work.childIndex(of: item) {
                        guard !movedItems.contains(item) else { continue }
                        movedItems.insert(item)
                        instructions.append(.move(item, from: fromIndex, work.parent(of: item), to: index, parent))
                        work.move([item], toIndex: index, of: parent)
                    } else {
                        instructions.append(.insert(item, at: index, parent: parent))
                        work.insert(item, newSnapshot.nodes[item]!, at: index, of: parent)
                    }
                case .remove(let item, let index):
                    if let toIndex = newSnapshot.childIndex(of: item) {
                        guard !movedItems.contains(item) else { continue }
                        movedItems.insert(item)
                        instructions.append(.move(item, from: index, work.parent(of: item), to: toIndex, parent))
                        work.move([item], toIndex: toIndex, of: parent)
                    } else {
                        instructions.append(.remove(item, at: index, parent: parent))
                        work.delete([item])
                    }
                case .move(let item, let from, let to):
                    instructions.append(.move(item, from: from, parent, to: to, parent))
                    work.move([item], toIndex: to, of: parent)
                }
            }
            for item in destination {
                instructions += calculateSteps(from: work.children(of: item), to: newSnapshot.children(of: item), parent: item)
            }
            return instructions
        }
        var instructions = calculateSteps(from: rootItems, to: newSnapshot.rootItems)
        return instructions
    }
}

extension NSOutlineView {
    func apply<Item: Hashable>(_ snapshot: OutlineViewDiffableDataSourceSnapshot<Item>, currentSnapshot: OutlineViewDiffableDataSourceSnapshot<Item>, option: NSDiffableDataSourceSnapshotApplyOption, animation: NSTableView.AnimationOptions, completion: (() -> Void)?) {
        func applySnapshot() {
            beginUpdates()
            for instruction in currentSnapshot.instructions(forMorphingTo: snapshot) {
                switch instruction {
                case .insert(let item, let index, let parent):
                    insertItems(at: IndexSet(integer: index), inParent: parent, withAnimation: animation)
                case .remove(let item, let index, let parent):
                    removeItems(at: IndexSet(integer: index), inParent: parent, withAnimation: animation)
                case .move(let item, let from, let fromParent, let to, let toParent):
                    moveItem(at: from, inParent: fromParent, to: to, inParent: toParent)
                }
            }
            expandCollapseItems()
            endUpdates()
        }
        
        func expandCollapseItems() {
            let oldExpanded = Set(currentSnapshot.nodes.filter { $0.value.isExpanded }.map { $0.key } + currentSnapshot.groupItems)
            let newExpanded = Set(snapshot.nodes.filter { $0.value.isExpanded }.map { $0.key } + snapshot.groupItems)
            let collapse = Array(oldExpanded.subtracting(newExpanded))
            var expand = Array(newExpanded.subtracting(oldExpanded))
            collapse.forEach({ animator().collapseItem($0) })
            expand.forEach({ animator().expandItem($0) })
        }
        
        if option.isReloadData {
            reloadData()
            expandCollapseItems()
            completion?()
        } else if let duration = option.animationDuration, duration > 0.0 {
            NSView.animate(withDuration: duration, animations: {
                applySnapshot()
            }, completion: completion)
        } else {
            NSView.performWithoutAnimation {
                applySnapshot()
                completion?()
            }
        }
    }
}

/*
 fileprivate extension Array where Element: Hashable {
     func insertIndex(for element: Element, of other: [Element]) -> Int {
         let indexMap = Dictionary(uniqueKeysWithValues: other.enumerated().map { ($1, $0) })
         guard let targetIndex = indexMap[element] else { return 0 }
         for (i, item) in self.enumerated() {
             if let indexInOther = indexMap[item], indexInOther > targetIndex {
                 return i
             }
         }
         return count
     }
 }
 
 func instructionsAlt1(forMorphingTo newSnapshot: OutlineViewDiffableDataSourceSnapshot) -> [OutlineChangeInstruction] {
     var work = self
     var result: [OutlineChangeInstruction] = []
     // let items = Set(items)
     // let newItems = Set(newSnapshot.items)
     let items = orderedItems
     let newItems = newSnapshot.orderedItems
     let added = newItems.subtracting(items)
     var removed = items.subtracting(newItems)
     var moved = newItems
     
     moved = moved.filter({
         guard let node = nodes[$0], let newNode = newSnapshot.nodes[$0] else { return false }
         return node.parent != newNode.parent || node.children.firstIndex(of: $0) != newNode.children.firstIndex(of: $0)
     })
     
     
                     
     for remove in removed {
         if let parent = work.parent(of: remove), let index = work.childIndex(of: remove) {
             result.append(.remove(remove, at: index, parent: parent))
         } else if let index = work.rootItems.firstIndex(of: remove) {
             result.append(.remove(remove, at: index, parent: nil))
         }
         work.delete([remove])
     }
     for add in added {
         if let parent = newSnapshot.parent(of: add) {
             let index = work.children(of: parent).insertIndex(for: add, of: newSnapshot.children(of: parent))
             result.append(.insert(add, at: index, parent: parent))
             work.insert(add, newSnapshot.nodes[add]!, at: index, of: parent)
         } else  {
             let index = work.rootItems.insertIndex(for: add, of: newSnapshot.rootItems)
             result.append(.insert(add, at: index, parent: nil))
             work.insert(add, newSnapshot.nodes[add]!, at: index, of: nil)
         }
     }
     for move in moved {
         func moveItem(_ fromIndex: Int, _ fromParent: ItemIdentifierType? = nil) {
             if let toParent = newSnapshot.parent(of: move) {
                 let index = work.children(of: toParent).insertIndex(for: move, of: newSnapshot.children(of: toParent))
                 result.append(.move(move, from: fromIndex, fromParent, to: index, toParent))
                 work.move([move], toIndex: index, of: toParent)
             } else {
                 let index = work.rootItems.insertIndex(for: move, of: newSnapshot.rootItems)
                 result.append(.move(move, from: fromIndex, fromParent, to: index, nil))
                 work.move([move], toIndex: index, of: nil)
             }
         }
         if let fromParent = work.parent(of: move), let fromIndex = work.childIndex(of: move) {
             moveItem(fromIndex, fromParent)
         } else if let fromIndex = work.rootItems.firstIndex(of: move) {
             moveItem(fromIndex)
         }
     }
     return result
 }
 
 func instructionsAlt3(forMorphingTo newSnapshot: OutlineViewDiffableDataSourceSnapshot) -> [OutlineChangeInstruction] {
     var work = self
     var result: [OutlineChangeInstruction] = []
     // let items = Set(items)
     // let newItems = Set(newSnapshot.items)
     let items = orderedItems
     let newItems = newSnapshot.orderedItems
     var added = newItems.filter({ !items.contains($0) })
     var removed = items.filter({ !newItems.contains($0) })
     var moved = newItems
     
     /*
     Swift.print("-----------")
     Swift.print("added")
     for item in added {
         Swift.print(item)
     }
     Swift.print("-----------")
     */

     
     moved = moved.filter({
         guard let node = nodes[$0], let newNode = newSnapshot.nodes[$0] else { return false }
         return node.parent != newNode.parent || node.children.firstIndex(of: $0) != newNode.children.firstIndex(of: $0)
     })
     
     func addItem(_ add: ItemIdentifierType) {
         if let parent = newSnapshot.parent(of: add) {
             let index = work.children(of: parent).insertIndex(for: add, of: newSnapshot.children(of: parent))
             result.append(.insert(add, at: index, parent: parent))
             work.insert(add, newSnapshot.nodes[add]!, at: index, of: parent)
         } else  {
             let index = work.rootItems.insertIndex(for: add, of: newSnapshot.rootItems)
             result.append(.insert(add, at: index, parent: nil))
             work.insert(add, newSnapshot.nodes[add]!, at: index, of: nil)
         }
     }
     
     func removeItem(_ remove: ItemIdentifierType) {
         if let parent = work.parent(of: remove), let index = work.childIndex(of: remove) {
             result.append(.remove(remove, at: index, parent: parent))
         } else if let index = work.rootItems.firstIndex(of: remove) {
             result.append(.remove(remove, at: index, parent: nil))
         }
         work.delete([remove])
     }
     
     func _moveItem(_ move: ItemIdentifierType) {
         func moveItem(_ fromIndex: Int, _ fromParent: ItemIdentifierType? = nil) {
             if let toParent = newSnapshot.parent(of: move) {
                 let index = work.children(of: toParent).insertIndex(for: move, of: newSnapshot.children(of: toParent))
                 result.append(.move(move, from: fromIndex, fromParent, to: index, toParent))
                 work.move([move], toIndex: index, of: toParent)
             } else {
                 let index = work.rootItems.insertIndex(for: move, of: newSnapshot.rootItems)
                 result.append(.move(move, from: fromIndex, fromParent, to: index, nil))
                 work.move([move], toIndex: index, of: nil)
             }
         }
         if let fromParent = work.parent(of: move), let fromIndex = work.childIndex(of: move) {
             moveItem(fromIndex, fromParent)
         } else if let fromIndex = work.rootItems.firstIndex(of: move) {
             moveItem(fromIndex)
         }
     }
     
     func check(_ parent: ItemIdentifierType?) {
         var remove = removed.first
         while let toRemove = remove, work.parent(of: toRemove) == parent {
             removeItem(toRemove)
             removed.removeFirst()
             remove = removed.first
         }
         var add = added.first
         while let toAdd = add, newSnapshot.parent(of: toAdd) == parent {
             addItem(toAdd)
             added.removeFirst()
             add = added.first
         }
         var move = moved.first
         while let toMove = move, newSnapshot.parent(of: toMove) == parent {
             _moveItem(toMove)
             moved.removeFirst()
             move = moved.first
         }
         if let parent = parent {
             let childs = newSnapshot.children(of: parent)
             if !childs.isEmpty {
                 childs.forEach({ check($0) })
             } else if !removed.isEmpty || !added.isEmpty || !moved.isEmpty {
                 check(nil)
             }
         } else {
             let childs = newSnapshot.rootItems
             if !childs.isEmpty {
                 childs.forEach({ check($0) })
             } else if !removed.isEmpty || !added.isEmpty || !moved.isEmpty {
                 check(nil)
             }
         }
     }
     
     check(nil)
     return result
 }
 
 func diff(from oldSnapshot: OutlineViewDiffableDataSourceSnapshot) -> [OutlineChangeInstruction] {
     var instructions: [OutlineChangeInstruction] = []
     var processedItems: Set<ItemIdentifierType> = []

     // Helper function to compare children recursively
     func compareChildren(oldChildren: [ItemIdentifierType], newChildren: [ItemIdentifierType], parent: ItemIdentifierType?) {
         
         var oldIndexMap = Dictionary(uniqueKeysWithValues: oldChildren.enumerated().map { ($1, $0) })
         var newIndexMap = Dictionary(uniqueKeysWithValues: newChildren.enumerated().map { ($1, $0) })

       //  let oldSet = oldChildren
       //  let newSet = newChildren

         // Find removed items
         for oldItem in oldChildren.filter({ !newChildren.contains($0)}) {
             if let oldIndex = oldIndexMap[oldItem] {
                 instructions.append(.remove(oldItem, at: oldIndex, parent: parent))
                 processedItems.insert(oldItem)
             }
         }

         // Find inserted items
         for newItem in newChildren.filter({ !oldChildren.contains($0)}) {
             if let newIndex = newIndexMap[newItem] {
                 instructions.append(.insert(newItem, at: newIndex, parent: parent))
                 processedItems.insert(newItem)
             }
             compareChildren(
                 oldChildren: oldSnapshot.nodes[newItem]?.children ?? [],
                 newChildren: nodes[newItem]?.children ?? [],
                 parent: newItem
             )
         }

         // Find moved or reordered items
         for newItem in newChildren.filter({ oldChildren.contains($0)}) {
             guard !processedItems.contains(newItem) else { continue }
             let oldIndex = oldIndexMap[newItem]!
             let newIndex = newIndexMap[newItem]!
             if oldIndex != newIndex || oldSnapshot.nodes[newItem]?.parent != nodes[newItem]?.parent {
                 instructions.append(
                     .move(
                         newItem,
                         from: oldIndex,
                         oldSnapshot.nodes[newItem]?.parent,
                         to: newIndex,
                         nodes[newItem]?.parent
                     )
                 )
             }
             processedItems.insert(newItem)
             compareChildren(
                 oldChildren: oldSnapshot.nodes[newItem]?.children ?? [],
                 newChildren: nodes[newItem]?.children ?? [],
                 parent: newItem
             )
         }
     }

     // Compare root items
     compareChildren(oldChildren: oldSnapshot.rootItems, newChildren: rootItems, parent: nil)

     return instructions
 }
 
 func diff1(from oldSnapshot: OutlineViewDiffableDataSourceSnapshot<ItemIdentifierType>) -> [OutlineChangeInstruction] {
     var instructions: [OutlineChangeInstruction] = []
     var processedItems: Set<ItemIdentifierType> = []

     // Helper function to compare children recursively
     func compareChildren(oldChildren: [ItemIdentifierType], newChildren: [ItemIdentifierType], parent: ItemIdentifierType?) {
         // Find removed items
         let removedItems = oldChildren.filter { !newChildren.contains($0) }
         for (index, item) in oldChildren.enumerated() where removedItems.contains(item) {
             instructions.append(.remove(item, at: index, parent: parent))
             processedItems.insert(item)
         }

         // Find inserted items
         let insertedItems = newChildren.filter { !oldChildren.contains($0) }
         for (index, item) in newChildren.enumerated() where insertedItems.contains(item) {
             instructions.append(.insert(item, at: index, parent: parent))
             processedItems.insert(item)
         }

         // Find moved items (including parent changes)
         for (newIndex, newItem) in newChildren.enumerated() {
             guard let oldIndex = oldChildren.firstIndex(of: newItem), !processedItems.contains(newItem) else { continue }

             let oldParent = oldSnapshot.nodes[newItem]?.parent
             let newParent = nodes[newItem]?.parent

             // Detect if item has moved (index or parent changed)
             if oldIndex != newIndex || oldParent != newParent {
                 instructions.append(
                     .move(
                         newItem,
                         from: oldIndex,
                         oldParent,
                         to: newIndex,
                         newParent
                     )
                 )
             }
             processedItems.insert(newItem)

             // Recursively compare children
             compareChildren(
                 oldChildren: oldSnapshot.nodes[newItem]?.children ?? [],
                 newChildren: nodes[newItem]?.children ?? [],
                 parent: newItem
             )
         }
     }

     // Compare root items
     compareChildren(oldChildren: oldSnapshot.rootItems, newChildren: rootItems, parent: nil)

     return instructions
 }
 */

/*
var description: String {
    switch self {
    case .insert(let item, let index, let parent):
        return "+ \"\(item)\" at \(index) in \"\(parent != nil ? "\(parent!)" : "Root")\""
    case .remove(let item, let index, let parent):
        return "- \"\(item)\" at \(index) from \"\(parent != nil ? "\(parent!)" : "Root")\""
    case .move(let item, let from, let fromParent, let to, let toParent):
        return "\"\(item)\" \"\(fromParent != nil ? "\(fromParent!)" : "Root")\" at \(from) → \"\(toParent != nil ? "\(toParent!)" : "Root")\" at \(to)"
    }
}
*/

/*
var index: Int {
    switch self {
    case .insert(_, let index,_): return index
    case .remove(_, let index,_): return index
    default: return 0
    }
}

var parent: AnyHashable? {
    switch self {
    case .insert(_,_,let parent): return parent
    case .remove(_,_,let parent): return parent
    default: return nil
    }
}

var item: Any {
    switch self {
    case .insert(let item,_,_): return item
    case .remove(let item,_,_): return item
    case .move(let item,_,_,_,_): return item
    }
}
*/
