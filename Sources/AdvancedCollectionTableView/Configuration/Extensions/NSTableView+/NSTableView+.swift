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
            observerView?.removeFromSuperview()
            observerView = nil
        } else if observerView == nil {
            observerView = ObserverView(for: self)
        }
    }

    @objc dynamic var hoveredRow: IndexPath? {
        get { getAssociatedValue("hoveredRow", initialValue: nil) }
        set {
            guard newValue != hoveredRow else { return }
            hoveredRowView?.setNeedsAutomaticUpdateConfiguration(updateCells: true)
            setAssociatedValue(newValue, key: "hoveredRow")
            hoveredRowView?.setNeedsAutomaticUpdateConfiguration(updateCells: true)
        }
    }
    
    var hoveredRowView: NSTableRowView? {
        if let hoveredRow = hoveredRow {
            return rowView(atRow: hoveredRow.item, makeIfNecessary: false)
        }
        return nil
    }
    
    var observerView: ObserverView? {
        get { getAssociatedValue("tableViewObserverView", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "tableViewObserverView") }
    }
    
    class ObserverView: NSView {
        var tokens: [NotificationToken] = []
        lazy var trackingArea = TrackingArea(for: self, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow])
        weak var tableView: NSTableView?
        var isEnabledObservation: KeyValueObservation?
        var styleObservation: KeyValueObservation?
        
        init(for tableView: NSTableView) {
            self.tableView = tableView
            super.init(frame: .zero)
            updateTrackingAreas()
            tableView.addSubview(withConstraint: self)
            self.sendToBack()
            styleObservation = tableView.observeChanges(for: \.effectiveStyle) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.tableView?.visibleRows().forEach { $0.setNeedsAutomaticUpdateConfiguration(updateCells: true) }
            }
            isEnabledObservation = tableView.observeChanges(for: \.isEnabled) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.tableView?.visibleRows().forEach { $0.setNeedsAutomaticUpdateConfiguration(updateCells: true) }
            }
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
            updateHoveredRow(for: event)
        }
        
        override func mouseMoved(with event: NSEvent) {
            super.mouseMoved(with: event)
            updateHoveredRow(for: event)
        }
        
        func updateHoveredRow(for event: NSEvent) {
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
                    tableView.visibleRows().forEach { $0.setNeedsAutomaticUpdateConfiguration(updateCells: true) }

                }, NotificationCenter.default.observe(NSWindow.didResignKeyNotification, object: newWindow) { [weak self] _ in
                    guard let self = self, let tableView = self.tableView else { return }
                    tableView.hoveredRow = nil
                    tableView.visibleRows().forEach { $0.setNeedsAutomaticUpdateConfiguration(updateCells: true) }
                }]
            }
        }
    }
}

class TableViewObserverView: NSView {
    let handler: ((NSTableView)->())
    
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        guard newWindow != nil, let tableView = firstSuperview(for: NSTableView.self) else { return }
        handler(tableView)
    }
    
    init(handler: @escaping ((NSTableView)->())) {
        self.handler = handler
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
