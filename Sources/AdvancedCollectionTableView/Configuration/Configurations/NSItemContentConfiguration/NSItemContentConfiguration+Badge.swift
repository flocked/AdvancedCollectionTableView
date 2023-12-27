//
//  NSItemContentConfiguration+Badge.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

public extension NSItemContentConfiguration {
    /// Properties for a badge.
    struct Badge: Hashable {
        /// The type of the badge.
        public enum BadgeType: Hashable {
            /// The badge is attached to the border of the item's content (image/view).
            case attachment
            /// The badge is displayed as overlay to the item's content (image/view) with a spacing to the content's edge.
            case overlay(spacing: CGFloat)
            
            /// The badge is displayed as overlay to the item's content (image/view) with a spacing of `4.0` to the content's edge.
            static let overlay = BadgeType.overlay(spacing: 4.0)
            
            internal var spacing: CGFloat? {
                switch self {
                case .overlay(spacing: let spacing): return spacing
                case .attachment: return nil
                }
            }
        }
        
        /// The position of the badge.
        public enum Position: Int, Hashable, CaseIterable {
            /// The badge is positioned at the top left.
            case topLeft
            /// The badge is positioned at the top.
            case top
            /// The badge is positioned at the top right.
            case topRight
            /// The badge is positioned at the center left.
            case centerLeft
            /// The badge is positioned at the center.
            case center
            /// The badge is positioned at the center right.
            case centerRight
            /// The badge is positioned at the bottom left.
            case bottomLeft
            /// The badge is positioned at the bottom.
            case bottom
            /// The badge is positioned at the bottom right.
            case bottomRight
        }
        
        /// The text of the badge..
        public var text: String? = nil
        /// An attributed variant of the text.
        public var attributedText: AttributedString? = nil
        
        /// The image of the badge..
        public var image: NSImage? = nil
        
        /// The view of the badge.
        public var view: NSView? = nil
        
        /// Properties for configuring the text.
        public var textProperties: TextProperties = TextProperties()
        
        /// Properties for configuring the image.
        public var imageProperties: ImageProperties = ImageProperties()
        
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
        
        /**
         The visual effect of the badge.
         
         If the badge has a visual effect, it's background color will be ignored.
         */
        public var visualEffect: VisualEffectConfiguration? = nil {
            didSet { updateResolvedColors() } }
        
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
        public var margins = NSDirectionalEdgeInsets(width: 12, height: 4)
        
        /// The maximum width of the badge. If the text is larger than the width, it will be truncated.
        public var maxWidth: CGFloat? = nil
        
        /// The padding between the image and text.
        public var imageToTextPadding: CGFloat = 2.0
        
        /// The type of the badge.
        public var type: BadgeType = .attachment
        
        /// The position of the badge.
        public var position: Position = .topRight
        
        /// The spacing of the badge.
        public var spacing: CGFloat = 3.0
        
        /// Creates a badge.
        public init() {
            
        }
        
        /// A text badge.
        public static func text(_ text: String, font: NSFont = .caption, color: NSColor?, type: BadgeType, position: Position = .topRight) -> Badge {
            var badge = Badge()
            badge.text = text
            badge.textProperties.font = font
            badge.backgroundColor = color
            badge.type = type
            badge.position = position
            return badge
        }
        
        /// A badge displaying an image.
        public static func image(_ image: NSImage, color: NSColor?, type: BadgeType, position: Position = .topRight) -> Badge {
            var badge = Badge()
            badge.image = image
            badge.backgroundColor = color
            badge.type = type
            badge.position = position
            return badge
        }
        
        /// A badge displaying an image.
        public static func view(_ view: NSView, color: NSColor?, type: BadgeType, position: Position = .topRight) -> Badge {
            var badge = Badge()
            badge.view = view
            badge.backgroundColor = color
            badge.type = type
            badge.position = position
            return badge
        }
        
        /// A badge displaying a symbol image.
        public static func symbolImage(_ symbolName: String, textStyle: NSFont.TextStyle = .caption1, color: NSColor?, type: BadgeType, position: Position = .topRight) -> Badge? {
            guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
            var badge = Badge()
            badge.image = image
            badge.imageProperties.symbolConfiguration = .font(textStyle)
            badge.backgroundColor = color
            badge.type = type
            badge.position = position
            return badge
        }
        
        internal var isVisible: Bool {
            text != nil || attributedText != nil || image != nil || view != nil
        }
        
        internal var _resolvedBorderColor: NSColor? = nil
        internal var _resolvedBackgroundColor: NSColor? = .controlAccentColor
        internal mutating func updateResolvedColors() {
            _resolvedBorderColor = resolvedBorderColor()
            if visualEffect == nil {
                _resolvedBackgroundColor = resolvedBackgroundColor()
            } else {
                _resolvedBackgroundColor = nil
            }
            /*
             if visualEffect?.appearance?.isDark == true, _resolvedTextColor == .white {
             _resolvedTextColor = .labelColor
             } else if visualEffect?.appearance?.isLight == true, _resolvedTextColor == .labelColor {
             
             }
             */
        }
    }
}

public extension NSItemContentConfiguration.Badge {
    /// Properties that affect the text of a badge.
    struct TextProperties: Hashable {
        
        /// The font of the text.
        public var font: NSFont = .systemFont(ofSize: 7)
        
        /// The border color of the badge..
        public var textColor: NSColor = .white {
            didSet { updateResolvedColors() } }
        
        /// The color transformer of the border color.
        public var textColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// Generates the resolved border color,, using the border color and border color transformer.
        public func resolvedTextColor() -> NSColor {
            textColorTransform?(textColor) ?? textColor
        }
        
        internal init() {
            
        }
        
        internal var _resolvedTextColor: NSColor = .white
        internal mutating func updateResolvedColors() {
            _resolvedTextColor = resolvedTextColor()
        }
    }
    
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
        
        /// The position of the image.
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
