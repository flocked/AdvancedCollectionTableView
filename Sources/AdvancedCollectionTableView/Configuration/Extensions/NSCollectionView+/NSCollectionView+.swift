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
                self.removeHoveredItem()
            }
            self.visibleItems().forEach({$0.setNeedsAutomaticUpdateConfiguration()})
        }
    }
    
    var isEnabled: Bool {
        get { getAssociatedValue(key: "NSCollectionView_isEnabled", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_isEnabled", object: self)
            self.visibleItems().forEach({$0.isEnabled = newValue })
        }
    }
    
    var _isFirstResponder: Bool {
        get { getAssociatedValue(key: "_NSCollectionView__isFirstResponder", object: self, initialValue: false) }
        set {
            guard newValue != _isFirstResponder else { return }
            set(associatedValue: newValue, key: "_NSCollectionView__isFirstResponder", object: self)
            self.visibleItems().forEach({$0.setNeedsAutomaticUpdateConfiguration() })
        }
    }
    
    internal func setupCollectionViewFirstResponderObserver() {
        self.firstResponderHandler = { isFirstResponder in
            self._isFirstResponder = isFirstResponder
        }
    }
}
