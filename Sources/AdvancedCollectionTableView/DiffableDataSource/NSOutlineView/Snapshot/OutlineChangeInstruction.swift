//
//  OutlineChangeInstruction.swift
//  
//
//  Created by Florian Zand on 09.01.25.
//

import AppKit

enum OutlineChangeInstruction: CustomStringConvertible {
    case remove(AnyHashable, IndexPath)
    case insert(AnyHashable, IndexPath)
    case move(IndexPath, IndexPath)

    public var description: String {
        switch self {
        case .remove(let item, let idx): return "Removing @ \(idx): \(item)"
        case .insert(let item, let idx): return "Inserting @ \(idx): \(item)"
        case .move(let from, let to): return "Moving from \(from) to \(to)"
        }
    }
}

extension OutlineChangeInstruction: Equatable {
    static func ==(lhs: OutlineChangeInstruction, rhs: OutlineChangeInstruction) -> Bool {
        switch (lhs, rhs) {
        case (.insert(let l, let l2), .insert(let r, let r2)): return l == r && l2 == r2
        case (.remove(let l, let l2), .remove(let r, let r2)): return l == r && l2 == r2
        case (.move(let l, let l2), .move(let r, let r2)): return l == r && l2 == r2
        default: break
        }

        return false
    }

    var item: AnyHashable? {
        switch self {
        case .remove(let item, _), .insert(let item, _): return item
        case .insert(let item, _): return item
        default: return nil
        }
    }

    var targetIndexPath: IndexPath {
        switch self {
        case .remove(_, let indexPath): return indexPath
        case .insert(_, let indexPath): return indexPath
        case .move(_, let indexPath): return indexPath
        }
    }
}

extension Array where Element == OutlineChangeInstruction {
    mutating func reduce() {
        // search for all removed, then try to pair with an inserted
        let removeds = filter { if case .remove = $0 { return true } else { return false } }
        for removed in removeds {
            let inserteds = filter { if case .insert = $0 { return true } else { return false } }
            if let item = removed.item,
                let inserted = inserteds.first(where: { $0.item == item }) {
                let newInstruction = OutlineChangeInstruction.move(removed.targetIndexPath, inserted.targetIndexPath)
                if let removeIdx = firstIndex(where: { $0 == removed }) {
                    remove(at: removeIdx)
                }
                guard let insertIdx = firstIndex(where: { $0 == inserted }) else {
                    preconditionFailure("how does this happen")
                }
                insert(newInstruction, at: insertIdx)
            }
        }
    }
}

extension OutlineViewDiffableDataSourceSnapshot {
    func instructions(forMorphingInto newSnapshot: OutlineViewDiffableDataSourceSnapshot) -> [OutlineChangeInstruction] {
        func calculateInstructions(from source: [ItemIdentifierType], to destination: [ItemIdentifierType], baseIndexPath: IndexPath) -> [OutlineChangeInstruction] {
            var result: [OutlineChangeInstruction] = []
            var work = source
     
            for deletable in work.filter({ !destination.contains($0) }) {
                if let delIdx = work.firstIndex(of: deletable) {
                    work.remove(at: delIdx)
                    result.append(.remove(deletable, baseIndexPath.appending(delIdx)))
                }
            }
            for (dstIdx, item) in destination.enumerated() {
                if work.firstIndex(of: item) == nil {
                    work.insert(item, at: dstIdx)
                    result.append(.insert(item, baseIndexPath.appending(dstIdx)))
                }
            }
            for (index, item) in destination.enumerated() {
                let indexPath = baseIndexPath.appending(index)
                if work.contains(item) {
                    result += calculateInstructions(from: children(of: item), to: newSnapshot.children(of: item), baseIndexPath: indexPath)
                }
            }
            return result
        }
        
        var result = calculateInstructions(from: rootItems, to: newSnapshot.rootItems, baseIndexPath: IndexPath())
        result.reduce()
        return result
    }
}


extension NSOutlineView {
    func apply<Item: Hashable>(_ snapshot: OutlineViewDiffableDataSourceSnapshot<Item>, currentSnapshot: OutlineViewDiffableDataSourceSnapshot<Item>, option: NSDiffableDataSourceSnapshotApplyOption, animation: NSTableView.AnimationOptions, completion: (() -> Void)?) {
        let instructions = currentSnapshot.instructions(forMorphingInto: snapshot)
        
        let oldExpanded = Set(currentSnapshot.nodes.filter { $0.value.isExpanded }.map { $0.key } + currentSnapshot.groupItems)
        let newExpanded = Set(snapshot.nodes.filter { $0.value.isExpanded }.map { $0.key } + snapshot.groupItems)
        let collapse = Array(oldExpanded.subtracting(newExpanded))
        var expand = Array(newExpanded.subtracting(oldExpanded))
                
        var animation = animation
        if case .withoutAnimation = option {
            animation = []
        }
        if !option.isReloadData {
            func applySnapshot() {
                beginUpdates()
                instructions.forEach { instr in
                    switch instr {
                    case .insert(_, let indexPath):
                        let parent = lastParent(for: indexPath)
                        if let childIndex = indexPath.last {
                            insertItems(at: [childIndex], inParent: parent, withAnimation: animation)
                        }
                    case .move(let src, let dst):
                        let srcParent = lastParent(for: src)
                        let dstParent = lastParent(for: dst)
                        if let srcChild = src.last, let dstChild = dst.last {
                            moveItem(at: srcChild, inParent: srcParent, to: dstChild, inParent: dstParent)
                        }
                    case .remove(_, let indexPath):
                        let parent = lastParent(for: indexPath)
                        if let childIndex = indexPath.last {
                            removeItems(at: [childIndex], inParent: parent, withAnimation: animation)
                        }
                    }
                }
                let animates = option.animationDuration ?? 0.0 > 0.0
                if animates {
                    collapse.forEach({ animator().collapseItem($0) })
                    expand.forEach({ animator().expandItem($0) })
                }
                endUpdates()
                if !animates {
                    collapse.forEach({ collapseItem($0) })
                    expand.forEach({ expandItem($0) })
                }
            }
            if let duration = option.animationDuration, duration > 0.0 {
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = duration
                NSAnimationContext.current.completionHandler = completion
                applySnapshot()
                NSAnimationContext.endGrouping()
            } else {
                applySnapshot()
                completion?()
            }
        } else {
            reloadData()
        }
        
    }
    
    func lastParent(for indexPath: IndexPath) -> Any? {
        var indexPath = indexPath
        indexPath.removeLast()
        return indexPath.compactMap({ child($0, ofItem: parent) }).last
    }
}
