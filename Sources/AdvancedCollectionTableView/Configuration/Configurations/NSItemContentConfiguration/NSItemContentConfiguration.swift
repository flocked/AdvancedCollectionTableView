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
 A content configuration for a collection item-based content view.
 
 An item content configuration describes the styling and content for an individual element that might appear in a collection view. Using a item content configuration, you can obtain system default styling for a variety of different item states. You fill the configuration with your content, and then assign it directly to collection view items via ``NSCollectionViewItem.contentConfiguration``, or to your own view via ``NSItemContentConfiguration.makeContentView()``.
 
 ```
 public var content = collectionViewItem.defaultContentConfiguration()

 // Configure content.
 content.text = "Favorites"
 content.image = NSImage(systemSymbolName: "star", accessibilityDescription: "star")

 // Customize appearance.
 content.imageProperties.tintColor = .purple

 collectionViewItem.contentConfiguration = content
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
     
     The content displays the ``view``, ``image`` and/or ``contentProperties.backgroundColor``.
     */
    public var contentProperties: ContentProperties = ContentProperties()

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
    
    /// The position of the content next to the text.
    public var contentPosition: ContentPosition = .top
    
    /// The margins between the content and the edges of the content view.
    public var padding: NSDirectionalEdgeInsets = .init(4.0)
    
    /**
    The scaling of the item.
     
    The default is 1.0, which displays the item at it's original scale.
     */
    public var scaleTransform: CGFloat = 1.0
    
    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        return NSItemContentView(configuration: self)
    }
    
    /**
     Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
     */
    public func updated(for state: NSConfigurationState) -> Self {
        var configuration = self
        if let state = state as? NSItemConfigurationState {
            if state.isSelected {
                configuration.contentProperties.borderColorTransform = .color(.controlAccentColor)
                if configuration.contentProperties.borderWidth == 0.0 {
                    configuration.contentProperties.borderWidth = 2.0
                    configuration.contentProperties.needsBorderWidthReset = true
                }
                configuration.contentProperties.shadowProperties.colorTransform = .color(.controlAccentColor)
                Swift.print("_resolvedBorderColor", configuration.contentProperties._resolvedBorderColor)
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
        configuration.updateResolvedColors()
        return configuration
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
    
    mutating internal func updateResolvedColors() {
        self.contentProperties.updateResolvedColors()
        self.contentProperties.shadowProperties.updateResolvedColor()
        self.textProperties.updateResolvedTextColor()
        self.secondaryTextProperties.updateResolvedTextColor()
    }
    
    /// The position of the content.
    public enum ContentPosition: Hashable {
        /// The content is displayed before the text.
        case leading
        /// The content is displayed after the text.
        case trailing
        /// The content is displayed above the text.
        case top
        /// The content is displayed bellow the text.
        case bottom
        
        internal var isVertical: Bool {
            self == .top || self == .bottom
        }
    }

    public init(text: String? = nil,
         attributedText: AttributedString? = nil,
         secondaryText: String? = nil,
         secondaryAttributedText: AttributedString? = nil,
         image: NSImage? = nil,
         view: NSView? = nil,
         textProperties: TextProperties = .body,
         secondaryTextProperties: TextProperties = .caption1,
         contentProperties: ContentProperties = ContentProperties(),
         contentPosition: ContentPosition = .top,
         contentToTextPadding: CGFloat = 6.0,
         textToSecondaryTextPadding: CGFloat = 2.0,
         padding: NSDirectionalEdgeInsets = .init(4.0),
         scaleTransform: CGFloat = 1.0) {
        self.text = text
        self.attributedText = attributedText
        self.secondaryText = secondaryText
        self.secondaryAttributedText = secondaryAttributedText
        self.image = image
        self.view = view
        self.textProperties = textProperties
        self.secondaryTextProperties = secondaryTextProperties
        self.contentPosition = contentPosition
        self.contentProperties = contentProperties
        self.contentToTextPadding = contentToTextPadding
        self.textToSecondaryTextPadding = textToSecondaryTextPadding
        self.padding = padding
        self.scaleTransform = scaleTransform
    }
    
    public static func imageItem(_ image: NSImage, text: String? = nil, secondaryText: String? = nil, cornerRadius: CGFloat = 4.0) -> NSItemContentConfiguration {
        return NSItemContentConfiguration(text: text, secondaryText: secondaryText, image: image, textProperties: .body, secondaryTextProperties: .callout, contentProperties: ContentProperties(shape: .roundedRect(cornerRadius)))
    }
    
    public static func viewItem(_ view: NSView, text: String? = nil, secondaryText: String? = nil, cornerRadius: CGFloat = 4.0) -> NSItemContentConfiguration {
        return NSItemContentConfiguration(text: text, secondaryText: secondaryText, view: view, textProperties: .body, secondaryTextProperties: .callout, contentProperties: ContentProperties(shape: .roundedRect(cornerRadius)))
    }
}

