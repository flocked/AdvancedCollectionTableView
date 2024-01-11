//
//  NSCollectionViewDiffableDataSource+Apply.swift
//
//
//  Created by Florian Zand on 16.12.22.
//

import AppKit

extension NSCollectionViewDiffableDataSource {
    /**
     Updates the UI to reflect the state of the data in the specified snapshot, optionally animating the UI changes and executing a completion handler.

     It’s safe to call this method from a background queue, but you must do so consistently in your app. Always call this method exclusively from the main queue or from a background queue.

     - Parameters:
        - snapshot: The snapshot reflecting the new state of the data in the collection view.
        - option: Option how to apply the snapshot to the table view. The default value is `animated`.
        - completion: An optional closure to be executed when the animations are complete. This closure has no return value and takes no parameters. The system calls this closure from the main queue. The default value is `nil`.
     */
    public func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        switch option {
        case .usingReloadData:
            applySnapshotUsingReloadData(snapshot, completion: completion)
        case .animated:
            apply(snapshot, animated: true, animationDuration: option.animationDuration, completion: completion)
        case .withoutAnimation:
            apply(snapshot, animated: false, completion: completion)
        }
    }

    private func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
                                              completion: (() -> Void)? = nil)
    {
        apply(snapshot, animatingDifferences: false, completion: completion)
    }

    private func apply(
        _ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        animated: Bool = true,
        animationDuration: TimeInterval? = nil,
        completion: (() -> Void)? = nil
    ) {
        if animated, animationDuration == nil {
            apply(snapshot, animatingDifferences: true, completion: completion)
        } else {
            NSAnimationContext.beginGrouping()
            NSAnimationContext.current.duration = animationDuration ?? 0
            apply(snapshot, animatingDifferences: true, completion: completion)
            NSAnimationContext.endGrouping()
        }
    }
}
