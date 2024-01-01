//
//  NSTableViewDiffableDataSource+Delete.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import FZQuicklook

extension NSTableViewDiffableDataSource {
    /**
     A Boolean value that indicates whether users can delete rows either via backsapace keyboard shortcut.
     
     If the value of this property is `true` (the default is `false), users can delete rows.   
     
     ``deletionHandlers`` provides additional handlers.
     */
    public var allowsDeleting: Bool {
        get { getAssociatedValue(key: "NSTableViewDiffableDataSource_allowsDeleting", object: self, initialValue: false) }
        set {
            guard newValue != allowsDeleting else { return }
            set(associatedValue: newValue, key: "NSTableViewDiffableDataSource_allowsDeleting", object: self)
            self.setupKeyDownMonitor()
        }
    }
    
    /// Handlers for deletion of items.
    public var deletionHandlers: DeletionHandlers {
        get { getAssociatedValue(key: "diffableDataSource_deletionHandlers", object: self, initialValue: .init()) }
        set { set(associatedValue: newValue, key: "diffableDataSource_deletionHandlers", object: self)  }
    }
    
    /// Handlers for deletion of items.
    public struct DeletionHandlers {
        /// The handler that determines whether items should get deleted. The default value is `nil`, which indicates that all items can be deleted.
        public var canDelete: ((_ items: [ItemIdentifierType]) -> [ItemIdentifierType])? = nil
        /// The handler that that gets called before deleting items.
        public var willDelete: ((_ items: [ItemIdentifierType], _ transaction: NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> ())? = nil
        /// The handler that that gets called after deleting items.
        public var didDelete: ((_ items: [ItemIdentifierType], _ transaction: NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>) -> ())? = nil
    }
    
    var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "NSTableViewDiffableDataSource_keyDownMonitor", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSTableViewDiffableDataSource_keyDownMonitor", object: self)
        }
    }
    
    func setupKeyDownMonitor() {
        if self.allowsDeleting {
            if keyDownMonitor == nil {
                keyDownMonitor =  NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    guard event.keyCode ==  51 else { return event }
                    if allowsDeleting, let tableView =  (NSApp.keyWindow?.firstResponder as? NSTableView), tableView.dataSource === self {
                        let selecedRowIndexes = tableView.selectedRowIndexes.map({$0})
                                                
                        var elementsToDelete = selecedRowIndexes.compactMap({self.itemIdentifier(forRow:$0)})
                        elementsToDelete = self.deletionHandlers.canDelete?(elementsToDelete) ?? elementsToDelete
                        if (elementsToDelete.isEmpty == false) {
                            if QuicklookPanel.shared.isVisible {
                                QuicklookPanel.shared.close()
                            }
                            var finalSnapshot = self.snapshot()
                            finalSnapshot.deleteItems(elementsToDelete)
                                                        
                            func getTransaction() ->  NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType> {
                                let initalSnapshot = self.snapshot()
                                let difference = initalSnapshot.itemIdentifiers.difference(from: finalSnapshot.itemIdentifiers)
                                return NSDiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: finalSnapshot, difference: difference)
                            }
                            
                            var transaction: NSDiffableDataSourceTransaction<SectionIdentifierType, ItemIdentifierType>? = nil
                            
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
            if let keyDownMonitor = self.keyDownMonitor {
                NSEvent.removeMonitor(keyDownMonitor)
            }
            keyDownMonitor = nil
        }
    }
}

