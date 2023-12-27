//
//  NSListContentConfiguration+Badge.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

public extension NSListContentConfiguration {
    /// Properties for a list badge.
    struct Badge: Hashable {
        /// The position of the badge.
        public enum Position {
            /// The badge is vertically centered to the text, or if it's `nil` to the secondary text.
            case leading
            /// The badge is vertically centered.
            case trailing
        }
        
        /// The text of the badge..
        public var text: String? = nil
        
        /// An attributed variant of the text.
        public var attributedText: AttributedString? = nil
        
        /// The image of the badge..
        public var image: NSImage? = nil
        
        /// Properties for configuring the image.
        public var imageProperties: ImageProperties = ImageProperties()
        
        /// The font of the text.
        public var font: NSFont = .systemFont(ofSize: 7)
        
        /// The color of the badge text and symbol/template image.
        public var color: NSColor = .white {
            didSet { updateResolvedColors() } }
        
        /// The color transformer of the border color.
        public var colorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// Generates the resolved border color,, using the border color and border color transformer.
        public func resolvedColor() -> NSColor {
            colorTransform?(color) ?? color
        }
        
        /// The background color of the badge.
        public var backgroundColor: NSColor? = .controlAccentColor {
            didSet { updateResolvedColors() } }
        
        /// The color transformer for resolving the background color.
        public var backgroundColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// Generates the resolved background color, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        /// The border width of the badge.
        public var borderWidth: CGFloat = 0.0
        
        /// The border color of the badge.
        public var borderColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        
        /// The color transformer of the border color.
        public var borderColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// Generates the resolved border color, using the border color and border color transformer.
        public func resolvedBorderColor() -> NSColor? {
            if let borderColor = borderColor {
                return borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }
        
        /// The corner radius of the badge.
        public var cornerRadius: CGFloat = 6.0
        
        /// The shadow of the badge.
        public var shadow: ShadowConfiguration = .none()
        
        /// The margins between the text and the edges of the badge.
        public var margins = NSDirectionalEdgeInsets(width: 4, height: 2)
        
        /// The maximum width of the badge. If the text is larger than the width, it will be truncated.
        public var maxWidth: CGFloat? = nil
        
        /// The position of the badge.
        public var position: Position = .trailing
        
        
        /// The padding between the image and text.
        public var imageToTextPadding: CGFloat = 2.0
        
        /// Creates a badge.
        public init() {
            
        }
        
        /// A text badge.
        public static func text(_ text: String, font: NSFont = .body, color: NSColor = .controlAccentColor) -> Badge {
            var badge = Badge()
            badge.text = text
            badge.font = font
            badge.backgroundColor = color
            return badge
        }
        
        /// A badge displaying an image.
        public static func image(_ image: NSImage, color: NSColor = .controlAccentColor) -> Badge {
            var badge = Badge()
            badge.image = image
            badge.backgroundColor = color
            return badge
        }
        
        /// A badge displaying a symbol image.
        public static func symbolImage(_ symbolName: String, textStyle: NSFont.TextStyle = .caption1, color: NSColor = .controlAccentColor) -> Badge? {
            guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
            var badge = Badge()
            badge.image = image
            badge.imageProperties.symbolConfiguration = .font(textStyle)
            badge.backgroundColor = color
            return badge
        }
        
        internal var isVisible: Bool {
            text != nil || attributedText != nil || image != nil
        }
        
        internal var resolvedImageTintColor: NSColor {
            imageProperties._resolvedTintColor ?? color
        }
        
        internal var _resolvedBorderColor: NSColor? = nil
        internal var _resolvedBackgroundColor: NSColor? = .controlAccentColor
        internal var _resolvedColor: NSColor = .white
        internal mutating func updateResolvedColors() {
            _resolvedBorderColor = resolvedBorderColor()
            _resolvedBackgroundColor = resolvedBackgroundColor()
            _resolvedColor = resolvedColor()
        }
    }
}

public extension NSListContentConfiguration.Badge {
    /// Properties that affect the image of a badge.
    struct ImageProperties: Hashable {
        
        /// The position of the badge image.
        enum Position: Int, Hashable {
            /// The image is leading.
            case leading
            /// The image is trailing.
            case trailing
        }
        
        /// The symbol configuration of the image.
        var symbolConfiguration: ImageSymbolConfiguration? = nil
        
        /// The maximum width of the image.
        var maxWidth: CGFloat? = nil
        
        /// The maximum height of the image.
        var maxHeight: CGFloat? = nil
        
        /// The image scaling.
        public var scaling: NSImageScaling = .scaleNone
        
        var position: Position = .leading
        
        /// The tint color for an image that is a template or symbol image.
        public var tintColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        
        /// The color transformer for resolving the image tint color.
        public var tintColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// Generates the resolved tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = tintColor {
                return tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }
        
        internal var _resolvedTintColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            _resolvedTintColor = symbolConfiguration?.resolvedPrimaryColor() ?? resolvedTintColor()
        }
    }
}
