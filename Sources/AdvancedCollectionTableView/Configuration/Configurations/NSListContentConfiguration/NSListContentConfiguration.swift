//
//  NSListContentConfiguration.swift
//
//
//  Created by Florian Zand on 18.06.23.
//

import AppKit
import FZUIKit

/**
 A content configuration for a table cell based content view.
 
 A table cell content configuration describes the styling and content for an individual table cell element. You fill the configuration with your content, and then assign it directly to table cells via ``AppKit/NSTableCellView/contentConfiguration``, or to your own view via ``makeContentView()``.
 
 Use  ``AppKit/NSTableCellView/defaultContentConfiguration()`` to get a content configuration that has preconfigured default styling based on the table view it is presented.
 
 ```swift
 var content = tableCell.defaultContentConfiguration()
 
 // Configure content.
 content.image = NSImage(systemSymbolName: "star")
 content.text = "Favorites"
 
 // Customize appearance.
 content.imageProperties.tintColor = .purple
 
 tableCell.contentConfiguration = content
 ```
 */
public struct NSListContentConfiguration: NSContentConfiguration, AutoSizeable, Hashable {
    // MARK: Creating item configurations

    /// Creates a cell content configuration for a table view with plain style.
    public static func plain(imageColor: SidebarImageColor = .accentColor) -> NSListContentConfiguration {
        var configuration = sidebar(.body, imageColor: imageColor)
        configuration.imageToTextPadding = 6.0
        configuration.type = .plain
        configuration.imageProperties.position = .leading(.firstBaseline)
        configuration.imageProperties.sizing = .firstTextHeight
        configuration.margins = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        return configuration
    }
    
    /// Creates a cell content configuration for a sidebar table view (source style).
    public static func sidebar(imageColor: SidebarImageColor = .accentColor) -> NSListContentConfiguration {
        return sidebar(.body, imageColor: imageColor)
    }
    
    /// Creates a cell content configuration for a sidebar table view (source style).
    public static func image(systemName: String, imageColor: SidebarImageColor = .accentColor) -> NSListContentConfiguration {
        return sidebar(.body, imageColor: imageColor)
    }
    
    /// Creates a header cell content configuration for a sidebar table view (source style).
    public static func sidebarHeader() -> NSListContentConfiguration {
        var configuration = NSListContentConfiguration()
        configuration.type = .sidebarHeader
        configuration.textProperties.font = .subheadline.weight(.bold)
        configuration.textProperties.color = .tertiaryLabelColor
        configuration.imageProperties.tintColor = .tertiaryLabelColor
        configuration.imageProperties.position = .leading(.firstBaseline)
        configuration.imageProperties.sizing = .firstTextHeight
        configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .subheadline, weight: .bold), colorConfiguration: .monochrome)
        configuration.margins = .init(top: 2, leading: 0.0, bottom: 2, trailing: 2.0)
        return configuration
    }
    
    /// Creates a large cell content configuration for a sidebar table view (source style).
    public static func sidebarLarge(imageColor: SidebarImageColor = .accentColor) -> NSListContentConfiguration {
        var configuration = sidebar(.title3, imageColor: imageColor)
        configuration.type = .sidebarLarge
        configuration.margins = .init(top: 8.0, leading: 4.0, bottom: 8.0, trailing: 4.0)
        return configuration
    }
    
    /// Creates a cell content configuration.
    public init() {
        
    }
    
    // MARK: Customizing content
    
    /// The primary text.
    public var text: String? = nil
    /// An attributed variant of the primary text.
    public var attributedText: AttributedString? = nil
    /// The secondary text.
    public var secondaryText: String? = nil
    /// An attributed variant of the secondary text.
    public var secondaryAttributedText: AttributedString? = nil
    /// The image.
    public var image: NSImage? = nil
    
    public var badge: Badge? = nil
    
    // MARK: Customizing appearance
    
    /// Properties for configuring the primary text.
    public var textProperties: ContentConfiguration.Text = .primary
    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: ContentConfiguration.Text = .secondary
    /// Properties for configuring the image.
    public var imageProperties = ImageProperties()
    
    // MARK: Customizing layout
    
    /// The padding between the image and text.
    public var imageToTextPadding: CGFloat = 8.0
    /// The padding between primary and secndary text.
    public var textToSecondaryTextPadding: CGFloat = 2.0
    /// The padding between the text and badge.
    public var textToBadgePadding: CGFloat = 6.0
    /// The margins between the content and the edges of the cell view.
    public var margins = NSDirectionalEdgeInsets(top: 6.0, leading: 4.0, bottom: 6.0, trailing: 4.0)
    
    internal var type: TableCellType? = nil
    internal var tableViewStyle: NSTableView.Style? = nil
    
    internal enum TableCellType {
        case automatic
        case plain
        case sidebar
        case sidebarLarge
        case sidebarHeader
        var isSelectedTextColor: NSColor? {
            switch self {
            default: return nil
            }
        }
    }
    
    internal var hasText: Bool {
        self.text != nil || self.attributedText != nil
    }
    
    internal var hasSecondaryText: Bool {
        self.secondaryText != nil || self.secondaryAttributedText != nil
    }
    
    internal var hasContent: Bool {
        return self.image != nil
    }
    
    internal var hasBadge: Bool {
        return(self.badge?.isVisible == true)
    }
    
    // MARK: Creating a content view
    
    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        return NSListContentView(configuration: self)
    }
    
    // MARK: Updating the configuration
    
    /// Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
    public func updated(for state: NSConfigurationState) -> NSListContentConfiguration {
        return self
        /*
         guard let state = state as? NSTableCellConfigurationState else { return self }
         var configuration = self
         /*
          if state.isSelected, let isSelectedTextColor = self.cellType?.isSelectedTextColor {
          configuration.textProperties.textColorTansform = .color(isSelectedTextColor)
          configuration.secondaryTextProperties.textColorTansform = .color(isSelectedTextColor)
          } else {
          configuration.textProperties.textColorTansform = nil
          configuration.secondaryTextProperties.textColorTansform = nil
          }
          */
         return configuration
         */
    }
}

