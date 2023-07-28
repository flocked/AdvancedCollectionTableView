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
    var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "AdvanceColllectionViewDiffableDataSource_keyDownMonitor", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "AdvanceColllectionViewDiffableDataSource_keyDownMonitor", object: self)
        }
    }
    
    func setupKeyDownMonitor() {
        if self.allowsDeleting {
            if keyDownMonitor == nil {
                keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    guard self.tableView.window?.firstResponder == self.tableView else { return event }
                    if allowsDeleting, event.keyCode == 51 {
                        var selectedElements = self.selectedElements
                        if let shouldDelete = deletionHandlers.shouldDelete {
                            selectedElements = shouldDelete(selectedElements)
                        }
                        if (selectedElements.isEmpty == false) {
                            if QuicklookPanel.shared.isVisible {
                                QuicklookPanel.shared.close()
                            }
                            self.removeElements(selectedElements)
                            deletionHandlers.didDelete?(selectedElements)
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

