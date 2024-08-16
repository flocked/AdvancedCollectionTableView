//
//  NSListContentView.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

/**
 A content view for displaying list-based item content.
 
 You use a list content view for displaying list-based content in a custom view hierarchy. You can embed a list content view manually in a custom cell or in a container view, like a `NSStackView`. You can use Auto Layout or manual layout techniques to size and position the view, and its height adjusts dynamically according to its width and the space it needs to display its content.
 
 A list content view relies on its list content configuration to supply its styling and content. You create a list content view by passing in a ``NSListContentConfiguration`` to ``init(configuration:)``. To update the content view, you set a new configuration on it through its ``configuration`` property.
 
 If you’re using a `NSTableView` or `NSCollectionView`, you don’t need to manually create a list content view to take advantage of the list configuration. Instead, you assign a ``NSListContentConfiguration`` to the ``AppKit/NSTableCellView/contentConfiguration`` property of the table view cells or collection view items.
 */
open class NSListContentView: NSView, NSContentView, EditingContentView {
    
    /// Creates a list content view with the specified content configuration.
    public init(configuration: NSListContentConfiguration) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
        
        clipsToBounds = false
        imageTextStackView.translatesAutoresizingMaskIntoConstraints = false
        badgeStackView.translatesAutoresizingMaskIntoConstraints = false
        stackViewConstraints = addSubview(withConstraint: badgeStackView)
        
