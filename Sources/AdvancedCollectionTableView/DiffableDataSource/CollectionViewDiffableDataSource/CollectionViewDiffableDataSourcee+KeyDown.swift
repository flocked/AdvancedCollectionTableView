//
//  File.swift
//  
//
//  Created by Florian Zand on 24.06.23.
//

import AppKit
import FZSwiftUtils

internal extension CollectionViewDiffableDataSource {
    var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "CollectionViewDiffableDataSource_keyDownMonitor", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "CollectionViewDiffableDataSource_keyDownMonitor", object: self)
        }
    }
    
    func setupKeyDownMonitor() {
        Swift.print("setupKeyDownMonitor")
        if self.allowsDeleting {
            if keyDownMonitor == nil {
                keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    Swift.print("keyDownMonitor", event.keyCode, self.collectionView.window?.firstResponder ?? "")
                    guard self.collectionView.window?.firstResponder == self.collectionView else { return event }
                    if allowsDeleting, event.keyCode == 51 {
                        var selectedElements = self.selectedElements
                        if let shouldDelete = deletionHandlers.shouldDelete {
                            selectedElements = shouldDelete(selectedElements)
                        }
                        if (selectedElements.isEmpty == false) {
                            self.removeElements(selectedElements)
                            deletionHandlers.didDelete?(selectedElements)
                        }
                    }
                    return event
                })
            }
        } else {
            keyDownMonitor = nil
        }
    }
}
