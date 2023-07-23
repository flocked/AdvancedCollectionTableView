//
//  NSTableView+.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 10.12.22.
//


import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableView {
    internal func removeHoveredRow() {
        self.hoveredRowView?.isHovered = false
        self.hoveredRowView = nil
    }
    
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSTableView_isEmphasized", object: self, initialValue: false) }
        set {
            guard newValue != self.isEmphasized else { return }
            set(associatedValue: newValue, key: "NSTableView_isEmphasized", object: self)
            if newValue == false {
                self.removeHoveredRow()
            }
            self.visibleRows(makeIfNecessary: false).forEach({
                $0.setNeedsAutomaticUpdateConfiguration()
                $0.setCellViewsNeedAutomaticUpdateConfiguration()
            })
        }
    }
        
    internal var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSTableView_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSTableView_firstResponderObserver", object: self) }
    }
    
    internal func setupTableViewFirstResponderObserver() {
        guard firstResponderObserver == nil else { return }
        firstResponderObserver = self.observeChanges(for: \.superview?.window?.firstResponder, sendInitalValue: true, handler: { old, new in
            guard old != new else { return }
            guard (old == self && new != self) || (old != self && new == self) else { return }
            self.visibleRows(makeIfNecessary: false).forEach({
                $0.setNeedsAutomaticUpdateConfiguration()
                $0.setCellViewsNeedAutomaticUpdateConfiguration()
            })
        })
    }
}
