//
//  TableCellContentConfiguration.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit
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
public struct NSTableCellContentConfiguration: NSContentConfiguration, Hashable {
    /// The primary text.
    public var text: String? = nil
    /// An attributed variant of the primary text.
    public var attributedText: AttributedString? = nil
    /// The secondary text.
    public var secondaryText: String? = nil
    /// An attributed variant of the secondary text.
    public var secondaryAttributedText: AttributedString? = nil
    /// The image to display.
    public var image: NSImage? = nil
    /// The view to display.
    public var view: NSView? = nil
    
    /// Array of accessories display at the top of the cell.
    public var topAccessories: [Accessory] = []

    /// Array of accessories display at the bottom of the cell.
    public var bottomAccessories: [Accessory] = []

    /// Properties for configuring the primary text.
    public var textProperties: TextProperties = .body.weight(.bold)
    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: TextProperties = .body
    /// Properties for configuring the content.
    public var contentProperties: ContentProperties = ContentProperties()
    
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
    
    /// The position of the content.
    public var contentPosition: ContentPosition = .leading
    
    public static func `default`() -> NSTableCellContentConfiguration {
        return NSTableCellContentConfiguration()
    }

    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        let contentView = ContentView(configuration: self)
        return contentView
    }
    
    /**
     Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
     */
    public func updated(for state: NSConfigurationState) -> Self {
        var configuration = self
        if let state = state as? NSTableCellConfigurationState {
            if state.isSelected {
                configuration.contentProperties.borderColorTransform = .color(.controlAccentColor)
                if configuration.contentProperties.borderWidth == 0.0 {
                    configuration.contentProperties.borderWidth = 1.0
                    configuration.contentProperties.needsBorderWidthReset = true
                }
                configuration.contentProperties.shadowProperties.colorTransform = .color(.controlAccentColor)
                if configuration.hasContent == false {
                    configuration.textProperties.textColorTansform = .color(.controlAccentColor)
                    configuration.secondaryTextProperties.textColorTansform = .color(.controlAccentColor)
                } else {
                    configuration.textProperties.textColorTansform = nil
                    configuration.secondaryTextProperties.textColorTansform = nil
                }
            } else {
                configuration.contentProperties.borderColorTransform = nil
                configuration.contentProperties.shadowProperties.colorTransform = nil
                configuration.textProperties.textColorTansform = nil
                configuration.secondaryTextProperties.textColorTansform = nil
                if configuration.contentProperties.needsBorderWidthReset == true {
                    configuration.contentProperties.borderWidth = 0.0
                }
            }
        }
        return configuration
    }
    
    internal var hasText: Bool {
        self.text != nil || self.attributedText != nil
    }
    
    internal var hasSecondaryText: Bool {
        self.secondaryText != nil || self.secondaryAttributedText != nil
    }
    
    internal var hasContent: Bool {
        self.image != nil || self.view != nil ||   self.contentProperties.resolvedBackgroundColor() != nil
    }
    
    internal var contentIsHidden: Bool {
        var contentIsHidden = (self.hasContent == false)
        if contentIsHidden == false {
            switch self.contentProperties.size {
                case .textHeight:
                contentIsHidden = self.hasText
            case .secondaryTextHeight:
                contentIsHidden = self.hasSecondaryText
            case .textAndSecondaryTextHeight:
                contentIsHidden = self.hasText || self.hasSecondaryText
            default:
                break
            }
        }
        return contentIsHidden
    }
    
    public enum ContentPosition: Hashable {
        case leading
        case trailing
    }
    
    /*
   public init(text: String? = nil, attributedText: AttributedString? = nil, secondaryText: String? = nil, secondaryattributedText: AttributedString? = nil, image: NSImage? = nil, accessories: [AccessoryProperties] = [], imageProperties: ImageProperties = ImageProperties(), textProperties: TextProperties = TextProperties(), secondaryTextProperties: TextProperties = TextProperties(), imageToTextPadding: CGFloat = 4.0, textToSecondaryTextPadding: CGFloat = 4.0, padding: NSDirectionalEdgeInsets = .init(4.0)) {
        self.text = text
        self.attributedText = attributedText
        self.secondaryText = secondaryText
        self.secondaryattributedText = secondaryattributedText
        self.image = image
        self.accessories = accessories
        self.imageProperties = imageProperties
        self.textProperties = textProperties
        self.secondaryTextProperties = secondaryTextProperties
        self.imageToTextPadding = imageToTextPadding
        self.textToSecondaryTextPadding = textToSecondaryTextPadding
        self.padding = padding
    }
     */
}
