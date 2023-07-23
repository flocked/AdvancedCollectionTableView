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
}
