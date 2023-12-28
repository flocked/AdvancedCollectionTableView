//
//  NSDiffableDataSourceSnapshotApplyOption.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit

/**
 Options for applying a snapshot to a diffable data source.
  
 When using Apple's `apply(_:animatingDifferences:completion:)` to apply a snapshot to a diffable data source, passing `true` to `animatingDifferences` would apply the diff and animate updates in the UI, while passing `false` is equivalent to calling `reloadData()`.
 
 `NSDiffableDataSourceSnapshotApplyOption` lets you always perform a diff for much improved performance using ``withoutAnimation``.
 
 You can also change the apply animation duration using ``animated(duration:)``.
 
 ```swift
 collectionViewDatasource.apply(snapshot, .withoutAnimation)
 ```
 */
public enum NSDiffableDataSourceSnapshotApplyOption: Hashable, Sendable {
    /**
     The snapshot gets applied animated.
     
     The diffable data source computes the difference between the current state and the new state in the snapshot, which is an O(n) operation, where n is the number of items in the snapshot. The differences in the UI between the current state and new state are animated.
     */
    public static var animated: Self { return .animated(duration: Self.noAnimationDuration) }
    
    /**
     The snapshot gets applied animiated with the specified animation duration.
     
     The diffable data source computes the difference between the current state and the new state in the snapshot, which is an O(n) operation, where n is the number of items in the snapshot. The differences in the UI between the current state and new state are animated.
     */
    
    case animated(duration: TimeInterval)
    
    /**
     The snapshot gets applied using `reloadData()`.
     
     The system resets the UI to reflect the state of the data in the snapshot without computing a diff or animating the changes.
     */
    case usingReloadData
    /**
     The snapshot gets applied without any animation.
     
     The UI is set to the new state without any animations, with no additional overhead for computing a diff of the previous and new state. Any ongoing item animations are interrupted and the content is reloaded immediately.
     */
    case withoutAnimation
    
    internal static var noAnimationDuration: TimeInterval { 2344235 }
    internal var animationDuration: TimeInterval? {
        switch self {
        case .animated(let duration): return (duration != Self.noAnimationDuration) ? duration : nil
        default: return nil
        }
    }
    internal var isAnimating: Bool {
        switch self {
        case .animated(_): return true
        default: return false
        }
    }
}
