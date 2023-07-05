//
//  File.swift
//  
//
//  Created by Florian Zand on 16.12.22.
//

import AppKit

/// Options for applying snapshots to a diffable data source.
public enum NSDiffableDataSourceSnapshotApplyOption {
    /**
     The collection view applies the snapshot using `reloadData()`.
     
     The system interrupts any ongoing item animations and immediately reloads the collection view’s content.
     */
    case reloadData
    /**
     The collection view applies the snapshot animated, optionally with the specified animation duration.
     
     The diffable data source computes the difference between the collection view’s current state and the new state in the snapshot, which is an O(n) operation, where n is the number of items in the snapshot. The differences in the UI between the current state and new state are animated.
     */

    case animated(duration: TimeInterval? = nil)
    /**
     The collection view applies the snapshot without animation.

     The collection view UI is set to the new state without any animations, with no additional overhead for computing a diff of the previous and new state. Any ongoing item animations are interrupted and the collection view’s content is reloaded immediately.
     */
    case non
}

public extension NSCollectionViewDiffableDataSource {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    
    /**
     Returns the item identifiers for the specified index paths.
     
     - Parameters indexPaths: The index paths.
     - Returns: An array of item identifiers for the index paths.
     */
    func itemIdentifiers(for indexPaths: [IndexPath]) -> [ItemIdentifierType] {
        return indexPaths.compactMap({self.itemIdentifier(for:$0)})
    }
    
    /**
     Returns the index paths for the specified item identifiers.
     
     - Parameters identifiers: The item identifiers.
     - Returns: An array of index paths for the item identifiers.
     */
    func indexPaths(for identifiers: [ItemIdentifierType]) -> [IndexPath] {
        return identifiers.compactMap({self.indexPath(for: $0)})
    }
    
    /**
     Updates the UI to reflect the state of the data in the specified snapshot, optionally animating the UI changes and executing a completion handler.
     
     It’s safe to call this method from a background queue, but you must do so consistently in your app. Always call this method exclusively from the main queue or from a background queue.

     - Parameters snapshot: The snapshot reflecting the new state of the data in the collection view.
     - Parameters option:  Option how to apply the snapshot to the collection view.
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
    
    private func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
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

