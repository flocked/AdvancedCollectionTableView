//
//  NSTableView+.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 10.12.22.
//


import AppKit
import FZSwiftUtils
import FZUIKit
import InterposeKit

public extension NSTableView {
    /**
     Constants that describe modes for invalidating the size of self-sizing table view items.

     Use these constants with the ``selfSizingInvalidation`` property.
     
     - Parameters:
        - disabled: A mode that disables self-sizing invalidation.
        - enabled: A mode that enables manual self-sizing invalidation.
        - enabledIncludingConstraints: A mode that enables automatic self-sizing invalidation after Auto Layout changes.
     */
    enum SelfSizingInvalidation: Int {
        case disabled = 0
        case enabledUsingConstraints = 1
    }
    
    /**
     The mode that the table view uses for invalidating the size of self-sizing cells..
     */
    var selfSizingInvalidation: SelfSizingInvalidation {
        get {
            let rawValue: Int = getAssociatedValue(key: "NSTableView_selfSizingInvalidation", object: self, initialValue: SelfSizingInvalidation.enabledUsingConstraints.rawValue)
            return SelfSizingInvalidation(rawValue: rawValue)!
        }
        set {
            set(associatedValue: newValue.rawValue, key: "NSTableView_selfSizingInvalidation", object: self)
        }
    }
    
    internal var trackingArea: NSTrackingArea? {
         get { getAssociatedValue(key: "NSTableView_trackingArea", object: self) }
         set { set(associatedValue: newValue, key: "NSTableView_trackingArea", object: self) } }
        
    override func updateTrackingAreas() {
        if let trackingArea = trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        self.installTrackingArea()
        super.updateTrackingAreas()
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
    
    /*
    override dynamic func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        Swift.print("viewDidMoveToSuperview")
        self.installTrackingArea()
    }
     */
   
    @objc func swizzled_mouseEntered(with event: NSEvent) {
       super.mouseEntered(with: event)
       self.updateRowHoverState(event)
        self.swizzled_mouseEntered(with: event)

   }
   
    @objc func swizzled_mouseMoved(with event: NSEvent) {
       super.mouseMoved(with: event)
       self.updateRowHoverState(event)
        self.swizzled_mouseMoved(with: event)

   }
   
    @objc func swizzled_mouseExited(with event: NSEvent) {
       super.mouseExited(with: event)
        self.updateRowHoverState(nil)
        self.swizzled_mouseExited(with: event)

   }
 
    internal var hoveredRowView: NSTableRowView? {
         get { getAssociatedValue(key: "NSTableView_hoveredRowView", object: self) }
         set {  set(associatedValue: newValue, key: "NSTableView_hoveredRowView", object: self) }
     }
    
    /*
    override var isSelectable: Bool {
         get { getAssociatedValue(key: "NSTableView_isSelectable", object: self, initialValue: true) }
         set { set(associatedValue: newValue, key: "NSTableView_isSelectable", object: self) } }
     */

        
    internal func updateRowHoverState(_ event: NSEvent?) {
        if let location = event?.location(in: self) {
            let rowIndex = self.row(at: location)
            let newHoveredRowView = self.rowView(atRow: rowIndex, makeIfNecessary: true)
            if (newHoveredRowView != hoveredRowView) {
                hoveredRowView?.isHovered = false
                hoveredRowView?.cellViews.forEach({$0.isHovered = false})
                hoveredRowView = newHoveredRowView
                hoveredRowView?.isHovered = true
                hoveredRowView?.cellViews.first(where: {$0.frame.contains(location)})?.isHovered = true
            }
        } else {
            hoveredRowView?.isHovered = false
            hoveredRowView?.cellViews.forEach({$0.isHovered = false})
        }
    }
    
    internal var isObservingWindowState: Bool {
         get { getAssociatedValue(key: "NSTableView_isObservingWindowState", object: self, initialValue: false) }
         set {
             set(associatedValue: newValue, key: "NSTableView_isObservingWindowState", object: self)
         }
     }
    
    /*
    override var isEnabled: Bool {
        didSet {
            self.visibleRowViews().forEach({$0.isDisabled = !self.isEnabled})
        }
    }
    */
    
    internal func observeWindowState() {
        if (isObservingWindowState == false) {
            isObservingWindowState = true
            NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey), name: NSWindow.didBecomeKeyNotification, object: self.window)
            NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey), name: NSWindow.didResignKeyNotification, object: self.window)
        }
    }
    
    @objc internal func windowDidBecomeKey() {
        self.isEmphasized = true
    }
    
     @objc internal func windowDidResignKey() {
         self.isEmphasized = false
      }
    
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSTableView_isEmphasized", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSTableView_isEmphasized", object: self)
            self.visibleRows(makeIfNecessary: false).forEach({$0.isEmphasized = newValue})
        }
    }
    
     internal var didSwizzleTableViewTrackingArea: Bool {
        get { getAssociatedValue(key: "_didSwizzleTableViewTrackingArea", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_didSwizzleTableViewTrackingArea", object: self)
        }
    }
    
    @objc internal func swizzleTableViewTrackingArea(_ shouldSwizzle: Bool = true) {
        if (didSwizzleTableViewTrackingArea == false) {
            didSwizzleTableViewTrackingArea = true
            do {
                let hooks = [
     try  self.hook(#selector(NSTableView.updateTrackingAreas),
                            methodSignature: (@convention(c) (AnyObject, Selector) -> ()).self,
                            hookSignature: (@convention(block) (AnyObject) -> ()).self) {
     store in { (object) in
         self.installTrackingArea()
         store.original(object, store.selector)
     }
 },
     try  self.hook(#selector(NSTableView.mouseMoved(with:)),
                            methodSignature: (@convention(c) (AnyObject, Selector, NSEvent) -> ()).self,
                            hookSignature: (@convention(block) (AnyObject, NSEvent) -> ()).self) {
     store in { (object, event) in
         let location = event.location(in: self)
         if self.visibleRect.contains(location) {
             self.updateRowHoverState(event)
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
