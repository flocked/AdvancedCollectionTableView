//
//  NSCollectionViewDiffableDataSource+Delete.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import FZQuicklook

public extension NSCollectionViewDiffableDataSource {
    /**
     A Boolean value that indicates whether users can delete items either via backspace keyboard shortcut.
     
     If the value of this property is `true` (the default is `false`), users can delete items.
     */
    var isDeletable: Bool {
        get { getAssociatedValue(key: "NSCollectionViewDiffableDataSource_isDeletable", object: self, initialValue: false) }
        set {
            guard newValue != isDeletable else { return }
            set(associatedValue: newValue, key: "NSCollectionViewDiffableDataSource_isDeletable", object: self)
            self.setupKeyDownMonitor()
        }
    }
    
    internal var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "NSCollectionViewDiffableDataSource_keyDownMonitor", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSCollectionViewDiffableDataSource_keyDownMonitor", object: self)
        }
    }
    
    internal func setupKeyDownMonitor() {
        if self.isDeletable {
            if keyDownMonitor == nil {
                keyDownMonitor =  NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    guard event.keyCode ==  51 else { return event }
                    if isDeletable, let collectionView =  (NSApp.keyWindow?.firstResponder as? NSCollectionView), collectionView.dataSource === self {
                        let selectionIndexPaths = collectionView.selectionIndexPaths.map({$0})
                        let elementsToDelete = self.itemIdentifiers(for: selectionIndexPaths)
                        
                        if (elementsToDelete.isEmpty == false) {
                            if QuicklookPanel.shared.isVisible {
                                QuicklookPanel.shared.close()
                            }
                            var snapshot = self.snapshot()
                            snapshot.deleteItems(elementsToDelete)
                            self.apply(snapshot, .usingReloadData)
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
            if let keyDownMonitor = self.keyDownMonitor {
                NSEvent.removeMonitor(keyDownMonitor)
            }
            keyDownMonitor = nil
        }
    }
}

