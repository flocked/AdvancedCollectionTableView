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
    class CellTextField: NSTextField, NSTextFieldDelegate {
        var properties: ContentConfiguration.Text {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        func text(_ text: String?, attributedString: AttributedString?) {
            if let attributedString = attributedString {
                self.isHidden = false
                self.attributedStringValue = NSAttributedString(attributedString)
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
            
            self.drawsBackground = false
            self.backgroundColor = nil
            self.isBordered = false
        }
        
        init(properties: ContentConfiguration.Text) {
            self.properties = properties
            super.init(frame: .zero)
            self.drawsBackground = false
            self.backgroundColor = nil
            self.delegate = self
            self.textLayout = .wraps
            self.truncatesLastVisibleLine = true
            self.update()
        }
        
        override func becomeFirstResponder() -> Bool {
            let canBecome = super.becomeFirstResponder()
            if isEditable && canBecome {
                self.firstSuperview(for: NSTableCellView.self)?.isEditing = true
            }
            return canBecome
        }
              
        var tableCellContentView: NSListContentView? {
            self.firstSuperview(for: NSListContentView.self)
        }
        
        override func layout() {
            super.layout()
            tableCellContentView?.updateRowHeight()
        }
        
        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            intrinsicContentSize.width = NSView.noIntrinsicMetric
            let width = self.frame.size.width
                        
            if let cellSize = cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: width, height: 10000)) {
            //    Swift.print(cellSize)
                intrinsicContentSize.height = cellSize.height
            }
            
            if isEditing == false {
                return intrinsicContentSize
            }
            
            guard let fieldEditor = self.window?.fieldEditor(false, for: self) as? NSTextView else {
                return intrinsicContentSize }
            if let textContainer = fieldEditor.textContainer, let layoutManager = fieldEditor.layoutManager {
                layoutManager.ensureLayout(for: textContainer)
                let fieldEditorSize = layoutManager.usedRect(for: textContainer).size
                intrinsicContentSize.height = fieldEditorSize.height
            }
            return intrinsicContentSize
        }
        
        internal var lastContentSize = NSSize() { didSet {
            lastContentSize = NSSize(width: ceil(self.lastContentSize.width), height: ceil(self.lastContentSize.height))
        }}
        
        internal func stringValueSize() -> CGSize {
            let stringSize = self.attributedStringValue.size()
            return CGSize(width: stringSize.width, height: super.intrinsicContentSize.height)
        }
        
        var isEditing: Bool = false
        override func textDidBeginEditing(_ notification: Notification) {
            super.textDidBeginEditing(notification)
            self.isEditing = true
            self.previousStringValue = self.stringValue
            self.firstSuperview(for: NSTableCellView.self)?.isEditing = true
        }
        
        override func textDidEndEditing(_ notification: Notification) {
            super.textDidEndEditing(notification)
            self.isEditing = false
            self.firstSuperview(for: NSTableCellView.self)?.isEditing = false
            self.properties.onEditEnd?(self.stringValue)
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
                if self.properties.stringValidation?(self.stringValue) ?? true {
                    self.window?.makeFirstResponder(tableView)
                    return true
                } else {
                    NSSound.beep()
                }
            } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                self.stringValue = self.previousStringValue
                self.window?.makeFirstResponder(tableView)
                return true
            }
            return false
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
