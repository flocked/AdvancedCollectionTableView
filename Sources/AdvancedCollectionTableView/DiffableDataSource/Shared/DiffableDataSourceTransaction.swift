//
//  DiffableDataSourceTransaction.swift
//
//
//  Created by Florian Zand on 16.09.23.
//

import AppKit

/// A transaction that describes the changes after reordering the items in the view.
public struct DiffableDataSourceTransaction<Section, Item> where Section: Hashable, Item: Hashable {
    /// The snapshot before the transaction occured.
    public let initialSnapshot: NSDiffableDataSourceSnapshot<Section, Item>

    /// The snapshot after the transaction occured.
    public let finalSnapshot: NSDiffableDataSourceSnapshot<Section, Item>

    /// A collection of insertions and removals that describe the difference between initial and final snapshots.
    public let difference: CollectionDifference<Item>
}

extension DiffableDataSourceTransaction {
    init(initial: NSDiffableDataSourceSnapshot<Section, Item>, final: NSDiffableDataSourceSnapshot<Section, Item>) {
        initialSnapshot = initial
        finalSnapshot = final
        difference = initial.itemIdentifiers.difference(from: final.itemIdentifiers)
    }
}
