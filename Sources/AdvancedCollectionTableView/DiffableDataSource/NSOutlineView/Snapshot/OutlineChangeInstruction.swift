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
        case .remove(let item, _): return item
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
        let removeds = allRemoved
        for removed in removeds {
            let inserteds = allInserted
            if let item = removed.item,
                let inserted = inserteds.first(where: { $0.item == item }) {
                let newInstruction = OutlineChangeInstruction.move(removed.targetIndexPath, inserted.targetIndexPath)
                delete(removed)
                guard let insertIdx = firstIndex(where: { $0 == inserted }) else {
                    preconditionFailure("how does this happen")
                }
                insert(newInstruction, at: insertIdx)
            }
        }
    }

    mutating func delete(_ item: OutlineChangeInstruction) {
        if let removeIdx = firstIndex(where: { $0 == item }) {
            remove(at: removeIdx)
        }
    }
    var allRemoved: [OutlineChangeInstruction] {
        filter { if case .remove = $0 { return true } else { return false } }
    }
    var allInserted: [OutlineChangeInstruction] {
        filter { if case .insert = $0 { return true } else { return false } }
    }
}

extension OutlineViewDiffableDataSourceSnapshot {
    func instructions(forMorphingInto destination: OutlineViewDiffableDataSourceSnapshot) -> [OutlineChangeInstruction] {
        func instructions(forMorphing from: [ItemIdentifierType], to: [ItemIdentifierType], baseIndexPath: IndexPath) -> [OutlineChangeInstruction] {
            let src = from
            let dst = to
            var result: [OutlineChangeInstruction] = []
            var work = src
            var deletables = [ItemIdentifierType]()
            for item in work {
                if !dst.contains(item) {
                    deletables.append(item)
                }
            }
            for deletable in deletables {
                if let delIdx = work.firstIndex(of: deletable) {
                    work.remove(at: delIdx)
                    result.append(.remove(deletable, baseIndexPath.appending(delIdx)))
                }
            }
            for (dstIdx, item) in dst.enumerated() {
                if work.firstIndex(of: item) == nil {
                    work.insert(item, at: dstIdx)
                    result.append(.insert(item, baseIndexPath.appending(dstIdx)))
                }
            }
            for (index, item) in dst.enumerated() {
                let indexPath = baseIndexPath.appending(index)
                if work.contains(item) {
                    result.append(contentsOf: instructions(forMorphing: children(of: item), to: destination.children(of: item), baseIndexPath: indexPath))
                }
            }
            return result
        }
        
        var result: [OutlineChangeInstruction] = []
        result.append(contentsOf: instructions(forMorphing: rootItems, to: destination.rootItems, baseIndexPath: IndexPath()))
        result.reduce()
        return result
    }
    
    func expandCollapse(forMorphingInto destination: OutlineViewDiffableDataSourceSnapshot) -> (expand: [ItemIdentifierType], collapse: [ItemIdentifierType]) {
        let oldExpanded = nodes.filter({$0.value.isExpanded}).compactMap({$0.key})
        let expanded = destination.nodes.filter({$0.value.isExpanded}).compactMap({$0.key})
        let collapse = oldExpanded.filter({ !expanded.contains($0) })
        let expand = expanded.filter({ !oldExpanded.contains($0) })
        return (expand, collapse)
    }
}


extension NSOutlineView {
    func apply(_ snapshot: [OutlineChangeInstruction], _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, animation: NSTableView.AnimationOptions = [.effectFade], expand: [Any] = [], collapse: [Any] = [], completion: (() -> Void)? = nil) {
        var animation = animation
        if case .withoutAnimation = option {
            animation = []
        }
        if !option.isReloadData {
            func applySnapshot() {
                beginUpdates()
                snapshot.forEach { instr in
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
                collapse.forEach({ animator().collapseItem($0) })
                expand.forEach({ animator().expandItem($0) })
                endUpdates()
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
