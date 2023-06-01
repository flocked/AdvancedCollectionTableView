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
    
    func setCollectionViewLayout(_ layout: NSCollectionViewLayout, animated: Bool) {
        if (animated == true) {
            self.performBatchUpdates({
                self.animator().collectionViewLayout = layout
            })
        } else {
            self.collectionViewLayout = layout
        }
    }
    
    func setCollectionViewLayout(_ layout: NSCollectionViewLayout, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        if (animated == true) {
            self.performBatchUpdates({
                self.animator().collectionViewLayout = layout
            }, completionHandler: { completed in
                completion?(completed)
            })
        } else {
            self.collectionViewLayout = layout
            completion?(true)
        }
    }
    
    internal var isObservingWindowState: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isObservingWindowState", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_isObservingWindowState", object: self)
        }
    }
    
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isEmphasized", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_isEmphasized", object: self)
            self.visibleItems().forEach({$0.isEmphasized = newValue})
        }
    }
    
    internal func updateItemHoverState(_ event: NSEvent) {
        let visibleItems = self.visibleItems()
            let location = event.location(in: self)
            let mouseItem = self.item(at: location)
            if let mouseItem = mouseItem, mouseItem.isHovered == false {
                Swift.print("mouseItem")
                mouseItem.isHovered = true
            }
            let items = visibleItems.filter({$0.isHovered && $0 != mouseItem})
            Swift.print("nonMouseItem", items.count)
            items.forEach({$0.isHovered = false })
        }
    
    /*
     internal var trackingArea: NSTrackingArea? {
     get { getAssociatedValue(key: "NSCollectionView_trackingArea", object: self) }
     set { set(associatedValue: newValue, key: "NSCollectionView_trackingArea", object: self) } }
     */
    
    internal var trackDisplayingItems: Bool {
        get { getAssociatedValue(key: "NSCollectionView_trackDisplayingItems", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_trackDisplayingItems", object: self)
            self.updateDisplayingItemsTracking()
        }
    }
    
    /*
    override var isSelectable: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isSelectable", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "NSCollectionView_isSelectable", object: self) } }
     */
    
    var isEnabled: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isEnabled", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_isEnabled", object: self)
            self.visibleItems().forEach({$0.isEnabled = newValue })
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
    
    internal var collectionViewObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSCollectionItem_Observer", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSCollectionItem_Observer", object: self)
        }
   }
    
    internal func setupCollectionViewObserver() {
        if (collectionViewObserver == nil) {
            collectionViewObserver = self.observeChange(\.selectionIndexPaths) { object, previousIndexes, newIndexes in
                var itemIndexPaths: [IndexPath] = []
                
                let added = newIndexes.symmetricDifference(previousIndexes)
                let removed = previousIndexes.symmetricDifference(newIndexes)

                itemIndexPaths.append(contentsOf: added)
                itemIndexPaths.append(contentsOf: removed)
                itemIndexPaths = itemIndexPaths.uniqued()
                let items = itemIndexPaths.compactMap({self.item(at: $0)})
                Swift.print("selectionIndexPaths", itemIndexPaths.count, items.count)
                items.forEach({ $0.setNeedsUpdateConfiguration() })
                
            }
        }
    }
    
    /*
    internal func setupCollectionViewObserver() {
        if collectionViewObserver.isObserving(\.selectionIndexPaths) == false {
            collectionViewObserver.add(\.selectionIndexPaths) { [weak self] old, newIndexes in
                guard let self = self else { return }
                let previousIndexes = self.previousSelectionIndexPaths
                var itemIndexPaths: [IndexPath] = []
                
                let added = newIndexes.symmetricDifference(previousIndexes)
                let removed = previousIndexes.symmetricDifference(newIndexes)

                itemIndexPaths.append(contentsOf: added)
                itemIndexPaths.append(contentsOf: removed)
                
                Swift.print("selectionIndexPaths", itemIndexPaths.count)
                
                let items = itemIndexPaths.compactMap({self.item(at: $0)})
                items.forEach({ $0.setNeedsUpdateConfiguration() })
                self.previousSelectionIndexPaths = newIndexes
                
                /*
                let indexPathsForVisibleItems = self.indexPathsForVisibleItems()
                for previousIndex in previousIndexes {
                    if newIndexes.contains(previousIndex) == false {
                        if (indexPathsForVisibleItems.contains(previousIndex)) {
                            itemIndexPaths.append(previousIndex)
                        }
                    }
                }
                
                
                for value in newIndexes.symmetricDifference(previousIndexes) {
                    
                }
                
               let diff = Array(newIndexes).difference(from: Array(previousIndexes))
                for insert in diff.insertions {
                
                }
               
                
                for newIndex in newIndexes {
                    if previousIndexes.contains(newIndex) == false {
                        if (indexPathsForVisibleItems.contains(newIndex)) {
                            itemIndexPaths.append(newIndex)
                        }
                    }
                }
          */
            }
        }
    }
     */
    
    @objc func didScroll() {
        
    }
}


