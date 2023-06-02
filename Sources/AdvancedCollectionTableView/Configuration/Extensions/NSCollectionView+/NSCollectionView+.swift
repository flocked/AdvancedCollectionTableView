//
//  NSCollectionView.swift
//  NSHostingViewSizeInTableView
//
//  Created by Florian Zand on 01.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSCollectionView {
    /**
     Constants that describe modes for invalidating the size of self-sizing table view items.
     
     Use these constants with the selfSizingInvalidation property.
     
     - Parameters:
     - disabled: A mode that disables self-sizing invalidation.
     - enabled: A mode that enables manual self-sizing invalidation.
     - enabledIncludingConstraints: A mode that enables automatic self-sizing invalidation after Auto Layout changes.
     */
    enum SelfSizingInvalidation: Int {
        case disabled = 0
        case enabled = 1
        case enabledIncludingConstraints = 2
    }
    
    /**
     The mode that the table view uses for invalidating the size of self-sizing items.
     */
    var selfSizingInvalidation: SelfSizingInvalidation {
        get {
            let rawValue: Int = getAssociatedValue(key: "NSCollectionView_selfSizingInvalidation", object: self, initialValue: SelfSizingInvalidation.disabled.rawValue)
            return SelfSizingInvalidation(rawValue: rawValue)!
        }
        set {
            self.indexPathsForVisibleItems()
            set(associatedValue: newValue.rawValue, key: "NSCollectionView_selfSizingInvalidation", object: self)
        }
    }
        
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isEmphasized", object: self, initialValue: false) }
        set {
            guard newValue != isEmphasized else { return }
            set(associatedValue: newValue, key: "NSCollectionView_isEmphasized", object: self)
            if newValue == false {
                self.removeHoveredItem()
            }
            self.visibleItems().forEach({$0.isEmphasized = newValue})
        }
    }
    
    var isEnabled: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isEnabled", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_isEnabled", object: self)
            self.visibleItems().forEach({$0.isEnabled = newValue })
        }
        
    }
    
    internal var hoveredItem: NSCollectionViewItem? {
        get { getAssociatedValue(key: "NSCollectionView_hoveredItem", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSCollectionView_hoveredItem", object: self)
        }
    }
        
    internal func updateItemHoverState(_ event: NSEvent) {
        let mouseItem = self.item(for: event)
        if hoveredItem != mouseItem {
            removeHoveredItem()
        }
        
        mouseItem?.isHovered = true
        hoveredItem = mouseItem
    }
        
    internal func removeHoveredItem() {
        hoveredItem?.isHovered = false
        hoveredItem = nil
    }
        
    internal func setupObservers(shouldObserve: Bool = true) {
        self.setupSelectionObserver(shouldObserve: shouldObserve)
        self.setupObserverView(shouldObserve: shouldObserve)
    }
    
    internal func setupSelectionObserver(shouldObserve: Bool = true) {
        if shouldObserve {
            if selectionObserver == nil {
                selectionObserver = self.observeChange(\.selectionIndexPaths) { object, previousIndexes, newIndexes in
                    var itemIndexPaths: [IndexPath] = []
                    
                    let added = newIndexes.symmetricDifference(previousIndexes)
                    let removed = previousIndexes.symmetricDifference(newIndexes)

                    itemIndexPaths.append(contentsOf: added)
                    itemIndexPaths.append(contentsOf: removed)
                    itemIndexPaths = itemIndexPaths.uniqued()
                    let items = itemIndexPaths.compactMap({self.item(at: $0)})
                    items.forEach({ $0.setNeedsUpdateConfiguration() })
                }
            }
        } else {
            selectionObserver?.invalidate()
            selectionObserver = nil
        }
    }
    
    func setupObserverView(shouldObserve: Bool = true) {
        if shouldObserve {
            if (self.observerView == nil) {
                self.observerView = ObserverView()
                self.addSubview(withConstraint: self.observerView!)
                self.observerView!.sendToBack()
                self.observerView?.windowHandlers.isKey = { [weak self] windowIsKey in
                    guard let self = self else { return }
                    self.isEmphasized = windowIsKey
                }
                
                self.observerView?.mouseHandlers.exited = { [weak self] event in
                    guard let self = self else { return }
                    self.removeHoveredItem()
                }
                
                self.observerView?.mouseHandlers.moved = { [weak self] event in
                    guard let self = self else { return }
                    let location = event.location(in: self)
                    if self.bounds.contains(location) {
                        self.updateItemHoverState(event)
                    }
                }
            }
        } else {
            observerView?.removeFromSuperview()
            observerView = nil
        }
    }
    
    internal var selectionObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSCollectionItem_Observer", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSCollectionItem_Observer", object: self)
        }
   }
    
    var observerView: ObserverView? {
        get { getAssociatedValue(key: "NSCollectionView_observerView", object: self) }
        set { set(associatedValue: newValue, key: "NSCollectionView_observerView", object: self)
        }
    }
}



/*
 internal var trackDisplayingItems: Bool {
     get { getAssociatedValue(key: "NSCollectionView_trackDisplayingItems", object: self, initialValue: false) }
     set {
         set(associatedValue: newValue, key: "NSCollectionView_trackDisplayingItems", object: self)
         self.updateDisplayingItemsTracking()
     }
 }
 
 internal func updateDisplayingItemsTracking() {
     guard let scrollView = self.enclosingScrollView else {  return }
     let clipView = scrollView.contentView
     if (self.trackDisplayingItems) {
         clipView.postsBoundsChangedNotifications = true
         NotificationCenter.default.addObserver(self, selector: #selector(didScroll), name: NSView.boundsDidChangeNotification, object: clipView)
     } else {
         clipView.postsBoundsChangedNotifications = false
         NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification, object: clipView)
     }
 }
 
 @objc func didScroll() {
     
 }
 */

/*
 internal func updateItemHoverState(_ event: NSEvent) {
 if let mouseItem = mouseItem, mouseItem.isHovered == false {
     mouseItem.isHovered = true
     hoveredItem = mouseItem
 }

 let visibleItems = self.visibleItems()
 let previousHoveredItems = visibleItems.filter({$0.isHovered && $0 != mouseItem})
 previousHoveredItems.forEach({$0.isHovered = false })
 }
 */
