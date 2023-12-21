//
//  NSCollectionViewDiffableDataSource+Apply.swift
//  
//
//  Created by Florian Zand on 16.12.22.
//

import AppKit

public extension NSCollectionViewDiffableDataSource {
    /**
     Updates the UI to reflect the state of the data in the specified snapshot, optionally animating the UI changes and executing a completion handler.
     
     It’s safe to call this method from a background queue, but you must do so consistently in your app. Always call this method exclusively from the main queue or from a background queue.
     
     - Parameters:
        - snapshot: The snapshot reflecting the new state of the data in the collection view.
        - option:  Option how to apply the snapshot to the collection view.
        - completion: A closure to be executed when the animations are complete. This closure has no return value and takes no parameters. The system calls this closure from the main queue.
     */
    func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,_ option: NSDiffableDataSourceSnapshotApplyOption, completion: (() -> Void)? = nil) {
        switch option {
        case .usingReloadData:
            self.applySnapshotUsingReloadData(snapshot, completion: completion)
        case .animated(_):
            self.apply(snapshot, animated: true, animationDuration: option.animationDuration, completion: completion)
        case .withoutAnimation:
            self.apply(snapshot, animated: false, completion: completion)
        }
    }
    
    private func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
                                              completion: (() -> Void)? = nil) {
        self.apply(snapshot, animatingDifferences: false, completion: completion)
    }
    
    private func apply(
        _ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
        animated: Bool = true,
        animationDuration: TimeInterval? = nil,
        completion: (() -> Void)? = nil) {
            if let animationDuration = animationDuration {
                Swift.debugPrint("animationDuration", animationDuration == NSDiffableDataSourceSnapshotApplyOption.noAnimationDuration)
            }
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

