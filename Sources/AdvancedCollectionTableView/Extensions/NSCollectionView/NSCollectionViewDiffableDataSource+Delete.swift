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

public extension NSCollectionViewDiffableDataSource {
    /**
     A Boolean value that indicates whether users can delete items via backspace keyboard shortcut.

     If the value of this property is `true`, users can delete items using the backspace. The default value is `false`.

     ``deletionHandlers`` provides additional handlers.
     */
    var allowsDeleting: Bool {
        get { getAssociatedValue(key: "NSCollectionViewDiffableDataSource_allowsDeleting", object: self, initialValue: false) }
        set {
            guard newValue != allowsDeleting else { return }
            set(associatedValue: newValue, key: "NSCollectionViewDiffableDataSource_allowsDeleting", object: self)
            setupKeyDownMonitor()
        }
    }

    /// The handlers for deleting of items.
    var deletionHandlers: DeletionHandlers {
        get { getAssociatedValue(key: "diffableDataSource_deletionHandlers", object: self, initialValue: .init()) }
        set { set(associatedValue: newValue, key: "diffableDataSource_deletionHandlers", object: self) }
    }

    /// Handlers for deleting of items.
    struct DeletionHandlers {
        /// The handler that determines whether items should get deleted. The default value is `nil`, which indicates that all items can be deleted.
        public var canDelete: ((_ items: [ItemIdentifierType]) -> [ItemIdentifierType])?
        /// The handler that that gets called before deleting items.
        public var willDelete: ((_ items: [ItemIdentifierType], _ transaction: NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> Void)?
        /// The handler that that gets called after deleting items.
        public var didDelete: ((_ items: [ItemIdentifierType], _ transaction: NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> Void)?
    }

    internal var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "diffableDataSource_keyDownMonitor", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "diffableDataSource_keyDownMonitor", object: self) }
    }

    internal func setupKeyDownMonitor() {
        if allowsDeleting {
            if keyDownMonitor == nil {
                keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    guard event.keyCode == 51 else { return event }
                    if allowsDeleting, let collectionView = (NSApp.keyWindow?.firstResponder as? NSCollectionView), collectionView.dataSource === self {
                        let selectionIndexPaths = collectionView.selectionIndexPaths.map { $0 }
                        var elementsToDelete = selectionIndexPaths.compactMap { self.itemIdentifier(for: $0) }
                        if !elementsToDelete.isEmpty, let canDelete = self.deletionHandlers.canDelete {
                            elementsToDelete = canDelete(elementsToDelete)
                        }
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

                            if collectionView.allowsEmptySelection == false {
                                let indexPath = (selectionIndexPaths.first ?? IndexPath(item: 0, section: 0))
                                collectionView.selectItems(at: Set([indexPath]), scrollPosition: [])
                                if collectionView.allowsMultipleSelection {
                                    let selectionIndexPaths = collectionView.selectionIndexPaths
                                    if selectionIndexPaths.count == 2, selectionIndexPaths.contains(IndexPath(item: 0, section: 0)) {
                                        collectionView.deselectItems(at: Set([IndexPath(item: 0, section: 0)]))
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
