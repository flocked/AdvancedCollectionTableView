//
//  NSItemContentConfiguration+Badge.swift
//
//
//  Created by Florian Zand on 02.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

public extension NSItemContentConfiguration {
    struct Badge: Hashable {
        
        /// Creates a badge configuration.
        public init() {

        }
        
        /// A badge configuration with the specified text and color.
        public static func text(_ text: String, color: NSColor = .controlAccentColor) -> Self {
            var badge = Self()
            badge.text = text
            badge.badgeColor = color
            return badge
        }
        
        /// A badge configuration with the specified image and color.
        public static func image(_ image: NSImage, color: NSColor = .controlAccentColor) -> Self {
            var badge = Self()
            badge.image = image
            badge.badgeColor = color
            return badge
        }
        
        public enum Position: Hashable {
            case topLeft
            case topRight
            case bottomLeft
            case bottomRight
        }
        
        /// The primary text.
        public var text: String? = nil
        /// An attributed variant of the primary text.
        public var attributedText: AttributedString? = nil
        /// The image to display.
        public var image: NSImage? = nil
        
        /// The color of the badge.
        public var badgeColor: NSColor = .controlAccentColor {
            didSet { updateResolvedColors() } }
        
        /// The color transformer of the badge color.
        public var badgeColorTansform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// Generates the resolved badge color, using the badge color and color transformer.
        public func resolvedBadgeColor() -> NSColor {
            badgeColorTansform?(badgeColor) ?? badgeColor
        }
        
        /// The border width of the image.
        public var borderWidth: CGFloat = 0.0
        /// The border color of the image.
        public var borderColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        /// The color transformer of the border color.
        public var borderColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        /// Generates the resolved border color for the specified border color, using the border color and border color transformer.
        public func resolvedBorderColor() -> NSColor? {
            if let borderColor = self.borderColor {
                return self.borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }
        
        /// The corner radius of the image.
        public var cornerRadius: CGFloat = 4.0
        /// The shadow properties of the image.
        public var shadowProperties: ConfigurationProperties.Shadow = .none()
        
        internal var _resolvedBadgeColor: NSColor = .controlAccentColor
        internal var _resolvedBorderColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            _resolvedBadgeColor = resolvedBadgeColor()
        }
        
        /// Properties for configuring the primary text.
        public var textProperties: ConfigurationProperties.Text = {
            var properties: ConfigurationProperties.Text = .body
            properties.textColor = .white
            return properties
        }()
        
        /// Properties for configuring the image.
        public var imageProperties: ImageProperties = ImageProperties()
        
        /// The position of the badge.
        var position: Position  = .topRight
        
        var textToImageSpacing: CGFloat = 4.0

        /// The margins between the badge content and the edges of the badge view.
        public var padding: NSDirectionalEdgeInsets = .init(4.0)
        
        internal var hasBadge: Bool {
            self.text != nil || self.attributedText != nil || self.image != nil
        }
    }
}

public extension NSItemContentConfiguration.Badge {
    /// Properties that affect the image of the badge.
    struct ImageProperties: Hashable {
        
        /// The position of the image.
        public enum ImagePosition: Hashable {
            /// The image is positioned leading the text.
            case leading
            /// The image is positioned trailing the text.
            case trailing
            /// The image is positioned below the text.
            case bottom
            /// The image is positioned above the text.
            case top
            internal var imageIsLeading: Bool {
                self == .leading || self == .top
            }
            
            internal var orientation: NSUserInterfaceLayoutOrientation {
                switch self {
                case .leading, .trailing:
                    return .horizontal
                case .top, .bottom:
                    return .vertical
                }
            }
        }
        
        /// The tint color for an image that is a template or symbol image.
        public var tintColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        /// The color transformer for resolving the image tint color.
        public var tintColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        /// Generates the resolved tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = self.tintColor {
                return self.tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }
        
        /// The background color.
        public var backgroundColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        /// The color transformer for resolving the background color.
        public var backgroundColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        /// Generates the resolved background color for the specified background color, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        /// The border width of the image.
        public var borderWidth: CGFloat = 0.0
        /// The border color of the image.
        public var borderColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        /// The color transformer of the border color.
        public var borderColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        /// Generates the resolved border color for the specified border color, using the border color and border color transformer.
        public func resolvedBorderColor() -> NSColor? {
            if let borderColor = self.borderColor {
                return self.borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }
        
        /// The corner radius of the image.
        public var cornerRadius: CGFloat = 0.0
        /// The shadow properties of the image.
        public var shadowProperties: ConfigurationProperties.Shadow = .none()
        
        /// The symbol configuration of the image.
        public var symbolConfiguration: ConfigurationProperties.SymbolConfiguration? = .font(.body)
        
        /// The image scaling.
        public var scaling: NSImageScaling = .scaleNone
        
        /// The maximum width of the image.
        public var maxWidth: CGFloat? = nil
        /// The maximum height of the image.
        public var maxHeight: CGFloat? = nil
        
        /// The position of the image.
        public var position: ImagePosition = .leading
        
        internal init() {
            
        }
        
        internal var _resolvedTintColor: NSColor? = nil
        internal var _resolvedBorderColor: NSColor? = nil
        internal var _resolvedBackgroundColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            //  symbolConfiguration?.updateResolvedColors()
            _resolvedTintColor = symbolConfiguration?._resolvedPrimaryColor ?? resolvedTintColor()
            _resolvedBorderColor = resolvedBorderColor()
            _resolvedBackgroundColor = resolvedBackgroundColor()
        }
    }
}
