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

public extension NSTableCellContentConfiguration {
    /// Properties that affect the cell content configuration’s text.
    struct TextProperties: Hashable {
        
        /// The font of the text.
        public var font: NSFont = .body
        
        /// The color of the text.
        public var color: NSColor = .labelColor {
            didSet { updateResolvedColor() } }
        /// The color transformer of the text color.
        public var colorTansform: NSConfigurationColorTransformer? = nil {
            didSet { updateResolvedColor() } }
        
        /// Generates the resolved text color for the specified text color, using the color and color transformer.
        public func resolvedColor() -> NSColor {
            colorTansform?(color) ?? color
        }
        
        /// The  text alignment.
        public var alignment: NSTextAlignment = .left
        
        
        /// The line break mode to use for the text.
        public var lineBreakMode: NSLineBreakMode = .byWordWrapping
        
        /**
         The maximum number of lines.
         
         The default value of 0 indicates no limit to the number of lines.
         */
        public var maxNumberOfLines: Int = 0
        
        /// A Boolean value that determines whether the user can select the text.
        public var isSelectable: Bool = false
        /// A Boolean value that controls whether the user can edit the text.
        public var isEditable: Bool = false
        
        /// A default configuration for a primary text.
        public static func primary() -> Self { TextProperties(maxNumberOfLines: 1) }
        /// A default configuration for a secondary text.
        public static func secondary() -> Self { TextProperties(font: .callout, color: .secondaryLabelColor) }
        
        /// A configuration with a font for captions.
        public static func caption2() -> Self { TextProperties(font: .caption2) }
        /// A configuration with a font for captions.
        public static func caption() -> Self { TextProperties(font: .caption) }
        /// A configuration with a font for footnotes.
        public static func footnote() -> Self { TextProperties(font: .footnote) }
        /// A configuration with a font for callouts.
        public static func callout() -> Self { TextProperties(font: .callout) }
        /// A configuration with a font for body.
        public static func body() -> Self { TextProperties(font: .body) }
        /// A configuration with a font for subheadlines.
        public static func subheadline() -> Self { TextProperties(font: .subheadline) }
        /// A configuration with a font for headlines.
        public static func headline() -> Self { TextProperties(font: .headline) }
        /// A configuration with a font for titles.
        public static func title() -> Self { TextProperties(font: .title) }
        /// A configuration with a font for titles.
        public static func title2() -> Self { TextProperties(font: .title2) }
        /// A configuration with a font for titles.
        public static func title3() -> Self { TextProperties(font: .title3) }
        /// A configuration with a font for large titles.
        public static func largeTitle() -> Self { TextProperties(font: .largeTitle) }
        
        internal var _resolvedColor: NSColor = .labelColor
        internal mutating func updateResolvedColor() {
            _resolvedColor = resolvedColor()
        }
        
    }
}
