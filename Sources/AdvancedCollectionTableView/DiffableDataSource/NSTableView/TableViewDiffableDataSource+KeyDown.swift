//
//  TableViewDiffableDataSource+KeyDown.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit
import FZSwiftUtils
import FZQuicklook

internal extension TableViewDiffableDataSource {    
    func setupKeyDownMonitor() {
        if self.allowsDeleting {
            if keyDownMonitor == nil {
                keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self, self.tableView.isFirstResponder else { return event }
                    if allowsDeleting, event.keyCode == 51 {
                        let elementsToDelete = deletionHandlers.shouldDelete?(self.selectedItems) ?? self.selectedItems
                        if (elementsToDelete.isEmpty == false) {
                            let transaction = self.deletingTransaction(elementsToDelete)
                            self.deletionHandlers.willDelete?(elementsToDelete, transaction)
                            if QuicklookPanel.shared.isVisible {
                                QuicklookPanel.shared.close()
                            }
                            self.apply(transaction.finalSnapshot, .animated)
                            deletionHandlers.didDelete?(elementsToDelete, transaction)
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
