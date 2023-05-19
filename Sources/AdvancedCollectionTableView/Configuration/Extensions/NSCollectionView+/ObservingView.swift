//
//  File.swift
//  
//
//  Created by Florian Zand on 19.05.23.
//

import AppKit
import FZExtensions

class ObserverView: NSView {
    var windowStateHandler: ((_ windowIsKey: Bool)->())? = nil
    var mouseMoveHandler: ((NSEvent)->())? = nil
    
    internal var trackingArea: NSTrackingArea? = nil
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.initalSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initalSetup()
    }
    
    func initalSetup() {
        self.installTrackingArea()
    }
    
    override func updateTrackingAreas() {
        installTrackingArea()
        super.updateTrackingAreas()
   }
    
internal func installTrackingArea() {
    guard let window = window else { return }
     window.acceptsMouseMovedEvents = true
    if let trackingArea = self.trackingArea { removeTrackingArea(trackingArea) }
    let trackingOptions: NSTrackingArea.Options = [.activeInKeyWindow, .inVisibleRect, .mouseMoved, .enabledDuringMouseDrag]
    self.trackingArea = NSTrackingArea(rect: bounds,
                                   options: trackingOptions,
                                   owner: self, userInfo: nil)
     self.addTrackingArea(trackingArea!)
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
    //   Swift.print("obserview windowDidBecomeKey")
   }
    
    @objc internal func windowDidResignKey() {
        self.windowIsKey = false
    //    Swift.print("obserview windowDidResignKey")
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
    internal func addObserverViewIfNeeded() {
        if (self.observerView == nil) {
            self.observerView = ObserverView()
            self.addSubview(withConstraint: self.observerView!)
            self.observerView?.windowStateHandler = { [weak self] windowIsKey in
                guard let self = self else { return }
                self.isEmphasized = windowIsKey
                Swift.print("ObserverView windowIsKey", windowIsKey)
            }
            
            self.observerView?.mouseMoveHandler = { [weak self] event in
                guard let self = self else { return }
                let location = event.location(in: self)
                if self.bounds.contains(location) {
                    self.updateItemHoverState(event)
                  //  Swift.print("ObserverView location", location)
                }
            }
        }
    }
    
    internal var observerView: ObserverView? {
        get { getAssociatedValue(key: "NSCollectionView_observerView", object: self) }
        set {
            set(associatedValue: newValue, key: "NSCollectionView_observerView", object: self)
            if let newValue = newValue {
                
            }
        }
    }
}
