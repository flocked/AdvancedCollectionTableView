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
        
        /// The maximum width of the content.
        public var maximumWidth: CGFloat? = nil
        
        /// The maximum height of the content.
        public var maximumHeight: CGFloat? = nil
        
        /**
         The scaling of the content view.
         
         The default is 1.0, which displays the content view at it's original scale. A larger value will display the content view at a larger, a smaller value at a smaller size.
         */
        public var scaleTransform: CGPoint = CGPoint(x: 1, y: 1)
        
        /// The background color.
        public var backgroundColor: NSColor? = .lightGray {
            didSet { updateResolvedColors() } }
        
        /// The color transformer for resolving the background color.
        public var backgroundColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// Generates the resolved background color for the specified background color, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = backgroundColor {
                return backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        /// The visual effect background of the content.
        public var visualEffect: VisualEffectConfiguration? = nil
        
        /// The border width.
        public var borderWidth: CGFloat = 0.0 {
            didSet { resolvedBorderWidth = state.borderWidth ?? borderWidth }
        }
        /// The border color.
        public var borderColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        
        /// The color transformer for resolving the border color.
        public var borderColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// Generates the resolved border color for the specified border color, using the border color and border color transformer.
        public func resolvedBorderColor() -> NSColor? {
            if let borderColor = borderColor {
                return borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }
        
        struct State: Hashable {
            var borderWidth: CGFloat? = nil
            var borderColor: NSColor? = nil
            var shadowColor: NSColor? = nil
        }
        
        var state: State = State() {
            didSet {
                resolvedBorderWidth = state.borderWidth ?? borderWidth
                updateResolvedColors()
            }
        }
   
        var stateShadow: ShadowConfiguration {
            guard let shadowColor = state.shadowColor else { return shadow }
            var shadow = shadow
            shadow.color = shadowColor
            return shadow
        }
        
        var resolvedBorderWidth: CGFloat = 0.0
        
        /// Properties for configuring the image.
        public var imageProperties: ImageProperties = ImageProperties()
        
        /// The shadow properties.
        public var shadow: ShadowConfiguration = .black()
        
        /// Resets the  border width to 0 when the item state isSelected is false.
        var needsBorderWidthReset: Bool = false
        /// Resets the  border width to 0 when the item state isSelected is false.
        var needsBorderColorReset: Bool = false
        var _resolvedImageTintColor: NSColor? = nil
        var _resolvedBorderColor: NSColor? = nil
        var _resolvedBackgroundColor: NSColor? = nil
        mutating func updateResolvedColors() {
            //  imageSymbolConfiguration?.updateResolvedColors()
            _resolvedImageTintColor = imageProperties.symbolConfiguration?.resolvedPrimaryColor() ?? imageProperties.resolvedTintColor()
            _resolvedBorderColor = state.borderColor ?? resolvedBorderColor()
            _resolvedBackgroundColor = resolvedBackgroundColor()
        }
        
        init() {
            
        }
        
    }
}

extension NSItemContentConfiguration.ContentProperties {
    /// Properties that affect the image of the content.
    public struct ImageProperties: Hashable {
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
        public var symbolConfiguration: ImageSymbolConfiguration? = nil
        
        /// The image scaling.
        public var scaling: ImageScaling = .fit
        
        /// The tint color for an image that is a template or symbol image.
        public var tintColor: NSColor? = nil
        
        /// The color transformer for resolving the image tint color.
        public var tintColorTransform: ColorTransformer? = nil
        
        /// Generates the resolved image tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = tintColor {
                return tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }
        
    }
}
