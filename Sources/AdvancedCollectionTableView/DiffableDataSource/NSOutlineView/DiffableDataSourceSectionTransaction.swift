//
//  NSDiffableDataSourceSectionTransaction.swift
//  
//
//  Created by Florian Zand on 09.01.25.
//

import Foundation

public struct DiffableDataSourceSectionTransaction<ItemIdentifierType: Hashable> {
    /// The section snapshot before the transaction occured.
    public let initialSnapshot: DiffableDataSourceSectionSnapshot<ItemIdentifierType>
    
    /// The section snapshot after the transaction occured.
    public let finalSnapshot: DiffableDataSourceSectionSnapshot<ItemIdentifierType>
    
    /// A collection of insertions and removals that describe the difference between initial and final snapshots.
    public let difference: CollectionDifference<ItemIdentifierType>
}

extension DiffableDataSourceSectionTransaction {
    init(initial: DiffableDataSourceSectionSnapshot<ItemIdentifierType>, final: DiffableDataSourceSectionSnapshot<ItemIdentifierType>) {
        initialSnapshot = initial
        finalSnapshot = final
        difference = initial.items.difference(from: final.items)
    }
}
