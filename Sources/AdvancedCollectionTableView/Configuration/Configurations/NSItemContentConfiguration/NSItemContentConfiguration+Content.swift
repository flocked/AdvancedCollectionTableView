//
//  ItemConfiguration+Content.swift
//  ItemConfiguration
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
            internal var gravity: CALayerContentsGravity {
                switch self {
                case .fit: return .resizeAspect
                case .fill: return .resizeAspectFill
                case .resize: return .resize
                case .none: return .center
                }
            }
            
            internal var swiftui: ContentMode {
                switch self {
                case .none: return .fit
                case .fit: return .fit
                case .fill: return .fill
                case .resize: return .fit
                }
            }
            internal var shouldResize: Bool {
                self == .fit
            }
        }
        
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
        public var scaleTransform: CGFloat = 1.0
        
        /// The background color.
        public var backgroundColor: NSColor? = .lightGray {
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
        
        /// The border width.
        public var borderWidth: CGFloat = 0.0 {
            didSet { resolvedBorderWidth = stateBorderWidth ?? borderWidth }
        }
        /// The border color.
        public var borderColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        /// The color transformer for resolving the border color.
        public var borderColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        /// Generates the resolved border color for the specified border color, using the border color and border color transformer.
        public func resolvedBorderColor() -> NSColor? {
            if let borderColor = self.borderColor {
                return self.borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }
        
        internal var stateBorderWidth: CGFloat? {
            didSet { resolvedBorderWidth = stateBorderWidth ?? borderWidth } }
        
        internal var stateBorderColor: NSColor? {
            didSet { updateResolvedColors() } }
        
        internal var stateShadowColor: NSColor? = nil
        
        internal var stateShadow: ShadowConfiguration {
            guard let stateShadowColor else { return shadow }
            var shadow = self.shadow
            shadow.color = stateShadowColor
            return shadow
        }
        
        internal var resolvedBorderWidth: CGFloat = 0.0
        
        /// The symbol configuration for the image.
        public var imageSymbolConfiguration: ImageSymbolConfiguration? = nil
        /// The image scaling.
        public var imageScaling: ImageScaling = .fit
        /// The image tint color for an image that is a template or symbol image.
        public var imageTintColor: NSColor? = nil
        /// The color transformer for resolving the image tint color.
        public var imageTintColorTransform: ColorTransformer? = nil
        /// Generates the resolved image tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedImageTintColor() -> NSColor? {
            if let imageTintColor = self.imageTintColor {
                return self.imageTintColorTransform?(imageTintColor) ?? imageTintColor
            }
            return nil
        }
        
        /// The shadow properties.
        public var shadow: ShadowConfiguration = .black()
        
        /// Resets the  border width to 0 when the item state isSelected is false.
        internal var needsBorderWidthReset: Bool = false
        /// Resets the  border width to 0 when the item state isSelected is false.
        internal var needsBorderColorReset: Bool = false
        
        internal var _resolvedImageTintColor: NSColor? = nil
        internal var _resolvedBorderColor: NSColor? = nil
        internal var _resolvedBackgroundColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            //  imageSymbolConfiguration?.updateResolvedColors()
            _resolvedImageTintColor = imageSymbolConfiguration?.resolvedPrimaryColor() ?? resolvedImageTintColor()
            _resolvedBorderColor = stateBorderColor ?? resolvedBorderColor()
            _resolvedBackgroundColor = resolvedBackgroundColor()
        }
        
        internal init() {
            
        }
        
    }
}
