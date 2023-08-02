//
//  ImageProperties.swift
//  
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

public extension NSTableCellContentConfiguration {
    /// Properties that affect the cell content configuration’s image.
    struct ImageProperties: Hashable {
        public enum ImageSizing: Hashable {
            case firstTextHeight
            case totalTextHeight
        }
        
        /// The position of the image.
        public enum ImagePosition: Hashable {
            /// The image is positioned leading the text.
            case leading
            /// The image is positioned trailing the text.
            case trailing
            /// The image is positioned below the text.
            case bottom
            /// The image is positioned above the text.
            case top
            internal var imageIsLeading: Bool {
                self == .leading || self == .top
            }
            internal var orientation: NSUserInterfaceLayoutOrientation {
                switch self {
                case .leading, .trailing:
                    return .horizontal
                case .top, .bottom:
                    return .vertical
                }
            }
        }
        
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
        /// The shadow properties of the image.
        public var shadowProperties: ConfigurationProperties.Shadow = .none()
        
        /// The symbol configuration of the image.
        public var symbolConfiguration: ConfigurationProperties.SymbolConfiguration? = .font(.body)
        
        /// The image scaling.
        public var scaling: NSImageScaling = .scaleNone
        
        /// The maximum width of the image.
        public var maxWidth: CGFloat? = nil
        /// The maximum height of the image.
        public var maxHeight: CGFloat? = nil
        
        /// The sizing option for the image.
        public var sizing: ImageSizing = .firstTextHeight
        
        /// The position of the image.
        public var position: ImagePosition = .leading
        
        internal init() {
            
        }
        
        internal var _resolvedTintColor: NSColor? = nil
        internal var _resolvedBorderColor: NSColor? = nil
        internal var _resolvedBackgroundColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            //  symbolConfiguration?.updateResolvedColors()
            _resolvedTintColor = symbolConfiguration?._resolvedPrimaryColor ?? resolvedTintColor()
            _resolvedBorderColor = resolvedBorderColor()
            _resolvedBackgroundColor = resolvedBackgroundColor()
        }
    }
}
