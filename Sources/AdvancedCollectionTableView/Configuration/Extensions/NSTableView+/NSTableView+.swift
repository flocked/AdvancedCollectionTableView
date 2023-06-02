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
    
    internal func updateHoveredRow(_ mouseLocation: CGPoint) {
        let newHoveredRowView = self.rowView(at: mouseLocation)
        if newHoveredRowView != self.hoveredRowView {
            self.hoveredRowView?.isHovered = false
        }
        newHoveredRowView?.isHovered = true
        self.hoveredRowView = newHoveredRowView
    }
        
    internal func removeHoveredRow() {
        self.hoveredRowView?.isHovered = false
        self.hoveredRowView = nil
    }
    
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSTableView_isEmphasized", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSTableView_isEmphasized", object: self)
            self.visibleRows(makeIfNecessary: false).forEach({$0.isEmphasized = newValue})
        }
    }
    
    
    /*
     override var isEnabled: Bool {
     didSet {
     self.visibleRowViews().forEach({$0.isDisabled = !self.isEnabled})
     }
     }
     */
    
    
    /*
     override var isSelectable: Bool {
     get { getAssociatedValue(key: "NSTableView_isSelectable", object: self, initialValue: true) }
     set { set(associatedValue: newValue, key: "NSTableView_isSelectable", object: self) } }
     */
}

internal extension NSTableView {
    func setupObservers(shouldObserve: Bool = true) {
        self.setupSelectionObserver(shouldObserve: shouldObserve)
        self.setupObserverView(shouldObserve: shouldObserve)
    }
    
    func setupSelectionObserver(shouldObserve: Bool = true) {
        if shouldObserve {
            if selectionObserver == nil {
                self._selectedRowIndexes = self.selectedRowIndexes
                selectionObserver =  NotificationCenter.default.observe(name: NSTableView.selectionDidChangeNotification, object: self) { [weak self] notification in
                    guard let self = self else { return }
                    let previous = self._selectedRowIndexes
                    let new = self.selectedRowIndexes
                    let added = previous.symmetricDifference(new)
                    let removed = new.symmetricDifference(previous)
                    
                    var rowIndexes: [Int] = []
                    rowIndexes.append(contentsOf: added)
                    rowIndexes.append(contentsOf: removed)
                    rowIndexes = rowIndexes.uniqued()
                    
                    let rowViews = rowIndexes.compactMap({ self.rowView(atRow: $0, makeIfNecessary: false) })
                    rowViews.forEach({
                        $0.setNeedsAutomaticUpdateConfiguration()
                        $0.setCellViewsNeedAutomaticUpdateConfiguration()
                    })
                    self._selectedRowIndexes = new
                }
            }
        } else {
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
                    self.removeHoveredRow()
                }
                
                self.observerView?.mouseHandlers.moved = { [weak self] event in
                    guard let self = self else { return }
                    let location = event.location(in: self)
                    if self.bounds.contains(location) {
                        self.updateHoveredRow(location)
                    }
                }
            }
        } else {
            self.observerView?.removeFromSuperview()
            self.observerView = nil
        }
    }
        
    var observerView: ObserverView? {
        get { getAssociatedValue(key: "NSTableView_observerView", object: self) }
        set { set(associatedValue: newValue, key: "NSTableView_observerView", object: self)
        }
    }
    
    var selectionObserver: NotificationToken? {
        get { getAssociatedValue(key: "NSTableView_selectionObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSTableView_selectionObserver", object: self)
        }
    }
    
    var _selectedRowIndexes: IndexSet {
        get { getAssociatedValue(key: "_NSTableView_SelectedRowIndexes", object: self, initialValue: IndexSet()) }
        set {  set(associatedValue: newValue, key: "_NSTableView_SelectedRowIndexes", object: self)
        }
    }
    
    var hoveredRowView: NSTableRowView? {
        get { getAssociatedValue(key: "NSTableView_hoveredRowView", object: self, initialValue: nil) }
        set { set(weakAssociatedValue: newValue, key: "NSTableView_hoveredRowView", object: self)
        }
    }
}
