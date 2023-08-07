//
//  NSItemContentConfiguration+ContentProperties.swift
//  
//
//  Created by Florian Zand on 02.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

public extension NSItemContentConfiguration {
    /**
     Properties for configuring the content of an item.
     
     The item content view is displayed if there is a item view, item image and/or background color.
     */
    struct ContentProperties: Hashable {
        /// The image scaling of an item image.
        public enum ImageScaling {
            /// The image is resized to fit.
            case fit
            /// The image is resized to completely fill the bounds rectangle, while still preserving the aspect of the image. The image is centered in the axis it exceeds.
            case fill
            /// The image is resized to fit the entire bounds rectangle.
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
            internal var shouldResize: Bool {
                self == .fit
            }
            internal var swiftui: ContentMode {
                switch self {
                case .none: return .fit
                case .fit: return .fit
                case .fill: return .fill
                case .resize: return .fit
                }
            }
        }
        
        public enum SizeOption: Hashable {
            case max(width: CGFloat?, height: CGFloat?)
            case textAndSecondaryTextHeight
            case size(CGSize)
            case min(width: CGFloat?, height: CGFloat?)
        }
        
        public enum ContentSizing: Hashable {
            case contentHeight(max: CGSize? = nil)
            case textHeight
            case secondaryTextHeight
            case textAndSecondaryTextHeight
            case size(CGSize)
        }
        
        /// The corner radius of the content.
        public var cornerRadius: CGFloat = 10.0
        
        /// The maximum width of the content.
        public var maxWidth: CGFloat? = nil
        /// The maximum height of the content.
        public var maxHeight: CGFloat? = nil
        
        /// The size of the content.
        public var sizing: SizeOption? = nil
        /**
         The scaling of the content.
         
         The default is 1.0, which displays the content at it's original scale.
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
        public var borderWidth: CGFloat = 0.0
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
        
        /// The symbol configuration for the image.
        public var imageSymbolConfiguration: ConfigurationProperties.SymbolConfiguration? = nil
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
        public var shadow: ConfigurationProperties.Shadow = .black()
        
        /// Resets the  border width to 0 when the item state isSelected is false.
        internal var needsBorderWidthReset: Bool = false
        /// Resets the  border width to 0 when the item state isSelected is false.
        internal var needsBorderColorReset: Bool = false
        
        internal var _resolvedImageTintColor: NSColor? = nil
        internal var _resolvedBorderColor: NSColor? = nil
        internal var _resolvedBackgroundColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            imageSymbolConfiguration?.updateResolvedColors()
            _resolvedImageTintColor = imageSymbolConfiguration?._resolvedPrimaryColor ?? resolvedImageTintColor()
            _resolvedBorderColor = resolvedBorderColor()
            _resolvedBackgroundColor = resolvedBackgroundColor()
        }
        
        internal init() {
            
        }
    }
}
