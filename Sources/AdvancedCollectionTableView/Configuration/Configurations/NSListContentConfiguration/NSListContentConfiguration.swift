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
 
 A list content configuration describes the styling and content for an individual table cell element. You fill the configuration with your content, and then assign it directly to table cells via ``AppKit/NSTableCellView/contentConfiguration``, or to your own view via ``makeContentView()``.
 
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
public struct NSListContentConfiguration: NSContentConfiguration, Hashable {
    // MARK: Customizing content
    
    /**
     The primary text.
     
     If you configurate the value with a non-`nil` value, ``attributedText`` will be `nil`.
     */
    public var text: String? = nil {
        didSet {
            if text != nil {
                attributedText = nil
            }
        }
    }
    
    /**
     An attributed variant of the primary text.
     
     If you configurate the value with a non-`nil` value, ``text`` will be `nil`.
     */
    public var attributedText: AttributedString? = nil {
        didSet {
            if attributedText != nil {
                text = nil
            }
        }
    }
    
    /**
     The primary placeholder text.
     
     If you configurate the value with a non-`nil` value, ``attributedPlaceholderText`` will be `nil`.
     */
    public var placeholderText: String? = nil {
        didSet {
            if placeholderText != nil {
                attributedPlaceholderText = nil
            }
        }
    }
    
    /**
     An attributed variant of the primary placeholder text.
     
     If you configurate the value with a non-`nil` value, ``placeholderText`` will be `nil`.
     */
    public var attributedPlaceholderText: AttributedString? = nil {
        didSet {
            if attributedPlaceholderText != nil {
                placeholderText = nil
            }
        }
    }
    
    /**
     The secondary text.
     
     If you configurate the value with a non-`nil` value, ``secondaryAttributedText`` will be `nil`.
     */
    public var secondaryText: String? = nil {
        didSet {
            if secondaryText != nil {
                secondaryAttributedText = nil
            }
        }
    }
    
    /**
     An attributed variant of the secondary text.
     
     If you configurate the value with a non-`nil` value, ``secondaryText`` will be `nil`.
     */
    public var secondaryAttributedText: AttributedString? = nil {
        didSet {
            if secondaryAttributedText != nil {
                secondaryText = nil
            }
        }
    }
    
    /**
     The secondary placeholder text.
     
     If you configurate the value with a non-`nil` value, ``secondaryAttributedPlaceholderText`` will be `nil`.
     */
    public var secondaryPlaceholderText: String? = nil {
        didSet {
            if secondaryPlaceholderText != nil {
                secondaryAttributedPlaceholderText = nil
            }
        }
    }
    
    /**
     An attributed variant of the secondary placeholder text.
     
     If you configurate the value with a non-`nil` value, ``secondaryPlaceholderText`` will be `nil`.
     */
    public var secondaryAttributedPlaceholderText: AttributedString? = nil {
        didSet {
            if secondaryAttributedPlaceholderText != nil {
                secondaryPlaceholderText = nil
            }
        }
    }
    
    /// The image.
    public var image: NSImage? = nil
    
    /// The badge.
    public var badge: Badge? = nil
    
    // MARK: Customizing appearance
    
    /// Properties for configuring the primary text.
    public var textProperties: TextConfiguration = .primary
    
    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: TextConfiguration = .secondary
    
    /// Properties for configuring the image.
    public var imageProperties = ImageProperties()
    
    // MARK: Customizing layout
    
    /// The padding between the image and text.
    public var imageToTextPadding: CGFloat = 8.0
    
    /// The padding between primary and secndary text.
    public var textToSecondaryTextPadding: CGFloat = 2.0
    
    /// The padding between the text and badge.
    public var textToBadgePadding: CGFloat = 6.0
    
    /// The margins between the content and the edges of the list view.
    public var margins = NSDirectionalEdgeInsets(top: 6.0, leading: 4.0, bottom: 6.0, trailing: 4.0)
    
    // MARK: Creating item configurations

    /// Creates a list content configuration for a table view with plain style.
    /**
     Creates a list content configuration for a table view with plain style.
     
     - parameter imageColor: The color of the image, if it's a template or symbol image. The default value is `monochrome(.controlAccentColor)`.
          */
    public static func plain(imageColor: ImageSymbolConfiguration.ColorConfiguration = .monochrome(.controlAccentColor)) -> NSListContentConfiguration {
        var configuration = sidebar(.body, color: imageColor)
        configuration.imageToTextPadding = 6.0
        configuration.type = .plain
        configuration.imageProperties.position = .leading(.firstBaseline)
        configuration.imageProperties.sizing = .firstTextHeight
        configuration.margins = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        return configuration
    }
    
    /**
     Creates a list content configuration for a sidebar table view (source style).
     
     - parameter imageColor: The color of the image, if it's a template or symbol image. The default value is `monochrome(.controlAccentColor)`.
     */
    public static func sidebar(imageColor: ImageSymbolConfiguration.ColorConfiguration = .monochrome(.controlAccentColor)) -> NSListContentConfiguration {
        return sidebar(.body, color: imageColor)
    }
    
    /**
     Creates a list content configuration for a sidebar table view (source style).
     
     - parameter imageColor: The color of the symbol image. The default value is `monochrome(.controlAccentColor)`.
     */
    public static func image(systemName: String, imageColor: ImageSymbolConfiguration.ColorConfiguration = .monochrome(.controlAccentColor)) -> NSListContentConfiguration {
        return sidebar(.body, color: imageColor)
    }
    
