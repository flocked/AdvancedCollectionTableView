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

    func setupObservation(shouldObserve: Bool = true) {
        if shouldObserve {
            if windowHandlers.isKey == nil {
                windowHandlers.isKey = { [weak self] windowIsKey in
                    guard let self = self else { return }
                    if windowIsKey == false {
                        self.hoveredRowIndex = nil
                    }
                    self.updateVisibleRowConfigurations()
                }

                mouseHandlers.exited = { [weak self] _ in
                    guard let self = self else { return }
                    self.hoveredRowIndex = nil
                }

                mouseHandlers.moved = { [weak self] event in
                    guard let self = self else { return }
                    let location = event.location(in: self)
                    if self.bounds.contains(location) {
                        let row = self.row(at: location)
                        if row != -1 {
                            self.hoveredRowIndex = IndexPath(item: row, section: 0)
                        } else {
                            self.hoveredRowIndex = nil
                        }
                    }
                }
            }
            do {
                try replaceMethod(
                    #selector(setter: NSTableView.isEnabled),
                    methodSignature: (@convention(c)  (AnyObject, Selector, Bool) -> ()).self,
                    hookSignature: (@convention(block)  (AnyObject, Bool) -> ()).self) { store in {
                       object, isEnabled in
                        let tableView = object as? NSTableView
                        let oldIsEnabled = tableView?.isEnabled ?? false
                       store.original(object, #selector(setter: NSTableView.isEnabled), isEnabled)
                        if oldIsEnabled != isEnabled {
                            tableView?.updateVisibleRowConfigurations()
                        }
                    }
               }
            } catch {
                Swift.debugPrint(error)
            }
        } else {
            windowHandlers.isKey = nil
            mouseHandlers.exited = nil
            mouseHandlers.moved = nil
            resetMethod(#selector(setter: NSTableView.isEnabled))
        }
    }

    var hoveredRowView: NSTableRowView? {
        if let index = hoveredRowIndex?.item, let rowView = rowView(atRow: index, makeIfNecessary: false) {
            return rowView
        }
        return nil
    }

    var hoveredRowIndex: IndexPath? {
        get { getAssociatedValue(key: "hoveredRowIndex", object: self, initialValue: nil) }
        set {
            guard newValue != hoveredRowIndex else { return }
            let oldIndex = hoveredRowIndex
            let previousHoveredRowView = hoveredRowView
            set(associatedValue: newValue, key: "hoveredRowIndex", object: self)
            if let rowView = previousHoveredRowView {
                rowView.setNeedsAutomaticUpdateConfiguration()
                rowView.setCellViewsNeedAutomaticUpdateConfiguration()
            }
            if let rowView = hoveredRowView {
                rowView.setNeedsAutomaticUpdateConfiguration()
                rowView.setCellViewsNeedAutomaticUpdateConfiguration()
            }
            (dataSource as? DiffableDataSource)?.hoveredIndexPathChanged(old: oldIndex, new: newValue)
        }
    }
}

/*
 var firstResponderObserver: KeyValueObservation? {
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
