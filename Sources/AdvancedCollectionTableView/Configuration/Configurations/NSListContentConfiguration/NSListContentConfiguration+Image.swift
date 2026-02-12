//
//  NSListContentConfiguration+Image.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

public extension NSListContentConfiguration {
    /// Properties that affect the image.
    struct ImageProperties: Hashable {
        /// The sizing of the image.
        public enum Sizing: Hashable {
            /// The image is resized to fit the height of the text, or secondary text.
            case firstTextHeight

            /// The image is resized to fit the height of both the text and secondary text.
            case totalTextHeight

            /// The image is resized to the specified size.
            case size(CGSize)

            /// The image is resized to fit the specified maximum width and height.
            case maxiumSize(width: CGFloat?, height: CGFloat?)

            /// The image is resized to fit the specified relative size.
            case relative(CGFloat)

            /// The image isn't resized.
            case none
        }

        /// The scaling of the image.
        public enum ImageScaling: Int, Hashable {
            /// The image is resized to fit the bounds rectangle, preserving the aspect of the image. If the image does not completely fill the bounds rectangle, the image is centered in the partial axis.
            case scaleToFit
            /// The image is resized to completely fill the bounds rectangle, while still preserving the aspect of the image.
            case scaleToFill
            /// The image is resized to fit the entire bounds rectangle.
            case resize
            /// The image isn't resized.
            case none

            var scaling: NSImageScaling {
                switch self {
                case .scaleToFit: return .scaleProportionallyUpOrDown
                case .scaleToFill: return .scaleProportionallyUpOrDown
                case .resize: return .scaleAxesIndependently
                case .none: return .scaleNone
                }
            }
            
            var imageScaling: ImageView.ImageScaling {
                ImageView.ImageScaling(rawValue: rawValue)!
            }
        }

        /// The position of the image.
        public enum Position: Hashable {
            /// The image is positioned leading the text.
            case leading(HorizontalPosition)

            /// The image is positioned trailing the text.
            case trailing(HorizontalPosition)

            /// The image is positioned below the text.
            case bottom(VerticalPosition)

            /// The image is positioned above the text.
            case top(VerticalPosition)

            /// The horizontal position of the image.
            public enum HorizontalPosition {
                /// The image is positioned at the top edge.
                case top
                /// The image is positioned at the center.
                case center
                /// The image is positioned at the bottom edge.
                case bottom
                /// The image is positioned at the first baseline.
                case firstBaseline

                var alignment: NSLayoutConstraint.Attribute {
                    switch self {
                    case .top: return .centerY
                    case .center: return .centerY
                    case .bottom: return .centerY
                    case .firstBaseline: return .firstBaseline
                    }
                }
            }

            /// The vertical position of the image.
            public enum VerticalPosition {
                /// The image is positioned at the leading edge.
                case leading
                /// The image is positioned at the center.
                case center
                /// The image is positioned at the trailing edge.
                case trailing

                var alignment: NSLayoutConstraint.Attribute {
                    switch self {
                    case .leading: return .leading
                    case .center: return .centerX
                    case .trailing: return .trailing
                    }
                }
            }

            var alignment: NSLayoutConstraint.Attribute {
                switch self {
                case let .top(vertical), let .bottom(vertical):
                    return vertical.alignment
                case let .leading(horizonal), let .trailing(horizonal):
                    return horizonal.alignment
                }
            }

            var imageIsLeading: Bool {
                switch self {
                case .leading, .top: return true
                default: return false
                }
            }

            var orientation: NSUserInterfaceLayoutOrientation {
                switch self {
                case .leading, .trailing:
                    return .horizontal
                case .top, .bottom:
                    return .vertical
                }
            }
        }

        /**
         The layout size that the system reserves for the image, and then centers the image within.
         
         Use this property to ensure:
         - Consistent horizontal alignment for images across adjacent content views, even when the images vary in width.
         - Consistent height for content views, even when the images vary in height.
         
         The reserved layout size only affects the amount of space for the image, and its positioning within that space. It doesn’t affect the size of the image.
         
         The default value is `zero`. A width or height of zero means that the system uses the default behavior for that dimension:
         - The system centers symbol images inside a predefined reserved layout size that scales with the content size category.
         - Nonsymbol images use a reserved layout size equal to the actual size of the displayed image.
         */
        public var reservedLayoutSize: CGSize = CGSize(0, 0)
        
        /**
         The system standard layout dimension for reserved layout size.
         
         Setting the ``reservedLayoutSize`` width or height to this constant results in using the system standard value for a symbol image for that dimension, even when the image is not a symbol image.
         */
        public static let standardDimension: CGFloat = -CGFloat.greatestFiniteMagnitude

