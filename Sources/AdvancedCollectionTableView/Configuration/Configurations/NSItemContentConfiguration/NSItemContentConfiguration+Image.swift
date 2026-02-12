//
//  NSItemContentConfiguration+Image.swift
//  
//
//  Created by Florian Zand on 08.12.24.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

public extension NSItemContentConfiguration {
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
            tintColorTransformer?(tintColor) ?? tintColor
        }
    }
}
