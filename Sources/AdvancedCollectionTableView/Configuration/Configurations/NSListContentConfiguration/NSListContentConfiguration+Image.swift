//
//  NSListContentConfiguration+Image.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

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
            
            var contentMode: ContentMode? {
                switch self {
                case .fit: return .fit
                case .resize: return .fill
                case .none: return nil
                }
            }
            
            var resizable: Bool {
                switch self {
                case .none: return false
                default: return true
                }
            }
            
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
                
                internal var alignment: NSLayoutConstraint.Attribute {
                    switch self {
                    case .top: return .centerY
                    case .center: return .centerY
                    case .bottom: return .centerY
                    case .firstBaseline: return .centerY
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
                
                internal var alignment: NSLayoutConstraint.Attribute {
                    switch self {
                    case .leading: return .leading
                    case .center: return .centerX
                    case .trailing: return .trailing
                    }
                }
            }
            
            internal var alignment: NSLayoutConstraint.Attribute {
                switch self {
                case .top(let vertical), .bottom(let vertical):
                    return vertical.alignment
                case .leading(let horizonal), .trailing(let horizonal):
                    return horizonal.alignment
                }
            }
            
            internal var imageIsLeading: Bool {
                switch self {
                case .leading(_), .top(_): return true
                default: return false
                }
            }
            
            internal var orientation: NSUserInterfaceLayoutOrientation {
                switch self {
                case .leading(_), .trailing(_):
                    return .horizontal
                case .top(_), .bottom(_):
                    return .vertical
                }
            }
        }
        
        //   var reservedLayoutSize: CGSize = CGSize(0, 0)
        //    static let standardDimension: CGFloat = -CGFloat.greatestFiniteMagnitude
        
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
        
        /// The shadow of the image.
        public var shadow: ShadowConfiguration = .none()
        
        /// The symbol configuration of the image.
        public var symbolConfiguration: ImageSymbolConfiguration? = .font(.body)
        
        /// The image scaling.
        public var scaling: Scaling = .fit
        
        /// The sizing option for the image.
        public var sizing: Sizing = .totalTextHeight
        
        /// The position of the image.
        public var position: Position = .leading(.center)
        
        internal init() {
            
        }
        
        internal var _resolvedTintColor: NSColor? = nil
        internal var _resolvedBorderColor: NSColor? = nil
        internal var _resolvedBackgroundColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            _resolvedTintColor = symbolConfiguration?.resolvedPrimaryColor() ?? resolvedTintColor()
            _resolvedBorderColor = resolvedBorderColor()
            _resolvedBackgroundColor = resolvedBackgroundColor()
        }
    }
}
