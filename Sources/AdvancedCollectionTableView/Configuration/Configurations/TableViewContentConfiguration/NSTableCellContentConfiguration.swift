//
//  TableCellContentConfiguration.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZExtensions

/**
 A content configuration for a table cell-based content view.
 
 A table cell content configuration describes the styling and content for an individual element that might appear in a list, like a cell, header, or footer. Using a list content configuration, you can obtain system default styling for a variety of different view states. You fill the configuration with your content, and then assign it directly to cells, headers, and footers in UICollectionView and UITableView, or to your own custom list content view (UIListContentView).
 
 For views like cells, headers, and footers, use their defaultContentConfiguration() to get a list content configuration that has preconfigured default styling. Alternatively, you can create a list content configuration from one of the system default styles. After you get the configuration, you assign your content to it, customize any other properties, and assign it to your view as the current content configuration.
 
 ```
 var content = cell.defaultContentConfiguration()

 // Configure content.
 content.text = "Favorites"
 content.image = NSImage(systemSymbolName: "star", accessibilityDescription: "star")

 // Customize appearance.
 content.imageProperties.tintColor = .purple

 cell.contentConfiguration = content
 ```
 */
public class NSTableCellContentConfiguration: NSContentConfiguration {
    /**
     The primary text.
     */
    var text: String? = nil
    /**
     An attributed variant of the primary text.
     */
    var attributedText: NSAttributedString? = nil
    /**
     The secondary text.
     */
    var secondaryText: String? = nil
    /**
     An attributed variant of the secondary text.
     */
    var secondaryattributedText: NSAttributedString? = nil
    /**
     The image to display.
     */
    var image: NSImage? = nil
    
    /**
     Properties for configuring the image.
     */
    var imageProperties: ImageProperties = ImageProperties()
    /**
     Properties for configuring the primary text.
     */
    var textProperties: TextProperties = .textStyle(.body, weight: .bold)
    /**
     Properties for configuring the secondary text.
     */
    var secondaryTextProperties: TextProperties = .textStyle(.body)
   
    /**
     The padding between the image and text.
     
     This value only applies when there’s both an image and text.
     */
    var imageToTextPadding: CGFloat = 4.0
    /**
     The padding between the primary and secondary text.

     This value only applies when there’s both a text and secondary text.
     */
    var textToSecondaryTextPadding: CGFloat = 4.0
    /**
     The margins between the content and the edges of the content view.
     */
    var padding: NSDirectionalEdgeInsets = .init(4.0)
    
    public static func style(_ style: NSTableView.Style) -> NSTableCellContentConfiguration {
        switch style {
        case .automatic:
            return .fullWidth()
        case .fullWidth:
            return .fullWidth()
        case .inset:
            return .inset()
        case .sourceList:
            return .sourceList()
        case .plain:
            return .plain()
        @unknown default:
            return .fullWidth()
        }
    }
    
    public static func fullWidth() -> NSTableCellContentConfiguration {
        let configuration = NSTableCellContentConfiguration()
        return configuration
    }
    
    public static func sourceList() -> NSTableCellContentConfiguration {
        let configuration = NSTableCellContentConfiguration()
        return configuration
    }
    
    public static func plain() -> NSTableCellContentConfiguration {
        let configuration = NSTableCellContentConfiguration()
        return configuration
    }

    public static func inset() -> NSTableCellContentConfiguration {
        let configuration = NSTableCellContentConfiguration()
        return configuration
    }

    public func makeContentView() -> NSView & NSContentView {
        let contentView = ContentView(configuration: self)
        return contentView
    }
    
    public func updated(for state: NSConfigurationState) -> Self {
        return self
    }
    
    internal var hasText: Bool {
        self.text != nil || self.attributedText != nil
    }
    
    internal var hasSecondaryText: Bool {
        self.secondaryText != nil || self.secondaryattributedText != nil
    }
    
