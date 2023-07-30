//
//  NSDiffableDataSourceSnapshotApplyOption.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit

/// Options for applying snapshots to a diffable data source.
public enum NSDiffableDataSourceSnapshotApplyOption: Hashable {
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
    internal var isAnimating: Bool {
        switch self {
        case .animated(_): return true
        default: return false
        }
    }
}