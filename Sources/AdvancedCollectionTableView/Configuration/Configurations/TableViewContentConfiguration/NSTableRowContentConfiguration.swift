//
//  TableRowContentConfiguration.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZExtensions

/**
 A content configuration for a table row-based content view.
 
 A table row content configuration describes the styling and content for an individual element that might appear in a list, like a row, header, or footer. Using a list content configuration, you can obtain system default styling for a variety of different view states. You fill the configuration with your content, and then assign it directly to rows, headers, and footers in UICollectionView and UITableView, or to your own custom list content view (UIListContentView).
 
 For views like rows, headers, and footers, use their defaultContentConfiguration() to get a list content configuration that has preconfigured default styling. Alternatively, you can create a list content configuration from one of the system default styles. After you get the configuration, you assign your content to it, customize any other properties, and assign it to your view as the current content configuration.
 
 ```
 var content = rowView.defaultContentConfiguration()

 // Configure content.
 content.backgroundColor = .controlAccentColor
 content.cornerRadius = 4.0

 rowView.contentConfiguration = content
 ```
 */
public struct NSTableRowContentConfiguration: NSContentConfiguration {
    
    public init() {
        
    }
    /**
     The background color.
     */
    var backgroundColor: NSColor? = nil
    /**
     The background color.
     */
    var selectionBackgroundColor: NSColor? = nil
    /**
     The corner radius..
     */
    var cornerRadius: CGFloat = 0.0
    /**
     The image to display.
     */
    var backgroundImage: NSImage? = nil
    
    /**
     The margins between the content and the edges of the content view.
     */
    var autoAdjustRowSize: Bool = false
    
    var backgroundPadding: NSDirectionalEdgeInsets = .zero
    
    internal var roundedCorners: CACornerMask = .all
    
    static func sourceList() -> NSTableRowContentConfiguration {
        var configuration = NSTableRowContentConfiguration()
        configuration.backgroundPadding = .init(top: 4.0, leading: 4.0, bottom: 4.0, trailing: 4.0)
        configuration.cornerRadius = 4.0
        configuration.imageProperties.tintColor = .controlAccentColor
        configuration.selectionBackgroundColor = .controlAccentColor
        return configuration
    }
    
    static func fullSize() -> NSTableRowContentConfiguration {
        var configuration = NSTableRowContentConfiguration()
        configuration.selectionBackgroundColor = .systemBlue
        configuration.backgroundPadding = .zero
        configuration.cornerRadius = 0.0
        configuration.imageProperties.symbolConfiguration.colorStyle = .multicolor(.controlAccentColor)
        return configuration
    }
        
    /**
     Properties for configuring the image.
     */
    var imageProperties: ImageProperties = ImageProperties()
    /**
     Properties for configuring the seperator.
     */
    var seperatorProperties: SeperatorProperties = .default()
    var backgroundColorTansform: NSConfigurationColorTransformer? = nil
    var selectionBackgroundColorTansform: NSConfigurationColorTransformer? = nil

    /**
    Generates the resolved background color, using the background color and background color transformer.

    The resulting tint color depends on backgroundColor and backgroundColorTransformer.
    */
    func resolvedBackgroundColor() -> NSColor? {
        if let backgroundColor = self.backgroundColor {
            return self.backgroundColorTansform?(backgroundColor) ?? backgroundColor
        }
        return nil
    }
    
    /**
    Generates the resolved background color, using the background color and background color transformer.

    The resulting tint color depends on backgroundColor and backgroundColorTransformer.
    */
    func resolvedSelectionBackgroundColor() -> NSColor? {
        if let selectionBackgroundColor = self.selectionBackgroundColor {
            return self.selectionBackgroundColorTansform?(selectionBackgroundColor) ?? selectionBackgroundColor
        }
        return nil
    }
    
    public func makeContentView() -> NSView & NSContentView {
        let contentView = ContentView(configuration: self)
        return contentView
    }
    
    public func updated(for state: NSConfigurationState) -> Self {
        var configuration = self
        if let state = state as? NSTableRowConfigurationState {
            configuration.roundedCorners = []
            if (state.isPreviousRowSelected == false) {
                configuration.roundedCorners.insert(.topLeft)
                configuration.roundedCorners.insert(.topRight)
            }
            if (state.isNextRowSelected == false) {
                configuration.roundedCorners.insert(.bottomLeft)
                configuration.roundedCorners.insert(.bottomRight)
            }
            if (state.isSelected) {
                configuration.backgroundColor = .controlAccentColor
            } else {
                configuration.backgroundColor = nil
            }
        }
        return configuration
    }

}

