//
//  ItemConfiguration.swift
//  ItemConfiguration
//
//  Created by Florian Zand on 07.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

/**
 A content configuration for a collection view item based content view.
 
 An item content configuration describes the styling and content for an individual element that might appear in a collection view. You fill the configuration with your content, and then assign it directly to collection view items via ``AppKit/NSCollectionViewItem/contentConfiguration``, or to your own view via ``makeContentView()``.
  
 ```swift
 var content = NSItemContentConfiguration()
 
 // Configure content.
 content.image = NSImage(named: "Mozart")
 content.text = "Mozart"
 content.secondaryText = "A genius composer"
 
 // Customize appearance.
 content.textProperties.font = .body
 
 collectionViewItem.contentConfiguration = content
 ```
 */
public struct NSItemContentConfiguration: Hashable, NSContentConfiguration {
    // MARK: Creating item configurations
    
    /// Creates an item content configuration.
    public init() {
        
    }
    
    /// Creates an image item content configuration.
    public static func imageItem(_ image: NSImage, text: String? = nil, secondaryText: String? = nil, cornerRadius: CGFloat = 4.0) -> NSItemContentConfiguration {
        var configuration = NSItemContentConfiguration()
        configuration.text = text
        configuration.secondaryText = secondaryText
        configuration.image = image
        configuration.textProperties = .body
        configuration.textProperties.alignment = .center
        configuration.secondaryTextProperties = .callout
        configuration.secondaryTextProperties.alignment = .center
        configuration.contentProperties.cornerRadius = cornerRadius
        return configuration
    }
    
    /// Creates a view item content configuration.
    public static func viewItem(_ view: NSView, text: String? = nil, secondaryText: String? = nil, cornerRadius: CGFloat = 4.0) -> NSItemContentConfiguration {
        var configuration = NSItemContentConfiguration()
        configuration.text = text
        configuration.secondaryText = secondaryText
        configuration.view = view
        configuration.textProperties = .body
        configuration.textProperties.alignment = .center
        configuration.secondaryTextProperties = .callout
        configuration.secondaryTextProperties.alignment = .center
        configuration.contentProperties.cornerRadius = cornerRadius
        return configuration
    }
    
    /// Creates a list item content configuration.
    public static func listItem(_ text: String, secondaryText: String? = nil, image: NSImage? = nil) -> NSItemContentConfiguration {
        var configuration = NSItemContentConfiguration()
        configuration.text = text
        configuration.secondaryText = secondaryText
        configuration.image = image
        configuration.contentPosition = .leading
        configuration.textProperties = .body
        configuration.textProperties.alignment = .left
        configuration.secondaryTextProperties = .callout
        configuration.secondaryTextProperties.alignment = .left
        return configuration
    }
    
    // MARK: Creating item configurations
    
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
    /// An overlay view the system places above the view and image and automatically resizes to fill the frame.
    public var overlayView: NSView? = nil
    /// The badges displayed either as overlay or attachment next to the image/view.
    public var badges: [Badge] = []
    
    // MARK: Customizing appearance
    
    /// Properties for configuring the primary text.
    public var textProperties: ContentConfiguration.Text = {
        var properties: ContentConfiguration.Text = .body
        properties.alignment = .center
        return properties
    }()
    
    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: ContentConfiguration.Text = {
        var properties: ContentConfiguration.Text = .caption1
        properties.alignment = .center
        return properties
    }()
    
    /**
     Properties for configuring the content view that displays the `view` and `image`.
     
     The properties only applies when there’s a `view` and/or `image`.
     */
    public var contentProperties: ContentProperties = ContentProperties() {
        didSet {
            if isRestoringContentProperties == false {
                _borderColor = contentProperties._resolvedBorderColor
                _borderWidth = contentProperties.borderWidth
                _shadowColor = contentProperties.shadow.resolvedColor()
            }
        }
    }
    
    /**
     The padding between the content view that displays  the`image` and/or `view`  and text.
     
     This value only applies when there’s both content (`image` and/or `view`) and text.
     */
    public var contentToTextPadding: CGFloat = 6.0
    
    /**
     The padding between the primary and secondary text.
     
     This value only applies when there’s both a text and secondary text.
     */
    public var textToSecondaryTextPadding: CGFloat = 4.0
    
    /**
     The position of the content view that displays  the`image` and/or `view` next to the text.
     
     This value only applies when there’s both content and text.
     */
    public var contentPosition: ContentPosition = .top
    
