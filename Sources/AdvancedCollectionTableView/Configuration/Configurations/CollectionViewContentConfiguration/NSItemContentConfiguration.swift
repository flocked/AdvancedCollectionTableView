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
    
    // The primary text.
    public var text: String? = nil
    // An attributed variant of the primary text.
    public var attributedText: AttributedString? = nil
    // The secondary text.
    public var secondaryText: String? = nil
    // An attributed variant of the secondary text.
    public var secondaryattributedText: AttributedString? = nil
    // The image to display.
    public var image: NSImage? = nil
    // The view to display.
    public var view: NSView? = nil
    
    // Properties for configuring the primary text.
    public var textProperties: TextProperties = .textStyle(.body, weight: .bold)
    // Properties for configuring the secondary text.
    public var secondaryTextProperties: TextProperties = .textStyle(.body)
    // Properties for configuring the image.
    public var imageProperties: ImageProperties = ImageProperties()
    // Properties for configuring the image.
    public var contentProperties: ContentProperties = ContentProperties()
   
    /**
     The padding between the image and text.
     
     This value only applies when there’s both an image and text.
     */
    public var orientation: NSUserInterfaceLayoutOrientation = .horizontal
    /**
     A Boolean value that determines whether the configuration positions the text and secondary text side by side.
     
     When this value is true, the configuration positions the text and secondary text side by side if there’s sufficient space. Otherwise, the configuration stacks the text in a vertical layout.
     */
    public var prefersSideBySideTextAndSecondaryText: Bool = false
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
    
    // Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        return NSItemContentConfigurationHostingView(configuration: self)
      //  let contentView = ContentView(configuration: self)
      //  return contentView
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
        self.image != nil || self.contentProperties.backgroundColor != nil
    }
    
    init(text: String? = nil,
         attributedText: AttributedString? = nil,
         secondaryText: String? = nil,
         secondaryattributedText: AttributedString? = nil,
         image: NSImage? = nil,
         imageProperties: ImageProperties = ImageProperties(),
         textProperties: TextProperties = .textStyle(.body),
         secondaryTextProperties: TextProperties = .textStyle(.body),
         contentProperties: ContentProperties = ContentProperties(),
         orientation: NSUserInterfaceLayoutOrientation = .vertical,
         prefersSideBySideTextAndSecondaryText: Bool = false,
         imageToTextPadding: CGFloat = 2.0,
         textToSecondaryTextPadding: CGFloat = 2.0,
         padding: NSDirectionalEdgeInsets = .zero) {
        self.text = text
        self.attributedText = attributedText
        self.secondaryText = secondaryText
        self.secondaryattributedText = secondaryattributedText
        self.image = image
        self.imageProperties = imageProperties
        self.textProperties = textProperties
        self.secondaryTextProperties = secondaryTextProperties
        self.orientation = orientation
        self.prefersSideBySideTextAndSecondaryText = prefersSideBySideTextAndSecondaryText
        self.imageToTextPadding = imageToTextPadding
        self.textToSecondaryTextPadding = textToSecondaryTextPadding
        self.padding = padding
    }
    
    static func image(_ image: NSImage, text: String? = nil, secondaryText: String? = nil, cornerRadius: CGFloat = 0.0) -> NSItemContentConfiguration {
        return NSItemContentConfiguration(text: text, secondaryText: secondaryText, image: image, contentProperties: ContentProperties(shape: .roundedRectangular(cornerRadius)))
    }
}

internal extension String {
    func transform(using transform: NSItemContentConfiguration.TextProperties.TextTransform) -> String {
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
    func transform(using transform: NSItemContentConfiguration.TextProperties.TextTransform) -> String {
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

extension AttributedString {
    func transform(using transform: NSItemContentConfiguration.TextProperties.TextTransform) -> String {
        switch transform {
        case .none:
           return String(self.characters[...])
        case .capitalized:
            return String(self.characters[...]).capitalized
        case .lowercase:
            return String(self.characters[...]).lowercased()
        case .uppercase:
            return String(self.characters[...]).uppercased()
        }
    }
}

/*
 public var cornerRadius: CGFloat = 0.0
 public var backgroundColor: NSColor? = nil
 public var shadowProperties: ShadowProperties = .black()
 public var backgroundColorTransform: NSConfigurationColorTransformer? = nil
 */
