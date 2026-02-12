//
//  NSListContentView+Accessory+Image.swift
//
//
//  Created by Florian Zand on 13.08.23.
//

import AppKit
import FZUIKit
import SwiftUI

extension NSListContentConfiguration.AccessoryProperties {
    /// Properties that affect the image of the content.
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

            /// The image is resized to fit the specified relative maximum width and height.
            case maxiumSizeRelative(width: CGFloat?, height: CGFloat?)

            /// The image isn't resized.
            case none
        }

        /// The scaling of the image.
        public enum Scaling: Hashable {
            /// The image is resized to fit the bounds rectangle, preserving the aspect of the image. If the image does not completely fill the bounds rectangle, the image is centered in the partial axis.
            case fit
            //   case fill
            /// The image is resized to fit the entire bounds rectangle.
            case resize
            /// The image isn't resized.
            case none

            var imageScaling: NSImageScaling {
                switch self {
                case .fit: return .scaleProportionallyUpOrDown
                //   case .fill: return .scaleProportionallyUpOrDown
                case .resize: return .scaleAxesIndependently
                case .none: return .scaleNone
                }
            }

            var contentsGravity: CALayerContentsGravity {
                switch self {
                case .fit: return .resizeAspect
                //    case .fill: return .resizeAspectFill
                case .resize: return .resize
                case .none: return .center
                }
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

        //   var reservedLayoutSize: CGSize = CGSize(0, 0)
        //    static let standardDimension: CGFloat = -CGFloat.greatestFiniteMagnitude

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
        public var scaling: Scaling = .fit

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
extension Image {
    @ViewBuilder
    func configurate(using properties: NSListContentConfiguration.AccessoryProperties.ImageProperties) -> some View {
        if properties.scaling.isResizable {
            resizable()
                .foregroundColor(properties.tintColor?.swiftUI)
                .symbolConfiguration(tintColor: properties.tintColor?.swiftUI, configuration: properties.symbolConfiguration)
                .aspectRatio(contentMode: properties.scaling.contentMode ?? .fit)
                .frame(maxWidth: properties.maxWidth, maxHeight: properties.maxHeight)
        } else {
            foregroundColor(properties.tintColor?.swiftUI)
                .frame(maxWidth: properties.maxWidth, maxHeight: properties.maxHeight)
        }
    }
}
*/
