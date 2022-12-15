//
//  NSCollectionView.swift
//  NSHostingViewSizeInTableView
//
//  Created by Florian Zand on 01.11.22.
//

import AppKit
import FZExtensions

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
            let rawValue: Int = getAssociatedValue(key: "__selfSizingInvalidation", object: self, initialValue: SelfSizingInvalidation.disabled.rawValue)
            return SelfSizingInvalidation(rawValue: rawValue)!
        }
        set {
            self.indexPathsForVisibleItems()
            set(associatedValue: newValue.rawValue, key: "__selfSizingInvalidation", object: self)
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
         get { getAssociatedValue(key: "_isObservingWindowState", object: self, initialValue: false) }
         set {
             set(associatedValue: newValue, key: "_isObservingWindowState", object: self)
         }
     }
     
     internal func observeWindowState() {
         if (isObservingWindowState == false) {
             isObservingWindowState = true
             NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey), name: NSWindow.didBecomeKeyNotification, object: self.window)
             NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey), name: NSWindow.didResignKeyNotification, object: self.window)
         }
     }
    
    @objc internal func windowDidBecomeKey() {
        self.visibleItems().forEach({$0.isEmphasized = true})
    }
     
     @objc internal func windowDidResignKey() {
         self.visibleItems().forEach({$0.isEmphasized = false})
      }
        
     override func updateTrackingAreas() {
         if let trackingArea = trackingArea {
             self.removeTrackingArea(trackingArea)
         }
         let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .mouseMoved, .enabledDuringMouseDrag, .activeInKeyWindow, .inVisibleRect]
         self.trackingArea = NSTrackingArea(rect: self.bounds, options:  options, owner: self)
         self.addTrackingArea(self.trackingArea!)
         super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.updateItemHoverState(event)
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        self.updateItemHoverState(event)
    }
    
     override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
         self.updateItemHoverState(nil)
    }
    
    /*
    override var isSelectable: Bool {
        get { super.isSelectable }
        set { super.isSelectable = newValue }
    }
    */
    
    internal func updateItemHoverState(_ event: NSEvent?) {
        let visibleItems = self.visibleItems()
        if let event = event {
            let location = event.location(in: self)
            let mouseItem = self.item(at: location)
            visibleItems.forEach({$0.isHovered = ($0 == mouseItem) })
        } else {
            visibleItems.forEach({$0.isHovered = false })
        }
    }
    
    func item(at point: CGPoint) -> NSCollectionViewItem? {
        if let indexPath = self.indexPathForItem(at: point) {
            return self.item(at: indexPath)
        }
        return nil
    }
    
   internal var trackingArea: NSTrackingArea? {
        get { getAssociatedValue(key: "_trackingArea", object: self) }
        set { set(associatedValue: newValue, key: "_trackingArea", object: self) } }
    
   internal var trackDisplayingItems: Bool {
        get { getAssociatedValue(key: "_trackDisplayingItems", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_trackDisplayingItems", object: self)
            self.updateDisplayingItemsTracking()
        }
    }
    
   internal func updateDisplayingItemsTracking() {
        guard let scrollView = self.enclosingScrollView else {  return }
        let clipView = scrollView.contentView
        if (self.trackDisplayingItems) {
            clipView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(didScroll),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: clipView)
        } else {
            clipView.postsBoundsChangedNotifications = false
            NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification, object: clipView)
        }
    }
    
    @objc func didScroll() {
       
    }
    
    internal func nextItem(for item: NSCollectionViewItem) -> NSCollectionViewItem? {
        if let indexPath = indexPath(for: item), indexPath.item + 1 < numberOfItems(inSection: indexPath.section) {
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            return self.item(at: nextIndexPath)
        }
        return nil
    }
    
    internal func previousItem(for item: NSCollectionViewItem) -> NSCollectionViewItem? {
        if let indexPath = indexPath(for: item), indexPath.item - 1 >= 0 {
            let previousIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            return self.item(at: previousIndexPath)
        }
        return nil
    }
}
 

/*
 internal var _collectionViewLayoutKVO: NSKeyValueObservation? {
     get { getAssociatedValue(key: "_collectionViewLayoutKVO", object: self) }
     set { set(associatedValue: newValue, key: "_collectionViewLayoutKVO", object: self) } }
 
internal func observeCollectionViewLayout() {
     if (self._collectionViewLayoutKVO == nil) {
         self._collectionViewLayoutKVO = self.observe(\.collectionViewLayout, changeHandler: { [weak self]
             collectionView, value in
             if let self = self {
                 
             }
         })
     }
 }
 */
