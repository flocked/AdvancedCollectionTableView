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

public extension NSTableViewDiffableDataSource {
    /**
     A Boolean value that indicates whether users can delete items either via keyboard shortcut or right click menu.

     If the value of this property is true (the default is false), users can delete items.
     */
    var allowsDeleting: Bool {
        get { getAssociatedValue(key: "NSTableViewDiffableDataSource_allowsDeleting", object: self, initialValue: false) }
        set {
            guard newValue != allowsDeleting else { return }
            set(associatedValue: newValue, key: "NSTableViewDiffableDataSource_allowsDeleting", object: self)
            self.setupKeyDownMonitor()
        }
    }
    
    internal var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "NSTableViewDiffableDataSource_keyDownMonitor", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSTableViewDiffableDataSource_keyDownMonitor", object: self)
        }
    }
    
    internal func setupKeyDownMonitor() {
        if self.allowsDeleting {
            if keyDownMonitor == nil {
                keyDownMonitor =  NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    guard event.keyCode ==  51 else { return event }
                    if allowsDeleting, let tableView =  (NSApp.keyWindow?.firstResponder as? NSTableView), tableView.dataSource === self {
                        let selecedRowIndexes = tableView.selectedRowIndexes.map({$0})
                       let elementsToDelete = self.itemIdentifiers(for: selecedRowIndexes)
                        
                        if (elementsToDelete.isEmpty == false) {
                            if QuicklookPanel.shared.isVisible {
                                QuicklookPanel.shared.close()
                            }
                            var snapshot = self.snapshot()
                            snapshot.deleteItems(elementsToDelete)
                            self.apply(snapshot, .usingReloadData)
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

