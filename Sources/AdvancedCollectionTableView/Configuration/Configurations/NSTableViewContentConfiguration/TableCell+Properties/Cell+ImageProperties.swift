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

/// The content properties of an item configuraton.
public extension NSTableCellContentConfiguration {
    struct ImageProperties: Hashable {
        public enum ImageSizing: Hashable {
            case firstTextHeight
            case totalTextHeight
        }
        
        public enum ImagePosition: Hashable {
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
        public var tintColor: NSColor? = nil {
            didSet { updateResolvedColors() } }
        /// The color transformer for resolving the image tint color.
        public var tintColorTransform: NSConfigurationColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        /// Generates the resolved image tint color for the specified tint color, using the tint color and tint color transformer.
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
        public var backgroundColorTransform: NSConfigurationColorTransformer? = nil {
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
        
        public var borderColorTransform: NSConfigurationColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        /// Generates the resolved border color for the specified border color, using the border color and border color transformer.
        public func resolvedBorderColor() -> NSColor? {
            if let borderColor = self.borderColor {
                return self.borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }
        
        public var cornerRadius: CGFloat = 0.0
        public var shadowProperties: ShadowProperties = ShadowProperties()
        
        public var symbolConfiguration: SymbolConfiguration? = SymbolConfiguration().font(.textStyle(.body, weight: nil))
        
        public var imageScaling: NSImageScaling = .scaleNone
        public var imageMaxWidth: CGFloat? = nil
        public var imageMaxHeight: CGFloat? = nil
        public var imageSizing: ImageSizing = .firstTextHeight
        public var imagePosition: ImagePosition = .leading
        
        internal var _resolvedTintColor: NSColor? = nil
        internal var _resolvedBorderColor: NSColor? = nil
        internal var _resolvedBackgroundColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            symbolConfiguration?.updateResolvedColors()
            _resolvedTintColor = symbolConfiguration?._resolvedPrimaryColor ?? resolvedTintColor()
            _resolvedBorderColor = resolvedBorderColor()
            _resolvedBackgroundColor = resolvedBackgroundColor()
        }
    }
}

internal extension NSTableCellContentConfiguration.SymbolConfiguration {
    func nsSymbolConfiguration() -> NSImage.SymbolConfiguration {
        var configuration: NSImage.SymbolConfiguration
        switch self.colorConfiguration {
        case .hierarchical(let color):
            configuration = .hierarchical(color)
        case .monochrome:
            configuration = .monochrome()
        case .palette(let primary, let secondary, let tertiary):
            configuration = .palette(primary, secondary, tertiary)
        case .multicolor(let color):
            configuration = .multicolor(color)
        case .none:
            configuration = .unspecified
        }
        
        switch self.font {
            case .systemFont(size: let size, weight: let weight):
                configuration = configuration.font(size: size)
                configuration = configuration.weight(weight)
            case .textStyle(let style, weight: let weight):
                configuration = configuration.font(style)
                configuration = configuration.weight(weight)
            case .none:
                break
        }
        
        if let symbolScale = self.imageScale?.nsSymbolScale {
            configuration = configuration.scale(symbolScale)
        }
        
        return configuration
    }
}

/// textHeight
/// textAndSecondaryTextHeight
