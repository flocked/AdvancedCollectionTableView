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
     
     internal func observeWindowState() {
         Swift.print(observeWindowState)
         if (isObservingWindowState == false) {
             isObservingWindowState = true
             Swift.print("observeWindowState", self.window)
             NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey), name: NSWindow.didBecomeKeyNotification, object: self.window)
             NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey), name: NSWindow.didResignKeyNotification, object: self.window)
         }
     }
    
    @objc internal func windowDidBecomeKey() {
        self.isEmphasized = true
        Swift.print("windowDidBecomeKey")
    }
     
     @objc internal func windowDidResignKey() {
         self.isEmphasized = false
         Swift.print("windowDidResignKey")
      }
        
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isEmphasized", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_isEmphasized", object: self)
            self.visibleItems().forEach({$0.isEmphasized = newValue})
        }
    }
       
    /*
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
    */
    
    internal func updateItemHoverState(_ event: NSEvent?) {
        let visibleItems = self.visibleItems()
        if let event = event {
            let location = event.location(in: self)
            let mouseItem = self.item(at: location)
            if let mouseItem = mouseItem, mouseItem.isHovered == false {
                mouseItem.isHovered = true
            }
            visibleItems.filter({$0.isHovered && $0 != mouseItem}).forEach({$0.isHovered = false })
        } else {
            visibleItems.filter({$0.isHovered}).forEach({$0.isHovered = false })
        }
    }
        
   internal var trackingArea: NSTrackingArea? {
        get { getAssociatedValue(key: "NSCollectionView_trackingArea", object: self) }
        set { set(associatedValue: newValue, key: "NSCollectionView_trackingArea", object: self) } }
    
   internal var trackDisplayingItems: Bool {
        get { getAssociatedValue(key: "NSCollectionView_trackDisplayingItems", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_trackDisplayingItems", object: self)
            self.updateDisplayingItemsTracking()
        }
    }
    
    override var isSelectable: Bool {
         get { getAssociatedValue(key: "NSCollectionView_isSelectable", object: self, initialValue: true) }
         set { set(associatedValue: newValue, key: "NSCollectionView_isSelectable", object: self) } }
     
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
    
    @objc func didScroll() {
       
    }
        
    internal func installTrackingArea() {
        guard let window = window else { return }
         window.acceptsMouseMovedEvents = true
         if trackingArea != nil { removeTrackingArea(trackingArea!) }
        let trackingOptions: NSTrackingArea.Options = [.activeInKeyWindow, .inVisibleRect, .mouseMoved, .enabledDuringMouseDrag]
         trackingArea = NSTrackingArea(rect: bounds,
                                       options: trackingOptions,
                                       owner: self, userInfo: nil)
         self.addTrackingArea(trackingArea!)
    }
    
    internal var didSwizzleCollectionViewTrackingArea: Bool {
       get { getAssociatedValue(key: "_didSwizzleTableViewTrackingArea", object: self, initialValue: false) }
       set {
           set(associatedValue: newValue, key: "_didSwizzleTableViewTrackingArea", object: self)
       }
   }
   
   @objc internal func swizzleCollectionViewTrackingArea(_ shouldSwizzle: Bool = true) {
       if (didSwizzleCollectionViewTrackingArea == false) {
           didSwizzleCollectionViewTrackingArea = true
           do {
               let hooks = [
    try  self.hook(#selector(NSCollectionView.updateTrackingAreas),
                           methodSignature: (@convention(c) (AnyObject, Selector) -> ()).self,
                           hookSignature: (@convention(block) (AnyObject) -> ()).self) {
    store in { (object) in
        self.installTrackingArea()
        store.original(object, store.selector)
    }
},
    try  self.hook(#selector(NSCollectionView.mouseMoved(with:)),
                           methodSignature: (@convention(c) (AnyObject, Selector, NSEvent) -> ()).self,
                           hookSignature: (@convention(block) (AnyObject, NSEvent) -> ()).self) {
    store in { (object, event) in
        let location = event.location(in: self)
        if self.visibleRect.contains(location) {
            self.updateItemHoverState(event)
        }
        store.original(object, store.selector, event)
    }
},
               ]
              try hooks.forEach({ _ = try (shouldSwizzle) ? $0.apply() : $0.revert() })
           } catch {
               Swift.print(error)
           }
       }
   }
}
