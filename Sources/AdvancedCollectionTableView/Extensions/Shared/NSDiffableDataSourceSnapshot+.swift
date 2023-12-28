//
//  NSDiffableDataSourceSnapshot+.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

import AppKit

extension NSDiffableDataSourceSnapshot where ItemIdentifierType: Identifiable, SectionIdentifierType: Identifiable {
    typealias IdentifiableSnapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType.ID, ItemIdentifierType.ID>
    /// Creates a snapshot from the section and item ids.
    func toIdentifiableSnapshot() -> IdentifiableSnapshot {
         var identifiableSnapshot = IdentifiableSnapshot()
         let sections = self.sectionIdentifiers
         identifiableSnapshot.appendSections(sections.ids)
         for section in sections {
             let items = self.itemIdentifiers(inSection: section)
            identifiableSnapshot.appendItems(items.ids, toSection: section.id)
         }
         return identifiableSnapshot
    }
}
