//
//  NSTableCellContentConfiguration.swift
//  
//
//  Created by Florian Zand on 18.06.23.
//

import AppKit
import FZUIKit

/**
 A content configuration for a table cell based content view.
 
 A table cell content configuration describes the styling and content for an individual table cell element. You fill the configuration with your content, and then assign it directly to a NSTableCellView, or any other view accepting a content configuration.
 
 Use  NSTableCellView.defaultContentConfiguration() to get a content configuration that has preconfigured default styling based on the table view it is presented.
 
 ```
 var content = tableCell.defaultContentConfiguration()
 
 // Configure content.
 content.image = NSImage(systemSymbolName: "star")
 content.text = "Favorites"
 
 // Customize appearance.
 content.imageProperties.tintColor = .purple
 
 tableCell.contentConfiguration = content
 ```
 */
public struct NSTableCellContentConfiguration: NSContentConfiguration, Hashable {
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
    
    /// Properties for configuring the primary text.
    public var textProperties: ConfigurationProperties.Text = .primary
    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: ConfigurationProperties.Text = .secondary
    /// Properties for configuring the image.
    public var imageProperties = ImageProperties()
    
    /// The padding between the image and text.
    public var imageToTextPadding: CGFloat = 8.0
    /// The padding between primary and secndary text.
    public var textToSecondaryTextPadding: CGFloat = 2.0
    /// The margins between the content and the edges of the content view.
    public var insets = NSEdgeInsets(top: 6.0, left: 4.0, bottom: 6.0, right: 4.0)
    
    internal var type: TableCellType? = nil
    internal var tableViewStyle: NSTableView.Style? = nil
    
    internal enum TableCellType {
        case sidebar
        case large
        case automatic
        case plain
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
    
    internal var check: (Bool, Bool, Bool) {
        return (hasText, hasSecondaryText, hasContent)
    }
    
    internal var contentPosition: ImageProperties.ImagePosition? {
        guard hasContent else { return nil }
        return imageProperties.position
    }
    
    internal var contentSizing: ImageProperties.ImageSizing? {
        guard hasContent else { return nil }
        return imageProperties.sizing
    }
    
    // When an updated configuration gets applied the content view, the values get compared to the previos configuration. If any value changed, an update to the layout constraints is needed.
    internal var constraintProperties: [any Equatable] {
        [self.hasText, self.hasSecondaryText, self.hasContent, self.imageToTextPadding, self.textToSecondaryTextPadding, self.insets, self.imageProperties.sizing]
    }
    
    mutating internal func updateResolvedColors() {
        self.imageProperties.updateResolvedColors()
        self.imageProperties.shadowProperties.updateResolvedColor()
        self.textProperties.updateResolvedTextColor()
        self.secondaryTextProperties.updateResolvedTextColor()
    }
    
    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        return NSTableCellContentView(configuration: self)
    }
    
    /// Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
    public func updated(for state: NSConfigurationState) -> NSTableCellContentConfiguration {
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
    
    /// Creates a cell content configuration.
    public init(text: String? = nil,
                attributedText: AttributedString? = nil,
                secondaryText: String? = nil,
                secondaryAttributedText: AttributedString? = nil,
                image: NSImage? = nil,
                textProperties: ConfigurationProperties.Text = .primary,
                secondaryTextProperties: ConfigurationProperties.Text = .secondary,
                imageProperties: ImageProperties = ImageProperties(),
                imageToTextPadding: CGFloat = 8.0,
                textToSecondaryTextPadding: CGFloat = 2.0,
                insets: NSEdgeInsets = NSEdgeInsets(top: 6.0, left: 4.0, bottom: 6.0, right: 4.0)) {
        self.text = text
        self.attributedText = attributedText
        self.secondaryText = secondaryText
        self.secondaryAttributedText = secondaryAttributedText
        self.image = image
        self.textProperties = textProperties
        self.secondaryTextProperties = secondaryTextProperties
        self.imageProperties = imageProperties
        self.imageToTextPadding = imageToTextPadding
        self.textToSecondaryTextPadding = textToSecondaryTextPadding
        self.insets = insets
        self.type = nil
        self.tableViewStyle = nil
    }
}

public extension NSTableCellContentConfiguration {
    enum SidebarImageColor {
        case multiColor(NSColor)
        case accentColor
        case color(NSColor)
        internal var tintColor: NSColor? {
            switch self {
            case .multiColor(_): return nil
            case .accentColor: return .controlAccentColor
            case .color(let color): return color
            }
        }
        internal var symbolColorConfiguration: ConfigurationProperties.SymbolConfiguration.ColorConfiguration {
            switch self {
            case .multiColor(let color): return .multicolor(color)
            case .accentColor: return .monochrome
            case .color(_): return .monochrome
            }
        }
    }
    
