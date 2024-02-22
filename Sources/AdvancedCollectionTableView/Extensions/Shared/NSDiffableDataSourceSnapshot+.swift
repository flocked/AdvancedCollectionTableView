//
//  NSDiffableDataSourceSnapshot+.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

import AppKit

extension NSDiffableDataSourceSnapshot where ItemIdentifierType: Identifiable, SectionIdentifierType: Identifiable {
    /// A snapshot from the section and item identifiers.
    typealias IdentifiableSnapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType.ID, ItemIdentifierType.ID>
    
    /// Creates a snapshot from the section and item identifiers.
    func toIdentifiableSnapshot() -> IdentifiableSnapshot {
        var identifiableSnapshot = IdentifiableSnapshot()
        let sections = sectionIdentifiers
        identifiableSnapshot.appendSections(sections.ids)
        for section in sections {
            let items = itemIdentifiers(inSection: section)
            identifiableSnapshot.appendItems(items.ids, toSection: section.id)
        }
        return identifiableSnapshot
    }
}

extension NSDiffableDataSourceSnapshot {
    /// A Boolean value indicating whether the snapshot is empty.
    var isEmpty: Bool {
        numberOfItems == 0 && numberOfSections == 0
    }
}
