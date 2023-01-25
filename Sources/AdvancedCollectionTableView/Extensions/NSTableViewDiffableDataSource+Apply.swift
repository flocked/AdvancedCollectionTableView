//
//  File.swift
//  
//
//  Created by Florian Zand on 16.12.22.
//

import AppKit

public extension NSTableViewDiffableDataSource {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    typealias ApplyOption = NSDiffableDataSourceSnapshotApplyOption

    func itemIdentifiers(for rows: [Int]) -> [ItemIdentifierType] {
       return rows.compactMap({self.itemIdentifier(forRow:$0)})
    }
    
    func rows(for identifiers: [ItemIdentifierType]) -> [Int] {
       return identifiers.compactMap({self.row(forItemIdentifier: $0)})
    }
    
    func apply(_ snapshot: Snapshot,_ option: ApplyOption? = nil, completion: (() -> Void)? = nil) {
        if let option = option {
            switch option {
            case .reloadData:
                self.applySnapshotUsingReloadData(snapshot, completion: completion)
            case .animated:
                self.applySnapshot(snapshot, animated: true, completion: completion)
            case .non:
                self.applySnapshot(snapshot, animated: false, completion: completion)
            }
        } else {
            self.applySnapshot(snapshot, animated: false, completion: completion)
        }
    }
    
   private func applySnapshotUsingReloadData(_
        snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        completion: (() -> Void)? = nil) {
            self.apply(snapshot, animatingDifferences: false, completion: completion)
    }

    private func applySnapshot(
        _ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        animated: Bool = true,
        completion: (() -> Void)? = nil) {
            if animated {
                self.apply(snapshot, animatingDifferences: true, completion: completion)
            } else {
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = 0
                    self.apply(snapshot, animatingDifferences: true, completion: completion)
                NSAnimationContext.endGrouping()
        }
    }
}