    static func plain(imageColor: SidebarImageColor = .accentColor) -> NSTableCellContentConfiguration {
        var configuration = sidebar(.body, imageColor: imageColor)
        configuration.imageToTextPadding = 6.0
        configuration.type = .plain
        configuration.insets = NSEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
        return configuration
    }
    
    internal static func automatic() -> NSTableCellContentConfiguration {
        var configuration = sidebar(.body, imageColor: .accentColor)
        configuration.type = .automatic
        return configuration 
    }
    
    static func sidebar(imageColor: SidebarImageColor = .accentColor) -> NSTableCellContentConfiguration {
        return sidebar(.body, imageColor: imageColor)
    }
    
    static func sidebarHeader() -> NSTableCellContentConfiguration {
        var configuration = NSTableCellContentConfiguration()
        configuration.type = .sidebarHeader
        configuration.textProperties.font = .subheadline.weight(.bold)
        configuration.textProperties.textColor = .tertiaryLabelColor
        configuration.imageProperties.tintColor = .tertiaryLabelColor
        configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .subheadline, weight: .bold), colorConfiguration: .monochrome)
        configuration.insets = .init(top: 2, left: 0.0, bottom: 2, right: 2.0)
        return configuration
    }
    
    static func large(imageColor: SidebarImageColor = .accentColor) -> NSTableCellContentConfiguration {
        var configuration = sidebar(.title3, imageColor: imageColor)
        configuration.type = .large
        configuration.insets = NSEdgeInsets(top: 8.0, left: 4.0, bottom: 8.0, right: 4.0)
        return configuration
    }
    
    internal func tableViewStyle(_ style: NSTableView.Style) -> NSTableCellContentConfiguration {
        var configuration = self
        configuration.tableViewStyle = style
        switch style {
        case .automatic: return .sidebar()
        case .fullWidth, .plain, .inset:
            configuration.textProperties.font = .body
            configuration.secondaryTextProperties.font = .body
            configuration.imageToTextPadding = 6.0
            configuration.insets = NSEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
        case .sourceList:
            configuration.textProperties.font = .body
            configuration.secondaryTextProperties.font = .body
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle(.body))
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .body), colorConfiguration: .monochrome)
            configuration.imageToTextPadding = 8.0
            configuration.insets = NSEdgeInsets(top: 6.0, left: 4.0, bottom: 6.0, right: 4.0)
        @unknown default:
            configuration.textProperties.font = .body
            configuration.secondaryTextProperties.font = .body
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle(.body))
            configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .body), colorConfiguration: .monochrome)
            configuration.imageToTextPadding = 8.0
            configuration.insets = NSEdgeInsets(top: 6.0, left: 4.0, bottom: 6.0, right: 4.0)
        }
        return configuration
    }
    
    internal static func tableViewStyle(_ style: NSTableView.Style) -> NSTableCellContentConfiguration {
        switch style {
        case .automatic: return .sidebar()
        case .fullWidth:  return .plain()
        case .inset: return .plain()
        case .sourceList: return .sidebar()
        case .plain: return .plain()
        @unknown default: return .sidebar()
        }
    }
    
    internal static func sidebar(_ style: NSFont.TextStyle, weight: NSFont.Weight = .regular, imageColor: SidebarImageColor = .accentColor) -> NSTableCellContentConfiguration {
        var configuration = NSTableCellContentConfiguration()
        configuration.type = .sidebar
        configuration.textProperties.font = .system(style).weight(weight)
        configuration.secondaryTextProperties.font = .system(style).weight(weight)
        configuration.imageProperties.symbolConfiguration = .font(style, weight: weight.symbolWeight())
        configuration.imageProperties.tintColor = imageColor.tintColor
        configuration.imageProperties.symbolConfiguration = .font(style).colorConfiguration(imageColor.symbolColorConfiguration)
        configuration.imageToTextPadding = 8.0
        configuration.insets = NSEdgeInsets(top: 6.0, left: 4.0, bottom: 6.0, right: 4.0)
        return configuration
    }
    
}
