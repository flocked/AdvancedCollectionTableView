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
        var movedItems: Set<Item> = []
        var work = self
        work.isCalculatingDiff = true
        func calculateSteps(from source: [Item], to destination: [Item], parent: Item? = nil) -> [OutlineChangeInstruction] {
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
                        work.insert(item, at: index, of: parent)
                    }
                case .remove(let item, let index):
                    if let toIndex = newSnapshot.childIndex(of: item) {
                        guard !movedItems.contains(item) else { continue }
                        movedItems.insert(item)
                        let newParent = newSnapshot.parent(of: item)
                        instructions.append(.move(item, from: index, work.parent(of: item), to: toIndex, newParent))
                        work.move([item], toIndex: toIndex, of: newParent)
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
        let instructions = calculateSteps(from: rootItems, to: newSnapshot.rootItems)
        return instructions
    }
}

extension NSOutlineView {
    func apply<Item: Hashable>(_ snapshot: OutlineViewDiffableDataSourceSnapshot<Item>, currentSnapshot: OutlineViewDiffableDataSourceSnapshot<Item>, option: NSDiffableDataSourceSnapshotApplyOption, animation: AnimationOptions, completion: (() -> Void)?) {
        func applySnapshot() {
            beginUpdates()
            for instruction in currentSnapshot.instructions(forMorphingTo: snapshot) {
                switch instruction {
                case .insert(_, let index, let parent):
                    insertItems(at: IndexSet(integer: index), inParent: parent, withAnimation: animation)
                case .remove(_, let index, let parent):
                    removeItems(at: IndexSet(integer: index), inParent: parent, withAnimation: animation)
                case .move(_, let from, let fromParent, let to, let toParent):
                    moveItem(at: from, inParent: fromParent, to: to, inParent: toParent)
                }
            }
            expandCollapseItems()
            endUpdates()
        }
        
        func expandCollapseItems() {
            let oldExpanded = currentSnapshot.expandedItems
            let newExpanded = snapshot.expandedItems
            oldExpanded.subtracting(newExpanded).forEach({ animator().collapseItem($0) })
            newExpanded.subtracting(oldExpanded).forEach({ animator().expandItem($0) })
        }
                
        if option.isReloadData {
            reloadData()
            expandCollapseItems()
            completion?()
        } else if let duration = option.animationDuration, duration > 0.0 {
            NSView.animate(withDuration: duration, changes: {
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
