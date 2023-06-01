//
//  File.swift
//  
//
//  Created by Florian Zand on 19.05.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal class ObserverView: NSView {
    var windowStateHandler: ((_ windowIsKey: Bool)->())? = nil
    var mouseMoveHandler: ((NSEvent)->())? = nil
    
    internal lazy var trackingArea: TrackingArea = TrackingArea(for: self, options: [.activeInKeyWindow, .inVisibleRect, .mouseMoved, .enabledDuringMouseDrag])
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.initalSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initalSetup()
    }
    
    func initalSetup() {
        trackingArea.update()
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        trackingArea.update()
    }
    
    
    override func mouseMoved(with event: NSEvent) {
        mouseMoveHandler?(event)
        super.mouseMoved(with: event)
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        self.observeWindowState()
    }
    
    internal func observeWindowState() {
        Swift.print(observeWindowState)
        if (isObservingWindowState == false) {
            isObservingWindowState = true
            NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey), name: NSWindow.didBecomeKeyNotification, object: self.window)
            NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey), name: NSWindow.didResignKeyNotification, object: self.window)
        }
    }
    
    @objc internal func windowDidBecomeKey() {
        self.windowIsKey = true
    }
    
    @objc internal func windowDidResignKey() {
        self.windowIsKey = false
    }
    
    var windowIsKey = false {
        didSet {
            if (oldValue != self.windowIsKey) {
                windowStateHandler?(self.windowIsKey)
            }
        }
    }
    
    var isObservingWindowState = false
}

extension NSCollectionView {
    internal func addObserverView() {
        if (self.observerView == nil) {
            self.observerView = ObserverView()
            self.addSubview(withConstraint: self.observerView!)
            self.observerView!.sendToBack()
            self.observerView?.windowStateHandler = { [weak self] windowIsKey in
                guard let self = self else { return }
                self.isEmphasized = windowIsKey
            }
            
            self.observerView?.mouseMoveHandler = { [weak self] event in
                guard let self = self else { return }
                let location = event.location(in: self)
                if self.bounds.contains(location) {
                    self.updateItemHoverState(event)
                }
            }
        }
    }
    
    internal var observerView: ObserverView? {
        get { getAssociatedValue(key: "NSCollectionView_observerView", object: self) }
        set { set(associatedValue: newValue, key: "NSCollectionView_observerView", object: self)
        }
    }
}

extension NSTableView {
    internal func addObserverView() {
        if (self.observerView == nil) {
            self.observerView = ObserverView()
            self.addSubview(withConstraint: self.observerView!)
            self.observerView!.sendToBack()
            self.observerView?.windowStateHandler = { [weak self] windowIsKey in
                guard let self = self else { return }
                self.isEmphasized = windowIsKey
            }
            
            self.observerView?.mouseMoveHandler = { [weak self] event in
                guard let self = self else { return }
                let location = event.location(in: self)
                if self.bounds.contains(location) {
                    self.updateRowHoverState(event)
                }
            }
        }
    }
    
    internal var observerView: ObserverView? {
        get { getAssociatedValue(key: "NSTableView_observerView", object: self) }
        set { set(associatedValue: newValue, key: "NSTableView_observerView", object: self)
        }
    }
}
