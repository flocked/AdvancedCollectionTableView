//
//  NSCollectionView+.swift
//
//
//  Created by Florian Zand on 01.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSCollectionView {
    /// The index path of the item that is hovered by the mouse.
    @objc dynamic var hoveredIndexPath: IndexPath? {
        get { getAssociatedValue("hoveredIndexPath") }
        set {
            guard newValue != hoveredIndexPath else { return }
            hoveredItem?.isHovered = false
            setAssociatedValue(newValue, key: "hoveredIndexPath")
        }
    }
    
    /// The item that is hovered by the mouse.
    var hoveredItem: NSCollectionViewItem? {
        guard let indexPath = hoveredIndexPath else { return nil }
        return item(at: indexPath)
    }
    
    func setupObservation(shouldObserve: Bool = true) {
        if !shouldObserve {
            observerView?._removeFromSuperview()
            observerView = nil
        } else if observerView == nil {
            observerView = .init(for: self)
        }
    }
    
    var observerView: TableCollectionObserverView? {
        get { getAssociatedValue("collectionViewObserverView") }
        set { setAssociatedValue(newValue, key: "collectionViewObserverView") }
    }
    
    var editingView: NSView? {
        observerView?.editingView
    }
    
    var activeState: NSItemConfigurationState.ActiveState {
        isActive ? isFocused ? .focused : .active : .inactive
    }
    
    var isFocused: Bool {
        observerView?.isFocused == true
    }
    
    var isActive: Bool {
        window?.isKeyWindow == true
    }
}


