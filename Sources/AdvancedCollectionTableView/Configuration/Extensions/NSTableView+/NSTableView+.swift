//
//  NSTableView+.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 10.12.22.
//


import AppKit
import FZExtensions
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
    
    override var isSelectable: Bool {
         get { getAssociatedValue(key: "NSTableView_isSelectable", object: self, initialValue: true) }
         set { set(associatedValue: newValue, key: "NSTableView_isSelectable", object: self) } }

        
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
            self.visibleRowViews().forEach({$0.isEmphasized = newValue})
        }
    }
        
    /*
    func dragImageForRows(with dragRows: IndexSet, tableColumns: [NSTableColumn], event dragEvent: NSEvent, offset dragImageOffset: NSPointPointer
    ) -> NSImage {
        self.dragHandler?(dragRows, tableColumns, dragEvent, dragImageOffset) ?? NSImage(color: .gray)
    }
    */
    
    
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

public extension NSTableView {
    func reloadMaintainingSelection(completionHandler: (() -> ())? = nil) {
           let oldSelectedRowIndexes = selectedRowIndexes
           reloadOnMainThread {
               if oldSelectedRowIndexes.count == 0 {
                   if self.numberOfRows > 0 {
                       self.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                   }
               } else {
                   self.selectRowIndexes(oldSelectedRowIndexes, byExtendingSelection: false)
               }
           }
       }
    
    /**
     Returns the row indexes currently visible.

     - Returns: The array of row indexes corresponding to the currently visible rows.
     */
    func visibleRowIndexes() -> [Int] {
        let visibleRect = self.visibleRect
        let range = self.rows(in: visibleRect)
        var visibleRows = [Int]()
        for row in range.lowerBound...range.upperBound {
            visibleRows.append(row)
        }
        return visibleRows
    }
    
    /**
     Returns the row views currently visible.

     - Returns: The array of row views corresponding to the currently visible row views.
     */
    func visibleRowViews() -> [NSTableRowView] {
        let visibleRowIndexes = self.visibleRowIndexes()
        var visibleRowViews = [NSTableRowView]()
        for row in visibleRowIndexes {
            if let rowView = self.rowView(atRow: row, makeIfNecessary: false) {
                visibleRowViews.append(rowView)
            }
        }
        return visibleRowViews
    }
    
    
    /**
     Returns the cell views currently visible.
     
     - Returns: The array of row views corresponding to the currently visible cell view.
     */
    func visibleCellViews() -> [NSTableCellView] {
        let visibleRowIndexes = self.visibleRowIndexes()
        var visibleCellViews = [NSTableCellView]()
        for row in visibleRowIndexes {
            if let rowView = self.rowView(atRow: row, makeIfNecessary: false) {
                visibleCellViews.append(contentsOf: rowView.cellViews)
            }
        }
        return visibleCellViews
    }
    
    
    internal func cellViews(atRow index: Int) -> [NSTableCellView] {
        guard index >= 0 && index < self.numberOfRows else { return [] }
        return self.rowView(atRow: index, makeIfNecessary: false)?.cellViews ?? []
    }
}

/*
 typealias DragHandler = (IndexSet, [NSTableColumn], NSEvent, NSPointPointer)->(NSImage)
     
 internal var dragHandler: DragHandler? {
      get { getAssociatedValue(key: "NSTableView_dragHandler", object: self) }
      set { set(associatedValue: newValue, key: "NSTableView_dragHandler", object: self) } }
 
 try  self.hook(#selector(NSTableView.dragImageForRows(with:tableColumns:event:offset:)),
                methodSignature: (@convention(c) (AnyObject, Selector, IndexSet, [NSTableColumn], NSEvent, NSPointPointer) -> (NSImage)).self,
                hookSignature: (@convention(block) (AnyObject, IndexSet, [NSTableColumn], NSEvent, NSPointPointer) -> (NSImage)).self) {
                    store in { (object, dragRows, tableColumns, dragEvent, dragImageOffset ) in
                       return self.dragHandler?(dragRows, tableColumns, dragEvent, dragImageOffset) ?? store.original(object, store.selector, dragRows, tableColumns, dragEvent, dragImageOffset)
                    }
                },
 */
