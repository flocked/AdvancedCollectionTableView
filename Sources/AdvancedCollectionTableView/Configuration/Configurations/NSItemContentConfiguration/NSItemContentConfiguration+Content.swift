//
//  NSItemContentConfiguration+Content.swift
//
//
//  Created by Florian Zand on 07.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

public extension NSItemContentConfiguration {
    /// Properties that affect the content that displays the image and view.
    struct ContentProperties: Hashable {
        /// The corner radius of the content.
        public var cornerRadius: CGFloat = 10.0

        /// The maximum size of the content.
        public var maximumSize = ProposedSize()

        public struct ProposedSize: Hashable {
            /// The proposed width.
            public var width: CGFloat?
            /// The proposed height.
            public var height: CGFloat?
            /// The proposed Sizing mode. The default value is `absolute`.
            public var mode: Mode = .absolute

            /// Proposed Sizing mode.
            public enum Mode: Int, Hashable {
                /// The `width` and `height` is absolute.
                case absolute
                /// The `width` and `height` is relative.
                case relative
            }
        }

        /**
         The scaling of the content view.

         The default is `1.0`, which displays the content view at it's original scale. A larger value will display the content view at a larger, a smaller value at a smaller size.
         */
        public var scaleTransform: ScaleTransform = 1.0

        /// The background color.
        public var backgroundColor: NSColor? = .lightGray

        /// The color transformer for resolving the background color.
        public var backgroundColorTransformer: ColorTransformer?

        /// Generates the resolved background color for the specified background color, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransformer?(backgroundColor) ?? backgroundColor
            }
            return nil
        }

        /// The visual effect background of the content.
        public var visualEffect: VisualEffectConfiguration?
        
        /// The border of the content.
        public var border: BorderConfiguration = .none()
        
        /// The border transformer for resolving the border.
        public var borderTransformer: BorderTransformer? = nil
                
        /// Generates the resolved border, using the border and border transformer.
        public func resolvedBorder() -> BorderConfiguration {
            borderTransformer?(border) ?? border
        }
        
        var borderStateTransformer: BorderTransformer? = nil
        
        func _resolvedBorder() -> BorderConfiguration {
            let border = borderTransformer?(border) ?? border
            return borderStateTransformer?(border) ?? border
        }

        /// Properties for configuring the image.
        public var imageProperties: ImageProperties = .init()

        /// The shadow properties.
        public var shadow: ShadowConfiguration = .black()
        
        /// The shadow transformer for resolving the shadow.
        public var shadowTransformer: ShadowTransformer? = nil
        
        /// Generates the resolved shadow, using the shadow and shadow transformer.
        public func resolvedShadow() -> ShadowConfiguration {
            shadowTransformer?(shadow) ?? shadow
        }
        
        var shadowStateTransformer: ShadowTransformer? = nil
        
        func _resolvedShadow() -> ShadowConfiguration {
            let shadow = shadowTransformer?(shadow) ?? shadow
            return shadowStateTransformer?(shadow) ?? shadow
        }
        
        /// The text for the tooltip of the content.
        public var toolTip: String? = nil

        init() {}
    }
}

public extension NSItemContentConfiguration.ContentProperties {
    /// Properties that affect the image of the content.
    struct ImageProperties: Hashable {
        /// The scaling of the image.
        public enum ImageScaling {
            /// The image is resized to fit the bounds size, while still preserving the aspect ratio of the image.
            case fit
            /// The image is resized to completely fill the bounds rectangle, while still preserving the aspect ratio of the image. The image is centered in the axis it exceeds.
            case fill
            /// The image is resized to the entire bounds rectangle.
            case resize
            /// The image isn't resized.
            case none

            var gravity: CALayerContentsGravity {
                switch self {
                case .fit: return .resizeAspect
                case .fill: return .resizeAspectFill
                case .resize: return .resize
                case .none: return .center
                }
            }
            
            var scaling: ImageView.ImageScaling {
                switch self {
                case .fit: return .scaleToFit
                case .fill: return .scaleToFill
                case .resize: return .resize
                case .none: return .none
                }
            }

            var swiftui: ContentMode {
                switch self {
                case .none: return .fit
                case .fit: return .fit
                case .fill: return .fill
                case .resize: return .fit
                }
            }

            var shouldResize: Bool {
                self == .fit
            }
        }

        /// The symbol configuration for the image.
        public var symbolConfiguration: ImageSymbolConfiguration?

        /// The image scaling.
        public var scaling: ImageScaling = .fit

        /// The tint color for an image that is a template or symbol image.
        public var tintColor: NSColor?

        /// The color transformer for resolving the image tint color.
        public var tintColorTransformer: ColorTransformer?
        
        /// Generates the resolved image tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = tintColor {
                return tintColorTransformer?(tintColor) ?? tintColor
            }
            return nil
        }
    }
}
