//
//  NSItemContentView+TextField.swift
//
//
//  Created by Florian Zand on 24.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSItemContentView {
    class ItemTextField: NSTextField, NSTextFieldDelegate {
        var properties: ContentConfiguration.Text {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        func updateText(_ text: String?, _ attributedText: AttributedString?) {
            if let attributedText = attributedText {
                self.isHidden = false
                self.attributedStringValue = NSAttributedString(attributedText)
            } else if let text = text {
                self.stringValue = text
                self.isHidden = false
            } else {
                self.stringValue = ""
                self.isHidden = true
            }
        }
        
        func update() {
            self.maximumNumberOfLines = properties.numberOfLines
            self.textColor = properties.resolvedColor()
            self.lineBreakMode = properties.lineBreakMode
            self.font = properties.font
            self.alignment = properties.alignment
            self.isSelectable = properties.isSelectable
            self.isEditable = properties.isEditable
        }
        
        init(properties: ContentConfiguration.Text) {
            self.properties = properties
            super.init(frame: .zero)
            self.delegate = self
            self.textLayout = .wraps
            self.drawsBackground = false
            self.backgroundColor = nil
            self.isBordered = false
            self.truncatesLastVisibleLine = true
            self.update()
        }
        
        var nointrinsicWidth = true
        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            if nointrinsicWidth {
                intrinsicContentSize.width = NSView.noIntrinsicMetric
            }
            return intrinsicContentSize
        }
        
        internal var collectionViewItem: NSCollectionViewItem? {
            (self.firstSuperview(where: { $0.parentController is NSCollectionViewItem })?.parentController as? NSCollectionViewItem)
        }
        
        override public func becomeFirstResponder() -> Bool {
            let canBecome = super.becomeFirstResponder()
            if isEditable && canBecome {
                collectionViewItem?.isEditing = true
            }
            return canBecome
        }
        
        public override func textDidBeginEditing(_ notification: Notification) {
            super.textDidBeginEditing(notification)
            collectionViewItem?.isEditing = true
        }
        
        public override func textDidEndEditing(_ notification: Notification) {
            super.textDidEndEditing(notification)
            self.previousStringValue = self.stringValue
            collectionViewItem?.isEditing = false
            self.properties.onEditEnd?(self.stringValue)
        }
        
        internal var previousStringValue: String = ""
        public func control(_: NSControl, textView _: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if self.properties.stringValidation?(self.stringValue) ?? true {
                    self.window?.makeFirstResponder(nil)
                    return true
                } else {
                    NSSound.beep()
                }
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                self.stringValue = self.previousStringValue
                self.window?.makeFirstResponder(nil)
                return true
            }
            return false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
