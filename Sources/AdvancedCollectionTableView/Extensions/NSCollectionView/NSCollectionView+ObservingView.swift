//
//  NSCollectionView+ObservingView.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSCollectionView {
    class HoverHandlers {
        var isHovering: ((_ item: NSCollectionViewItem) -> ())?
        var didEndHovering: ((_ item: NSCollectionViewItem) -> ())?
    }
    
    var hoveredItem: NSCollectionViewItem? {
        get { getAssociatedValue(key: "NSCollectionView_hoveredItem", object: self, initialValue: nil) }
        set {
            guard newValue != hoveredItem else { return }
            let previousHoveredtem = hoveredItem
            set(weakAssociatedValue: newValue, key: "NSCollectionView_hoveredItem", object: self)
            
            previousHoveredtem?.isHovered = false
            newValue?.isHovered = true
        }
    }
        
    func updateHoveredItem(_ location: CGPoint) {
        let mouseItem = self.subviews.first(where: {
            $0.frame.contains(location) && $0.parentController is NSCollectionViewItem})?.parentController as? NSCollectionViewItem
        hoveredItem = mouseItem
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
                    self.hoveredItem = nil
                    return true
                }
                
                self.observingView?.mouseHandlers.moved = { [weak self] event in
                    guard let self = self else { return true }
                    let location = event.location(in: self)
                    if self.bounds.contains(location) {
                        self.updateHoveredItem(location)
                    }
                    return true
                }
            }
        } else {
            observingView?.removeFromSuperview()
            observingView = nil
        }
    }
        
    var observingView: ObservingView? {
        get { getAssociatedValue(key: "NSCollectionView_observingView", object: self) }
        set { set(associatedValue: newValue, key: "NSCollectionView_observingView", object: self)
        }
    }
}
