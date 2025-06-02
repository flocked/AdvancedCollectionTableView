//
//  OutlineViewDiffableDataSourceTransaction.swift
//  
//
//  Created by Florian Zand on 09.01.25.
//

import Foundation

/// A transaction that describes the changes after reordering the items of a outline view..
public struct OutlineViewDiffableDataSourceTransaction<Item: Hashable> {
    /// The section snapshot before the transaction occured.
    public let initialSnapshot: OutlineViewDiffableDataSourceSnapshot<Item>
    
    /// The section snapshot after the transaction occured.
    public let finalSnapshot: OutlineViewDiffableDataSourceSnapshot<Item>
    
    /// A collection of insertions and removals that describe the difference between initial and final snapshots.
    public let difference: CollectionDifference<Item>
}

extension OutlineViewDiffableDataSourceTransaction {
    init(initial: OutlineViewDiffableDataSourceSnapshot<Item>, final: OutlineViewDiffableDataSourceSnapshot<Item>) {
        initialSnapshot = initial
        finalSnapshot = final
        difference = initial.items.difference(from: final.items)
    }
}
