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
    func setupObservation(shouldObserve: Bool = true) {
        if !shouldObserve {
            observerView?._removeFromSuperview()
            observerView = nil
        } else if observerView == nil {
            observerView = .init(for: self)
        }
    }

    @objc dynamic var hoveredRow: Int {
        get { getAssociatedValue("hoveredRow", initialValue: -1) }
        set {
            guard newValue != hoveredRow else { return }
            let previousRow = hoveredRowView
            setAssociatedValue(newValue, key: "hoveredRow")
            previousRow?.setNeedsAutomaticUpdateConfiguration()
            hoveredRowView?.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    var hoveredRowView: NSTableRowView? {
        if hoveredRow != -1, hoveredRow < numberOfRows {
            return rowView(atRow: hoveredRow, makeIfNecessary: false)
        }
        return nil
    }
    
    var observerView: TableCollectionObserverView? {
        get { getAssociatedValue("tableViewObserverView") }
        set { setAssociatedValue(newValue, key: "tableViewObserverView") }
    }
    
    var editingView: NSView? {
        observerView?.editingView
    }
    
    var activeState: NSListConfigurationState.ActiveState {
        isActive ? isFocused ? .focused : .active : .inactive
    }
    
    var isFocused: Bool {
        observerView?.isFocused == true
    }
    
    var isActive: Bool {
        window?.isKeyWindow == true
    }
}
