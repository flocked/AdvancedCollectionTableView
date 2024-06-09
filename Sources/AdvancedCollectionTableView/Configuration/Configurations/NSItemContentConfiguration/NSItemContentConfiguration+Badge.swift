//
//  NSItemContentConfiguration+Badge.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

public extension NSItemContentConfiguration {
    /// Properties for a item badge.
    struct Badge: Hashable {
        /// The type of the badge.
        public enum BadgeType: Hashable {
            /// The badge is attached to the border of the item's content (image/view).
            case attachment
            /// The badge is displayed as overlay to the item's content (image/view) with a spacing to the content's edge.
            case overlay(spacing: CGFloat)

            /// The badge is displayed as overlay to the item's content (image/view) with a spacing of `3.0` to the content's edge.
            public static let overlay = BadgeType.overlay(spacing: 3.0)

            var spacing: CGFloat? {
                switch self {
                case let .overlay(spacing: spacing): return spacing
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
        
        /// The shape of the badge.
        public enum Shape: Hashable {
            /// A rounded badge with the specified corner radius.
            case roundedRect(radius: CGFloat)
            /// A circular badge.
            case circle
            
            /// A rounded badge with a corner radius of `6.0`.
            public static let roundedRect = Shape.roundedRect(radius: 6.0)
            
        }

        /// The text of the badge.
        public var text: String?
        
        /// An attributed variant of the text.
        public var attributedText: AttributedString?

        /// The image of the badge.
        public var image: NSImage?

        /// The view of the badge. **Currently not working.**
        public var view: NSView?

        /// Properties for configuring the text.
        public var textProperties: TextProperties = .init()

        /// Properties for configuring the image.
        public var imageProperties: ImageProperties = .init()

        /// The background color of the badge.
        public var backgroundColor: NSColor? = .controlAccentColor {
            didSet { updateResolvedColors() }
        }

        /// The color transformer for resolving the background color.
        public var backgroundColorTransform: ColorTransformer? {
            didSet { updateResolvedColors() }
        }

        /// Generates the resolved background color, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
               
        /**
         The visual effect of the badge.

         If the badge has a visual effect, the background color is ignored.
         */
        public var visualEffect: VisualEffectConfiguration? {
            didSet { updateResolvedColors() }
        }

        /// The border width of the badge.
        public var borderWidth: CGFloat = 0.0

        /// The border color of the badge.
        public var borderColor: NSColor? {
            didSet { updateResolvedColors() }
        }

        /// The color transformer of the border color.
        public var borderColorTransform: ColorTransformer? {
            didSet { updateResolvedColors() }
        }

        /// Generates the resolved border color, using the border color and border color transformer.
        public func resolvedBorderColor() -> NSColor? {
            if let borderColor = borderColor {
                return borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }

        /// The shadow of the badge.
        public var shadow: ShadowConfiguration = .none()

        /// The margins between the text and the edges of the badge.
        public var margins = NSDirectionalEdgeInsets(width: 8, height: 4)

        /// The maximum width of the badge. If the text is larger than the width, it will be truncated.
        public var maxWidth: CGFloat?

        /// The padding between the image and text.
        public var imageToTextPadding: CGFloat = 2.0
        
        /// The shape of the badge.
        public var shape: Shape = .roundedRect

        /// The type of the badge.
        public var type: BadgeType = .attachment

        /// The position of the badge.
        public var position: Position = .topRight
        
        /**
         The tooltip of the text. If set to "", the text is automatically used.

         It only gets called, if `isEditable` is true.
         */
        public var toolTip: String? = nil
        
        /// Creates a badge.
        public init() {}

        /// A text badge.
        public static func textBadge(_ text: String, textStyle: NSFont.TextStyle = .body, textColor: NSColor = .white, color: NSColor? = .controlAccentColor, shape: Shape = .roundedRect, type: BadgeType, position: Position = .topRight) -> Badge {
            var badge = Badge()
            badge.text = text
            badge.textProperties.font = .systemFont(textStyle)
            badge.textProperties.textColor = textColor
            badge.backgroundColor = color
            badge.shape = shape
            badge.type = type
            badge.position = position
            if shape == .circle {
                badge.margins = .init(5)
            }
            return badge
        }
        
        /// A badge displaying a view.
        public static func viewBadge(_ view: NSView, color: NSColor? = .controlAccentColor, shape: Shape = .roundedRect, type: BadgeType, position: Position = .topRight) -> Badge {
            var badge = Badge()
            badge.view = view
            badge.backgroundColor = color
            badge.shape = shape
            badge.type = type
            badge.position = position
            if shape == .circle {
                badge.margins = .init(5)
            }
            return badge
        }
        
        /// A symbol image badge.
        public static func symbolImageBadge(_ symbolName: String, text: String? = nil, size: NSFont.TextStyle = .body, color: NSColor = .white, backgroundColor: NSColor? = .controlAccentColor, shape: Shape = .roundedRect, type: BadgeType, position: Position = .topRight) -> Badge {
            var badge = Badge()
            badge.text = text
            badge.image = NSImage(systemSymbolName: symbolName)
            badge.textProperties.font = .systemFont(size)
            badge.textProperties.textColor = color
            badge.imageProperties.symbolConfiguration = .font(size)
            badge.imageProperties.tintColor = color
            badge.imageProperties.scaling = .none
            badge.backgroundColor = backgroundColor
            badge.shape = shape
            badge.type = type
            badge.position = position
            if shape == .circle {
                badge.margins = .init(5)
            }
            return badge
        }
        
        /// An image badge.
        public static func imageBadge(_ image: NSImage, text: String? = nil, textStyle: NSFont.TextStyle = .body, color: NSColor? = .controlAccentColor, shape: Shape = .roundedRect, type: BadgeType, position: Position = .topRight) -> Badge {
            var badge = Badge()
            badge.image = image
            badge.text = text
            badge.textProperties.font = .systemFont(textStyle)
            badge.backgroundColor = color
            badge.shape = shape
            badge.type = type
            badge.position = position
            if shape == .circle {
                badge.margins = .init(5)
            }
            return badge
        }

        var isVisible: Bool {
            text != nil || attributedText != nil || image != nil || view != nil
        }

        var _resolvedBorderColor: NSColor?
        var _resolvedBackgroundColor: NSColor? = .controlAccentColor
        mutating func updateResolvedColors() {
            _resolvedBorderColor = resolvedBorderColor()
            if visualEffect == nil {
                _resolvedBackgroundColor = resolvedBackgroundColor()
            } else {
                _resolvedBackgroundColor = nil
            }
        }
    }
}

public extension NSItemContentConfiguration.Badge {
    /// Properties that affect the text of a badge.
    struct TextProperties: Hashable {
        /// The font of the text.
        public var font: NSFont = .systemFont(ofSize: 7)

        /// The border color of the badge.
        public var textColor: NSColor = .white {
            didSet { updateResolvedColors() }
        }

        /// The color transformer of the border color.
        public var textColorTransform: ColorTransformer? {
            didSet { updateResolvedColors() }
        }

        /// Generates the resolved border color,, using the border color and border color transformer.
        public func resolvedTextColor() -> NSColor {
            textColorTransform?(textColor) ?? textColor
        }

        init() {}

        var _resolvedTextColor: NSColor = .white
        mutating func updateResolvedColors() {
            _resolvedTextColor = resolvedTextColor()
        }
    }

    /// Properties that affect the image of a badge.
    struct ImageProperties: Hashable {
        /// The position of the badge image.
        public enum Position: Int, Hashable {
            /// The image is leading the text.
            case leading
            /// The image is trailing the text.
            case trailing
        }
        
        /// The image scaling.
        public enum Scaling: Int, Hashable {
            /// The image is resized to fit the bounds rectangle, preserving the aspect of the image. If the image does not completely fill the bounds rectangle, the image is centered in the partial axis.
            case scaleToFit
            /// The image is resized to completely fill the bounds rectangle, while still preserving the aspect of the image.
            case scaleToFill
            /// The image is resized to fit the entire bounds rectangle.
            case resize
            /// The image isn't resized.
            case none
            
            var swiftUI: SwiftUI.Image.ImageScaling {
                return .init(rawValue: rawValue)!
            }
        }

        /// The symbol configuration of the image.
        public var symbolConfiguration: ImageSymbolConfiguration?
        
        /**
         The maximum size for the image.
         
         The default value is `0`. A width or height of `0` means that the system doesn’t constrain the size for that dimension.
         
         If the image exceeds this size on either dimension, the system reduces the size proportionately, maintaining the aspect ratio.
         */
        public var maxSize: CGSize = .zero
                
        /// The image scaling.
        public var scaling: Scaling = .scaleToFit

        /// The position of the image.
        public var position: Position = .leading

        /// The tint color for an image that is a template or symbol image.
        public var tintColor: NSColor? {
            didSet { updateResolvedColors() }
        }

        /// The color transformer for resolving the image tint color.
        public var tintColorTransform: ColorTransformer? {
            didSet { updateResolvedColors() }
        }

        /// Generates the resolved tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = tintColor {
                return tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }

        var _resolvedTintColor: NSColor?
        mutating func updateResolvedColors() {
            _resolvedTintColor = symbolConfiguration?.resolvedPrimaryColor() ?? resolvedTintColor()
        }
        
        var maxWidth: CGFloat? {
            maxSize.width == 0 ? nil : maxSize.width
        }

        var maxHeight: CGFloat? {
            maxSize.height == 0 ? nil : maxSize.height
        }
    }
}
