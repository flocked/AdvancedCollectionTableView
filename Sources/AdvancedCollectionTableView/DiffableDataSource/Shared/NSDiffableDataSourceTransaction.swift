//
//  NSDiffableDataSourceTransaction.swift
//
//
//  Created by Florian Zand on 16.09.23.
//

import AppKit

/// A transaction that describes the changes after reordering the items in the view.
public struct NSDiffableDataSourceTransaction<Section, Element> where Section: Hashable, Element: Hashable {
    /// The snapshot before the transaction occured.
    public let initialSnapshot: NSDiffableDataSourceSnapshot<Section, Element>

    /// The snapshot after the transaction occured.
    public let finalSnapshot: NSDiffableDataSourceSnapshot<Section, Element>

    /// A collection of insertions and removals that describe the difference between initial and final snapshots.
    public let difference: CollectionDifference<Element>
}

extension NSDiffableDataSourceTransaction {
    init(initial: NSDiffableDataSourceSnapshot<Section, Element>, final: NSDiffableDataSourceSnapshot<Section, Element>) {
        initialSnapshot = initial
        finalSnapshot = final
        difference = initial.itemIdentifiers.difference(from: final.itemIdentifiers)
    }
}
