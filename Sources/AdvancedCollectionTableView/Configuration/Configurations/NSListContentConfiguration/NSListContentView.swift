//
//  NSListContentView.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

/// A content view for displaying list-based content.
open class NSListContentView: NSView, NSContentView, EdiitingContentView {
    /// Creates a list content view with the specified content configuration.
    public init(configuration: NSListContentConfiguration) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
        initialSetup()
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

    func initialSetup() {
        clipsToBounds = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackViewConstraints = addSubview(withConstraint: stackView)
        addSubview(stackView)
    }

    var stackViewConstraints: [NSLayoutConstraint] = []
    var appliedConfiguration: NSListContentConfiguration {
        didSet {
            guard oldValue != appliedConfiguration else { return }
            updateConfiguration()
        }
    }

    lazy var textField = ListTextField(properties: appliedConfiguration.textProperties)
    lazy var secondaryTextField = ListTextField(properties: appliedConfiguration.secondaryTextProperties)
    lazy var imageView = ListImageView(properties: appliedConfiguration.imageProperties)
    var badgeView: BadgeView?

    lazy var textStackView: NSStackView = {
        var stackView = NSStackView(views: [textField, secondaryTextField])
        stackView.orientation = .vertical
        stackView.alignment = .leading
        return stackView
    }()

    lazy var stackView: NSStackView = {
        var stackView = NSStackView(views: [imageView, textStackView])
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        return stackView
    }()

    var isEditing: Bool = false {
        didSet {
            guard oldValue != isEditing else { return }
            if let tableCellView = tableCellView, tableCellView.contentView == self {
                tableCellView.setNeedsAutomaticUpdateConfiguration()
            } else if let tableRowView = tableRowView, tableRowView.contentView == self {
                tableRowView.setNeedsAutomaticUpdateConfiguration()
            } else if let collectionViewItem = collectionViewItem, collectionViewItem.view == self {
                collectionViewItem.setNeedsAutomaticUpdateConfiguration()
            }
        }
    }

    var tableCellView: NSTableCellView? {
        firstSuperview(for: NSTableCellView.self)
    }

    var tableRowView: NSTableRowView? {
        firstSuperview(for: NSTableRowView.self)
    }

    var collectionViewItem: NSCollectionViewItem? {
        firstSuperview(where: { $0.parentController is NSCollectionViewItem })?.parentController as? NSCollectionViewItem
    }

    func updateConfiguration() {
        toolTip = appliedConfiguration.toolTip
        imageView.verticalConstraint?.activate(false)
        badgeView?.verticalConstraint?.activate(false)

        textField.isEnabled = appliedConfiguration.state.isEnabled != false
        secondaryTextField.isEnabled = appliedConfiguration.state.isEnabled != false
        textField.updateText(appliedConfiguration.text, appliedConfiguration.attributedText, appliedConfiguration.placeholderText, appliedConfiguration.attributedPlaceholderText)
        secondaryTextField.updateText(appliedConfiguration.secondaryText, appliedConfiguration.secondaryAttributedText, appliedConfiguration.secondaryPlaceholderText, appliedConfiguration.secondaryAttributedPlaceholderText)
        imageView.image = appliedConfiguration.image

        imageView.properties = appliedConfiguration.imageProperties
        textField.properties = appliedConfiguration.textProperties
        secondaryTextField.properties = appliedConfiguration.secondaryTextProperties

        textStackView.spacing = appliedConfiguration.textToSecondaryTextPadding
        stackView.spacing = appliedConfiguration.imageToTextPadding
        stackView.orientation = appliedConfiguration.imageProperties.position.orientation
        stackView.alignment = appliedConfiguration.imageProperties.position.alignment

        if appliedConfiguration.imageProperties.position.imageIsLeading, stackView.arrangedSubviews.first != imageView {
            stackView.removeArrangedSubview(textStackView)
            stackView.addArrangedSubview(textStackView)
        } else if appliedConfiguration.imageProperties.position.imageIsLeading == false, stackView.arrangedSubviews.last != imageView {
            stackView.removeArrangedSubview(imageView)
            stackView.addArrangedSubview(imageView)
        }

        stackViewConstraints.constant(appliedConfiguration.margins)

        if appliedConfiguration.hasBadge, appliedConfiguration.imageProperties.position.orientation == .horizontal, let badge = appliedConfiguration.badge {
            if badgeView == nil {
                badgeView = BadgeView(properties: badge)
            }
            guard let badgeView = badgeView else { return }
            badgeView.properties = badge
            if badge.position == .leading, stackView.arrangedSubviews.first != badgeView {
                badgeView.removeFromSuperview()
                stackView.insertArrangedSubview(badgeView, at: 0)
                stackView.setCustomSpacing(appliedConfiguration.textToBadgePadding, after: badgeView)
                stackView.setCustomSpacing(NSStackView.useDefaultSpacing, after: textStackView)
            } else if badge.position == .trailing, stackView.arrangedSubviews.last != badgeView {
                badgeView.removeFromSuperview()
                stackView.addArrangedSubview(badgeView)
                stackView.setCustomSpacing(appliedConfiguration.textToBadgePadding, after: textStackView)
                stackView.setCustomSpacing(NSStackView.useDefaultSpacing, after: badgeView)
            }
        } else {
            badgeView?.removeFromSuperview()
            badgeView = nil
            stackView.setCustomSpacing(NSStackView.useDefaultSpacing, after: textStackView)
        }

        imageView.calculatedSize = calculateImageViewSize()

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
    }

