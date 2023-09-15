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
                self.hoveredRow = nil
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
                    self.hoveredRow = nil
                    return true
                }
                
                self.observingView?.mouseHandlers.moved = { [weak self] event in
                    guard let self = self else { return true }
                    let location = event.location(in: self)
                    if self.bounds.contains(location) {
                        let row = self.row(at: location)
                        if row != -1 {
                            self.hoveredRow = IndexPath(item: row, section: 0)
                        } else {
                            self.hoveredRow = nil
                        }
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
    
    internal var hoveredRowView: NSTableRowView? {
        if let hoveredRow = hoveredRow, let rowView = self.rowView(atRow: hoveredRow.item, makeIfNecessary: false) {
            return rowView
        }
        return nil
    }
    
    @objc dynamic var hoveredRow: IndexPath? {
         get { getAssociatedValue(key: "NSTableView_hoveredRow", object: self, initialValue: nil) }
         set {
             guard newValue != hoveredRow else { return }
             let previousRow = hoveredRow
             set(associatedValue: newValue, key: "NSTableView_hoveredRow", object: self)
             if let previousRow = previousRow, let rowView = self.rowView(atRow: previousRow.item, makeIfNecessary: false) {
                 rowView.setNeedsAutomaticUpdateConfiguration()
                 rowView.setCellViewsNeedAutomaticUpdateConfiguration()
             }
             if let rowView = self.hoveredRowView {
                 rowView.setNeedsAutomaticUpdateConfiguration()
                 rowView.setCellViewsNeedAutomaticUpdateConfiguration()
             }
         }
     }
}
