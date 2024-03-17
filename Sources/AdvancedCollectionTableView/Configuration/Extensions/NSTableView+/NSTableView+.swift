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

    var isEnabledObservation: KeyValueObservation? {
        get { getAssociatedValue(key: "isEnabledObservation", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "isEnabledObservation", object: self) }
    }
    
    func setupObservation(shouldObserve: Bool = true) {
        if shouldObserve {
            guard isEnabledObservation == nil else { return }
            isEnabledObservation = observeChanges(for: \.isEnabled) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.updateVisibleRowConfigurations()
            }
            windowHandlers.isKey = { [weak self] windowIsKey in
                guard let self = self else { return }
                if windowIsKey == false {
                    self.hoveredRow = nil
                }
                self.updateVisibleRowConfigurations()
            }
            mouseHandlers.exited = { [weak self] _ in
                guard let self = self else { return }
                self.hoveredRow = nil
            }
            mouseHandlers.moved = { [weak self] event in
                guard let self = self else { return }
                let location = event.location(in: self)
                if self.bounds.contains(location) {
                    let row = self.row(at: location)
                    if row != -1 {
                        self.hoveredRow = IndexPath(item: row, section: 0)
                    } else {
                        self.hoveredRow = nil
                    }
                }
            }
        } else {
            windowHandlers.isKey = nil
            mouseHandlers.exited = nil
            mouseHandlers.moved = nil
            isEnabledObservation = nil
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
