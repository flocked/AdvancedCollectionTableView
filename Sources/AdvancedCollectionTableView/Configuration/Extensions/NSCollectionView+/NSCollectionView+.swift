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
    /// A Boolean value that indicates whether the collection view reacts to mouse events.
    @objc open var isEnabled: Bool {
        get { getAssociatedValue("isEnabled", initialValue: false) }
        set {
            guard newValue != isEnabled else { return }
            setAssociatedValue(newValue, key: "isEnabled")
            visibleItems().forEach({$0.setNeedsAutomaticUpdateConfiguration()})
        }
    }
    
    @objc dynamic var hoveredIndexPath: IndexPath? {
        get { getAssociatedValue("hoveredIndexPath", initialValue: nil) }
        set {
            guard newValue != hoveredIndexPath else { return }
            hoveredItem?.isHovered = false
            setAssociatedValue(newValue, key: "hoveredIndexPath")
        }
    }
    
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
        get { getAssociatedValue("collectionViewObserverView", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "collectionViewObserverView") }
    }

    class ObserverView: NSView {
        var tokens: [NotificationToken] = []
        lazy var trackingArea = TrackingArea(for: self, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow])
        weak var collectionView: NSCollectionView?
        
        init(for collectionView: NSCollectionView) {
            self.collectionView = collectionView
            super.init(frame: .zero)
            updateTrackingAreas()
            collectionView.addSubview(withConstraint: self)
            self.sendToBack()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            trackingArea.update()
        }
        
        override func mouseEntered(with event: NSEvent) {
            super.mouseEntered(with: event)
            updateHoveredItem(for: event)
        }
        
        override func mouseMoved(with event: NSEvent) {
            super.mouseMoved(with: event)
            updateHoveredItem(for: event)
        }
        
        func updateHoveredItem(for event: NSEvent) {
            guard let collectionView = collectionView else { return }
            let location = event.location(in: collectionView)
            collectionView.hoveredIndexPath = collectionView.indexPathForItem(at: location)
            /*
             if let indexPath = collectionView.indexPathForItem(at: location), let item = collectionView.item(at: indexPath) {
             item.isHovered = (item.view as? NSItemContentView)?.checkHoverLocation(location) ?? true
             if let view = item.view as? NSItemContentView {
             item.isHovered = view.checkHoverLocation(location)
             } else {
             item.isHovered = item.view.frame.contains(location)
             }
             }
             */
            if let item = collectionView.hoveredItem {
                item.checkHoverLocation(collectionView.convert(location, to: item.view))
            }
        }
        
        override func mouseExited(with event: NSEvent) {
            super.mouseExited(with: event)
            collectionView?.hoveredIndexPath = nil
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
