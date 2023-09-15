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
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSTableView_isEmphasized", object: self, initialValue: false) }
        set {
            guard newValue != self.isEmphasized else { return }
            set(associatedValue: newValue, key: "NSTableView_isEmphasized", object: self)
            if newValue == false {
                self.hoveredRowView = nil
            }
            self.visibleRows().forEach({
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
            self.visibleRows().forEach({
                $0.setNeedsAutomaticUpdateConfiguration()
                $0.setCellViewsNeedAutomaticUpdateConfiguration()
            })
        })
    }
    
    func setupObservingView(shouldObserve: Bool = true) {
        if shouldObserve {
            if (self.observingView == nil) {
                self.observingView = ObservingView()
                self.addSubview(withConstraint: self.observingView!)
                self.observingView!.sendToBack()
                self.observingView?.windowHandlers.isKey = { [weak self] windowIsKey in
                    guard let self = self else { return }
                    self.isEmphasized = windowIsKey
                }
                
                self.observingView?.mouseHandlers.exited = { [weak self] event in
                    guard let self = self else { return true }
                    self.hoveredRowView = nil
                    return true
                }
                
                self.observingView?.mouseHandlers.moved = { [weak self] event in
                    guard let self = self else { return true }
                    let location = event.location(in: self)
                    if self.bounds.contains(location) {
                        let newHoveredRowView = self.rowView(at: location)
                        self.hoveredRowView = newHoveredRowView
                    }
                    return true
                }
            }
        } else {
            self.observingView?.removeFromSuperview()
            self.observingView = nil
        }
    }
    
    var observingView: ObservingView? {
        get { getAssociatedValue(key: "NSTableView_observingView", object: self) }
        set { set(associatedValue: newValue, key: "NSTableView_observingView", object: self)
        }
    }
    
   @objc dynamic var hoveredRowView: NSTableRowView? {
        get { getAssociatedValue(key: "NSTableView_hoveredRowView", object: self, initialValue: nil) }
        set {
            guard newValue != hoveredRowView else { return }
            let previousHovered = hoveredRowView
            set(weakAssociatedValue: newValue, key: "NSTableView_hoveredRowView", object: self)
            previousHovered?.setNeedsAutomaticUpdateConfiguration()
            previousHovered?.setCellViewsNeedAutomaticUpdateConfiguration()
            newValue?.setNeedsAutomaticUpdateConfiguration()
            newValue?.setCellViewsNeedAutomaticUpdateConfiguration()
        }
    }
}
