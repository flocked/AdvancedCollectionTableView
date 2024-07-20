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
        if !shouldObserve {
            observerView?.removeFromSuperview()
            observerView = nil
            isEnabledObservation = nil
        } else if observerView == nil {
            observerView = ObserverView(for: self)
            isEnabledObservation = observeChanges(for: \.isEnabled) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.updateVisibleRowConfigurations()
            }
        }
    }
    
    var isObserving: Bool {
        observerView != nil
    }

    var hoveredRowView: NSTableRowView? {
        if let hoveredRow = hoveredRow {
            return rowView(atRow: hoveredRow.item, makeIfNecessary: false)
        }
        return nil
    }

    @objc dynamic var hoveredRow: IndexPath? {
        get { getAssociatedValue("hoveredRow", initialValue: nil) }
        set {
            guard newValue != hoveredRow else { return }
            if let previousRowView = hoveredRowView {
                previousRowView.setNeedsAutomaticUpdateConfiguration()
                previousRowView.setCellViewsNeedAutomaticUpdateConfiguration()
            }
            setAssociatedValue(newValue, key: "hoveredRow")
            if let rowView = hoveredRowView {
                rowView.setNeedsAutomaticUpdateConfiguration()
                rowView.setCellViewsNeedAutomaticUpdateConfiguration()
            }
        }
    }
    
    var observerView: ObserverView? {
        get { getAssociatedValue("tableViewObserverView", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "tableViewObserverView") }
    }
    
    var isEnabledObservation: KeyValueObservation? {
        get { getAssociatedValue("isEnabledObservation", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "isEnabledObservation") }
    }
    
    class ObserverView: NSView {
        var tokens: [NotificationToken] = []
        lazy var trackingArea = TrackingArea(for: self, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow])
        weak var tableView: NSTableView?
        
        init(for tableView: NSTableView) {
            self.tableView = tableView
            super.init(frame: .zero)
            updateTrackingAreas()
            tableView.addSubview(withConstraint: self)
            self.sendToBack()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            trackingArea.update()
        }
        
        override func mouseEntered(with event: NSEvent) {
            super.mouseEntered(with: event)
        }
        
        override func mouseMoved(with event: NSEvent) {
            super.mouseMoved(with: event)
            guard let tableView = tableView else { return }
            let location = event.location(in: tableView)
            let row = tableView.row(at: location)
            if row != -1 {
                tableView.hoveredRow = IndexPath(item: row, section: 0)
            } else {
                tableView.hoveredRow = nil
            }
        }
        
        override func mouseExited(with event: NSEvent) {
            super.mouseExited(with: event)
            tableView?.hoveredRow = nil
        }
        
        override func viewWillMove(toWindow newWindow: NSWindow?) {
            tokens = []
            if let newWindow = newWindow {
                tokens = [NotificationCenter.default.observe(NSWindow.didBecomeKeyNotification, object: newWindow) { [weak self] _ in
                    guard let self = self, let tableView = self.tableView else { return }
                    tableView.updateVisibleRowConfigurations()
                }, NotificationCenter.default.observe(NSWindow.didResignKeyNotification, object: newWindow) { [weak self] _ in
                    guard let self = self, let tableView = self.tableView else { return }
                    tableView.hoveredRow = nil
                    tableView.updateVisibleRowConfigurations()
                }]
            }
        }
    }
    
    class TableViewObserverView: NSView {
        init(handler: @escaping ((NSTableView)->())) {
            self.handler = handler
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewWillMove(toWindow newWindow: NSWindow?) {
            guard newWindow != nil, let tableView = firstSuperview(for: NSTableView.self) else { return }
            handler(tableView)
        }
                
        var handler: ((NSTableView)->())
    }
}