    internal var hasImage: Bool {
        self.image != nil || self.imageProperties.backgroundColor != nil
    }
    
    public init() {

    }
}

public extension NSTableCellContentConfiguration {
    struct TextProperties {
        public enum TextTransform: Hashable {
            case none
            case capitalized
            case lowercase
            case uppercase
        }
        
        var font: NSFont = .system(.body)
        var numberOfLines: Int = 0
        var alignment: NSTextAlignment = .left
        var lineBreakMode: NSLineBreakMode = .byWordWrapping
        var textTransform: TextTransform = .none
        /**
         The style of bezel the text field displays.
         */
        var bezelStyle: NSTextField.BezelStyle? = nil
        
        /**
         A Boolean value that determines whether the user can select the content of the text field.
         
         If true, the text field becomes selectable but not editable. Use isEditable to make the text field selectable and editable. If false, the text is neither editable nor selectable.
         */
        var isSelectable: Bool = false
        /**
         A Boolean value that controls whether the user can edit the value in the text field.

         If true, the user can select and edit text. If false, the user can’t edit text, and the ability to select the text field’s content is dependent on the value of isSelectable.
         For example, if an NSTextField object is selectable but uneditable, becomes editable for a time, and then becomes uneditable again, it remains selectable. To ensure that text is neither editable nor selectable, use isSelectable to disable text selection.         */
        var isEditable: Bool = false
        
        /**
         The color of the text field’s content.
         */
        var textColor: NSColor = .labelColor
        var textColorTansform: NSConfigurationColorTransformer? = nil
        
        /**
         The color of the background the text field’s cell draws behind the text.
         */
        var backgroundColor: NSColor? = nil
        var backgroundColorTansform: NSConfigurationColorTransformer? = nil

        func resolvedTextColor() -> NSColor {
            return self.textColorTansform?(textColor) ?? textColor
        }
        
        func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.textColorTansform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        public static func textStyle(_ style: NSFont.TextStyle = .body, weight: NSFont.Weight? = nil) -> TextProperties {
            var property = TextProperties()
            if let weight = weight {
                property.font = .system(style).weight(weight)
            } else {
                property.font = .system(.body)
            }
            return property
        }
    }
    
    struct ImageProperties {
        var symbolConfiguration: SymbolConfiguration = SymbolConfiguration()
        var tintColor: NSColor? = nil
        var cornerRadius: CGFloat = 0.0
        var backgroundColor: NSColor? = nil
        var shadowProperties: ShadowProperties = .black()
        
        var backgroundColorTransform: NSConfigurationColorTransformer? = nil
        var tintColorTransform: NSConfigurationColorTransformer? = nil
        var size: ImageSize = .fullHeight
        var scaling: CALayerContentsGravity = .resizeAspectFill
        
        enum ImageSize {
            case fullHeight
            case textHeight
            case secondaryTextHeight
            case size(CGSize)
            case maxSize(CGSize)
        }
        
        static func `default`() -> ImageProperties {
            return ImageProperties()
        }

        func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
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

            func resolvedColor() -> NSColor? {
                if let color = self.color {
                    return self.colorTransform?(color) ?? color
                }
                return nil
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
            
            static func `default`() -> ShadowProperties {
                return ShadowProperties()
            }
        }
    }
}

internal extension String {
    func transform(using transform: NSTableCellContentConfiguration.TextProperties.TextTransform) -> String {
        switch transform {
        case .none:
            return self
        case .capitalized:
            return self.capitalized
        case .lowercase:
            return self.lowercased()
        case .uppercase:
            return self.uppercased()
        }
    }
}

internal extension NSAttributedString {
    func transform(using transform: NSTableCellContentConfiguration.TextProperties.TextTransform) -> String {
        switch transform {
        case .none:
            return self.string
        case .capitalized:
            return self.string.capitalized
        case .lowercase:
            return self.string.lowercased()
        case .uppercase:
            return self.string.uppercased()
        }
    }
}
