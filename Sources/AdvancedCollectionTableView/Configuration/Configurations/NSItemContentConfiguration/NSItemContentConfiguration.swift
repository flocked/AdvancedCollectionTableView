//
//  NSItemContentConfiguration.swift
//
//
//  Created by Florian Zand on 07.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

/**
 A content configuration for a collection-based content view.

 An item content configuration describes the styling and content for an individual element that might appear in a collection view. You fill the configuration with your content, and then assign it directly to collection view item's via ``AppKit/NSCollectionViewItem/contentConfiguration``, or to your own custom content view (``NSItemContentView``).

 ```swift
 var configuration = NSItemContentConfiguration()

 // Configure content.
 configuration.text = "Text"
 configuration.secondaryText = "Secondary Text"
 configuration.image = NSImage(named: "Sample")

 // Customize appearance.
 configuration.contentProperties.cornerRadius = 10.0

 collectionViewItem.contentConfiguration = configuration
 ```
 
 ![Item Content Configuration](NSItemContentConfiguration)
 */
public struct NSItemContentConfiguration: Hashable, NSContentConfiguration {
    // MARK: Creating item configurations

    /// Creates an item content configuration.
    public init() {}

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

    /**
     The primary text.

     This value supersedes the ``attributedText`` property.
     */
    public var text: String? {
        didSet {
            guard text != nil else { return }
            attributedText = nil
        }
    }

    /**
     An attributed variant of the primary text.

     This value supersedes the ``text`` property.
     */
    public var attributedText: AttributedString? {
        didSet {
            guard attributedText != nil else { return }
            text = nil
        }
    }

    /**
     The primary placeholder text.

     This value supersedes the ``attributedPlaceholderText`` property.
     */
    public var placeholderText: String? {
        didSet {
            guard placeholderText != nil else { return }
            attributedPlaceholderText = nil
        }
    }

    /**
     An attributed variant of the primary placeholder text.

     This value supersedes the ``placeholderText`` property.
     */
    public var attributedPlaceholderText: AttributedString? {
        didSet {
            guard attributedPlaceholderText != nil else { return }
            placeholderText = nil
        }
    }

    /**
     The secondary text.

     This value supersedes the ``secondaryAttributedText`` property.
     */
    public var secondaryText: String? {
        didSet {
            guard secondaryText != nil else { return }
            secondaryAttributedText = nil
        }
    }

    /**
     An attributed variant of the secondary text.

     This value supersedes the ``secondaryText`` property.
     */
    public var secondaryAttributedText: AttributedString? {
        didSet {
            guard secondaryAttributedText != nil else { return }
            secondaryText = nil
        }
    }

    /**
     The secondary placeholder text.

     This value supersedes the ``secondaryAttributedPlaceholderText`` property.
     */
    public var secondaryPlaceholderText: String? {
        didSet {
            guard secondaryPlaceholderText != nil else { return }
            secondaryAttributedPlaceholderText = nil
        }
    }

    /**
     An attributed variant of the secondary placeholder text.

     This value supersedes the ``secondaryPlaceholderText`` property.
     */
    public var secondaryAttributedPlaceholderText: AttributedString? {
        didSet {
            guard secondaryAttributedPlaceholderText != nil else { return }
            secondaryPlaceholderText = nil
        }
    }

    /// The image to display.
    public var image: NSImage?

    /// The view to display.
    public var view: NSView?

    /// An overlay view the system places above the view and image and automatically resizes to fill the frame.
    public var overlayView: NSView?

    /// The badges displayed either as overlay or attachment next to the image/view.
    public var badges: [Badge] = []

    /// The text for the tooltip.
    public var toolTip: String? = nil

    // MARK: Customizing appearance

    /// Properties for configuring the primary text.
    public var textProperties: TextProperties = {
        var properties: TextProperties = .body
        properties.alignment = .center
        return properties
    }()

    /// Properties for configuring the secondary text.
    public var secondaryTextProperties: TextProperties = {
        var properties: TextProperties = .caption1
        properties.alignment = .center
        return properties
    }()
    
    /// Properties for configuring the image.
    public var imageProperties: ImageProperties = .init()

    /**
     Properties for configuring the content view that displays the `view` and `image`.

     The properties only applies when there’s a `view` and/or `image`.
     */
    public var contentProperties: ContentProperties = .init()

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

     The default is `1.0`, which displays the item at it's original scale. A larger value will display the item at a larger and a smaller value at a smaller size.
     */
    public var scaleTransform: Scale = 1.0
    
    /**
     The rotation of the item, in degrees.

     The default is `zero`, which displays the item with no rotation.
     */
    public var rotation: Rotation = .zero
    
    /// The alpha value of the item.
    public var alpha: CGFloat = 1.0

    // MARK: Creating a content view

    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & FZUIKit.NSContentView {
        NSItemContentView(configuration: self)
    }

    // MARK: Updating the configuration

    /// Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
    public func updated(for state: NSConfigurationState) -> NSItemContentConfiguration {
        var configuration = self
        if let state = state as? ConfigurationState {
            let hash = "\(state.isSelected)\(state.isActive)"
            let isSelected = state.isSelected || (state as? NSItemConfigurationState)?.isDropTarget == true
            if isSelected {
                configuration.contentProperties.borderStateTransformer = .init(hash) { border in
                    var border = border
                    if isSelected {
                        border.width = border.width > 3.0 ? border.width : 3.0
                        border.color = state.isActive ? .controlAccentColor : .controlAccentColor.withAlphaComponent(0.7)
                    } else {
                        border.width = 0.0
                        border.color = nil
                    }
                    return border
                }
                configuration.contentProperties.shadowTransformer = .init(hash) { shadow in
                    var shadow = shadow
                    if isSelected {
                        if shadow.opacity != 0.0, let color = shadow.color, color.alphaComponent != 0.0 {
                            shadow.color = state.isActive ? .controlAccentColor : .controlAccentColor.withAlphaComponent(0.7)
                        }
                    }
                    return shadow
                }
            } else {
                configuration.contentProperties.borderStateTransformer = nil
                configuration.contentProperties.shadowStateTransformer = nil
            }
        }
        return configuration
    }

    var contentAlignment: NSLayoutConstraint.Attribute {
        switch contentPosition {
        case .bottom, .top: return .centerX
        case .leading, .trailing: return .centerY
        case .leadingFirstBaseline, .trailingFirstBaseline: return .firstBaseline
        }
    }

    var hasText: Bool {
        text != nil || attributedText != nil
    }

    var hasSecondaryText: Bool {
        secondaryText != nil || secondaryAttributedText != nil
    }

    var hasContent: Bool {
        image != nil || contentProperties.backgroundColor != nil || view != nil
    }

    var hasBadges: Bool {
        badges.isEmpty == false && hasContent
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

        var contentIsLeading: Bool {
            self == .leading || self == .leadingFirstBaseline || self == .top
        }

        var isFirstBaseline: Bool {
            self == .trailingFirstBaseline || self == .leadingFirstBaseline
        }

        var orientation: NSUserInterfaceLayoutOrientation {
            (self == .top || self == .bottom) ? .vertical : .horizontal
        }
    }
}

/*
 func shouldRecalculateContentView(_ previous: Self) {
 let keyPaths: [PartialKeyPath<Self>] = [\.contentProperties.imageScaling.shouldResize, \.image, \.view, \.contentProperties.maxWidth, \.contentProperties.maxHeight]

 contentProperties.imageScaling.shouldResize != previous.contentProperties.imageScaling.shouldResize ||
 image != previous.image
 }
 */
