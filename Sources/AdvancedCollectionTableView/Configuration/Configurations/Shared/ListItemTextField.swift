//
//  NSItemContentView+TextField.swift
//
//
//  Created by Florian Zand on 24.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

class ListItemTextField: NSTextField, NSTextFieldDelegate {
    var properties: TextProperties! {
        didSet {
            guard oldValue != properties else { return }
            update()
        }
    }
        
    var previousStringValue: String = ""
    var editingString: String = ""
    let noIntrinsicWidth = true
    
    var editingContentView: EdiitingContentView? {
        firstSuperview(where: { $0 is EdiitingContentView }) as? EdiitingContentView
    }
    
    var tableCollectionView: NSView? {
        guard let editingContentView = editingContentView else { return nil }
        return editingContentView is NSListContentView ? firstSuperview(for: NSTableView.self) : firstSuperview(for: NSCollectionView.self)
    }

    func updateText(_ text: String?, _ attributedString: AttributedString?, _ placeholder: String? = nil, _ attributedPlaceholder: AttributedString? = nil) {
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
        toolTip = properties.toolTip == "" ? stringValue != "" ? stringValue : nil : properties.toolTip
        isHidden = text == nil && attributedString == nil && placeholder == nil && attributedPlaceholder == nil
        invalidateIntrinsicContentSize()
    }

    func update() {
        configurate(using: properties)
        invalidateIntrinsicContentSize()
        if isFirstResponder, !properties.isEditable || !properties.isSelectable {
            isEditing = false
        }
    }

    var textBounds: CGRect {
        guard let cell = cell else { return .zero }
        let rect = cell.drawingRect(forBounds: bounds)
        let cellSize = cell.cellSize(forBounds: rect)
        switch alignment {
        case .center: return CGRect(CGPoint((bounds.width/2.0)-(cellSize.width/2.0), (bounds.height/2.0)-(cellSize.height/2.0)), cellSize)
        case .right: return CGRect(CGPoint(bounds.width-cellSize.width, bounds.height-cellSize.height), cellSize)
        default: return CGRect(.zero, cellSize)
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        truncatesLastVisibleLine = true
        delegate = self
    }
    
    static var textField = WidthTextField.wrapping().truncatesLastVisibleLine(true)
    override var intrinsicContentSize: NSSize {
        var intrinsicContentSize = super.intrinsicContentSize
        if preferredMaxLayoutWidth != 0 {
            Self.textField.properties = properties
            Self.textField.maximumNumberOfLines = isEditing ? 0 : Self.textField.maximumNumberOfLines
            Self.textField.preferredMaxLayoutWidth = preferredMaxLayoutWidth
            Self.textField.attributedStringValue = attributedStringValue
            intrinsicContentSize.width = NSView.noIntrinsicMetric
            intrinsicContentSize.height = Self.textField.intrinsicContentSize.height
        } else if noIntrinsicWidth {
            intrinsicContentSize.width = NSView.noIntrinsicMetric
        }
        return intrinsicContentSize
    }
    
    override public func becomeFirstResponder() -> Bool {
        let canBecome = super.becomeFirstResponder()
        if isEditable, isSelectable, canBecome {
            isEditing = true
        }
        return canBecome
    }

    var isEditing = false {
        didSet {
            guard oldValue != isEditing else { return }
            previousStringValue = isEditing ? stringValue : ""
            editingString = previousStringValue
            focusRingType = isEditing ? .none : .default
            editingContentView?.isEditing = isEditing
        }
    }
    override public func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        isEditing = true
    }

    override public func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        isEditing = false
        properties.onEditEnd?(stringValue)
    }
    
    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        if properties.stringValidation?(stringValue) == false {
            stringValue = editingString
        }
        editingString = stringValue
        invalidateIntrinsicContentSize()
    }

    public func control(_: NSControl, textView _: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            if properties.editingActionOnEnterKeyDown == .endEditing {
                if properties.stringValidation?(stringValue) ?? true {
                    window?.makeFirstResponder(tableCollectionView)
                    return true
                } else {
                    NSSound.beep()
                }
            }
        } else if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            if properties.editingActionOnEscapeKeyDown == .endEditingAndReset {
                stringValue = previousStringValue
                window?.makeFirstResponder(tableCollectionView)
                return true
            } else if properties.editingActionOnEscapeKeyDown == .endEditing {
                if properties.stringValidation?(stringValue) ?? true {
                    window?.makeFirstResponder(tableCollectionView)
                    return true
                } else {
                    NSSound.beep()
                }
            }
        }
        return false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class WidthTextField: NSTextField {
        var properties: TextProperties! {
            didSet {
                guard oldValue != properties else { return }
                properties.isSelectable = false
                configurate(using: properties)
            }
        }
    }
}
