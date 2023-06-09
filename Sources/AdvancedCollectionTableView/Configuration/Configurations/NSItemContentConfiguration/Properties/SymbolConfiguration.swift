//
//  File.swift
//  
//
//  Created by Florian Zand on 03.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

/// The content properties of an item configuraton.
public extension NSItemContentConfiguration.ContentProperties {
    /// An object that contains the specific font, style, and weight attributes to apply to a item symbol image.
    struct SymbolConfiguration: Hashable {
        /// The font for the symbol configuration.
        public var font: FontConfiguration? = .textStyle(.body)
        
        /// The color configuration of the symbol configuration.
        public var colorConfiguration: ColorConfiguration? = nil {
            didSet { updateResolvedColors() } }
        
        /// The image scaling of the symbol configuration.
        public var imageScale: ImageScale? = nil
        
        public func imageScale(_ scale: ImageScale?) -> Self {
            var configuration = self
            configuration.imageScale = imageScale
            return configuration
        }
        
        public func font(_ font: FontConfiguration?) -> Self {
            var configuration = self
            configuration.font = font
            return configuration
        }
        
        public func colorConfiguration(_ configuration: ColorConfiguration?) -> Self {
            var newConfiguration = self
            newConfiguration.colorConfiguration = configuration
            return newConfiguration
        }
        
        /// The color transformer for resolving the color style.
        public var colorTransform: NSConfigurationColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        public init(font: FontConfiguration? = nil, colorConfiguration: ColorConfiguration? = nil, imageScale: ImageScale? = nil, colorTransform: NSConfigurationColorTransformer? = nil) {
            self.font = font
            self.colorConfiguration = colorConfiguration
            self.imageScale = imageScale
            self.colorTransform = colorTransform
            self.updateResolvedColors()
        }
        
        /// Generates the resolved primary color for the specified color style, using the color style and color transformer.
        public func resolvedPrimaryColor() -> NSColor? {
            if let primary = self.colorConfiguration?.primary {
                return self.colorTransform?(primary) ?? primary
            }
            return nil
        }
        
        /// Generates the resolved secondary color for the specified color style, using the color style and color transformer.
        public func resolvedSecondaryColor() -> NSColor? {
            if let secondary = self.colorConfiguration?.secondary {
                return self.colorTransform?(secondary) ?? secondary
            }
            return nil
        }
        
        /// Generates the resolved tertiary color for the specified color style, using the color style and color transformer.
        public func resolvedTertiaryColor() -> NSColor? {
            if let tertiary = self.colorConfiguration?.tertiary {
                return self.colorTransform?(tertiary) ?? tertiary
            }
            return nil
        }
        
        internal var _resolvedPrimaryColor: NSColor? = nil
        internal var _resolvedSecondaryColor: NSColor? = nil
        internal var _resolvedTertiaryColor: NSColor? = nil
        internal mutating func updateResolvedColors() {
            _resolvedPrimaryColor = resolvedPrimaryColor()
            _resolvedSecondaryColor = resolvedSecondaryColor()
            _resolvedTertiaryColor = resolvedTertiaryColor()
        }
        
        /// Constants that specify the font of a symbol image.
        public enum FontConfiguration: Hashable {
            /// A font with the specified point size and font weight.
            case systemFont(size: CGFloat, weight: NSImage.SymbolWeight? = nil)
            /// A font with the specified text style and font weight.
            case textStyle(NSFont.TextStyle, weight: NSImage.SymbolWeight? = nil)
            internal var swiftui: Font {
                switch self {
                case .textStyle(let style, weight: let weight):
                    return Font.system(style.swiftUI).weight(weight?.swiftUI ?? .regular)
                case .systemFont(size: let size, weight: let weight):
                    return Font.system(size: size).weight(weight?.swiftUI ?? .regular)
                }
            }
        }
        
        /// Constants that specify which symbol image scale.
        public enum ImageScale: Hashable {
            /// A scale that produces small images.
            case small
            /// A scale that produces medium-sized images.
            case medium
            /// A scale that produces large images.
            case large
            
            internal var nsSymbolScale: NSImage.SymbolScale {
                switch self {
                case .small: return .small
                case .medium: return .medium
                case .large: return .large
                }
            }
            
            internal var swiftui: Image.Scale {
                switch self {
                case .small: return .small
                case .medium: return .medium
                case .large: return .large
                }
            }
        }
        
        /// Constants that specify the color configuration of a symbol image.
        public enum ColorConfiguration: Hashable {
            /// A color configuration by specifying a palette of colors.
            case palette(NSColor, NSColor, NSColor? = nil)
            ///  A monochrome color configuration using the color you specify.
            case monochrome
            ///  A multicolor color configuration using the color you specify as primary color.
            case multicolor(NSColor)
            ///  A hierarchical color configuration using the color you specify.
            case hierarchical(NSColor)
            
            internal var renderingMode: SymbolRenderingMode {
                switch self {
                case .palette(_, _, _): return .palette
                case .monochrome: return .monochrome
                case .multicolor(_): return .multicolor
                case .hierarchical(_): return .hierarchical
                }
            }
            
            internal var primary: NSColor? {
                switch self {
                case .palette(let primary, _, _):
                    return primary
                case .multicolor(let primary):
                    return primary
                case .hierarchical(let primary):
                    return primary
                case .monochrome:
                    return nil
                }
            }
            
            internal var secondary: NSColor? {
                switch self {
                case .palette(_, let secondary, _):
                    return secondary
                default:
                    return nil
                }
            }
            
            internal var tertiary: NSColor? {
                switch self {
                case .palette(_, _, let tertiary):
                    return tertiary
                default:
                    return nil
                }
            }
        }
    }
}

internal extension NSItemContentConfiguration.ContentProperties.SymbolConfiguration {
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

internal extension View {
    @ViewBuilder func symbolConfiguration(_ configuration: NSItemContentConfiguration.ContentProperties.SymbolConfiguration?) -> some View {
        if let configuration = configuration {
            self
                .symbolRenderingMode(configuration.colorConfiguration?.renderingMode)
                .foregroundStyle(configuration.colorConfiguration?.primary?.swiftUI, configuration.colorConfiguration?.secondary?.swiftUI, configuration.colorConfiguration?.tertiary?.swiftUI)
                .imageScale(configuration.imageScale?.swiftui)
                .font(configuration.font?.swiftui)
        } else {
            self
        }
    }
}
