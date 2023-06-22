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
        public var tintColorTransform: NSConfigurationColorTransformer? = nil {
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
        public var backgroundColorTransform: NSConfigurationColorTransformer? = nil {
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
        public var borderColorTransform: NSConfigurationColorTransformer? = nil {
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
        public var shadowProperties: ShadowProperties = ShadowProperties()
        
        /// The symbol configuration of the image.
        public var symbolConfiguration: SymbolConfiguration? = SymbolConfiguration().font(.textStyle(.body, weight: nil))
        
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
        
        /// Creates image properties.
        public init(tintColor: NSColor? = nil,
                    tintColorTransform: NSConfigurationColorTransformer? = nil,
                    backgroundColor: NSColor? = nil,
                    backgroundColorTransform: NSConfigurationColorTransformer? = nil,
                    borderWidth: CGFloat = 0.0,
                    borderColor: NSColor? = nil,
                    borderColorTransform: NSConfigurationColorTransformer? = nil,
                    cornerRadius: CGFloat = 0.0,
                    shadowProperties: ShadowProperties = ShadowProperties(),
                    symbolConfiguration: SymbolConfiguration? = nil,
                    scaling: NSImageScaling = .scaleNone,
                    maxWidth: CGFloat? = nil,
                    maxHeight: CGFloat? = nil,
                    sizing: ImageSizing = .firstTextHeight,
                    position: ImagePosition = .leading) {
            self.tintColor = tintColor
            self.tintColorTransform = tintColorTransform
            self.backgroundColor = backgroundColor
            self.backgroundColorTransform = backgroundColorTransform
            self.borderWidth = borderWidth
            self.borderColor = borderColor
            self.borderColorTransform = borderColorTransform
            self.cornerRadius = cornerRadius
            self.shadowProperties = shadowProperties
            self.symbolConfiguration = symbolConfiguration
            self.scaling = scaling
            self.maxWidth = maxWidth
            self.maxHeight = maxHeight
            self.sizing = sizing
            self.position = position
        }
        
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
            configuration = configuration.weight(weight?.symbolWeight())
            case .textStyle(let style, weight: let weight):
                configuration = configuration.font(style)
            configuration = configuration.weight(weight?.symbolWeight())
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
