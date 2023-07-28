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
    var hoveredItem: NSCollectionViewItem? {
        get { getAssociatedValue(key: "_hoveredItem", object: self, initialValue: nil) }
        set {
            guard newValue != hoveredItem else { return }
            let previousHoveredItem = hoveredItem
            set(weakAssociatedValue: newValue, key: "_hoveredItem", object: self)
            previousHoveredItem?.setNeedsAutomaticUpdateConfiguration()
            newValue?.setNeedsAutomaticUpdateConfiguration()
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
                    self.hoveredItem = nil
                    return true
                }
                
                self.observingView?.mouseHandlers.moved = { [weak self] event in
                    guard let self = self else { return true }
                    let location = event.location(in: self)
                    if self.bounds.contains(location) {
                        let mouseItem = self.subviews.first(where: {
                            $0.frame.contains(location) && $0.parentController is NSCollectionViewItem})?.parentController as? NSCollectionViewItem
                        self.hoveredItem = mouseItem
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
