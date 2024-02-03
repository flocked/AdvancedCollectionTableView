//
//  NSTableViewDiffableDataSource+Reorder.swift
//  
//
//  Created by Florian Zand on 11.01.24.
//

import AppKit
import FZSwiftUtils

extension NSTableViewDiffableDataSource {
    /**
     The diffable data source’s handlers for reordering items.

     Provide ``ReorderingHandlers-swift.struct/canReorder`` to support the reordering of items in your table view.
     
     The system calls the ``ReorderingHandlers-swift.struct/didReorder`` handler after a reordering transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
     ```swift
     // Allow every item to be reordered
     dataSource.reorderingHandlers.canReorder = { items in return true }

     // Update the backing store from the final items
     dataSource.reorderingHandlers.didReorder = { [weak self] items, transaction in
         guard let self = self else { return }
         
         self.backingStore = transaction.finalSnapshot.itemIdentifiers
     }
     ```
     */
    var reorderingHandlers: ReorderingHandlers {
        get { getAssociatedValue(key: "reorderingHandlers", object: self, initialValue: .init()) }
        set {
            set(associatedValue: newValue, key: "reorderingHandlers", object: self)
            setupReording()
        }
    }
    
    func setupReording() {
        
    }
    
    struct ReorderingHandlers {
        /// The handler that determines if items can be reordered. The default value is `nil` which indicates that the items can be reordered.
        public var canReorder: (([ItemIdentifierType]) -> Bool)?

        /// The handler that that gets called before reordering items.
        public var willReorder: ((DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> Void)?

        /**
         The handler that that gets called after reordering items.

         The system calls the `didReorder` handler after a reordering transaction (``DiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
         
         ```swift
         // Allow every item to be reordered
         dataSource.reorderingHandlers.canDelete = { items in return true }


         // Option 1: Update the backing store from a CollectionDifference
         dataSource.reorderingHandlers.didDelete = { [weak self] items, transaction in
             guard let self = self else { return }
             
             if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
                 self.backingStore = updatedBackingStore
             }
         }


         // Option 2: Update the backing store from the final items
         dataSource.reorderingHandlers.didReorder = { [weak self] items, transaction in
             guard let self = self else { return }
             
             self.backingStore = transaction.finalSnapshot.itemIdentifiers
         }
         ```
         */
        public var didReorder: ((DiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> Void)?
    }
}