    /// Creates a header list content configuration for a sidebar table view (source style).
    public static func sidebarHeader() -> NSListContentConfiguration {
        var configuration = NSListContentConfiguration()
        configuration.type = .sidebarHeader
        configuration.textProperties.font = .subheadline.weight(.bold)
        configuration.textProperties.color = .tertiaryLabelColor
        configuration.imageProperties.tintColor = .tertiaryLabelColor
        configuration.imageProperties.position = .leading(.firstBaseline)
        configuration.imageProperties.sizing = .firstTextHeight
        configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .subheadline, weight: .bold), color: .monochrome)
        configuration.margins = .init(top: 2, leading: 0.0, bottom: 2, trailing: 2.0)
        return configuration
    }
    
    /**
     Creates a large list content configuration for a sidebar table view (source style).
     
     - parameter imageColor: The color of the image, if it's a template or symbol image. The default value is `monochrome(.controlAccentColor)`.
     */
    public static func sidebarLarge(imageColor: ImageSymbolConfiguration.ColorConfiguration = .monochrome(.controlAccentColor)) -> NSListContentConfiguration {
        var configuration = sidebar(.title3, color: imageColor)
        configuration.type = .sidebarLarge
        configuration.margins = .init(top: 8.0, leading: 4.0, bottom: 8.0, trailing: 4.0)
        return configuration
    }
    
    /// Creates a list content configuration with an editable text.
    public static func editableText(text: String?, placeholderText: String?, onTextEditEnd: @escaping (String)->()) -> Self {
        var configuration: Self = .plain()
        configuration.text = text
        configuration.placeholderText = placeholderText
        configuration.textProperties.onEditEnd = onTextEditEnd
        return configuration
    }
    
    /// Creates a list content configuration.
    public init() {
        
    }
    
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
        text != nil || attributedText != nil
    }
    
    internal var hasSecondaryText: Bool {
        secondaryText != nil || secondaryAttributedText != nil
    }
    
    internal var hasContent: Bool {
        image != nil
    }
    
    internal var hasBadge: Bool {
        badge?.isVisible == true
    }
    
    internal var state: NSTableCellConfigurationState? = nil
    
    // MARK: Creating a content view
    
    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        return NSListContentView(configuration: self)
    }
    
    // MARK: Updating the configuration
    
    /// Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
    public func updated(for state: NSConfigurationState) -> NSListContentConfiguration {
        var configuration = self
        configuration.state = state as? NSTableCellConfigurationState
        return configuration
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
    internal static func automatic() -> NSListContentConfiguration {
        var configuration = sidebar(.body, color: .accentColor)
        configuration.type = .automatic
        configuration.imageProperties.position = .leading(.firstBaseline)
        configuration.imageProperties.sizing = .firstTextHeight
        return configuration
    }
    
    internal func tableViewStyle(_ style: NSTableView.Style, isGroupRow: Bool = false) -> NSListContentConfiguration {
        var configuration = self
        configuration.tableViewStyle = style
        switch style {
        case .automatic:
            return configuration
        case .fullWidth, .plain, .inset:
            configuration.textProperties.font = .body
            configuration.secondaryTextProperties.font = .body
            configuration.imageToTextPadding = 6.0
            configuration.margins = .init(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        case .sourceList:
            if isGroupRow {
                configuration.textProperties.font = .subheadline.weight(.bold)
                configuration.textProperties.color = .tertiaryLabelColor
                configuration.imageProperties.tintColor = .tertiaryLabelColor
                configuration.imageProperties.position = .leading(.firstBaseline)
                configuration.imageProperties.sizing = .firstTextHeight
                configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .subheadline, weight: .bold), color: .monochrome)
                configuration.margins = .init(top: 2.0, leading: 0.0, bottom: 2.0, trailing: 2.0)
            } else {
                configuration.textProperties.font = .body
                configuration.secondaryTextProperties.font = .body
                configuration.imageProperties.symbolConfiguration = .init(font: .textStyle(.body))
                configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .body), color: .monochrome)
                configuration.imageToTextPadding = 3.0
                configuration.margins = .init(top: 6.0, leading: 4.0, bottom: 6.0, trailing: 4.0)
            }
        @unknown default:
            configuration.textProperties.font = .body
            configuration.secondaryTextProperties.font = .body
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle(.body))
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .body), color: .monochrome)
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
    
    internal static func sidebar(_ style: NSFont.TextStyle, weight: NSFont.Weight = .regular, color: ImageSymbolConfiguration.ColorConfiguration) -> NSListContentConfiguration {
        var configuration = NSListContentConfiguration()
        configuration.type = .sidebar
        configuration.imageProperties.position = .leading(.firstBaseline)
        configuration.textProperties.font = .systemFont(style).weight(weight)
        configuration.textProperties.numberOfLines = 1
        configuration.secondaryTextProperties.font = .systemFont(style).weight(weight)
        configuration.imageProperties.symbolConfiguration = .font(style, weight: weight.symbolWeight)
        configuration.imageProperties.tintColor = color.primary
        configuration.imageProperties.sizing = .firstTextHeight
        configuration.imageProperties.symbolConfiguration = .font(style).color(color)
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
