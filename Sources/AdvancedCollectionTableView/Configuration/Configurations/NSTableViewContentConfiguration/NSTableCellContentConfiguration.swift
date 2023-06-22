//
//  NSTableCellContentConfiguration.swift
//  
//
//  Created by Florian Zand on 18.06.23.
//

import AppKit
import FZUIKit

public struct NSTableCellContentConfiguration: NSContentConfiguration, Hashable {
    
    public var text: String? = nil
    public var attributedText: AttributedString? = nil
    public var secondaryText: String? = nil
    public var secondaryAttributedText: AttributedString? = nil
    public var image: NSImage? = nil
    
    public var textProperties = TextProperties.primary()
    public var secondaryTextProperties = TextProperties.secondary()
    public var imageProperties = ImageProperties()

    public var imageToTextPadding: CGFloat = 8.0
    public var textToSecondaryTextPadding: CGFloat = 2.0
    public var insets = NSEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    
    internal var cellType: CellType? = nil
    
    internal enum CellType {
        case sidebar
        case sidebarAlt
        var isSelectedTextColor: NSColor? {
            switch self {
            case .sidebarAlt: return .white
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
        return imageProperties.imagePosition
    }
    
    internal var contentSizing: ImageProperties.ImageSizing? {
        guard hasContent else { return nil }
        return imageProperties.imageSizing
    }
    
    // When an updated configuration gets applied the content view, the values get compared to the previos configuration. If any value changed, an update to the layout constraints is needed.
    internal var constraintProperties: [any Equatable] {
        [self.hasText, self.hasSecondaryText, self.hasContent, self.imageToTextPadding, self.textToSecondaryTextPadding, self.insets, self.imageProperties.imageSizing]
    }
    
    mutating internal func updateResolvedColors() {
        self.imageProperties.updateResolvedColors()
        self.imageProperties.shadowProperties.updateResolvedColor()
        self.textProperties.updateResolvedTextColor()
        self.secondaryTextProperties.updateResolvedTextColor()
    }
    
    public func makeContentView() -> NSView & AdvancedCollectionTableView.NSContentView {
        return NSTableCellContentView(configuration: self)
    }
    
    public func updated(for state: AdvancedCollectionTableView.NSConfigurationState) -> NSTableCellContentConfiguration {
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
        internal var symbolColorConfiguration:  NSTableCellContentConfiguration.SymbolConfiguration.ColorConfiguration {
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
        configuration.insets = NSEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
        return configuration
    }
    
    static func sidebar(imageColor: SidebarImageColor = .accentColor) -> NSTableCellContentConfiguration {
        return sidebar(.body, imageColor: imageColor)
    }
    
    static func sidebarHeader() -> NSTableCellContentConfiguration {
        var configuration = NSTableCellContentConfiguration()
        configuration.textProperties.font = .subheadline.weight(.bold)
        configuration.textProperties.textColor = .tertiaryLabelColor
        configuration.imageProperties.tintColor = .tertiaryLabelColor
        configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .subheadline, weight: .bold), colorConfiguration: .monochrome)
        configuration.insets = .init(top: 2, left: 0.0, bottom: 2, right: 2.0)
        return configuration
    }
    
    static func large(imageColor: SidebarImageColor = .accentColor) -> NSTableCellContentConfiguration {
        var configuration = sidebar(.title3, imageColor: imageColor)
        configuration.insets = NSEdgeInsets(top: 8.0, left: 4.0, bottom: 8.0, right: 4.0)
        return configuration
    }
    
    internal static func sidebar(_ style: NSFont.TextStyle, weight: NSFont.Weight = .regular, imageColor: SidebarImageColor = .accentColor) -> NSTableCellContentConfiguration {
        var configuration = NSTableCellContentConfiguration()
        configuration.textProperties.font = .system(style).weight(weight)
        configuration.imageProperties.symbolConfiguration = .init(font: .textStyle(style, weight: weight.symbolWeight()))
        configuration.imageProperties.tintColor = imageColor.tintColor
        configuration.imageProperties.symbolConfiguration = .init(font: .textStyle( .subheadline), colorConfiguration: imageColor.symbolColorConfiguration)
        configuration.imageToTextPadding = 8.0
        configuration.insets = NSEdgeInsets(top: 6.0, left: 4.0, bottom: 6.0, right: 4.0)
        return configuration
    }
    
}
