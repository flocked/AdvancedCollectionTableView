//
//  SymbolConfiguration.swift
//  
//
//  Created by Florian Zand on 03.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

public extension NSTableCellContentConfiguration {
    /// An object that contains the specific font, style, and weight attributes to apply to a image symbol configuration.
    struct SymbolConfiguration: Hashable {
        /// The font for the symbol configuration.
        public var font: FontConfiguration? = .textStyle(.body)
        
        /// The color configuration of the symbol configuration.
        public var colorConfiguration: ColorConfiguration? = nil {
            didSet { updateResolvedColors() } }
        
        /// The image scaling of the symbol configuration.
        public var imageScale: ImageScale? = nil
        
        /// The color transformer for resolving the color configuration.
        public var colorTransform: NSConfigurationColorTransformer? = nil {
            didSet { updateResolvedColors() } }
        
        /// Applies the specified image scaling of the symbol configuration.
        public func imageScale(_ scale: ImageScale?) -> Self {
            var configuration = self
            configuration.imageScale = imageScale
            return configuration
        }
        
        /// Applies the font for the symbol configuration.
        public func font(_ font: FontConfiguration?) -> Self {
            var configuration = self
            configuration.font = font
            return configuration
        }
        
        /// Applies the color configuration of the symbol configuration.
        public func colorConfiguration(_ configuration: ColorConfiguration?) -> Self {
            var newConfiguration = self
            newConfiguration.colorConfiguration = configuration
            return newConfiguration
        }
        
        /// Creates a configuration with a monochrome color configuration.
        public static func monochrome() -> SymbolConfiguration {
            SymbolConfiguration(colorConfiguration: .monochrome)
        }
        
        /// Creates a configuration with a hierarchical color configuration with the specified color.
        public static func hierarchical(_ color: NSColor) -> SymbolConfiguration {
            SymbolConfiguration(colorConfiguration: .hierarchical(color))
        }
        
        /// Creates a configuration with a multicolor configuration with the specified color.
        public static func multicolor(_ color: NSColor) -> SymbolConfiguration {
            SymbolConfiguration(colorConfiguration: .multicolor(color))
        }
        
        /// Creates a configuration with a palette color configuration with the specified primary, secondary and tertiary color.
        public static func palette(_ primary: NSColor, secondary: NSColor, tertiary: NSColor? = nil) -> SymbolConfiguration {
            SymbolConfiguration(colorConfiguration: .palette(primary, secondary, tertiary))
        }
        
        /// Creates a configuration with the specified font style and weight.
        public static func font(_ style: NSFont.TextStyle, weight: NSFont.Weight = .regular) -> SymbolConfiguration {
            SymbolConfiguration(font: .textStyle(style, weight:  weight))
        }
        
        /// Creates a configuration with the specified font size and weight.
        public static func font(size: CGFloat, weight: NSFont.Weight = .regular) -> SymbolConfiguration {
            SymbolConfiguration(font: .systemFont(size: size, weight: weight))
        }

        /// Creates a symbol configuration.
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
            case systemFont(size: CGFloat, weight: NSFont.Weight? = nil)
            /// A font with the specified text style and font weight.
            case textStyle(NSFont.TextStyle, weight: NSFont.Weight? = nil)
            internal var pointSize: CGFloat {
                switch self {
                case .textStyle(let style, weight: let weight):
                    if let weight = weight {
                        return NSFont.system(style).weight(weight).pointSize
                    }
                    return NSFont.system(style).pointSize
                case .systemFont(size: let size, weight: let weight):
                    if let weight = weight {
                        return NSFont.systemFont(ofSize: size).weight(weight).pointSize
                    }
                    return NSFont.systemFont(ofSize: size).pointSize
                }
            }
            
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

internal extension View {
    @ViewBuilder func symbolConfiguration(_ configuration: NSTableCellContentConfiguration.SymbolConfiguration?) -> some View {
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

internal extension NSImage.SymbolWeight {
    var nsFontWeight: NSFont.Weight {
        switch self {
        case .unspecified: return .regular
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        }
    }
}
