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
public struct NSTableCellContentConfiguration: NSContentConfiguration {
    /// The primary text.
    public var text: String? = nil
    /// An attributed variant of the primary text.
    public var attributedText: AttributedString? = nil
    /// The secondary text.
    public var secondaryText: String? = nil
    /// An attributed variant of the secondary text.
    public var secondaryattributedText: AttributedString? = nil
    /// The image to display.
    public var image: NSImage? = nil
    
    /**
     Array of properties for configuring additional accesories.
     */
    public var accessories: [AccessoryProperties] = []

    /// Properties for configuring the image.
    public var imageProperties: ImageProperties = ImageProperties()
    /// Properties for configuring the primary text.
    public var textProperties: TextProperties = .textStyle(.body, weight: .bold)
    /// Properties for configuring the secondary text.
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

    /// Creates a new instance of the content view using the configuration.
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