@available(macOS 12.0, *)
public extension NSTableRowContentConfiguration {
    struct SeperatorProperties {
        var color: NSColor = .separatorColor
        var colorTransform: NSConfigurationColorTransformer? = nil
        var height: CGFloat = 1.0
        var insets: NSDirectionalEdgeInsets = .init(top: 0, leading: 4.0, bottom: 0, trailing: 4.0)

        func resolvedColor() -> NSColor? {
            return self.colorTransform?(color) ?? color
        }
        
        static func `default`() -> SeperatorProperties {
            return SeperatorProperties()
        }
    }
    
    struct ImageProperties {
        enum ImageSize {
            case fullHeight
            case textHeight
            case secondaryTextHeight
            case size(CGSize)
            case maxSize(CGSize)
        }
        
        var symbolConfiguration: SymbolConfiguration = SymbolConfiguration()
        var tintColor: NSColor? = nil
        var cornerRadius: CGFloat = 0.0
        var backgroundColor: NSColor? = nil
        var shadowProperties: ShadowProperties = .black()
        
        var backgroundColorTransform: NSConfigurationColorTransformer? = nil
        var tintColorTransform: NSConfigurationColorTransformer? = nil
        var size: ImageSize = .fullHeight
        var scaling: CALayerContentsGravity = .resizeAspectFill
        
        static func `default`() -> ImageProperties {
            return ImageProperties()
        }

        /**
         Generates the resolved background color, using the background color and background color transformer.

         The resulting tint color depends on backgroundColor and backgroundColorTransformer.
         */
        func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }

        /**
         Generates the resolved tint color, using the tint color and tint color transformer.

         The resulting tint color depends on tintColor and tintColorTransformer.
         */
        func resolvedTintColor() -> NSColor? {
            if let tintColor = self.tintColor {
                return self.tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }
        
        struct SymbolConfiguration {
            var fontStyle: FontStyle? = .textStyle(.body)
            var colorStyle: ColorStyle? = .monochrome
            var colorTransform: NSConfigurationColorTransformer? = nil
            
            static func `default`() -> SymbolConfiguration {
                return SymbolConfiguration()
            }
            
            /**
             Generates the resolved primary color, using the primary color and color transformer.

             The resulting tint color depends on oolor and colorTransformer.
             */
            func resolvedPrimaryColor() -> NSColor? {
                if let primary = self.colorStyle?.primary {
                    return self.colorTransform?(primary) ?? primary
                }
                return nil
            }
            
            func resolvedSecondaryColor() -> NSColor? {
                if let secondary = self.colorStyle?.secondary {
                    return self.colorTransform?(secondary) ?? secondary
                }
                return nil
            }
            
            func resolvedTertiaryColor() -> NSColor? {
                if let tertiary = self.colorStyle?.tertiary {
                    return self.colorTransform?(tertiary) ?? tertiary
                }
                return nil
            }
            
            enum FontStyle {
                case systemFont(size: CGFloat, weight: NSImage.SymbolWeight? = nil)
                case textStyle(NSFont.TextStyle, weight: NSImage.SymbolWeight? = nil)
            }
            
            enum ColorStyle {
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
        
        public struct ShadowProperties {
            public var radius: CGFloat = 0.0
            public var color: NSColor? = nil
            public var opacity: CGFloat = 0.0
            public var offset: CGPoint = .zero
            var colorTransform: NSConfigurationColorTransformer? = nil

            /**
             Generates the resolved shadow color, using the color and color transformer.

             The resulting tint color depends on oolor and colorTransformer.
             */
            func resolvedColor() -> NSColor? {
                if let color = self.color {
                    return self.colorTransform?(color) ?? color
                }
                return nil
            }
            
            static func `default`() -> ShadowProperties {
                return ShadowProperties()
            }
            
            public static func black() -> ShadowProperties {
                var property = ShadowProperties()
                property.radius = 3.0
                property.color = .black
                property.opacity = 1.0
                return property
            }
            
            public static func none() -> ShadowProperties {
                return ShadowProperties()
            }
        }
    }
}
