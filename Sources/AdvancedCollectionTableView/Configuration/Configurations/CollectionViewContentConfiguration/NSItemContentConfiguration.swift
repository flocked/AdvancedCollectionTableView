//
//  CollectionItemContentConfiguration.swift
//  NSCollectionViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

/**
 A content configuration for a table item-based content view.
 
 A table item content configuration describes the styling and content for an individual element that might appear in a list, like a item, header, or footer. Using a list content configuration, you can obtain system default styling for a variety of different view states. You fill the configuration with your content, and then assign it directly to items, headers, and footers in ``NSCollectionView``, or to your own custom list content view (``NSContentView``).
 
 For views like items, headers, and footers, use their ``defaultContentConfiguration()`` to get a list content configuration that has preconfigured default styling. Alternatively, you can create a list content configuration from one of the system default styles. After you get the configuration, you assign your content to it, customize any other properties, and assign it to your view as the current content configuration.
 
 ```
 public var content = item.defaultContentConfiguration()

 // Configure content.
 content.text = "Favorites"
 content.image = NSImage(systemSymbolName: "star", accessibilityDescription: "star")

 // Customize appearance.
 content.imageProperties.tintColor = .purple

 item.contentConfiguration = content
 ```
 */
public struct NSItemContentConfiguration: NSContentConfiguration, Hashable {
    
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
    
    /// Properties for configuring the primary text.
    public var textProperties: TextProperties = .body
    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: TextProperties = .caption1
    /**
     Properties for configuring the content.
     
     The content view is displayed if there is a item view, image and/or contentProperties.backgroundColor.
     */
    public var contentProperties: ContentProperties = ContentProperties()
   
    /**
     The orientation of the content view and text.
     
     If vertical the text appears below the content view, if horizontal it appears on the right side.
     */
    public var orientation: NSUserInterfaceLayoutOrientation = .vertical

    /**
     The padding between the content view and text.
     
     This value only applies when there’s both a content view and text.
     */
    public var contentToTextPadding: CGFloat = 6.0
    
    /**
     The padding between the primary and secondary text.

     This value only applies when there’s both a text and secondary text.
     */
    public var textToSecondaryTextPadding: CGFloat = 4.0
    
    /// The margins between the content and the edges of the content view.
    public var padding: NSDirectionalEdgeInsets = .init(4.0)
    
    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        return NSItemContentConfigurationHostingView(configuration: self)
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
        self.secondaryText != nil || self.secondaryAttributedText != nil
    }
    
    internal var hasContent: Bool {
        self.image != nil || self.contentProperties.backgroundColor != nil || self.view != nil
    }
    
    init(text: String? = nil,
         attributedText: AttributedString? = nil,
         secondaryText: String? = nil,
         secondaryAttributedText: AttributedString? = nil,
         image: NSImage? = nil,
         view: NSView? = nil,
         textProperties: TextProperties = .body,
         secondaryTextProperties: TextProperties = .caption1,
         contentProperties: ContentProperties = ContentProperties(),
         orientation: NSUserInterfaceLayoutOrientation = .vertical,
         contentToTextPadding: CGFloat = 6.0,
         textToSecondaryTextPadding: CGFloat = 2.0,
         padding: NSDirectionalEdgeInsets = .zero) {
        self.text = text
        self.attributedText = attributedText
        self.secondaryText = secondaryText
        self.secondaryAttributedText = secondaryAttributedText
        self.image = image
        self.view = view
        self.textProperties = textProperties
        self.secondaryTextProperties = secondaryTextProperties
        self.orientation = orientation
        self.contentProperties = contentProperties
        self.contentToTextPadding = contentToTextPadding
        self.textToSecondaryTextPadding = textToSecondaryTextPadding
        self.padding = padding
    }
    
    static func image(_ image: NSImage, text: String? = nil, secondaryText: String? = nil, cornerRadius: CGFloat = 0.0) -> NSItemContentConfiguration {
        return NSItemContentConfiguration(text: text, secondaryText: secondaryText, image: image, contentProperties: ContentProperties(shape: .roundedRectangular(cornerRadius)))
    }
}

/*
/**
 A Boolean value that determines whether the configuration positions the text and secondary text side by side.
 
 When this value is true, the configuration positions the text and secondary text side by side if there’s sufficient space. Otherwise, the configuration stacks the text in a vertical layout.
 */
public var prefersSideBySideTextAndSecondaryText: Bool = false
 */
