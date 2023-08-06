//
//  CollectionItemContentConfiguration.swift
//  
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit


/**
 A content configuration for a collection item-based content view.
 
 An item content configuration describes the styling and content for an individual element that might appear in a collection view.
 
 You fill the configuration with your content, and then assign it directly to collection view items via ``AppKit/NSCollectionViewItem/contentConfiguration``, or to your own view via ``makeContentView()``.
 
 ```swift
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
    // MARK: Creating item configurations
    
    /// Creates a item content configuration.
    public init() {

    }
    
    /// Creates a image item content configuration.
    public static func imageItem(_ image: NSImage, text: String? = nil, secondaryText: String? = nil, cornerRadius: CGFloat = 4.0) -> NSItemContentConfiguration {
        var configuration = NSItemContentConfiguration()
        configuration.text = text
        configuration.secondaryText = secondaryText
        configuration.image = image
        configuration.textProperties = .body.alignment(.center)
        configuration.secondaryTextProperties = .callout.alignment(.center)
        configuration.contentProperties.cornerRadius = cornerRadius
        return configuration
    }
    
    /// Creates a view item content configuration.
    public static func viewItem(_ view: NSView, text: String? = nil, secondaryText: String? = nil, cornerRadius: CGFloat = 4.0) -> NSItemContentConfiguration {
        var configuration = NSItemContentConfiguration()
        configuration.text = text
        configuration.secondaryText = secondaryText
        configuration.view = view
        configuration.textProperties = .body.alignment(.center)
        configuration.secondaryTextProperties = .callout.alignment(.center)
        configuration.contentProperties.cornerRadius = cornerRadius
        return configuration
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
    /// The image to display.
    public var image: NSImage? = nil
    /// The view to display.
    public var view: NSView? = nil
    /// The overlay view for the image and view.
    public var overlayView: NSView? = nil
    
    // MARK: Customizing appearance
    
    /// Properties for configuring the primary text.
    public var textProperties: ConfigurationProperties.Text = .body.alignment(.center)
    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: ConfigurationProperties.Text = .caption1.alignment(.center)
    /**
     Properties for configuring the content).
     
     The content displays the `view`, `image`  and/or `contentProperties.backgroundColor`.
     */
    public var contentProperties: ContentProperties = ContentProperties()
    
    // MARK: Customizing layout
    
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
    
    // MARK: Creating a content view
    
    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        return NSItemContentView(configuration: self)
    }
    
    // MARK: Updating the configuration
    
    internal func needsUpdate(comparedTo compare: Self) -> Bool {
        let keyPaths: [PartialKeyPath<Self>] = [\.text, \.attributedText, \.secondaryText, \.secondaryAttributedText, \.image, \.textProperties.maxNumberOfLines, \.secondaryTextProperties.maxNumberOfLines, \.textProperties.font, \.secondaryTextProperties.font, \.hasContent]
        return self.isEqual(compare, for: keyPaths) == false
    }
        
    // MARK: Updating the configuration
    
    /**
     Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
     */
    public func updated(for state: NSConfigurationState) -> Self {
        var configuration = self
        if let state = state as? NSItemConfigurationState {
            if state.isSelected {
                if configuration.contentProperties.borderWidth == 0.0 {
                    configuration.contentProperties.borderWidth = 2.0
                    configuration.contentProperties.needsBorderWidthReset = true
                }
                if configuration.contentProperties.borderColor == nil {
                    configuration.contentProperties.borderColor = .controlAccentColor
                    configuration.contentProperties.needsBorderColorReset = true
                }
                configuration.contentProperties.shadow.colorTransform = .color(.controlAccentColor)
                if configuration.hasContent == false {
                    configuration.textProperties.textColorTansform = .color(.controlAccentColor)
                    configuration.secondaryTextProperties.textColorTansform = .color(.controlAccentColor)
                } else {
                    configuration.textProperties.textColorTansform = nil
                    configuration.secondaryTextProperties.textColorTansform = nil
                }
            } else {
                configuration.contentProperties.borderColorTransform = nil
                configuration.contentProperties.shadow.colorTransform = nil
                configuration.textProperties.textColorTansform = nil
                configuration.secondaryTextProperties.textColorTansform = nil
                if configuration.contentProperties.needsBorderWidthReset == true {
                    configuration.contentProperties.borderWidth = 0.0
                }
                
                if configuration.contentProperties.needsBorderColorReset == true {
                    configuration.contentProperties.borderColor = nil
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
    
    internal weak var collectionViewItem: NSCollectionViewItem? = nil
    
    mutating internal func updateResolvedColors() {
        self.contentProperties.updateResolvedColors()
        self.contentProperties.shadow.updateResolvedColor()
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
}