    /// The margins between the content and the edges of the content view.
    public var margins: NSDirectionalEdgeInsets = .init(6.0)
    
    /**
     The scaling of the item.
     
     The default is 1.0, which displays the item at it's original scale. A larger value will display the item at a larger, a smaller value at a smaller size.
     */
    public var scaleTransform: CGFloat = 1.0
    
    // MARK: Creating a content view
    
    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & FZUIKit.NSContentView {
        return NSItemContentView(configuration: self)
    }
    
    // MARK: Updating the configuration
    
    /// Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
    public func updated(for state: NSConfigurationState) -> NSItemContentConfiguration {
        var configuration = self
        if let state = state as? CollectionConfigurationState {
            if state.isSelected {
        
                
                var savedContentProperties = SavedContentProperties()
                savedContentProperties.borderWidth = configuration.contentProperties.borderWidth
                savedContentProperties.borderColor = configuration.contentProperties._resolvedBorderColor
                savedContentProperties.shadowColor = configuration.contentProperties.shadow.resolvedColor()
           //     configuration.savedContentProperties = savedContentProperties
                
                configuration.contentProperties.borderWidth = configuration.contentProperties.borderWidth != 0.0 ? configuration.contentProperties.borderWidth : 2.0
                configuration.contentProperties.borderColor = .controlAccentColor
                let shadow = configuration.contentProperties.shadow
                if shadow.resolvedColor() != nil, shadow.resolvedColor() != .clear, shadow.opacity != 0.0 {
                     configuration.contentProperties.shadow.color = .controlAccentColor
                }
            } else {
                
                configuration.isRestoringContentProperties = true
                configuration.contentProperties.borderWidth = configuration._borderWidth
                configuration.contentProperties.borderColor = configuration._borderColor
                configuration.contentProperties.shadow.color = configuration._shadowColor
                configuration.isRestoringContentProperties = false
                 
                /*
                if let savedContentProperties = configuration.savedContentProperties {
                    configuration.contentProperties.borderWidth = savedContentProperties.borderWidth
                    configuration.contentProperties.borderColor = savedContentProperties.borderColor
                    configuration.contentProperties.shadow.color = savedContentProperties.shadowColor
                }
                 */
                
            }
        }
        return configuration
    }
    
   // var savedContentProperties: SavedContentProperties? = nil
    internal struct SavedContentProperties {
        internal var borderWidth: CGFloat = 0.0
        internal var borderColor: NSUIColor? = nil
        internal var shadowColor: NSUIColor? = nil
    }
    
    internal var _borderWidth: CGFloat = 0.0
    internal var _borderColor: NSUIColor? = nil
    internal var _shadowColor: NSUIColor? = nil
    internal var isRestoringContentProperties: Bool = false
    
    internal var contentAlignment: NSLayoutConstraint.Attribute  {
        switch self.contentPosition {
        case .bottom, .top: return .centerX
        case .leading, .trailing: return .centerY
        case .leadingFirstBaseline, .trailingFirstBaseline: return .firstBaseline
        }
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
    
    internal var hasBadges: Bool {
        self.badges.isEmpty == false && self.hasContent
    }
    
    /// The position of the content.
    public enum ContentPosition: Hashable {
        /// The content is displayed before the text.
        case leading
        /// The content is displayed before the text.
        case leadingFirstBaseline
        /// The content is displayed after the text.
        case trailing
        /// The content is displayed after the text.
        case trailingFirstBaseline
        /// The content is displayed above the text.
        case top
        /// The content is displayed bellow the text.
        case bottom
        
        internal var contentIsLeading: Bool {
            self == .leading || self == .leadingFirstBaseline || self == .top
        }
        
        internal var isFirstBaseline: Bool {
            self == .trailingFirstBaseline || self == .leadingFirstBaseline
        }
        
        internal var orientation: NSUserInterfaceLayoutOrientation {
            return (self == .top || self == .bottom) ? .vertical : .horizontal
        }
    }
}

/*
 internal func shouldRecalculateContentView(_ previous: Self) {
 let keyPaths: [PartialKeyPath<Self>] = [\.contentProperties.imageScaling.shouldResize, \.image, \.view, \.contentProperties.maxWidth, \.contentProperties.maxHeight]
 
 self.contentProperties.imageScaling.shouldResize != previous.contentProperties.imageScaling.shouldResize ||
 self.image != previous.image
 }
 */
