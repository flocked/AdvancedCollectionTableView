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
    var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSCollectionView_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSCollectionView_firstResponderObserver", object: self) }
    }
    
    func setupCollectionViewFirstResponderObserver() {
        guard firstResponderObserver == nil else { return }
        firstResponderObserver = self.observeChanges(for: \.superview?.window?.firstResponder, sendInitalValue: true, handler: { old, new in
            guard old != new else { return }
            guard (old == self && new != self) || (old != self && new == self) else { return }
      //      self.visibleItems().forEach({$0.setNeedsAutomaticUpdateConfiguration() })
        })
    }
    
    @objc dynamic var hoveredIndexPath: IndexPath? {
        get { getAssociatedValue(key: "hoveredIndexPath", object: self, initialValue: nil) }
        set {
            guard newValue != hoveredIndexPath else { return }
            let previousIndexPath = hoveredIndexPath
            set(associatedValue: newValue, key: "hoveredIndexPath", object: self)
            if let indexPath = previousIndexPath, let item = self.item(at: indexPath) {
                item.setNeedsAutomaticUpdateConfiguration()
            }
            if let indexPath = hoveredIndexPath, let item = self.item(at: indexPath) {
                item.setNeedsAutomaticUpdateConfiguration()
            }
            //  previousHoveredItem?.setNeedsAutomaticUpdateConfiguration()
            //   newValue?.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    var hoveredItem: NSCollectionViewItem? {
        guard let indexPath = hoveredIndexPath else { return nil }
        return self.item(at: indexPath)
    }
    
    func setupObservation(shouldObserve: Bool = true) {
        if shouldObserve {
            if (self.observingView == nil) {
                self.observingView = ObservingView()
                self.addSubview(withConstraint: self.observingView!)
                self.observingView!.sendToBack()
                self.observingView?.windowHandlers.isKey = { [weak self] windowIsKey in
                    guard let self = self else { return }
                    if windowIsKey == false {
                        self.hoveredIndexPath = nil
                    }
                    self.visibleItems().forEach({$0.setNeedsAutomaticUpdateConfiguration()})
                }
                
                self.observingView?.mouseHandlers.exited = { [weak self] event in
                    guard let self = self else { return true }
                    self.hoveredIndexPath = nil
                    return true
                }
                
                self.observingView?.mouseHandlers.moved = { [weak self] event in
                    guard let self = self else { return true }
                    let location = event.location(in: self)
                    if self.bounds.contains(location) {
                        self.hoveredIndexPath = self.indexPathForItem(at: location)
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

/*
 var keyDownMonitor: NSEvent.Monitor? {
     get { getAssociatedValue(key: "keyDownMonitor", object: self, initialValue: nil) }
     set { set(associatedValue: newValue, key: "keyDownMonitor", object: self) }
 }
 
 /**
  A Boolean value that indicates whether the receiver reacts to mouse events.
  
  The value of this property is `true` if the receiver responds to mouse events; otherwise, `false`.
  */
 public var isEnabled: Bool {
     get { getAssociatedValue(key: "isEnabled", object: self, initialValue: false) }
     set {
         guard newValue != isEnabled else { return }
         set(associatedValue: newValue, key: "isEnabled", object: self)
         if isEnabled {
             if keyDownMonitor == nil {
                 keyDownMonitor = NSEvent.localMonitor(for: [.leftMouseDown]) { event in
                         if let contentView = NSApp.keyWindow?.contentView {
                             let location = event.location(in: contentView)
                             if contentView.hitTest(location)?.isDescendant(of: self) == true {
                                 return nil
                             }
                         }
                     return nil
                 }
             } else {
                 keyDownMonitor = nil
             }
         }
         self.visibleItems().forEach({$0.setNeedsAutomaticUpdateConfiguration()})
         }
 }
 */
