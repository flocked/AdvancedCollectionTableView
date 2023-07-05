//
//  File.swift
//  
//
//  Created by Florian Zand on 16.12.22.
//

import AppKit

public extension NSTableViewDiffableDataSource {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    
    /**
     Returns the item identifiers for the specified row indexes.
     
     - Parameters rows: The row indexes.
     - Returns: An array of item identifiers for row indexes.
     */
    func itemIdentifiers(for rows: [Int]) -> [ItemIdentifierType] {
        return rows.compactMap({self.itemIdentifier(forRow:$0)})
    }
    
    /**
     Returns the row indexes for the specified item identifiers.
     
     - Parameters identifiers: The item identifiers.
     - Returns: An array of row index for the item identifiers.
     */
    func rows(for identifiers: [ItemIdentifierType]) -> [Int] {
        return identifiers.compactMap({self.row(forItemIdentifier: $0)})
    }
    
    /**
     Updates the UI to reflect the state of the data in the specified snapshot, optionally animating the UI changes and executing a completion handler.
     
     It’s safe to call this method from a background queue, but you must do so consistently in your app. Always call this method exclusively from the main queue or from a background queue.
     
     - Parameters snapshot: The snapshot reflecting the new state of the data in the table view.
     - Parameters option:  Option how to apply the snapshot to the table view.
     - Parameters completion: A closure to be executed when the animations are complete. This closure has no return value and takes no parameters. The system calls this closure from the main queue.
     */
    func apply(_ snapshot: Snapshot,_ option: NSDiffableDataSourceSnapshotApplyOption = .non, completion: (() -> Void)? = nil) {
        switch option {
        case .reloadData:
            self.applySnapshotUsingReloadData(snapshot, completion: completion)
        case .animated(let duration):
            self.applySnapshot(snapshot, animated: true, animationDuration: duration, completion: completion)
        case .non:
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
        animationDuration: TimeInterval? = nil,
        completion: (() -> Void)? = nil) {
            if animated && animationDuration == nil {
                self.apply(snapshot, animatingDifferences: true, completion: completion)
            } else {
                NSAnimationContext.beginGrouping()
                NSAnimationContext.current.duration = animationDuration ?? 0
                self.apply(snapshot, animatingDifferences: true, completion: completion)
                NSAnimationContext.endGrouping()
            }
        }
}
