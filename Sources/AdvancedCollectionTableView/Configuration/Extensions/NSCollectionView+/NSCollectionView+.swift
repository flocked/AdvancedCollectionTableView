//
//  NSCollectionView.swift
//  NSHostingViewSizeInTableView
//
//  Created by Florian Zand on 01.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSCollectionView {
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isEmphasized", object: self, initialValue: false) }
        set {
            guard newValue != isEmphasized else { return }
            set(associatedValue: newValue, key: "NSCollectionView_isEmphasized", object: self)
            if newValue == false {
                self.hoveredItem = nil
            }
            self.visibleItems().forEach({$0.setNeedsAutomaticUpdateConfiguration()})
        }
    }
    
    internal var isEnabled: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isEnabled", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_isEnabled", object: self)
            self.visibleItems().forEach({$0.isEnabled = newValue })
        }
    }
    
    internal var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSCollectionView_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSCollectionView_firstResponderObserver", object: self) }
    }
    
    internal func setupCollectionViewFirstResponderObserver() {
        guard firstResponderObserver == nil else { return }
        firstResponderObserver = self.observeChanges(for: \.superview?.window?.firstResponder, sendInitalValue: true, handler: { old, new in
            guard old != new else { return }
            guard (old == self && new != self) || (old != self && new == self) else { return }
            self.visibleItems().forEach({$0.setNeedsAutomaticUpdateConfiguration() })
        })
    }
    
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
