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
    
    func nextItemForDeleting(_ items: [ItemIdentifierType]) -> ItemIdentifierType? {
        guard let delete = items.first, let index = indexOfItem(delete), let item = itemIdentifiers[safe: index-1] else { return nil  }
        if sectionIdentifier(containingItem: item) != sectionIdentifier(containingItem: delete), let section = sectionIdentifier(containingItem: delete), let item = itemIdentifiers(inSection: section).first(where: { !items.contains($0) }) {
           return item
        }
        return item
    }
}
