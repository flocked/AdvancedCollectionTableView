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
    typealias Transaction = DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>
    
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
        guard let delete = items.last, let index = indexOfItem(delete), let item = itemIdentifiers[safe: index+1] ?? itemIdentifiers[safe: index-1] else { return nil  }
        if sectionIdentifier(containingItem: item) != sectionIdentifier(containingItem: delete), let section = sectionIdentifier(containingItem: delete) {
            if let item = itemIdentifiers(inSection: section).reversed().first(where: { !items.contains($0) }) {
                return item
            } else if let index = indexOfSection(section), let section = sectionIdentifiers[safe: index-1], let item = itemIdentifiers(inSection: section).reversed().first(where: { !items.contains($0) }) {
                return item
            }
        }
        return item
    }
    
    func moveTransaction(_ section: SectionIdentifierType, after afterSection: SectionIdentifierType) -> Transaction {
        var snapshot = self
        snapshot.moveSection(section, afterSection: afterSection)
        return Transaction(initial: self, final: snapshot)
    }
    
    func moveTransaction(_ section: SectionIdentifierType, before beforeSection: SectionIdentifierType) -> Transaction {
        var snapshot = self
        snapshot.moveSection(section, beforeSection: beforeSection)
        return Transaction(initial: self, final: snapshot)
    }
    
    func deleteTransaction(_ items: [ItemIdentifierType]) -> Transaction {
        var finalSnapshot = Self()
        finalSnapshot.deleteItems(items)
        return DiffableDataSourceTransaction(initial: self, final: finalSnapshot)
    }
    
    /*
     func movingTransaction(_ items: [ItemIdentifierType], item: ItemIdentifierType?, section: SectionIdentifierType?) -> DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>? {
         var newSnapshot = self
         if let item = item {
             newSnapshot.insertItems(items, beforeItem: item)
         } else if let section = section {
             item
             if let item = item(forRow: row - 1) {
                 newSnapshot.insertItems(newItems, afterItem: item)
             } else {
                 newSnapshot.appendItems(newItems, toSection: section)
             }
         } else if let section = sections.last {
             newSnapshot.appendItems(newItems, toSection: section)
         }
         return DiffableDataSourceTransaction(initial: currentSnapshot, final: newSnapshot)
         
     }
     */
    
    /*
    func nextItemForDeleting(_ items: [ItemIdentifierType]) -> ItemIdentifierType? {
        guard let delete = items.last, let index = indexOfItem(delete), let item = itemIdentifiers[safe: index-1] else { return nil  }
        if sectionIdentifier(containingItem: item) != sectionIdentifier(containingItem: delete), let section = sectionIdentifier(containingItem: delete), let item = itemIdentifiers(inSection: section).first(where: { !items.contains($0) }) {
           return item
        }
        return item
    }
     */
}
