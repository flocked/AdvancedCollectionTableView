//
//  NSDiffableDataSourceSnapshotApplyOption.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit

/**
 Options for applying a snapshot to a diffable data source.
  
 Apple's `apply(_:animatingDifferences:completion:)` provides two options for applying snapshots to a diffable data source depending on `animatingDifferences`:
 - `true` applies a diff of the old and new state and animates updates in the UI.
 - `false`  is equivalent to calling `reloadData()`. It reloads every item.
  
 **Non-animated diff**
 
 `NSDiffableDataSourceSnapshotApplyOption`  lets you perform a diff even without animations using `withoutAnimation` for much better performance compared to using Apple's `reloadData()`.
 
 ```swift
 collectionViewDatasource.apply(snapshot, .withoutAnimation)
 ```
 
 **Animation duration**
 
 When you want to apply the snapshot animated, you can also change the animation duration  using `animated(duration:)`.
 
 ```swift
 collectionViewDatasource.apply(snapshot, .animated(duration: 1.0))
 ```
 */
public enum NSDiffableDataSourceSnapshotApplyOption: Hashable, Sendable {
    /**
     The snapshot gets applied animated.
     
     The data source computes a diff of the previous and new state and applies the new state animated with a default animation duration. Any ongoing item animations are interrupted and the content is reloaded immediately.
     */
    public static var animated: Self { return .animated(duration: Self.noAnimationDuration) }
    
    /**
     The snapshot gets applied animiated with the specified animation duration.
     
     The data source computes a diff of the previous and new state and applies the new state animated with the specified animation duration. Any ongoing item animations are interrupted and the content is reloaded immediately.
     */
    case animated(duration: TimeInterval)
    
    /**
     The snapshot gets applied using `reloadData()`.
     
     The system resets the UI to reflect the state of the data in the snapshot without computing a diff or animating the changes.
     */
    case usingReloadData
    /**
     The snapshot gets applied without any animation.
     
     The data source computes a diff of the previous and new state and applies the new state non animated. Any ongoing item animations are interrupted and the content is reloaded immediately.
     */
    case withoutAnimation
    
    static var noAnimationDuration: TimeInterval { 2344235 }
    
    var animationDuration: TimeInterval? {
        switch self {
        case .animated(let duration):
            return (duration != Self.noAnimationDuration) ? duration : nil
        default:
            return nil
        }
    }
}
