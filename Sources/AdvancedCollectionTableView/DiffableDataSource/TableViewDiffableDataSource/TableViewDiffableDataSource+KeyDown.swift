//
//  AdvanceTableViewDiffableDataSource+KeyDown.swift
//
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit
import FZSwiftUtils
import FZQuicklook

internal extension AdvanceTableViewDiffableDataSource {    
    func setupKeyDownMonitor() {
        if self.allowsDeleting {
            if keyDownMonitor == nil {
                keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    guard self.tableView.window?.firstResponder == self.tableView else { return event }
                    if allowsDeleting, event.keyCode == 51 {
                        let elementsToDelete =   deletionHandlers.shouldDelete?(self.selectedItems) ?? self.selectedItems
                        if (elementsToDelete.isEmpty == false) {
                            if QuicklookPanel.shared.isVisible {
                                QuicklookPanel.shared.close()
                            }
                            self.removeItems(elementsToDelete)
                            deletionHandlers.didDelete?(elementsToDelete)
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
