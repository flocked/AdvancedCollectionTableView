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
            observerView?.removeFromSuperview()
            observerView = nil
        } else if observerView == nil {
            observerView = ObserverView(for: self)
        }
    }
    
    var observerView: ObserverView? {
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
    
    /*
    /// A Boolean value that indicates whether the collection view reacts to mouse events.
    @objc open var isEnabled: Bool {
        get { getAssociatedValue("isEnabled", initialValue: false) }
        set {
            guard newValue != isEnabled else { return }
            setAssociatedValue(newValue, key: "isEnabled")
            visibleItems().forEach({ $0.setNeedsAutomaticUpdateConfiguration() })
        }
    }
     */

    class ObserverView: NSView {
        var tokens: [NotificationToken] = []
        lazy var trackingArea = TrackingArea(for: self, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow])
        weak var collectionView: NSCollectionView?
        var focusObservation: KeyValueObservation?
        var isFocused = false {
            didSet {
                guard oldValue != isFocused else { return }
                collectionView?.visibleItems().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
            }
        }
        weak var editingView: NSView? {
            didSet {
                guard oldValue != editingView else { return }
                (oldValue?.firstSuperview(where: { $0.parentController is NSCollectionViewItem })?.parentController as? NSCollectionViewItem)?.setNeedsAutomaticUpdateConfiguration()
                (editingView?.firstSuperview(where: { $0.parentController is NSCollectionViewItem })?.parentController as? NSCollectionViewItem)?.setNeedsAutomaticUpdateConfiguration()
            }
        }
        
        init(for collectionView: NSCollectionView) {
            super.init(frame: .zero)
            self.collectionView = collectionView
            collectionView.addSubview(withConstraint: self)
            zPosition = -CGFloat.greatestFiniteMagnitude
            isFocused = collectionView.isDescendantFirstResponder
            sendToBack()
            updateTrackingAreas()
            focusObservation = observeChanges(for: \.window?.firstResponder) { [weak self] oldValue, newValue in
                guard let self = self, let collectionView = self.collectionView else { return }
                if let view = (newValue as? NSView ?? (newValue as? NSText)?.delegate as? NSView), view.isDescendant(of: collectionView) {
                    self.isFocused = true
                    self.editingView = (view as? EditiableView)?.isEditable == true ? view : nil
                } else {
                    self.isFocused = false
                }
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
            updateHoveredItem(for: event)
        }
        
        override func mouseMoved(with event: NSEvent) {
            updateHoveredItem(for: event)
        }
        
        override func mouseExited(with event: NSEvent) {
            collectionView?.hoveredIndexPath = nil
        }
        
        func updateHoveredItem(for event: NSEvent) {
            guard let collectionView = collectionView else { return }
            let location = event.location(in: collectionView)
            collectionView.hoveredIndexPath = collectionView.indexPathForItem(at: location)
            if let item = collectionView.hoveredItem {
                if let view = item.view as? NSItemContentView {
                    item.isHovered = view.isHovering(at: collectionView.convert(location, to: view))
                } else {
                    item.isHovered = true
                }
            }
        }
        
        override func hitTest(_ point: NSPoint) -> NSView? {
            return nil
        }
        
        override func viewWillMove(toWindow newWindow: NSWindow?) {
            tokens = []
            if let newWindow = newWindow {
                tokens = [NotificationCenter.default.observe(NSWindow.didBecomeKeyNotification, object: newWindow) { [weak self] _ in
                    guard let self = self, let collectionView = self.collectionView else { return }
                    collectionView.visibleItems().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
                }, NotificationCenter.default.observe(NSWindow.didResignKeyNotification, object: newWindow) { [weak self] _ in
                    guard let self = self, let collectionView = self.collectionView else { return }
                    collectionView.hoveredIndexPath = nil
                    collectionView.visibleItems().forEach { $0.setNeedsAutomaticUpdateConfiguration() }
                }]
            }
        }
    }
}
