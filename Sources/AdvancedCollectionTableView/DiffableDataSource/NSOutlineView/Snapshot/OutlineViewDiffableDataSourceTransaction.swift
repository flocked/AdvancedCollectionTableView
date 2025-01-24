//
//  OutlineViewDiffableDataSourceTransaction.swift
//  
//
//  Created by Florian Zand on 09.01.25.
//

import Foundation

/// A transaction that describes the changes after reordering the items of a outline view..
public struct OutlineViewDiffableDataSourceTransaction<ItemIdentifierType: Hashable> {
    /// The section snapshot before the transaction occured.
    public let initialSnapshot: OutlineViewDiffableDataSourceSnapshot<ItemIdentifierType>
    
    /// The section snapshot after the transaction occured.
    public let finalSnapshot: OutlineViewDiffableDataSourceSnapshot<ItemIdentifierType>
    
    /// A collection of insertions and removals that describe the difference between initial and final snapshots.
    public let difference: CollectionDifference<ItemIdentifierType>
}

extension OutlineViewDiffableDataSourceTransaction {
    init(initial: OutlineViewDiffableDataSourceSnapshot<ItemIdentifierType>, final: OutlineViewDiffableDataSourceSnapshot<ItemIdentifierType>) {
        initialSnapshot = initial
        finalSnapshot = final
        difference = initial.items.difference(from: final.items)
    }
}
