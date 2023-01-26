//
//  NSTableView+.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 10.12.22.
//


import AppKit
import FZExtensions

public extension NSTableView {
    typealias DragHandler = (IndexSet, [NSTableColumn], NSEvent, NSPointPointer)->(NSImage)
    
    //typealias DragHandler = (rows: IndexSet, columns: [NSTableColumn], event: NSEvent, offset: NSPointPointer)->(NSImage)
    
    internal var dragHandler: DragHandler? {
         get { getAssociatedValue(key: "_dragHandler", object: self) }
         set { set(associatedValue: newValue, key: "_dragHandler", object: self) } }
    
    
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
            let rawValue: Int = getAssociatedValue(key: "__selfSizingInvalidation", object: self, initialValue: SelfSizingInvalidation.enabledUsingConstraints.rawValue)
            return SelfSizingInvalidation(rawValue: rawValue)!
        }
        set {
            set(associatedValue: newValue.rawValue, key: "__selfSizingInvalidation", object: self)
        }
    }
    
    internal var trackingArea: NSTrackingArea? {
         get { getAssociatedValue(key: "_trackingArea", object: self) }
         set { set(associatedValue: newValue, key: "_trackingArea", object: self) } }
    

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        self.installTrackingArea()
        /*
        if let trackingArea = trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .mouseMoved, .enabledDuringMouseDrag, .activeInKeyWindow, .inVisibleRect]
        self.trackingArea = NSTrackingArea(rect: self.bounds, options:  options, owner: self)
        self.addTrackingArea(self.trackingArea!)
        super.updateTrackingAreas()
        */
   }
    
    internal func installTrackingArea() {
        guard let window = window else { return }
         window.acceptsMouseMovedEvents = true
         if trackingArea != nil { removeTrackingArea(trackingArea!) }
        let trackingOptions: NSTrackingArea.Options = [.activeInKeyWindow, .inVisibleRect, .mouseMoved]
         trackingArea = NSTrackingArea(rect: bounds,
                                       options: trackingOptions,
                                       owner: self, userInfo: nil)
         self.addTrackingArea(trackingArea!)
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        self.installTrackingArea()
    }
   
   override func mouseEntered(with event: NSEvent) {
       super.mouseEntered(with: event)
       self.updateRowHoverState(event)
   }
   
   override func mouseMoved(with event: NSEvent) {
       super.mouseMoved(with: event)
       self.updateRowHoverState(event)
   }
   
    override func mouseExited(with event: NSEvent) {
       super.mouseExited(with: event)
        self.updateRowHoverState(nil)
   }
 
    
    internal var hoveredRowView: NSTableRowView? {
         get { getAssociatedValue(key: "_hoveredRowView", object: self) }
         set {  set(associatedValue: newValue, key: "_hoveredRowView", object: self) }
     }
        
    internal func updateRowHoverState(_ event: NSEvent?) {
        hoveredRowView?.isHovered = false
        if let location = event?.location(in: self) {
            let rowIndex = self.row(at: location)
            hoveredRowView = self.rowView(atRow: rowIndex, makeIfNecessary: true)
            hoveredRowView?.isHovered = true
        }
    }
    
    internal var isObservingWindowState: Bool {
         get { getAssociatedValue(key: "_isObservingWindowState", object: self, initialValue: false) }
         set {
             set(associatedValue: newValue, key: "_isObservingWindowState", object: self)
         }
     }
    
    override var isEnabled: Bool {
        didSet {
            self.visibleRowViews().forEach({$0.isDisabled = !self.isEnabled})
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
        self.visibleRowViews().forEach({$0.isEmphasized = true})
    }
    
     
     @objc internal func windowDidResignKey() {
         self.visibleRowViews().forEach({$0.isEmphasized = false})
      }
    
    func dragImageForRows(with dragRows: IndexSet, tableColumns: [NSTableColumn], event dragEvent: NSEvent, offset dragImageOffset: NSPointPointer
    ) -> NSImage {
        self.dragHandler?(dragRows, tableColumns, dragEvent, dragImageOffset) ?? NSImage(color: .gray)
    }
}
