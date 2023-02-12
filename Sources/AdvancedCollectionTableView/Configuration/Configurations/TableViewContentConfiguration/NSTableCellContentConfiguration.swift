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
 
 A table cell content configuration describes the styling and content for an individual element that might appear in a list, like a cell. Using a cell content configuration, you can obtain system default styling for a variety of different view states. You fill the configuration with your content, and then assign it directly to cells in NSTableView, or to your own custom cell content view (NSContentView).
 
 For views like cells (NSTableCellView) use their defaultContentConfiguration() to get a list content configuration that has preconfigured default styling. Alternatively, you can create a cell content configuration from one of the system default styles. After you get the configuration, you assign your content to it, customize any other properties, and assign it to your view as the current content configuration.
 
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
public struct NSTableCellContentConfiguration: NSContentConfiguration {
    /**
     The primary text.
     */
    public var text: String? = nil
    /**
     An attributed variant of the primary text.
     */
    public var attributedText: NSAttributedString? = nil
    /**
     The secondary text.
     */
    public var secondaryText: String? = nil
    /**
     An attributed variant of the secondary text.
     */
    public var secondaryattributedText: NSAttributedString? = nil
    /**
     The image to display.
     */
    public var image: NSImage? = nil
    
    /**
     Array of properties for configuring additional accesories.
     */
    public var accessories: [AccessoryProperties] = []

    /**
     Properties for configuring the image.
     */
    public var imageProperties: ImageProperties = ImageProperties()
    /**
     Properties for configuring the primary text.
     */
    public var textProperties: TextProperties = .textStyle(.body, weight: .bold)
    /**
     Properties for configuring the secondary text.
     */
    public var secondaryTextProperties: TextProperties = .textStyle(.body)
   
    /**
     The padding between the image and text.
     
     This value only applies when there’s both an image and text.
     */
    public var imageToTextPadding: CGFloat = 4.0
    /**
     The padding between the primary and secondary text.

     This value only applies when there’s both a text and secondary text.
     */
    public var textToSecondaryTextPadding: CGFloat = 4.0
    /**
     The margins between the content and the edges of the content view.
     */
    public var padding: NSDirectionalEdgeInsets = .init(4.0)
    
    public static func `default`() -> NSTableCellContentConfiguration {
        return NSTableCellContentConfiguration()
    }

    // Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        let contentView = ContentView(configuration: self)
        return contentView
    }
    
    /**
     Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
     */
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
        self.image != nil || self.imageProperties.resolvedBackgroundColor() != nil
    }
}

public extension NSTableCellContentConfiguration {
    struct TextProperties: Hashable {
        public enum TextTransform: Hashable {
            case none
            case capitalized
            case lowercase
            case uppercase
        }
        
        public var font: NSFont = .system(.body)
        public var numberOfLines: Int = 0
        public var alignment: NSTextAlignment = .left
        public var lineBreakMode: NSLineBreakMode = .byWordWrapping
        public var textTransform: TextTransform = .none
        /**
         The style of bezel the text field displays.
         */
        public var bezelStyle: NSTextField.BezelStyle? = nil
        /**
         A Boolean value that determines whether the user can select the content of the text field.
         
         If true, the text field becomes selectable but not editable. Use isEditable to make the text field selectable and editable. If false, the text is neither editable nor selectable.
         */
        public var isSelectable: Bool = false
        /**
         A Boolean value that controls whether the user can edit the value in the text field.

         If true, the user can select and edit text. If false, the user can’t edit text, and the ability to select the text field’s content is dependent on the value of isSelectable.
         For example, if an NSTextField object is selectable but uneditable, becomes editable for a time, and then becomes uneditable again, it remains selectable. To ensure that text is neither editable nor selectable, use isSelectable to disable text selection.         */
        public var isEditable: Bool = false
        
        /**
         The color of the text field’s content.
         */
        public var textColor: NSColor = .labelColor
        public var textColorTansform: NSConfigurationColorTransformer? = nil
        
        /**
         The color of the background the text field’s cell draws behind the text.
         */
        public var backgroundColor: NSColor? = nil
        public var backgroundColorTansform: NSConfigurationColorTransformer? = nil

        public func resolvedTextColor() -> NSColor {
            return self.textColorTansform?(textColor) ?? textColor
        }
        
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.textColorTansform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        public static func `default`() -> TextProperties {
            return .textStyle(.body)
        }
        
        public static func system(size: CGFloat, weight: NSFont.Weight? = nil) -> TextProperties {
            var property = TextProperties()
            property.font = .system(size: size, weight: weight ?? .regular)
            return property
        }
        