public extension NSListContentConfiguration {
    /// The image color of a sidebar content configuration.
    enum SidebarImageColor {
        /// Image with a tint color.
        case color(NSColor)
        /// Image with a multicolor symbol configuration.
        case multicolor(NSColor)
        /// Image with a hierarchical symbol configuration.
        case hierarchical(NSColor)
        /// Image with a palette color symbol configuration.
        case palette(NSColor, NSColor, NSColor? = nil)
        public static var accentColor: Self {
            return .color(.controlAccentColor)
        }
        internal var tintColor: NSColor? {
            switch self {
            case .color(let color): return color
            default: return nil
            }
        }
        internal var symbolColorConfiguration: ContentConfiguration.SymbolConfiguration.ColorConfiguration {
            switch self {
            case .palette(let primary, let secondary, let terr):
                return .palette(primary, secondary, terr)
            case .multicolor(let color):
                return .multicolor(color)
            case .hierarchical(let color):
                return .hierarchical(color)
            case .color(_):
                return .monochrome
            }
        }
    }
    
    internal static func automatic() -> NSListContentConfiguration {
        var configuration = sidebar(.body, imageColor: .accentColor)
        configuration.type = .automatic
        configuration.imageProperties.position = .leading(.firstBaseline)
        configuration.imageProperties.sizing = .firstTextHeight
        return configuration
    }
    
    internal func tableViewStyle(_ style: NSTableView.Style) -> NSListContentConfiguration {
        var configuration = self
        configuration.tableViewStyle = style
        switch style {
        case .automatic: return .sidebar()
        case .fullWidth, .plain, .inset:
            configuration.textProperties.font = .body
            configuration.secondaryTextProperties.font = .body
            configuration.imageToTextPadding = 6.0
            configuration.margins = .init(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        case .sourceList:
            configuration.textProperties.font = .body
            configuration.secondaryTextProperties.font = .body
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle(.body))
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .body), colorConfiguration: .monochrome)
            configuration.imageToTextPadding = 3.0
            configuration.margins = .init(top: 6.0, leading: 4.0, bottom: 6.0, trailing: 4.0)
        @unknown default:
            configuration.textProperties.font = .body
            configuration.secondaryTextProperties.font = .body
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle(.body))
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .body), colorConfiguration: .monochrome)
            configuration.imageToTextPadding = 8.0
            configuration.margins = .init(top: 6.0, leading: 4.0, bottom: 6.0, trailing: 4.0)
        }
        return configuration
    }
    
    internal static func tableViewStyle(_ style: NSTableView.Style) -> NSListContentConfiguration {
        switch style {
        case .automatic: return .sidebar()
        case .fullWidth:  return .plain()
        case .inset: return .plain()
        case .sourceList: return .sidebar()
        case .plain: return .plain()
        @unknown default: return .sidebar()
        }
    }
    
    internal static func sidebar(_ style: NSFont.TextStyle, weight: NSFont.Weight = .regular, imageColor: SidebarImageColor = .accentColor) -> NSListContentConfiguration {
        var configuration = NSListContentConfiguration()
        configuration.type = .sidebar
        configuration.imageProperties.position = .leading(.firstBaseline)
        configuration.textProperties.font = .systemFont(style).weight(weight)
        configuration.textProperties.numberOfLines = 1
        configuration.secondaryTextProperties.font = .systemFont(style).weight(weight)
        configuration.imageProperties.symbolConfiguration = .font(style, weight: weight.symbolWeight)
        configuration.imageProperties.tintColor = imageColor.tintColor
        configuration.imageProperties.sizing = .firstTextHeight
        configuration.imageProperties.symbolConfiguration = .font(style).colorConfiguration(imageColor.symbolColorConfiguration)
        configuration.imageToTextPadding = 3.0
        configuration.margins = .init(top: 6.0, leading: 4.0, bottom: 6.0, trailing: 4.0)
        return configuration
    }
    
}

internal extension NSFont.Weight {
    var symbolWeight: NSUIImage.SymbolWeight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
}

/*
 
case .ultraLight: return .ultraLight
case .thin: return .thin
case .light: return .light
case .regular: return .regular
case .medium: return .medium
case .semibold: return .semibold
case .bold: return .bold
case .heavy: return .heavy
case .black: return .black
 */