        /// The tint color for an image that is a template or symbol image.
        public var tintColor: NSColor?

        /// The color transformer for resolving the image tint color.
        public var tintColorTransformer: ColorTransformer?

        /// Generates the resolved tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedTintColor() -> NSColor? {
            tintColorTransformer?(tintColor) ?? tintColor
        }

        /// The background color.
        public var backgroundColor: NSColor?

        /// The color transformer for resolving the background color.
        public var backgroundColorTransformer: ColorTransformer?

        /// Generates the resolved background color for the specified background color, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSColor? {
            backgroundColorTransformer?(backgroundColor) ?? backgroundColor
        }
        
        /// The corner radius of the image.
        public var cornerRadius: CGFloat = 0.0

        /// The border of the image.
        public var border: BorderConfiguration = .none
        
        /// The border transformer for resolving the border.
        public var borderTransformer: BorderTransformer? = nil
        
        /// Generates the resolved border, using the border and border transformer.
        public func resolvedBorder() -> BorderConfiguration {
            borderTransformer?(border) ?? border
        }

        /// The shadow of the image.
        public var shadow: ShadowConfiguration = .none
        
        /// The shadow transformer for resolving the shadow.
        public var shadowTransformer: ShadowTransformer? = nil
        
        /// Generates the resolved shadow, using the shadow and shadow transformer.
        public func resolvedShadow() -> ShadowConfiguration {
            shadowTransformer?(shadow) ?? shadow
        }

        /// The symbol configuration of the image.
        public var symbolConfiguration: ImageSymbolConfiguration? = .font(.body)

        /// The image scaling.
        public var scaling: ImageScaling = .scaleToFit

        /// The sizing option for the image.
        public var sizing: Sizing = .totalTextHeight

        /// The position of the image.
        public var position: Position = .leading(.firstBaseline)
        
        /// The text for the tooltip of the image.
        public var toolTip: String? = nil

        init() {}
    }
}

/*
 struct Layout: Hashable {
     enum VerticalSizing: Hashable {
         /// The image isn't resized.
         case imageSize
         /// The image is resized to the list item's height.
         case totalHeight
         /// The image is resized to the text height.
         case textHeight
         /// The image is resized to the secondary text height.
         case secondaryTextHeight
         /// The image is resized to fit the specified width.
         case width(CGFloat)
         /// The image is resized to fit the specified height.
         case height(CGFloat)
         /// The image is resized to the specified size.
         case size(CGSize)
         /// The image is resized to fit the maximum size.
         case maxSize(CGSize)
     }
     
     enum HorizontalSizing: Hashable {
         /// The image isn't resized.
         case imageSize
         /// The image is resized to the list item's width.
         case totalWidth
         /// The image is resized to fit the specified width.
         case width(CGFloat)
         /// The image is resized to fit the specified height.
         case height(CGFloat)
         /// The image is resized to the specified size.
         case size(CGSize)
         /// The image is resized to fit the maximum size.
         case maxSize(CGSize)
     }
     
     enum VerticalPosition: Hashable {
         /// The image is positioned at the first baseline.
         case firstBaseline
         /// The image is positioned at the center the text.
         case text
         /// The image is positioned at the center the secondary text.
         case secondaryText
         /// The image is positioned at the top edge.
         case top
         /// The image is positioned at the vertical center.
         case center
         /// The image is positioned at the bottom edge.
         case bottom
     }
     
     enum HorizontalPosition: Hashable {
         /// The image is positioned at the leading edge.
         case leading
         /// The image is positioned at the horizontal center.
         case center
         /// The image is positioned at the trailing edge.
         case traiing
     }
     
     enum _Position: Hashable {
         case leading(VerticalPosition, VerticalSizing)
         case trailing(VerticalPosition, VerticalSizing)
         case bottom(HorizontalPosition, HorizontalSizing)
         case top(HorizontalPosition, HorizontalSizing)
     }
     
     func sdsd() {
        // Layout.
     }
     
     let positon: _Position
     
     init(_ positon: _Position) {
         self.positon = positon
     }
     
     public static func leading(at positon: VerticalPosition = .firstBaseline, size: VerticalSizing = .imageSize) -> Layout {
         Layout(.leading(positon, size))
     }
     
     public static func trailing(at positon: VerticalPosition = .firstBaseline, size: VerticalSizing = .imageSize) -> Layout {
         Layout(.trailing(positon, size))
     }
     
     public static func bottom(at positon: HorizontalPosition = .leading, size: HorizontalSizing = .totalWidth) -> Layout {
         Layout(.bottom(positon, size))
     }
     
     public static func top(at positon: HorizontalPosition = .leading, size: HorizontalSizing = .totalWidth) -> Layout {
         Layout(.top(positon, size))
     }
 }
 */
