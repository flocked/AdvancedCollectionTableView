//
//  NSTableView+.swift
//
//
//  Created by Florian Zand on 10.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSTableView {
    func updateVisibleRowConfigurations() {
        visibleRows().forEach {
            $0.setNeedsAutomaticUpdateConfiguration()
            $0.setCellViewsNeedAutomaticUpdateConfiguration()
        }
    }

    var tableViewObserver: KeyValueObserver<NSTableView>? {
        get { getAssociatedValue(key: "tableViewObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "tableViewObserver", object: self) }
    }

    func setupObservation(shouldObserve: Bool = true) {
        if shouldObserve {
            if tableViewObserver == nil {
                tableViewObserver = KeyValueObserver(self)
                tableViewObserver?.add(\.isEnabled) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.updateVisibleRowConfigurations()
                }
            }
            if observingView == nil {
                observingView = ObserverView()
                addSubview(withConstraint: observingView!)
                observingView!.sendToBack()
                observingView?.windowHandlers.isKey = { [weak self] windowIsKey in
                    guard let self = self else { return }
                    if windowIsKey == false {
                        self.hoveredRow = nil
                    }
                    self.updateVisibleRowConfigurations()
                }

                observingView?.mouseHandlers.exited = { [weak self] _ in
                    guard let self = self else { return true }
                    self.hoveredRow = nil
                    return true
                }

                observingView?.mouseHandlers.moved = { [weak self] event in
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
            observingView?.removeFromSuperview()
            observingView = nil
        }
    }

    var observingView: ObserverView? {
        get { getAssociatedValue(key: "tableView_observingView", object: self) }
        set { set(associatedValue: newValue, key: "tableView_observingView", object: self)
        }
    }

    var hoveredRowView: NSTableRowView? {
        if let hoveredRow = hoveredRow, let rowView = rowView(atRow: hoveredRow.item, makeIfNecessary: false) {
            return rowView
        }
        return nil
    }

    @objc dynamic var hoveredRow: IndexPath? {
        get { getAssociatedValue(key: "hoveredRow", object: self, initialValue: nil) }
        set {
            guard newValue != hoveredRow else { return }
            let previousHoveredRowView = hoveredRowView
            set(associatedValue: newValue, key: "hoveredRow", object: self)
            if let rowView = previousHoveredRowView {
                rowView.setNeedsAutomaticUpdateConfiguration()
                rowView.setCellViewsNeedAutomaticUpdateConfiguration()
            }
            if let rowView = hoveredRowView {
                rowView.setNeedsAutomaticUpdateConfiguration()
                rowView.setCellViewsNeedAutomaticUpdateConfiguration()
            }
        }
    }
}

/*
 var firstResponderObserver: NSKeyValueObservation? {
     get { getAssociatedValue(key: "NSTableView_firstResponderObserver", object: self, initialValue: nil) }
     set { set(associatedValue: newValue, key: "NSTableView_firstResponderObserver", object: self) }
 }

 func setupTableViewFirstResponderObserver() {
     guard firstResponderObserver == nil else { return }
     firstResponderObserver = self.observeChanges(for: \.superview?.window?.firstResponder, sendInitalValue: true, handler: { [weak self] old, new in
         guard let self = self, old != new else { return }
         guard (old == self && new != self) || (old != self && new == self) else { return }
         self.updateVisibleRowConfigurations()
     })
 }
 */