    func calculateTextFieldsSize(imageSize: CGSize?) -> CGSize {
        var textFieldsSize: CGSize = .zero
        textFieldsSize.width = frame.size.width - appliedConfiguration.margins.width
        if appliedConfiguration.imageProperties.position.orientation == .horizontal, let imageSize = imageSize {
            textFieldsSize.width = textFieldsSize.width - imageSize.width - appliedConfiguration.imageToTextPadding
        }
        textField.frame.size.width = textFieldsSize.width
        secondaryTextField.frame.size.width = textFieldsSize.width
        if appliedConfiguration.hasSecondaryText {
            textFieldsSize.height = secondaryTextField.intrinsicContentSize.height
            if appliedConfiguration.hasText {
                textFieldsSize.height += appliedConfiguration.textToSecondaryTextPadding
            }
        }
        if appliedConfiguration.hasText {
            textFieldsSize.height += textField.intrinsicContentSize.height
        }
        return textFieldsSize
    }

    func calculateImageViewSize() -> CGSize? {
        if let image = appliedConfiguration.image {
            var imageSize = image.size
            switch appliedConfiguration.imageProperties.sizing {
            case .firstTextHeight:
                if appliedConfiguration.hasText {
                    return scaleImageSize(imageSize, to: textField.intrinsicContentSize)
                } else if appliedConfiguration.hasSecondaryText {
                    return scaleImageSize(imageSize, to: secondaryTextField.intrinsicContentSize)
                } else {
                    let width = frame.size.width - appliedConfiguration.margins.width
                    if imageSize.width > width {
                        imageSize = imageSize.scaled(toWidth: width)
                    }
                    return imageSize
                }
            case .totalTextHeight:
                if appliedConfiguration.hasText, appliedConfiguration.hasSecondaryText {
                    var size = textField.intrinsicContentSize
                    size.height += secondaryTextField.intrinsicContentSize.height
                    size.height += appliedConfiguration.textToSecondaryTextPadding
                    return scaleImageSize(imageSize, to: size)
                } else if appliedConfiguration.hasText {
                    return scaleImageSize(imageSize, to: textField.intrinsicContentSize)
                } else if appliedConfiguration.hasSecondaryText {
                    return scaleImageSize(imageSize, to: secondaryTextField.intrinsicContentSize)
                } else {
                    let width = frame.size.width - appliedConfiguration.margins.width
                    if imageSize.width > width {
                        imageSize = imageSize.scaled(toWidth: width)
                    }
                    return imageSize
                }
            case let .size(size):
                var size = size
                let width = frame.size.width - appliedConfiguration.margins.width
                if size.width > width {
                    size = size.scaled(toWidth: width)
                }
                return size
            case let .maxiumSize(width: maxWidth, height: maxHeight):
                if let maxWidth = maxWidth, imageSize.width > maxWidth, let maxHeight = maxHeight, imageSize.height > maxHeight {
                    imageSize = imageSize.scaled(toFit: CGSize(maxWidth, maxHeight))
                } else if let maxWidth = maxWidth, imageSize.width > maxWidth {
                    imageSize = imageSize.scaled(toWidth: maxWidth)
                } else if let maxHeight = maxHeight, imageSize.height > maxHeight {
                    imageSize = imageSize.scaled(toHeight: maxHeight)
                }
                let width = frame.size.width - appliedConfiguration.margins.width
                if imageSize.width > width {
                    imageSize = imageSize.scaled(toWidth: width)
                }
                return imageSize
            case let .maxiumSizeRelative(width: relativeWidth, height: relativeHeight):
                let width = bounds.width - appliedConfiguration.margins.width
                if let relativeWidth = relativeWidth, let relativeHeight = relativeHeight {
                    imageSize = imageSize.scaled(toFit: CGSize(width * relativeWidth, bounds.width * relativeHeight))
                } else if let relativeWidth = relativeWidth {
                    imageSize = imageSize.scaled(toWidth: width * relativeWidth)
                } else if let relativeHeight = relativeHeight {
                    imageSize = imageSize.scaled(toHeight: width * relativeHeight)
                }
                return imageSize
            default:
                let width = frame.size.width - appliedConfiguration.margins.width
                if imageSize.width > width {
                    imageSize = imageSize.scaled(toWidth: width)
                }
                return imageSize
            }
        }
        return nil
    }

    func scaleImageSize(_ imageSize: CGSize, to size: CGSize) -> CGSize {
        switch appliedConfiguration.imageProperties.scaling {
        // case .fill, .fit: return imageSize.scaled(toHeight: size.height)
        case .fit: return imageSize.scaled(toHeight: size.height)
        default: return CGSize(size.height, size.height)
        }
    }

    /// Perform layout in concert with the constraint-based layout system.
    override open func layout() {
        super.layout()
        updateTableRowHeight()
    }

    var width: CGFloat = 0.0
    func updateTableRowHeight() {
        guard bounds.width != width else { return }
        width = bounds.width
        if let tableRowView = tableRowView, frame.size.height > fittingSize.height {
            tableRowView.frame.size.height = fittingSize.height
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
