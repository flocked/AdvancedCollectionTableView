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

public extension ConfigurationProperties {
    /// Properties for configuring the text of an item.
    struct Text {
        /// The font of the text.
        public var font: NSFont = .body
        
        /// The line limit of the text, or 0 if no line limit applies.
        public var maxNumberOfLines: Int = 0
        
        /// The alignment of the text.
        public var alignment: NSTextAlignment = .left
        /**
         A Boolean value that determines whether the user can select the content of the text field.
         
         If true, the text field becomes selectable but not editable. Use ``isEditable`` to make the text field selectable and editable. If false, the text is neither editable nor selectable.
         */
        public var isSelectable: Bool = false
        /**
         A Boolean value that controls whether the user can edit the value in the text field.

         If true, the user can select and edit text. If false, the user can’t edit text, and the ability to select the text field’s content is dependent on the value of ``´isSelectable``.
         */
        public var isEditable: Bool = false
        /**
         The edit handler that gets called when editing of the text ended.
         
         It only gets called, if ``isEditable`` and ``isSelectable`` is true.
         */
        public var onEditEnd: ((String)->())? = nil
        
        /// The color of the text.
        public var textColor: NSColor = .labelColor {
            didSet { updateResolvedTextColor() } }
        
        /// The color transformer of the text color.
        public var textColorTansform: ColorTransformer? = nil {
            didSet { updateResolvedTextColor() } }
        
        /// Generates the resolved text color for the specified text color, using the color and color transformer.
        public func resolvedTextColor() -> NSColor {
            textColorTansform?(textColor) ?? textColor
        }
        
        internal var _resolvedTextColor: NSColor = .labelColor
        internal mutating func updateResolvedTextColor() {
            _resolvedTextColor = resolvedTextColor()
        }
        
        public init(font: NSFont = .body, maxNumberOfLines: Int = 0, alignment: NSTextAlignment = .left, textColor: NSColor = .labelColor, textColorTansform: ColorTransformer? = nil, isSelectable: Bool = false, isEditable: Bool = false, onEditEnd: ((String) -> ())? = nil) {
            self.font = font
            self.maxNumberOfLines = maxNumberOfLines
            self.alignment = alignment
            self.isSelectable = isSelectable
            self.isEditable = isEditable
            self.onEditEnd = onEditEnd
            self.textColor = textColor
            self.textColorTansform = textColorTansform
            self.updateResolvedTextColor()
        }

        /**
         Specifies a system font to use, along with the size, weight, and any design parameters you want applied to the text.
         
         - Parameters size: The size of the font.
         - Parameters weight: The weight of the font.
         - Parameters design: The design of the font.
         */
        public static func system(size: CGFloat, weight: NSFont.Weight = .regular, design: NSFontDescriptor.SystemDesign = .default) -> Text  {
            var properties = Text()
            properties.font = .system(size: size, weight: weight, design: design)
            return properties
        }
                    
        /**
         Specifies a system font to use, along with the size, weight, and any design parameters you want applied to the text.
         
         - Parameters style: The style of the font.
         - Parameters weight: The weight of the font.
         - Parameters design: The design of the font.
         */
        public static func system(_ style: NSFont.TextStyle = .body, weight: NSFont.Weight = .regular, design: NSFontDescriptor.SystemDesign = .default) -> Text {
            var properties = Text()
            properties.font = .system(style, design: design).weight(weight)
            return properties
        }
        
        /// A default configuration for a primary text.
        public static var primary: Self { Text(maxNumberOfLines: 1) }
        
        /// A default configuration for a secondary text.
        public static var secondary: Self { Text(font: .callout, textColor: .secondaryLabelColor) }
        
        /// A default configuration for a tertiary text.
        public static var tertiary: Self { Text(font: .callout, textColor: .tertiaryLabelColor) }

        /// Text configuration with a font for bodies.
        public static var body: Self = .system(.body)
        /// Text configuration with a font for callouts.
        public static var callout: Self = .system(.callout)
        /// Text configuration with a font for captions.
        public static var caption1: Self = .system(.caption1)
        /// Text configuration with a font for alternate captions.
        public static var caption2: Self = .system(.caption2)
        /// Text configuration with a font for footnotes.
        public static var footnote: Self = .system(.footnote)
        /// Text configuration with a font for headlines.
        public static var headline: Self = .system(.headline)
        /// Text configuration with a font for subheadlines.
        public static var subheadline: Self = .system(.subheadline)
        /// Text configuration with a font for large titles.
        public static var largeTitle: Self = .system(.largeTitle)
        /// Text configuration with a font for titles.
        public static var title1: Self = .system(.title1)
        /// Text configuration with a font for alternate titles.
        public static var title2: Self = .system(.title2)
        /// Text configuration with a font for alternate titles.
        public static var title3: Self = .system(.title3)

    }
}

extension ConfigurationProperties.Text: Hashable {
    public static func == (lhs: ConfigurationProperties.Text, rhs: ConfigurationProperties.Text) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(font)
        hasher.combine(maxNumberOfLines)
        hasher.combine(alignment)
        hasher.combine(isEditable)
        hasher.combine(isSelectable)
        hasher.combine(textColor)
        hasher.combine(textColorTansform)
    }
}
