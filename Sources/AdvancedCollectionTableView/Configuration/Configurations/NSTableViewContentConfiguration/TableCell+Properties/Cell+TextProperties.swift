//
//  TextProperties.swift
//  
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

/// The content properties of an item configuraton.
public extension NSTableCellContentConfiguration {
    struct TextProperties: Hashable {
        /// Constants that specify text alignment.
        public enum Alignment: Hashable {
            /// Text is leading-aligned.
            case leading
            /// Text is center-aligned.
            case center
            /// Text is trailing-aligned.
            case trailing
                        
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
            
            internal var nsTextAlignment: NSTextAlignment {
                switch self {
                    case .leading: return .left
                    case .trailing: return .right
                    case .center: return .center
                }
            }
        }
        
        /// The font of the text.
        public var font: NSFont = .body
        
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
        
        /// The maximum number of lines.
        /**
         The maximum number of lines.
         
         The default value of 0 indicates no limit to the number of lines.
         */
        public var maxNumberOfLines: Int = 0
        /// The  text alignment.
        public var alignment: Alignment = .leading
        
        /// A Boolean value that determines whether the user can select the text.
        public var isSelectable: Bool = false
        /// A Boolean value that controls whether the user can edit the text.
        public var isEditable: Bool = false
        
        public static func primary() -> Self { TextProperties(maxNumberOfLines: 1) }
        public static func secondary() -> Self { TextProperties(font: .callout, textColor: .secondaryLabelColor) }
        
        public static func caption2() -> Self { TextProperties(font: .caption2) }
        public static func caption() -> Self { TextProperties(font: .caption) }
        public static func footnote() -> Self { TextProperties(font: .footnote) }
        public static func callout() -> Self { TextProperties(font: .callout) }
        public static func body() -> Self { TextProperties(font: .body) }
        public static func subheadline() -> Self { TextProperties(font: .subheadline) }
        public static func headline() -> Self { TextProperties(font: .headline) }
        public static func title() -> Self { TextProperties(font: .title) }
        public static func title2() -> Self { TextProperties(font: .title2) }
        public static func title3() -> Self { TextProperties(font: .title3) }
        public static func largeTitle() -> Self { TextProperties(font: .largeTitle) }
        
        internal var _resolvedTextColor: NSColor = .labelColor
        internal mutating func updateResolvedTextColor() {
            _resolvedTextColor = resolvedTextColor()
        }
        
    }
}
