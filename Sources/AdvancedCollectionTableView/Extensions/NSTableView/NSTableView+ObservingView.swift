//
//  NSTableView+ObservingView.swift
//
//
//  Created by Florian Zand on 08.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import FZQuicklook

public extension NSTableView {
    /// Handlers that get called whenever the mouse is hovering a rnow.
    struct RowHoverHandlers {
        /// The handler that gets called whenever the mouse is hovering a row.
        var isHovering: ((_ row: NSTableRowView) -> ())?
        /// The handler that gets called whenever the mouse did end hovering a row.
        var didEndHovering: ((_ row: NSTableRowView) -> ())?
    }
    
    /// Handlers that get called whenever the mouse is hovering a rnow.
    var rowHoverHandlers: RowHoverHandlers {
        get { getAssociatedValue(key: "NSTableView_rowHoverHandlers", object: self, initialValue: RowHoverHandlers()) }
        set { set(associatedValue: newValue, key: "NSTableView_rowHoverHandlers", object: self)
            let shouldObserve = (newValue.isHovering != nil || newValue.didEndHovering != nil)
            self.setupObservingView(shouldObserve: shouldObserve)
        }
    }
}

internal extension NSTableView {
    func updateHoveredRow(_ mouseLocation: CGPoint) {
        let newHoveredRowView = self.rowView(at: mouseLocation)
        if newHoveredRowView != self.hoveredRowView {
            if let hoveredRowView = self.hoveredRowView {
                rowHoverHandlers.didEndHovering?(hoveredRowView)
            }
            self.removeHoveredRow()
        }
        newHoveredRowView?.isHovered = true
        self.hoveredRowView = newHoveredRowView
        if let hoveredRowView = self.hoveredRowView {
            rowHoverHandlers.isHovering?(hoveredRowView)
        }
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
                    self.removeHoveredRow()
                    return true
                }
                
                self.observingView?.mouseHandlers.moved = { [weak self] event in
                    guard let self = self else { return true }
                    let location = event.location(in: self)
                    if self.bounds.contains(location) {
                        self.updateHoveredRow(location)
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
    
    var hoveredRowView: NSTableRowView? {
        get { getAssociatedValue(key: "NSTableView_hoveredRowView", object: self, initialValue: nil) }
        set { set(weakAssociatedValue: newValue, key: "NSTableView_hoveredRowView", object: self)
        }
    }
}

public extension NSTableViewDiffableDataSource {
    var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "NSTableViewDiffableDataSource_keyDownMonitor", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSTableViewDiffableDataSource_keyDownMonitor", object: self)
        }
    }
    
    var allowsDeleting: Bool {
        get { getAssociatedValue(key: "NSTableViewDiffableDataSource_allowsDeleting", object: self, initialValue: false) }
        set {
            guard newValue != allowsDeleting else { return }
            set(associatedValue: newValue, key: "NSTableViewDiffableDataSource_allowsDeleting", object: self)
            self.setupKeyDownMonitor()
        }
    }
    
    func setupKeyDownMonitor() {
        Swift.print("setupKeyDownMonitor", self.allowsDeleting)
        if self.allowsDeleting {
            if keyDownMonitor == nil {
                keyDownMonitor =  NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    Swift.print("keyDown", event.keyCode)
                    guard let self = self else { return event }
                    guard event.keyCode ==  51 else { return event }
                    Swift.print("keyDown", (NSApp.keyWindow?.initialFirstResponder as? NSTableView) != nil)
                    if allowsDeleting, let tableView =  (NSApp.keyWindow?.initialFirstResponder as? NSTableView), tableView.dataSource === self {
                       let elementsToDelete = self.itemIdentifiers(for: tableView.selectedRowIndexes.map({$0}))
                        if (elementsToDelete.isEmpty == false) {
                            if QuicklookPanel.shared.isVisible {
                                QuicklookPanel.shared.close()
                            }
                            var snapshot = self.snapshot()
                            snapshot.deleteItems(elementsToDelete)
                            self.apply(snapshot, .usingReloadData)
                            return nil
                        }
                    }
                    return event
                })
            }
        } else {
            if let keyDownMonitor = self.keyDownMonitor {
                NSEvent.removeMonitor(keyDownMonitor)
            }
            keyDownMonitor = nil
        }
    }
}
