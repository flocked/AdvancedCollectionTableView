//
//  NSTableViewDiffableDataSource+Delete.swift
//
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit
import FZQuicklook
import FZSwiftUtils
import FZUIKit

extension NSTableViewDiffableDataSource {
    /**
     The diffable data source’s handlers for deleting items.
     
     The system calls the ``DeletionHandlers/didDelete`` handler after a deleting transaction (``NSDiffableDataSourceTransaction``) occurs, so you can update your data backing store with information about the changes.
     
     ```swift
     // Allow every item to be deleted
     dataSource.deletionHandlers.canDelete = { items in return true }

     // Option 1: Update the backing store from a CollectionDifference
     dataSource.deletionHandlers.didDelete = { [weak self] items, transaction in
        guard let self = self else { return }
         
        if let updatedBackingStore = self.backingStore.applying(transaction.difference) {
            self.backingStore = updatedBackingStore
        }
     }

     // Option 2: Update the backing store from the final item identifiers
     dataSource.deletionHandlers.didDelete = { [weak self] items, transaction in
        guard let self = self else { return }
         
        self.backingStore = transaction.finalSnapshot.itemIdentifiers
     }
     ```
     */
    public var deletionHandlers: DeletionHandlers {
        get { getAssociatedValue(key: "deletionHandlers", object: self, initialValue: .init()) }
        set { 
            set(associatedValue: newValue, key: "deletionHandlers", object: self)
            setupKeyDownMonitor()
        }
    }

    /// Handlers for deleting items.
    public struct DeletionHandlers {
        /// The handler that determines whether you can delete items.
        public var canDelete: ((_ items: [ItemIdentifierType]) -> [ItemIdentifierType])?
        /// The handler that prepares the diffable data source for deleting its items.
        public var willDelete: ((_ items: [ItemIdentifierType], _ transaction: NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> Void)?
        /// The handler that processes a deleting transaction.
        public var didDelete: ((_ items: [ItemIdentifierType], _ transaction: NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> Void)?
    }

    var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "keyDownMonitor", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "keyDownMonitor", object: self)
        }
    }

    func setupKeyDownMonitor() {
        if let canDelete = deletionHandlers.canDelete {
            if keyDownMonitor == nil {
                keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    guard event.keyCode == 51 else { return event }
                    if let tableView = (NSApp.keyWindow?.firstResponder as? NSTableView), tableView.dataSource === self {
                        let selecedRowIndexes = tableView.selectedRowIndexes.map { $0 }

                        var elementsToDelete = selecedRowIndexes.compactMap { self.itemIdentifier(forRow: $0) }
                        elementsToDelete = canDelete(elementsToDelete)
                        if elementsToDelete.isEmpty == false {
                            if QuicklookPanel.shared.isVisible {
                                QuicklookPanel.shared.close()
                            }
                            var finalSnapshot = self.snapshot()
                            finalSnapshot.deleteItems(elementsToDelete)

                            func getTransaction() -> NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType> {
                                NSDiffableDataSourceTransaction(initial: self.snapshot(), final: finalSnapshot)
                            }

                            var transaction: NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>?

                            if let willDelete = deletionHandlers.willDelete {
                                transaction = getTransaction()
                                willDelete(elementsToDelete, transaction!)
                            }

                            self.apply(finalSnapshot, .usingReloadData)

                            if let didDelete = deletionHandlers.didDelete {
                                didDelete(elementsToDelete, transaction ?? getTransaction())
                            }

                            if tableView.allowsEmptySelection == false {
                                let row = (selecedRowIndexes.first ?? 0)
                                tableView.selectRowIndexes(IndexSet([row]), byExtendingSelection: true)
                                if tableView.allowsMultipleSelection {
                                    let selectedRowIndexes = tableView.selectedRowIndexes
                                    if selectedRowIndexes.count == 2, selectedRowIndexes.contains(0) {
                                        tableView.deselectRow(0)
                                    }
                                }
                            }
                            return nil
                        }
                    }
                    return event
                })
            }
        } else {
            if let keyDownMonitor = keyDownMonitor {
                NSEvent.removeMonitor(keyDownMonitor)
            }
            keyDownMonitor = nil
        }
    }
}
