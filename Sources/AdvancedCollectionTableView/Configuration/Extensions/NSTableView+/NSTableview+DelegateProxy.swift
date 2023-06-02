//
//  File.swift
//  
//
//  Created by Florian Zand on 02.06.23.
//

import AppKit
import FZSwiftUtils
import InterposeKit

internal extension NSTableView {
    var delegateObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSTableView_delegateObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSTableView_delegateObserver", object: self)
        }
    }
    
    var observingDelegate: ObjectIdentifier? {
        get { getAssociatedValue(key: "NSTableView_observingDelegate", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSTableView_observingDelegate", object: self)
        }
    }
    
    var selectionDelegate: SelectionDelegate? {
        get { getAssociatedValue(key: "NSTableView_selectionDelegate", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSTableView_selectionDelegate", object: self)
        }
    }
    
    func addSelectionDelegate() {
        Swift.print("addSelectionDelegate")
        let delegate = SelectionDelegate()
        self.selectionDelegate = delegate
        self.delegate = delegate
        self.swizzleDelegate(delegate)
    }
    
    func setupDelegateObserver() {
        Swift.print("setupDelegateObserver")
        if delegateObserver == nil {
            if let delegate = self.delegate {
                self.swizzleDelegate(delegate)
            } else {
                self.addSelectionDelegate()
            }
            delegateObserver = self.observeChange(\.delegate) { [weak self ] object, old, delegate in
                guard let self = self else { return }
                if let delegate = delegate  {
                    if delegate is SelectionDelegate == false {
                        self.selectionDelegate = nil
                    }
                    let identifier = ObjectIdentifier(delegate)
                    if self.observingDelegate != identifier {
                        self.swizzleDelegate(delegate)
                        self.observingDelegate = identifier
                    }
                } else {
                    self.observingDelegate = nil
                    self.addSelectionDelegate()
                }
                
            }
        }
    }
    
    func swizzledSelectionDidChange() {
        Swift.print("swizzled selectionChanged")
    }
    
    func swizzleDelegate(_ delegate: NSTableViewDelegate, shouldSwizzle: Bool = true) {
        Swift.print("swizzleDelegate start")
        guard let delegate = delegate as? (NSObject & NSTableViewDelegate) else { return }
        Swift.print("swizzleDelegate true")
        /*
        do {
            let hooks = [
                try  delegate.hook(#selector(NSTableViewDelegate.tableViewSelectionDidChange(_:)),
                               methodSignature: (@convention(c) (AnyObject, Selector, Notification) -> ()).self,
                               hookSignature: (@convention(block) (AnyObject, Notification) -> ()).self) {
                                   store in { (object, notification) in
                                       Swift.print("swizzled selectionChanged")
                                       store.original(object, store.selector, notification)
                                   }
                               },
            ]
            try hooks.forEach({ _ = try (shouldSwizzle) ? $0.apply() : $0.revert() })
        } catch {
            Swift.print(error)
        }
         */
    }
}

internal extension NSTableView {
    class SelectionDelegate: NSObject, NSTableViewDelegate {
        func tableViewSelectionDidChange(_ notification: Notification) {
            Swift.print("SelectionDelegate selectionChanged")
        }
    }
}
