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

public extension NSItemContentConfiguration {
    struct SymbolConfiguration: Hashable {
        public var font: FontStyle? = .textStyle(.body)
        public var colorStyle: ColorStyle? = nil
        public var imageScale: ImageScale? = nil
        
        public var colorTransform: NSConfigurationColorTransformer? = nil
        
        public func resolvedPrimaryColor() -> NSColor? {
            if let primary = self.colorStyle?.primary {
                return self.colorTransform?(primary) ?? primary
            }
            return nil
        }
        
        public func resolvedSecondaryColor() -> NSColor? {
            if let secondary = self.colorStyle?.secondary {
                return self.colorTransform?(secondary) ?? secondary
            }
            return nil
        }
        
        public func resolvedTertiaryColor() -> NSColor? {
            if let tertiary = self.colorStyle?.tertiary {
                return self.colorTransform?(tertiary) ?? tertiary
            }
            return nil
        }
        
        public struct FontStylee: Hashable {
            internal var font: Font
            static var body: Self = FontStylee(font: .body)
            static var largeTitle: Self = FontStylee(font: .largeTitle)
            static var title1: Self = FontStylee(font: .title)
            static var title2: Self = FontStylee(font: .title2)
            static var title3: Self = FontStylee(font: .title3)
            static var callout: Self = FontStylee(font: .callout)
            static var caption1: Self = FontStylee(font: .caption)
            static var caption2: Self = FontStylee(font: .caption2)
            static var headline: Self = FontStylee(font: .headline)
            static var subheadline: Self = FontStylee(font: .subheadline)
            static func system(size: CGFloat) -> Self {
                return FontStylee(font: .system(size: size))
            }
            public func weight(_ weight: NSFont.Weight) -> Self {
                var style = self
                style.font = style.font.weight(weight.swiftUI)
                return style
            }
            
        }
        
        public enum FontStyle: Hashable {
            case systemFont(size: CGFloat, weight: NSImage.SymbolWeight? = nil)
            case textStyle(NSFont.TextStyle, weight: NSImage.SymbolWeight? = nil)
            var swiftui: Font {
                switch self {
                case .textStyle(let style, weight: let weight):
                    return Font.system(style.swiftUI).weight(weight?.swiftUI ?? .regular)
                case .systemFont(size: let size, weight: let weight):
                    return Font.system(size: size).weight(weight?.swiftUI ?? .regular)
                }
            }
        }
        
        public enum ImageScale: Hashable {
            /// A scale that produces small images.
            case small
            /// A scale that produces medium-sized images.
            case medium
            /// A scale that produces large images.
            case large
            
            internal var swiftui: Image.Scale {
                switch self {
                case .small: return .small
                case .medium: return .medium
                case .large: return .large
                }
            }
        }
        
        public enum ColorStyle: Hashable {
            case palette(NSColor, NSColor, NSColor? = nil)
            case monochrome(NSColor)
            case multicolor(NSColor)
            case hierarchical(NSColor)
            
            internal var renderingMode: SymbolRenderingMode {
                switch self {
                case .palette(_, _, _): return .palette
                case .monochrome(_): return .monochrome
                case .multicolor(_): return .multicolor
                case .hierarchical(_): return .hierarchical
                }
            }
            
            internal var primary: NSColor {
                switch self {
                case .palette(let primary, _, _):
                    return primary
                case .multicolor(let primary):
                    return primary
                case .hierarchical(let primary):
                    return primary
                case .monochrome(let primary):
                    return primary
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
    @ViewBuilder func symbolConfiguration(_ configuration: NSItemContentConfiguration.SymbolConfiguration?) -> some View {
        if let configuration = configuration {
            self
                .symbolRenderingMode(configuration.colorStyle?.renderingMode)
                .foregroundStyleOptional(configuration.colorStyle?.primary.swiftUI, configuration.colorStyle?.secondary?.swiftUI, configuration.colorStyle?.tertiary?.swiftUI)
                .imageScaleOptional(configuration.imageScale?.swiftui)
                .font(configuration.font?.swiftui)
        } else {
            self
        }
    }
}
