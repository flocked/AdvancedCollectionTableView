//
//  NSTableView+ObservingView.swift
//
//
//  Created by Florian Zand on 08.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSTableView {
    class HoverHandlers {
        var isHovering: ((_ row: NSTableRowView) -> ())?
        var didEndHovering: ((_ row: NSTableRowView) -> ())?
    }
    
    var hoverHandlers: HoverHandlers? {
        get { getAssociatedValue(key: "NSTableView_hoverHandlers", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSTableView_hoverHandlers", object: self)
        }
    }
    
    func updateHoveredRow(_ mouseLocation: CGPoint) {
        let newHoveredRowView = self.rowView(at: mouseLocation)
        if newHoveredRowView != self.hoveredRowView {
            if let hoveredRowView = self.hoveredRowView {
                hoverHandlers?.didEndHovering?(hoveredRowView)
            }
            self.removeHoveredRow()
        }
        newHoveredRowView?.isHovered = true
        self.hoveredRowView = newHoveredRowView
        if let hoveredRowView = self.hoveredRowView {
            hoverHandlers?.isHovering?(hoveredRowView)
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
