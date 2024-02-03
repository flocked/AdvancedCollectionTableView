//
//  NSCollectionViewDiffableDataSource+Delete.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit
import FZQuicklook
import FZSwiftUtils
import FZUIKit

extension NSCollectionViewDiffableDataSource {
    /**
     The diffable data source’s handlers for deleting items.
     
     Provide the ``DeletingHandlers/canDelete`` and ``DeletingHandlers/didDelete`` handlers to support the deleting of elements in your collection view.
     
     The system calls the ``DeletingHandlers/didDelete`` handler after a deleting transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
     ```swift
     // Allow every item to be deleted
     dataSource.deletingHandlers.canDelete = { items in return true }

     // Option 1: Update the backing store from a CollectionDifference
     dataSource.deletingHandlers.didDelete = { [weak self] items, transaction in
        guard let self = self else { return }
         
        if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
            self.backingStore = updatedBackingStore
        }
     }

     // Option 2: Update the backing store from the final item identifiers
     dataSource.deletingHandlers.didDelete = { [weak self] items, transaction in
        guard let self = self else { return }
         
        self.backingStore = transaction.finalSnapshot.itemIdentifiers
     }
     ```
     */
    public var deletingHandlers: DeletingHandlers {
        get { getAssociatedValue(key: "deletingHandlers", object: self, initialValue: .init()) }
        set { set(associatedValue: newValue, key: "deletingHandlers", object: self)
            setupKeyDownMonitor()
        }
    }

    /**
     Handlers for deleting items.
     
     Take a look at ``deletingHandlers-swift.property`` how to support deleting items.
     */
    public struct DeletingHandlers {
        /// The handler that determines whether you can delete items.
        public var canDelete: ((_ items: [ItemIdentifierType]) -> [ItemIdentifierType])?
        /// The handler that that gets called before deleting items.
        public var willDelete: ((_ items: [ItemIdentifierType], _ transaction: DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> Void)?
        /**
         The handler that that gets called after deleting items.
         
         The system calls the `didDelete` handler after a deleting transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
         
         ```swift
         // Allow every item to be deleted
         dataSource.deletingHandlers.canDelete = { items in return items }


         // Option 1: Update the backing store from a CollectionDifference
         dataSource.deletingHandlers.didDelete = { [weak self] items, transaction in
             guard let self = self else { return }
             
             if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
                 self.backingStore = updatedBackingStore
             }
         }


         // Option 2: Update the backing store from the final items
         dataSource.deletingHandlers.didReorder = { [weak self] items, transaction in
             guard let self = self else { return }
             
             self.backingStore = transaction.finalSnapshot.itemIdentifiers
         }
         ```
         */
        public var didDelete: ((_ items: [ItemIdentifierType], _ transaction: DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> Void)?
    }
    
    var keyDownMonitor: NSEvent.Monitor? {
        get { getAssociatedValue(key: "keyDownMonitor", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "keyDownMonitor", object: self) }
    }

    func setupKeyDownMonitor() {
        if let canDelete = deletingHandlers.canDelete, let didDelete = deletingHandlers.didDelete {
            keyDownMonitor = NSEvent.localMonitor(for: .keyDown) { [weak self] event in
                guard let self = self else { return event }
                guard event.keyCode == 51 else { return event }
                if let collectionView = (NSApp.keyWindow?.firstResponder as? NSCollectionView), collectionView.dataSource === self {
                    var section: SectionIdentifierType? = nil
                    var selectionItem: ItemIdentifierType? = nil
                    let selectionIndexPaths = collectionView.selectionIndexPaths.map { $0 }
                    var elementsToDelete = selectionIndexPaths.compactMap { self.itemIdentifier(for: $0) }
                    if let indexPath = selectionIndexPaths.first, let item = itemIdentifier(for: indexPath) {
                        if indexPath.item > 0,  let item = self.itemIdentifier(for: IndexPath(item: indexPath.item - 1, section: indexPath.section)), !elementsToDelete.contains(item) {
                            selectionItem = item
                        } else {
                            section = snapshot().sectionIdentifier(containingItem: item)
                        }
                    }
                    if !elementsToDelete.isEmpty {
                        elementsToDelete = canDelete(elementsToDelete)
                    }
                    if elementsToDelete.isEmpty == false {
                        if QuicklookPanel.shared.isVisible {
                            QuicklookPanel.shared.close()
                        }
                        var finalSnapshot = self.snapshot()
                        finalSnapshot.deleteItems(elementsToDelete)

                        let transaction: DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType> = DiffableDataSourceTransaction(initial: self.snapshot(), final: finalSnapshot)

                        deletingHandlers.willDelete?(elementsToDelete, transaction)
                        if QuicklookPanel.shared.isVisible {
                            QuicklookPanel.shared.close()
                        }
                        self.apply(finalSnapshot, .usingReloadData)
                        didDelete(elementsToDelete, transaction)
                        
                        if collectionView.allowsEmptySelection == false, collectionView.selectionIndexPaths.isEmpty {
                            var selectionIndexPath: IndexPath? = nil
                            if let item = selectionItem, let indexPath = indexPath(for: item) {
                                selectionIndexPath = indexPath
                            } else if let section = section, let item = finalSnapshot.itemIdentifiers(inSection: section).first, let indexPath = indexPath(for: item) {
                                selectionIndexPath = indexPath
                                
                            } else if let item = finalSnapshot.itemIdentifiers.first, let indexPath = indexPath(for: item) {
                                selectionIndexPath = indexPath
                            }
                            if let indexPath = selectionIndexPath {
                                collectionView.selectItems(at: [indexPath], scrollPosition: [])
                            }
                        }
                        return nil
                    }
                }
                return event
            }
        } else {
            keyDownMonitor = nil
        }
    }
}
