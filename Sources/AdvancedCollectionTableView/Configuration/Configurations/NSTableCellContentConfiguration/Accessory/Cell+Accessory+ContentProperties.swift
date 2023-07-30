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

/*
/// The content properties of an item configuraton.
public extension NSTableCellContentConfiguration.Accessory.AccessoryContent {
   struct ContentProperties: Hashable {
        public enum ContentPosition: Int, Hashable {
            case leading
            case trailing
            case bottom
            case top
            internal var orientation: NSUserInterfaceLayoutOrientation {
                switch self {
                case .leading, .trailing:
                    return .horizontal
                case .top, .bottom:
                    return .vertical
                }
            }
        }
               
        /// The image tint color for an image that is a template or symbol image.
        public var imageTintColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        /// The color transformer for resolving the image tint color.
        public var imageTintColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        /// Generates the resolved image tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedImageTintColor() -> NSColor? {
            if let tintColor = self.imageTintColor {
                return self.imageTintColorTransform?(tintColor) ?? tintColor
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
        
        public var borderWidth: CGFloat = 0.0
        public var borderColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        
        public var borderColorTransform: ColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        /// Generates the resolved border color for the specified border color, using the border color and border color transformer.
        public func resolvedBorderColor() -> NSColor? {
            if let borderColor = self.borderColor {
                return self.borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }
        
        public var cornerRadius: CGFloat = 0.0
        public var shadowProperties: ConfigurationProperties.Shadow = .none()
        
        public var imageSymbolConfiguration: ConfigurationProperties.SymbolConfiguration? = .font(.body)
        
        public var imageScaling: NSImageScaling = .scaleNone
        public var contentMaxWidth: CGFloat? = nil
        public var contentMaxHeight: CGFloat? = nil
        public var contentPosition: ContentPosition = .leading
        
        internal var _resolvedImageTintColor: NSColor? = nil
        internal var _resolvedBorderColor: NSColor? = nil
        internal var _resolvedBackgroundColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            imageSymbolConfiguration?.updateResolvedColors()
            _resolvedImageTintColor = imageSymbolConfiguration?._resolvedPrimaryColor ?? resolvedImageTintColor()
            _resolvedBorderColor = resolvedBorderColor()
            _resolvedBackgroundColor = resolvedBackgroundColor()
        }
    }
}
*/
