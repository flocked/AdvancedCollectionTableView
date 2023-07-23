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
    
    var _isFirstResponder: Bool {
        get { getAssociatedValue(key: "_NSTableView__isFirstResponder", object: self, initialValue: false) }
        set {
            guard newValue != _isFirstResponder else { return }
            set(associatedValue: newValue, key: "_NSTableView__isFirstResponder", object: self)
            self.visibleRows(makeIfNecessary: false).forEach({
                $0.setNeedsAutomaticUpdateConfiguration()
                $0.setCellViewsNeedAutomaticUpdateConfiguration()
            })
        }
    }
    
    internal func setupTableViewFirstResponderObserver() {
        self.firstResponderHandler = { isFirstResponder in
            self._isFirstResponder = isFirstResponder
        }
    }
}