        updateConfiguration()
    }
    
    /// The current configuration of the view.
    open var configuration: NSContentConfiguration {
        get { appliedConfiguration }
        set {
            if let newValue = newValue as? NSListContentConfiguration {
                appliedConfiguration = newValue
            }
        }
    }
    
    /**
     Determines whether the view is compatible with the provided configuration.
     
     Returns `true` if the configuration is ``NSListContentConfiguration``, or `false` if not.
     */
    open func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSListContentConfiguration
    }
    
    var appliedConfiguration: NSListContentConfiguration {
        didSet {
            guard oldValue != appliedConfiguration else { return }
            updateConfiguration()
        }
    }
    
    let textField = ListItemTextField.wrapping().truncatesLastVisibleLine(true)
    let secondaryTextField = ListItemTextField.wrapping().truncatesLastVisibleLine(true)
    lazy var imageView = ListImageView(properties: appliedConfiguration.imageProperties)
    var badgeView: BadgeView?
    var topAccesoryViews: [AccessoryView] = []
    var bottomAccesoryViews: [AccessoryView] = []
    lazy var textStackView = NSStackView(views: [textField, secondaryTextField]).orientation(.vertical).alignment(.leading)
    lazy var imageTextStackView = NSStackView(views: [imageView, textStackView]).orientation(.horizontal).distribution(.fill)
    lazy var badgeStackView = NSStackView(views: [imageTextStackView]).orientation(.horizontal).distribution(.fill).alignment(.centerY)
    var stackViewConstraints: [NSLayoutConstraint] = []
    
    var isEditing: Bool = false {
        didSet {
            guard oldValue != isEditing else { return }
            if let tableCellView = tableCellView, tableCellView.contentView == self {
                tableCellView.setNeedsAutomaticUpdateConfiguration()
            } else if let tableRowView = tableRowView, tableRowView.contentView == self {
                tableRowView.setNeedsAutomaticUpdateConfiguration()
            } else if let collectionViewItem = collectionViewItem {
                collectionViewItem.setNeedsAutomaticUpdateConfiguration()
            }
            // textField.preferredMaxLayoutWidth = isEditing ? bounds.width-34 : 0
            // secondaryTextField.preferredMaxLayoutWidth = isEditing ? bounds.width-34 : 0
        }
    }
    
    var tableCellView: NSTableCellView? {
        superview as? NSTableCellView
    }
    
    var tableRowView: NSTableRowView? {
        firstSuperview(for: NSTableRowView.self)
    }
    
    var collectionViewItem: NSCollectionViewItem? {
        parentController as? NSCollectionViewItem
    }
    
    func updateConfiguration() {
        toolTip = appliedConfiguration.toolTip
        imageView.verticalConstraint?.activate(false)
        
        textField.isEnabled = appliedConfiguration.isEnabled
        textField.properties = appliedConfiguration.textProperties
        textField.updateText(appliedConfiguration.text, appliedConfiguration.attributedText, appliedConfiguration.placeholderText, appliedConfiguration.attributedPlaceholderText)
        secondaryTextField.isEnabled = appliedConfiguration.isEnabled
        secondaryTextField.properties = appliedConfiguration.secondaryTextProperties
        secondaryTextField.updateText(appliedConfiguration.secondaryText, appliedConfiguration.secondaryAttributedText, appliedConfiguration.secondaryPlaceholderText, appliedConfiguration.secondaryAttributedPlaceholderText)
        
        imageView.image = appliedConfiguration.image
        imageView.properties = appliedConfiguration.imageProperties
        
        textStackView.spacing = appliedConfiguration.textToSecondaryTextPadding
        imageTextStackView.spacing = appliedConfiguration.imageToTextPadding
        imageTextStackView.orientation = appliedConfiguration.imageProperties.position.orientation
        imageTextStackView.alignment = appliedConfiguration.imageProperties.position.alignment
        imageTextStackView.addArrangedSubview(appliedConfiguration.imageProperties.position.imageIsLeading ? textStackView : imageView)
        
        stackViewConstraints.constant(appliedConfiguration.margins)
        
        if let badge = appliedConfiguration.badge, appliedConfiguration.imageProperties.position.orientation == .horizontal {
            badgeStackView.spacing = appliedConfiguration.textToBadgePadding
            badgeStackView.alignment = badge.alignment.alignment
            if badgeView == nil {
                badgeView = BadgeView(properties: badge)
            }
            guard let badgeView = badgeView else { return }
            badgeView.properties = badge
            badgeStackView.arrangedViews = badge.position == .leading ? [badgeView, imageTextStackView] : [imageTextStackView, badgeView]
        } else {
            badgeView?.removeFromSuperview()
            badgeView = nil
            badgeStackView.spacing = 0
        }
        
        imageView.calculatedSize = calculateImageViewSize(appliedConfiguration.imageProperties.sizing)
        
        switch appliedConfiguration.imageProperties.position {
        case let .leading(value), let .trailing(value):
            switch value {
            case .bottom:
                imageView.verticalConstraint = imageView.bottomAnchor.constraint(equalTo: textStackView.bottomAnchor).activate()
            case .center:
                imageView.verticalConstraint = imageView.centerYAnchor.constraint(equalTo: textStackView.centerYAnchor).activate()
            case .top:
                imageView.verticalConstraint = imageView.topAnchor.constraint(equalTo: textStackView.topAnchor).activate()
            case .firstBaseline:
                if appliedConfiguration.image?.isSymbolImage == true {
                    if appliedConfiguration.hasText {
                        imageView.verticalConstraint = imageView.firstBaselineAnchor.constraint(equalTo: textField.firstBaselineAnchor)
                    } else if appliedConfiguration.hasSecondaryText {
                        imageView.verticalConstraint = imageView.firstBaselineAnchor.constraint(equalTo: secondaryTextField.firstBaselineAnchor)
                    }
                } else {
                    if appliedConfiguration.hasText {
                        //  var offset = textField.font!.capHeight / 2.0
                        let offset = (textField.font!.ascender + textField.font!.descender) / 2.0
                        imageView.verticalConstraint = imageView.centerYAnchor.constraint(equalTo: textField.firstBaselineAnchor, constant: -offset).activate()
                    } else if appliedConfiguration.hasSecondaryText {
                        // var offset = secondaryTextField.font!.capHeight / 2.0
                        let offset = (secondaryTextField.font!.ascender + secondaryTextField.font!.descender) / 2.0
                        imageView.verticalConstraint = imageView.centerYAnchor.constraint(equalTo: secondaryTextField.firstBaselineAnchor, constant: -offset).activate()
                    }
                }
            }
        default: break
        }
        
        updateAccesoryViews()
    }
    
    func updateAccesoryViews() {
        if topAccesoryViews.count != appliedConfiguration.topAccesories.count {
            var count = appliedConfiguration.topAccesories.count - topAccesoryViews.count
            if count > 0 {
                let range = appliedConfiguration.topAccesories.count-count..<appliedConfiguration.topAccesories.count
                topAccesoryViews.append(contentsOf: appliedConfiguration.topAccesories[range].compactMap({ AccessoryView(accessory: $0) }))
            } else {
                count = -count
                let range = topAccesoryViews.count-count..<topAccesoryViews.count
                topAccesoryViews[range].forEach({$0.removeFromSuperview()})
                topAccesoryViews.remove(at: range)
            }
        }
        if bottomAccesoryViews.count != appliedConfiguration.bottomAccesories.count {
            var count = appliedConfiguration.bottomAccesories.count - bottomAccesoryViews.count
            if count > 0 {
                let range = appliedConfiguration.bottomAccesories.count-count..<appliedConfiguration.bottomAccesories.count
                bottomAccesoryViews.append(contentsOf: appliedConfiguration.bottomAccesories[range].compactMap({ AccessoryView(accessory: $0) }))
            } else {
                count = -count
                let range = bottomAccesoryViews.count-count..<bottomAccesoryViews.count
                bottomAccesoryViews[range].forEach({$0.removeFromSuperview()})
                bottomAccesoryViews.remove(at: range)
            }
        }
    }
    
    func calculateImageViewSize(_ sizing: NSListContentConfiguration.ImageProperties.Sizing) -> CGSize? {
        guard let image = appliedConfiguration.image, !image.isSymbolImage else { return nil }
        var imageSize = image.size
        switch sizing {
        case .firstTextHeight:
            if appliedConfiguration.imageProperties.position.orientation == .horizontal {
                if appliedConfiguration.hasText {
                    return imageSize.scaled(toHeight: textField.intrinsicContentSize.height)
                } else if appliedConfiguration.hasSecondaryText {
                    return imageSize.scaled(toHeight: secondaryTextField.intrinsicContentSize.height)
                }
            }
            return calculateImageViewSize(.relative(1.0))
        case .totalTextHeight:
            if appliedConfiguration.imageProperties.position.orientation == .horizontal, appliedConfiguration.hasText, appliedConfiguration.hasSecondaryText {
                let height = textField.intrinsicContentSize.height + secondaryTextField.intrinsicContentSize.height + appliedConfiguration.textToSecondaryTextPadding
                return imageSize.scaled(toHeight: height)
            }
            return calculateImageViewSize(.firstTextHeight)
        case let .size(size):
            return size
        case let .maxiumSize(width: maxWidth, height: maxHeight):
            let maxWidth = maxWidth ?? imageSize.width
            let maxHeight = maxHeight ?? imageSize.height
            return imageSize.scaled(toFit: CGSize(maxWidth, maxHeight))
        case let .relative(relative):
            if appliedConfiguration.imageProperties.position.orientation == .vertical || !appliedConfiguration.hasText && !appliedConfiguration.hasSecondaryText {
                let width = bounds.width - appliedConfiguration.margins.width
                imageSize = imageSize.scaled(toWidth: width * relative)
            } else {
                let height = bounds.height - appliedConfiguration.margins.height
                imageSize = imageSize.scaled(toHeight: height * relative)
            }
            return imageSize
        case .none:
            return imageSize
        }
    }
    
    func scaleImageSize(_ imageSize: CGSize, to size: CGSize) -> CGSize {
        switch appliedConfiguration.imageProperties.scaling {
            // case .fill, .fit: return imageSize.scaled(toHeight: size.height)
        case .fit: return imageSize.scaled(toHeight: size.height)
        default: return CGSize(size.height, size.height)
        }
    }
    
    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
