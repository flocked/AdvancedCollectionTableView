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
    /// Properties for configuring the text of an item.
    struct TextProperties {
        /// Constants that specify text alignment.
        public enum Alignment: Hashable {
            /// Text is leading-aligned.
            case leading
            /// Text is center-aligned.
            case center
            /// Text is trailing-aligned.
            case trailing
            
            internal var nsTextAlignment: NSTextAlignment {
                switch self {
                    case .leading: return .left
                    case .trailing: return .right
                    case .center: return .center
                }
            }
            
            internal var swiftuiMultiline: SwiftUI.TextAlignment {
                switch self {
                    case .leading: return .leading
                    case .trailing: return .trailing
                    case .center: return .center
                }
            }
            
            internal var swiftui: SwiftUI.Alignment {
                switch self {
                    case .leading: return .leading
                    case .trailing: return .trailing
                    case .center: return .center
                }
            }
        }
        
        /// The font of the text.
        public var font: NSFont = .body
        internal var swiftuiFont: Font? = nil
        
        /// The line limit of the text. If nil, no line limit applies.
        public var numberOfLines: Int? = 1
        
        /// The alignment of the text.
        public var alignment: Alignment = .center
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
        public var textColorTansform: NSConfigurationColorTransformer? = nil {
            didSet { updateResolvedTextColor() } }
        
        /// Generates the resolved text color for the specified text color, using the color and color transformer.
        public func resolvedTextColor() -> NSColor {
            textColorTansform?(textColor) ?? textColor
        }
        
        public init(font: NSFont = .body, numberOfLines: Int? = nil, alignment: Alignment = .center, textColor: NSColor = .labelColor, textColorTansform: NSConfigurationColorTransformer? = nil, isSelectable: Bool = false, isEditable: Bool = false, onEditEnd: ((String) -> ())? = nil) {
            self.font = font
            self.swiftuiFont = font.swiftUI
            self.numberOfLines = numberOfLines
            self.alignment = alignment
            self.isSelectable = isSelectable
            self.isEditable = isEditable
            self.onEditEnd = onEditEnd
            self.textColor = textColor
            self.textColorTansform = textColorTansform
            self.updateResolvedTextColor()
        }
        
        internal var _resolvedTextColor: NSColor = .labelColor
        internal mutating func updateResolvedTextColor() {
            _resolvedTextColor = resolvedTextColor()
        }
        
        /// Configurates the weight of the font.
        public func weight(_ weight: NSFont.Weight) -> Self {
            var properties = self
            properties.font = properties.font.weight(weight)
            properties.swiftuiFont = properties.swiftuiFont?.weight(weight.swiftUI)
            return properties
        }
        
        /**
         Specifies a system font to use, along with the size and weight.
         
         - Parameters size: The size of the font.
         - Parameters weight: The weight of the font.
         */
        public static func systemFont(size: CGFloat, weight: NSFont.Weight? = nil) -> TextProperties  {
            var properties = TextProperties()
            properties.font = .system(size: size, weight: weight ?? .regular)
            properties.swiftuiFont = .system(size: size, weight: weight?.swiftUI ?? .regular)
            return properties
        }
        
        @available(macOS 13.0, *)
        /**
         Specifies a system font to use, along with the size, weight, and any design parameters you want applied to the text.
         
         - Parameters size: The size of the font.
         - Parameters weight: The weight of the font.
         - Parameters design: The design of the font.
         */
        public static func system(size: CGFloat, design: NSFontDescriptor.SystemDesign, weight: NSFont.Weight? = nil) -> TextProperties  {
            var properties = TextProperties()
            properties.font = .system(size: size, weight: weight ?? .regular, design: design)
            properties.swiftuiFont = .system(size: size, weight: weight?.swiftUI, design: design.swiftUI)
            return properties
        }
            
        /**
         Specifies a font to use, along with the style and weight.
         
         - Parameters style: The style of the font.
         - Parameters weight: The weight of the font.
         */
        public static func system(_ style: NSFont.TextStyle = .body, weight: NSFont.Weight? = nil) -> TextProperties {
            var properties = TextProperties()
            properties.font = .system(style).weight(weight ?? .regular)
            properties.swiftuiFont = .system(style.swiftUI).weight(weight?.swiftUI ?? .regular)
            return properties
        }
        
        @available(macOS 13.0, *)
        /**
         Specifies a system font to use, along with the size, weight, and any design parameters you want applied to the text.
         
         - Parameters style: The style of the font.
         - Parameters weight: The weight of the font.
         - Parameters design: The design of the font.
         */
        public static func system(_ style: NSFont.TextStyle = .body, design: NSFontDescriptor.SystemDesign, weight: NSFont.Weight? = nil) -> TextProperties {
            var properties = TextProperties()
            properties.font = .system(style, design: design).weight(weight ?? .regular)
            properties.swiftuiFont = .system(style.swiftUI, design: design.swiftUI, weight: weight?.swiftUI)
            return properties
        }
        
        /// TextProperties with a font for bodies.
        public static var body: Self = .system(.body)
        /// TextProperties with a font for callouts.
        public static var callout: Self = .system(.callout)
        /// TextProperties with a font for captions.
        public static var caption1: Self = .system(.caption1)
        /// TextProperties with a font for alternate captions.
        public static var caption2: Self = .system(.caption2)
        /// TextProperties with a font for footnotes.
        public static var footnote: Self = .system(.footnote)
        /// TextProperties with a font for headlines.
        public static var headline: Self = .system(.headline)
        /// TextProperties with a font for subheadlines.
        public static var subheadline: Self = .system(.subheadline)
        /// TextProperties with a font for large titles.
        public static var largeTitle: Self = .system(.largeTitle)
        /// TextProperties with a font for titles.
        public static var title1: Self = .system(.title1)
        /// TextProperties with a font for alternate titles.
        public static var title2: Self = .system(.title2)
        /// TextProperties with a font for alternate titles.
        public static var title3: Self = .system(.title3)

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
        hasher.combine(isEditable)
        hasher.combine(isSelectable)
        hasher.combine(textColor)
        hasher.combine(textColorTansform)
    }
}
