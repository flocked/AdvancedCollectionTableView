//
//  NSListContentConfiguration+Badge.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

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
        
        /// The alignment of the badge.
        public enum Alignment {
            /// The badge is aligned to the center of the list item.
            case center
            /// The badge is aligned to the first baseline of the list item.
            case firstBaseline
            
            var alignment: NSLayoutConstraint.Attribute {
                self == .firstBaseline ? .firstBaseline : .centerY
            }
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

        /// Properties for configuring the image.
        public var imageProperties: ImageProperties = .init()

        /// The font of the text.
        public var font: NSFont = .systemFont(ofSize: 7)

        /// The color of the badge text and symbol/template image.
        public var color: NSColor = .white

        /// The color transformer of the border color.
        public var colorTransformer: ColorTransformer?

        /// Generates the resolved border color,, using the border color and border color transformer.
        public func resolvedColor() -> NSColor {
            colorTransformer?(color) ?? color
        }

        /// The background color of the badge.
        public var backgroundColor: NSColor? = .controlAccentColor

        /// The color transformer for resolving the background color.
        public var backgroundColorTransformer: ColorTransformer?

        /// Generates the resolved background color, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransformer?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        /// The border of the badge.
        public var border: BorderConfiguration = .none()

        /// The shadow of the badge.
        public var shadow: ShadowConfiguration = .none()

        /// The margins between the text/image and the edges of the badge.
        public var margins = NSDirectionalEdgeInsets(width: 4, height: 2)

        /// The maximum width of the badge. If the text is larger than the width, it will be truncated.
        public var maxWidth: CGFloat?

        /// The position of the badge.
        public var position: Position = .trailing
        
        /// The alignment of the badge.
        public var alignment: Alignment = .center
        
        /// The shape of the badge.
        public var shape: Shape = .roundedRect

        /// The padding between the image and text.
        public var imageToTextPadding: CGFloat = 2.0
        
        /// The tooltip of the text. If set to "", the text is automatically used.
        public var toolTip: String? = nil

        /// Creates a badge.
        public init() { }

        /**
         A badge displaying a text.

         - Parameters:
            - text: The text of the badge.
            - font: The font of the text. The default value is `body`.
            - color: The color of the text. The default value is `white`.
            - backgroundColor: The background color of the badge. The default value is `controlAccentColor`.
         */
        public static func text(_ text: String, font: NSFont = .body, color: NSColor = .white, backgroundColor: NSColor? = .controlAccentColor) -> Badge {
            var badge = Badge()
            badge.text = text
            badge.font = font
            badge.color = color
            badge.backgroundColor = backgroundColor
            return badge
        }

        /**
         A badge displaying an image.

         - Parameters:
            - image: The image of the badge.
            - backgroundColor: The background color of the badge. The default value is `controlAccentColor`.
         */
        public static func image(_ image: NSImage, backgroundColor: NSColor? = .controlAccentColor) -> Badge {
            var badge = Badge()
            badge.image = image
            badge.backgroundColor = backgroundColor
            return badge
        }

        /**
         A badge displaying a symbol image.

         - Parameters:
            - symbolName: The name of the symbol image.
            - textStyle: The text style for the symbol image. The default value is `caption1`.
            - color: The color of the symbol image. The default value is `white`.
            - backgroundColor: The background color of the badge. The default value is `controlAccentColor`.
         */
        public static func symbolImage(_ symbolName: String, textStyle: NSFont.TextStyle = .caption1, color: NSColor = .white, backgroundColor: NSColor? = .controlAccentColor) -> Badge? {
            guard let image = NSImage(systemSymbolName: symbolName) else { return nil }
            var badge = Badge()
            badge.image = image
            badge.color = color
            badge.imageProperties.symbolConfiguration = .font(textStyle)
            badge.backgroundColor = backgroundColor
            return badge
        }
    }
}

public extension NSListContentConfiguration.Badge {
    /// Properties that affect the image of a badge.
    struct ImageProperties: Hashable {
        /// The position of the badge image.
        public enum Position: Int, Hashable {
            /// The image is leading.
            case leading
            /// The image is trailing.
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

        /// The image scaling.
        public var scaling: Scaling = .scaleToFit

        /// The tint color for an image that is a template or symbol image.
        public var tintColor: NSColor?

        /// The color transformer for resolving the image tint color.
        public var tintColorTransformer: ColorTransformer?

        /// Generates the resolved tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = tintColor {
                return tintColorTransformer?(tintColor) ?? tintColor
            }
            return nil
        }
        
        /// The position of the image.
        public var position: Position = .leading
        
        /// The maximum width of the image.
        public var maxWidth: CGFloat?

        /// The maximum height of the image.
        public var maxHeight: CGFloat?
    }
}
