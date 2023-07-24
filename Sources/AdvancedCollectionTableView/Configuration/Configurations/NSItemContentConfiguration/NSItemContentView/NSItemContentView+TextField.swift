//
//  File.swift
//  
//
//  Created by Florian Zand on 24.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSItemContentViewNS {
    class ItemTextField: NSTextField, NSTextFieldDelegate {
        var properties: ConfigurationProperties.Text {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        func text(_ text: String?, attributedText: AttributedString?) {
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
            self.maximumNumberOfLines = properties.maxNumberOfLines
            self.textColor = properties._resolvedTextColor
            self.lineBreakMode = properties.lineBreakMode
            self.font = properties.font
            self.alignment = properties.alignment
            self.isSelectable = properties.isSelectable
            self.isEditable = properties.isEditable

            self.drawsBackground = false
            self.backgroundColor = nil
            self.isBordered = false
        }
        
        init(properties: ConfigurationProperties.Text) {
            self.properties = properties
            super.init(frame: .zero)
            self.drawsBackground = false
            self.backgroundColor = nil
            self.delegate = self
            self.textLayout = .wraps
            self.update()
        }
        
        public override func textDidEndEditing(_ notification: Notification) {
            super.textDidEndEditing(notification)
            self.properties.onEditEnd?(self.stringValue)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