        public static func textStyle(_ style: NSFont.TextStyle, weight: NSFont.Weight? = nil) -> TextProperties {
            var property = TextProperties()
            if let weight = weight {
                property.font = .system(style).weight(weight)
            } else {
                property.font = .system(.body)
            }
            return property
        }
    }
    
    struct ImageProperties: Hashable {
        public enum Position: Hashable {
            case leading
            case trailing
        }
        public var symbolConfiguration: SymbolConfiguration = SymbolConfiguration()
        public var tintColor: NSColor? = nil
        public var cornerRadius: CGFloat = 0.0
        public var backgroundColor: NSColor? = nil
        public var shadowProperties: ShadowProperties = .black()
        public var position: Position = .leading
        
        public var backgroundColorTransform: NSConfigurationColorTransformer? = nil
        public var tintColorTransform: NSConfigurationColorTransformer? = nil
        public var size: ImageSize = .cellHeight
        public var scaling: CALayerContentsGravity = .resizeAspectFill
        
        public enum ImageSize: Hashable {
            case cellHeight
            case textHeight
            case secondaryTextHeight
            case size(CGSize)
            case maxSize(CGSize)
        }
        
        public static func `default`() -> ImageProperties {
            return ImageProperties()
        }

        func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = self.tintColor {
                return self.tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }
        
        public struct SymbolConfiguration: Hashable {
            public var fontStyle: FontStyle? = .textStyle(.body)
            public var colorStyle: ColorStyle? = .monochrome
            public var colorTransform: NSConfigurationColorTransformer? = nil
            
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
        
        public struct ShadowProperties: Hashable {
            public var radius: CGFloat = 0.0
            public var color: NSColor? = nil
            public var opacity: CGFloat = 0.0
            public var offset: CGPoint = .zero
            public var colorTransform: NSConfigurationColorTransformer? = nil

            public func resolvedColor() -> NSColor? {
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
            
            public static func `default`() -> ShadowProperties {
                return ShadowProperties()
            }
            
            public static func none() -> ShadowProperties {
                return ShadowProperties()
            }
        }
    }
    struct ViewProperties: Hashable {
        public enum WidthSizeOption: Hashable {
            case absolute(CGFloat)
            case textWidth
            case relative(CGFloat)
        }
        
        public enum HeightSizeOption: Hashable {
            case absolute(CGFloat)
            case textWidth
            case relative(CGFloat)
        }
        
        public typealias Corners = CACornerMask
        public var cornerRadius: CGFloat = 0.0
        public var roundedCorners: Corners = .all
        
        public var width: WidthSizeOption = .textWidth
        public var height: HeightSizeOption = .absolute(30.0)
        
        public var backgroundColor: NSColor? = nil
        public var backgroundColorTransform: NSConfigurationColorTransformer? = nil
        
        public static func `default`() -> ViewProperties {
            return ViewProperties()
        }

        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
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


public extension NSTableCellContentConfiguration {
    struct AccessoryProperties: Hashable {
        public enum Position: Hashable {
            case top
            case topLeft
            case topRight
            case bottom
            case bottomLeft
            case bottomRight
            internal var isTopPosition: Bool {
                return self == .top || self == .topLeft || self == .topRight
            }
        }
        
        public enum WidthSizeOption: Hashable {
            case absolute(CGFloat)
            case textWidth
            case relative(CGFloat)
        }
        
        public enum HeightSizeOption: Hashable {
            case absolute(CGFloat)
            case textWidth
            case relative(CGFloat)
        }
        
        public var position: Position = .topLeft
        /**
         The primary text.
         */
        public var text: String? = nil
        /**
         An attributed variant of the primary text.
         */
        public var attributedText: NSAttributedString? = nil
        
        /**
         The image to display.
         */
        public var image: NSImage? = nil
        
        /**
         The image to display.
         */
        public var view: NSView? = nil
        
        /**
         The image to display.
         */
        public var viewProperties: ViewProperties = .default()
        /**
         Properties for configuring the image.
         */
        public var imageProperties: ImageProperties = ImageProperties()
        /**
         Properties for configuring the primary text.
         */
        public var textProperties: TextProperties = .textStyle(.body, weight: .bold)
        
        public var backgroundColor: NSColor? = nil
        public var backgroundColorTansform: NSConfigurationColorTransformer? = nil
        
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTansform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
    }
}


// max(CGFloat)
// exactly(CGFloat)
// keepingAspectRat

