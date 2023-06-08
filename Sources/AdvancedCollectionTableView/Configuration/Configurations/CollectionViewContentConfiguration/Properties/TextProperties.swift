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
    struct TextProperties {
        public enum TextTransform: Hashable {
            case none
            case capitalized
            case lowercase
            case uppercase
        }
        
        public var font: NSFont = .body
        internal var swiftuiFont: Font? = nil
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
         */
        public var isEditable: Bool = false
        public var onEditEnd: ((String)->())? = nil
        
        /// The color of the text.
        public var textColor: NSColor = .labelColor
        /// The color transformer of the text color.
        public var textColorTansform: NSConfigurationColorTransformer? = nil
        
        public func weight(_ weight: NSFont.Weight) -> Self {
            var properties = self
            properties.font = properties.font.weight(weight)
            properties.swiftuiFont = properties.swiftuiFont?.weight(weight.swiftUI)
            return properties
        }
        
        public static func systemFont(size: CGFloat, weight: NSFont.Weight? = nil) -> TextProperties  {
            var properties = TextProperties()
            properties.font = .system(size: size, weight: weight ?? .regular)
            properties.swiftuiFont = .system(size: size, weight: weight?.swiftUI ?? .regular)
            return properties
        }
        
        @available(macOS 13.0, *)
        public static func systemFont(size: CGFloat, design: NSFontDescriptor.SystemDesign, weight: NSFont.Weight? = nil) -> TextProperties  {
            var properties = TextProperties()
            properties.font = .system(size: size, weight: weight ?? .regular, design: design)
            properties.swiftuiFont = .system(size: size, weight: weight?.swiftUI, design: design.swiftUI)
            return properties
        }
            
        public static var body: Self = .system(.body)
        public static var callout: Self = .system(.callout)
        public static var caption1: Self = .system(.caption1)
        public static var caption2: Self = .system(.caption2)
        public static var largeTitle: Self = .system(.largeTitle)
        public static var title1: Self = .system(.title1)
        public static var title2: Self = .system(.title2)
        public static var title3: Self = .system(.title3)
        public static var subheadline: Self = .system(.subheadline)
        public static var headline: Self = .system(.headline)


        public static func system(_ style: NSFont.TextStyle = .body, weight: NSFont.Weight? = nil) -> TextProperties {
            var properties = TextProperties()
            properties.font = .system(style).weight(weight ?? .regular)
            properties.swiftuiFont = .system(style.swiftUI).weight(weight?.swiftUI ?? .regular)
            return properties
        }
        
        @available(macOS 13.0, *)
        public static func system(_ style: NSFont.TextStyle = .body, design: NSFontDescriptor.SystemDesign, weight: NSFont.Weight? = nil) -> TextProperties {
            var properties = TextProperties()
            properties.font = .system(style, design: design).weight(weight ?? .regular)
            properties.swiftuiFont = .system(style.swiftUI, design: design.swiftUI, weight: weight?.swiftUI)
            return properties
        }
    }
}

extension NSItemContentConfiguration.TextProperties: Hashable {
    public static func == (lhs: NSItemContentConfiguration.TextProperties, rhs: NSItemContentConfiguration.TextProperties) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(font)
        hasher.combine(swiftuiFont)
        hasher.combine(numberOfLines)
        hasher.combine(alignment)
        hasher.combine(lineBreakMode)
        hasher.combine(textTransform)
        hasher.combine(bezelStyle)
        hasher.combine(lineBreakMode)
        hasher.combine(isEditable)
        hasher.combine(textColor)
        hasher.combine(textColorTansform)
        hasher.combine(lineBreakMode)

    }
}

internal extension String {
    func transform(using transform: NSItemContentConfiguration.TextProperties.TextTransform) -> String {
        switch transform {
        case .none:
            return self
        case .capitalized:
            return self.capitalized
        case .lowercase:
            return self.lowercased()
        case .uppercase:
            return self.uppercased()
        }
    }
}

internal extension NSAttributedString {
    func transform(using transform: NSItemContentConfiguration.TextProperties.TextTransform) -> String {
        switch transform {
        case .none:
            return self.string
        case .capitalized:
            return self.string.capitalized
        case .lowercase:
            return self.string.lowercased()
        case .uppercase:
            return self.string.uppercased()
        }
    }
}

extension AttributedString {
    func transform(using transform: NSItemContentConfiguration.TextProperties.TextTransform) -> String {
        switch transform {
        case .none:
           return String(self.characters[...])
        case .capitalized:
            return String(self.characters[...]).capitalized
        case .lowercase:
            return String(self.characters[...]).lowercased()
        case .uppercase:
            return String(self.characters[...]).uppercased()
        }
    }
}


