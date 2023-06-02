//
//  File.swift
//  
//
//  Created by Florian Zand on 02.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

public extension NSItemContentConfiguration {
    struct TextProperties: Hashable {
        public enum TextTransform: Hashable {
            case none
            case capitalized
            case lowercase
            case uppercase
        }
        
        public var font: NSFont = .system(.body)
        public var numberOfLines: Int? = 1
        public var alignment: NSTextAlignment = .left
        public var lineBreakMode: NSLineBreakMode = .byWordWrapping
        public var textTransform: TextTransform = .none
        
       //  The style of bezel the text field displays.
        public var bezelStyle: NSTextField.BezelStyle? = nil
        
        /**
         A Boolean value that determines whether the user can select the content of the text field.
         
         If true, the text field becomes selectable but not editable. Use isEditable to make the text field selectable and editable. If false, the text is neither editable nor selectable.
         */
        public var isSelectable: Bool = false
        /**
         A Boolean value that controls whether the user can edit the value in the text field.

         If true, the user can select and edit text. If false, the user can’t edit text, and the ability to select the text field’s content is dependent on the value of isSelectable.
         For example, if an NSTextField object is selectable but uneditable, becomes editable for a time, and then becomes uneditable again, it remains selectable. To ensure that text is neither editable nor selectable, use isSelectable to disable text selection.         */
        public var isEditable: Bool = false
        
        /**
         The color of the text field’s content.
         */
        public var textColor: NSColor = .labelColor
        public var textColorTansform: NSConfigurationColorTransformer? = nil
        
        // The color of the background the text field’s item draws behind the text.
        public var backgroundColor: NSColor? = nil
        public var backgroundColorTansform: NSConfigurationColorTransformer? = nil

        public func resolvedTextColor() -> NSColor {
            return self.textColorTansform?(textColor) ?? textColor
        }
        
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.textColorTansform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        public static func systemFont(_ fontSize: CGFloat, weight: NSFont.Weight = .regular) -> TextProperties  {
            var property = TextProperties()
            property.font = .systemFont(ofSize: fontSize, weight: weight)
            return property
        }
        
        public static func textStyle(_ style: NSFont.TextStyle = .body, weight: NSFont.Weight? = nil) -> TextProperties {
            var property = TextProperties()
            if let weight = weight {
                property.font = .system(style).weight(weight)
            } else {
                property.font = .system(.body)
            }
            return property
        }
    }
}
