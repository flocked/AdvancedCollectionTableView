//
//  NSListContentView+TextField.swift
//
//
//  Created by Florian Zand on 28.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSListContentView {
    class ListTextField: NSTextField, NSTextFieldDelegate {
        var properties: TextConfiguration {
            didSet {
                if oldValue != properties {
                    update()
                }
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
            formatter = properties.numberFormatter
            font = properties.font
            alignment = properties.alignment
            isSelectable = properties.isSelectable
            isEditable = properties.isEditable
            
            drawsBackground = false
            backgroundColor = nil
            isBordered = false
        }
        
        init(properties: TextConfiguration) {
            self.properties = properties
            super.init(frame: .zero)
            drawsBackground = false
            backgroundColor = nil
            delegate = self
            textLayout = .wraps
            truncatesLastVisibleLine = true
            update()
        }
        
        override func becomeFirstResponder() -> Bool {
            let canBecome = super.becomeFirstResponder()
            if isEditable && canBecome {
                listContentView?.isEditing = true
                previousStringValue = stringValue
            }
            return canBecome
        }
        
        var listContentView: NSListContentView? {
            firstSuperview(for: NSListContentView.self)
        }
        
        override func layout() {
            super.layout()
            listContentView?.updateRowHeight()
        }
        
        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            intrinsicContentSize.width = NSView.noIntrinsicMetric
            let width = frame.size.width
            
            if let cellSize = cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: width, height: 10000)) {
                //    Swift.debugPrint(cellSize)
                intrinsicContentSize.height = cellSize.height
            }
            
            if isEditing == false {
                return intrinsicContentSize
            }
            
            guard let fieldEditor = window?.fieldEditor(false, for: self) as? NSTextView else {
                return intrinsicContentSize }
            if let textContainer = fieldEditor.textContainer, let layoutManager = fieldEditor.layoutManager {
                layoutManager.ensureLayout(for: textContainer)
                let fieldEditorSize = layoutManager.usedRect(for: textContainer).size
                intrinsicContentSize.height = fieldEditorSize.height
            }
            return intrinsicContentSize
        }
        
        internal var lastContentSize = NSSize() { didSet {
            lastContentSize = NSSize(width: ceil(lastContentSize.width), height: ceil(lastContentSize.height))
        }}
        
        internal func stringValueSize() -> CGSize {
            let stringSize = attributedStringValue.size()
            return CGSize(width: stringSize.width, height: super.intrinsicContentSize.height)
        }
        
        var isEditing: Bool = false
        override func textDidBeginEditing(_ notification: Notification) {
            super.textDidBeginEditing(notification)
            isEditing = true
            previousStringValue = stringValue
            listContentView?.isEditing = true
        }
        
        override func textDidEndEditing(_ notification: Notification) {
            super.textDidEndEditing(notification)
            isEditing = false
            listContentView?.isEditing = false
            properties.onEditEnd?(stringValue)
        }
        
        override func textDidChange(_ notification: Notification) {
            invalidateIntrinsicContentSize()
        }
        
        internal var tableView: NSTableView? {
            firstSuperview(for: NSTableView.self)
        }
        
        var previousStringValue: String = ""
        func control(_: NSControl, textView _: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if properties.stringValidation?(stringValue) ?? true {
                    window?.makeFirstResponder(tableView)
                    return true
                } else {
                    NSSound.beep()
                }
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                stringValue = previousStringValue
                window?.makeFirstResponder(tableView)
                return true
            }
            return false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
