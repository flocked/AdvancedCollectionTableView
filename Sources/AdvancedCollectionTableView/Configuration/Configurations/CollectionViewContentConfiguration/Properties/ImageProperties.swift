//
//  File.swift
//  
//
//  Created by Florian Zand on 02.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit
/*
public extension NSItemContentConfiguration {
    struct ImageProperties: Hashable {
        public var tintColor: NSColor? = nil
        public var tintColorTransform: NSConfigurationColorTransformer? = nil
        public var size: ImageSize = .fullSize
        public var scaling: CALayerContentsGravity = .resizeAspectFill
        var symbolConfiguration: SymbolConfiguration = SymbolConfiguration()

        
        public enum ImageSize: Hashable {
            case fullSize
            case textHeight
            case secondaryTextHeight
            case textAndSecondaryTextHeight
            case size(CGSize)
            case maxSize(CGSize)
        }
        
        public static func `default`() -> ImageProperties {
            return ImageProperties()
        }
        
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = self.tintColor {
                return self.tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }
        
        struct SymbolConfiguration: Hashable {
            public var fontStyle: FontStyle? = .textStyle(.body)
            public var colorStyle: ColorStyle? = .monochrome
            public var colorTransform: NSConfigurationColorTransformer? = nil
            public var imageScale: ImageScale? = nil
            
            public static func `default`() -> SymbolConfiguration {
                return SymbolConfiguration()
            }
            
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
                case monochrome
                case multicolor(NSColor)
                case hierarchical(NSColor)
                
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
            
            internal var symbolConfiguration: NSImage.SymbolConfiguration {
                var symbolConfiguration = NSImage.SymbolConfiguration()
         
                if let fontStyle = fontStyle {
                    switch fontStyle {
                    case .systemFont(size: let pointSize, weight: let weight):
                        symbolConfiguration = symbolConfiguration.font(size: pointSize).weight(weight)
                    case .textStyle(let style, weight: let weight):
                        symbolConfiguration = symbolConfiguration.font(style).weight(weight)
                    }
                }

                if let colorStyle = colorStyle {
                    switch colorStyle {
                    case .palette(let primary, let secondary, let tertiary):
                        symbolConfiguration = symbolConfiguration.palette(primary, secondary, tertiary)
                    case .monochrome:
                        symbolConfiguration = symbolConfiguration.monochrome()
                    case .multicolor(let color):
                        symbolConfiguration = symbolConfiguration.multicolor(color)
                    case .hierarchical(let color):
                        symbolConfiguration = symbolConfiguration.hierarchical(color)
                    }
                }
                return symbolConfiguration
            }
        }
    }
}
*/
