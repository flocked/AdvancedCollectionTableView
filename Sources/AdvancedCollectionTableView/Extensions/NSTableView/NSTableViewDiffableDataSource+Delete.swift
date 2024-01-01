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
        /// The Handler that determines whether Itemlements should get deleted.
        public var canDelete: ((_ items: [ItemIdentifierType]) -> [ItemIdentifierType])? = nil
        /// The Handler that gets called whenever Itemlements get deleted.
        public var didDelete: ((_ items: [ItemIdentifierType]) -> ())? = nil
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
                            var snapshot = self.snapshot()
                            snapshot.deleteItems(elementsToDelete)
                            self.apply(snapshot, .usingReloadData)
                            self.deletionHandlers.didDelete?(elementsToDelete)
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

