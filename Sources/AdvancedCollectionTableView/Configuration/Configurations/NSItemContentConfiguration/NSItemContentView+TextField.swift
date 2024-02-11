//
//  NSItemContentView+TextField.swift
//
//
//  Created by Florian Zand on 24.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSItemContentView {
    class ItemTextField: NSTextField, NSTextFieldDelegate {
        var properties: TextProperties {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        var previousStringValue: String = ""

        var itemContentView: NSItemContentView? {
            firstSuperview(for: NSItemContentView.self)
        }

        func updateText(_ text: String?, _ attributedText: AttributedString?) {
            if let attributedText = attributedText {
                isHidden = false
                attributedStringValue = NSAttributedString(attributedText)
            } else if let text = text {
                stringValue = text
                isHidden = false
            } else {
                stringValue = ""
                isHidden = true
            }
        }

        func updateText(_ text: String?, _ attributedString: AttributedString?, _ placeholder: String?, _ attributedPlaceholder: AttributedString?) {
            if let attributedString = attributedString {
                attributedStringValue = NSAttributedString(attributedString)
            } else if let text = text {
                stringValue = text
            } else {
                stringValue = ""
            }

            if let attributedPlaceholder = attributedPlaceholder {
                placeholderAttributedString = NSAttributedString(attributedPlaceholder)
            } else if let placeholder = placeholder {
                placeholderString = placeholder
            } else {
                placeholderString = ""
            }
            isHidden = text == nil && attributedString == nil && placeholder == nil && attributedPlaceholder == nil
        }

        func update() {
            maximumNumberOfLines = properties.numberOfLines
            textColor = properties.resolvedColor()
            lineBreakMode = properties.lineBreakMode
            font = properties.font
            alignment = properties.alignment
            isSelectable = properties.isSelectable
            isEditable = properties.isEditable
            formatter = properties.numberFormatter
            adjustsFontSizeToFitWidth = properties.adjustsFontSizeToFitWidth
            minimumScaleFactor = properties.minimumScaleFactor
            allowsDefaultTighteningForTruncation = properties.allowsDefaultTighteningForTruncation
        }

        init(properties: TextProperties) {
            self.properties = properties
            super.init(frame: .zero)
            delegate = self
            textLayout = .wraps
            drawsBackground = false
            backgroundColor = nil
            isBordered = false
            truncatesLastVisibleLine = true
            update()
        }

        var nointrinsicWidth = true
        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            if nointrinsicWidth {
                intrinsicContentSize.width = NSView.noIntrinsicMetric
            }
            return intrinsicContentSize
        }

        override public func becomeFirstResponder() -> Bool {
            let canBecome = super.becomeFirstResponder()
            if isEditable, canBecome {
                itemContentView?.isEditing = true
                previousStringValue = stringValue
            }
            return canBecome
        }

        override public func textDidBeginEditing(_ notification: Notification) {
            super.textDidBeginEditing(notification)
            itemContentView?.isEditing = true
        }

        override public func textDidEndEditing(_ notification: Notification) {
            super.textDidEndEditing(notification)
            previousStringValue = stringValue
            itemContentView?.isEditing = false
            properties.onEditEnd?(stringValue)
        }
        
        override func textDidChange(_ notification: Notification) {
            super.textDidChange(notification)
            invalidateIntrinsicContentSize()
        }

        public func control(_: NSControl, textView _: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if properties.stringValidation?(stringValue) ?? true {
                    window?.makeFirstResponder(nil)
                    return true
                } else {
                    NSSound.beep()
                }
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                stringValue = previousStringValue
                window?.makeFirstResponder(nil)
                return true
            }
            return false
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
