//
//  NSTextField+Swizzle.swift
//
//
//  Created by Florian Zand on 18.10.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSTextField {
    static var didSwizzleEditState: Bool {
        get { getAssociatedValue(key: "didSwizzleEditState", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "didSwizzleEditState", object: self)
        }
    }
    
    
    @objc func swizzled_textDidBeginEditing(_ notification: Notification) {
        tableRowView?.isEditing = true
        self.swizzled_textDidBeginEditing(notification)
    }
    
    @objc func swizzled_textDidEndEditing(_ notification: Notification) {
        tableRowView?.isEditing = false
        self.swizzled_textDidBeginEditing(notification)
    }
    
    var tableRowView: NSTableRowView? {
        self.firstSuperview(for: NSTableRowView.self)
    }
    
    static func swizzleEditState() {
        guard didSwizzleEditState == false else { return }
        didSwizzleEditState = true
        do {
            try Swizzle(NSTextField.self) {
                #selector(NSTextField.textDidBeginEditing(_:)) <-> #selector(swizzled_textDidBeginEditing(_:))
                #selector(NSTextField.textDidEndEditing(_:)) <-> #selector(swizzled_textDidEndEditing(_:))
                
            }
        } catch {
            Swift.debugPrint(error)
        }
    }
}
