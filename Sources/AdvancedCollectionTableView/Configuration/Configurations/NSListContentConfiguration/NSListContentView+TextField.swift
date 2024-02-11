//
//  NSListContentView+TextField.swift
//
//
//  Created by Florian Zand on 28.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSListContentView {
    class ListTextField: NSTextField, NSTextFieldDelegate {
        var properties: TextProperties {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        var previousStringValue: String = ""
        var isEditing: Bool = false
        
        var tableView: NSTableView? {
            firstSuperview(for: NSTableView.self)
        }
        
        var listContentView: NSListContentView? {
            firstSuperview(for: NSListContentView.self)
        }

        func updateText(_ text: String?, _ attributedString: AttributedString?, _ placeholder: String?, _ attributedPlaceholder: AttributedString?) {
            var needsRowHeightUpdate = false
            if let attributedString = attributedString {
                attributedStringValue = NSAttributedString(attributedString)
                listContentView?.updateTableRowHeight()
            } else if let text = text {
                needsRowHeightUpdate = text != stringValue
                stringValue = text
            } else {
                needsRowHeightUpdate = stringValue != ""
                stringValue = ""
            }

            if let attributedPlaceholder = attributedPlaceholder {
                placeholderAttributedString = NSAttributedString(attributedPlaceholder)
                if stringValue == "" {
                    needsRowHeightUpdate = true
                }
            } else if let placeholder = placeholder {
                placeholderString = placeholder
                if stringValue == "" {
                    needsRowHeightUpdate = true
                }
            } else {
                placeholderString = ""
                if stringValue == "" {
                    needsRowHeightUpdate = true
                }
            }
            isHidden = text == nil && attributedString == nil && placeholder == nil && attributedPlaceholder == nil
            // Swift.print("needsRowHeightUpdate", needsRowHeightUpdate, listContentView != nil)
            if needsRowHeightUpdate {
                //  listContentView?.updateTableRowHeight()
            }
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
            formatter = properties.numberFormatter
            adjustsFontSizeToFitWidth = properties.adjustsFontSizeToFitWidth
            minimumScaleFactor = properties.minimumScaleFactor
            allowsDefaultTighteningForTruncation = properties.allowsDefaultTighteningForTruncation
        }

        init(properties: TextProperties) {
            self.properties = properties
            super.init(frame: .zero)
            drawsBackground = false
            backgroundColor = nil
            isBordered = false
            delegate = self
            textLayout = .wraps
            truncatesLastVisibleLine = true
            update()
        }

        override func becomeFirstResponder() -> Bool {
            let canBecome = super.becomeFirstResponder()
            if isEditable, canBecome {
                listContentView?.isEditing = true
                previousStringValue = stringValue
            }
            return canBecome
        }

        override func layout() {
            super.layout()
            listContentView?.updateTableRowHeight()
        }

        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            intrinsicContentSize.width = NSView.noIntrinsicMetric
            let width = frame.size.width

            if let cellSize = cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: width, height: 10000)) {
                intrinsicContentSize.height = cellSize.height
            }

            if isEditing == false {
                return intrinsicContentSize
            }

            guard let fieldEditor = window?.fieldEditor(false, for: self) as? NSTextView else {
                return intrinsicContentSize
            }
            if let textContainer = fieldEditor.textContainer, let layoutManager = fieldEditor.layoutManager {
                layoutManager.ensureLayout(for: textContainer)
                let fieldEditorSize = layoutManager.usedRect(for: textContainer).size
                intrinsicContentSize.height = fieldEditorSize.height
            }
            return intrinsicContentSize
        }

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

        override func textDidChange(_: Notification) {
            invalidateIntrinsicContentSize()
        }

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

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
