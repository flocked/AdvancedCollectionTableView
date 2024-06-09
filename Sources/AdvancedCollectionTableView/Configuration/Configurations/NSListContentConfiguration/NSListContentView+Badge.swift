//
//  NSListContentView+Badge.swift
//
//
//  Created by Florian Zand on 18.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSListContentView {
    class BadgeView: NSView {
        var properties: NSListContentConfiguration.Badge {
            didSet {
                guard oldValue != properties else { return }
                updateBadge()
            }
        }

        var verticalConstraint: NSLayoutConstraint?
        var widthConstraint: NSLayoutConstraint?

        func updateBadge() {
            border.color = properties._resolvedBorderColor
            border.width = properties.borderWidth
            cornerRadius = properties.cornerRadius
            backgroundColor = properties._resolvedBackgroundColor
            configurate(using: properties.shadow, type: .outer)
            textField.font = properties.font
            textField.textColor = properties._resolvedColor
            imageView.image = properties.image
            imageView.properties = properties.imageProperties
            imageView.contentTintColor = properties.resolvedImageTintColor
            if let attributedText = properties.attributedText {
                textField.attributedStringValue = NSAttributedString(attributedText)
            } else {
                textField.stringValue = properties.text ?? ""
            }
            textField.isHidden = (properties.text == nil && properties.attributedText == nil)

            stackViewConstraints.constant(properties.margins)
            stackView.spacing = properties.imageToTextPadding
            if properties.imageProperties.position == .leading, stackView.arrangedSubviews.first != imageView {
                stackView.removeArrangedSubview(textField)
                stackView.addArrangedSubview(textField)
            } else if properties.imageProperties.position == .trailing, stackView.arrangedSubviews.last != imageView {
                stackView.removeArrangedSubview(imageView)
                stackView.addArrangedSubview(imageView)
            }

            textField.invalidateIntrinsicContentSize()

            if let maxWidth = properties.maxWidth {
                if widthConstraint == nil {
                    widthConstraint = widthAnchor.constraint(equalToConstant: maxWidth)
                }
                widthConstraint?.constant = maxWidth
                widthConstraint?.activate()
            } else {
                widthConstraint?.activate(false)
                widthConstraint = nil
            }
            
            toolTip = properties.toolTip
        }

        init(properties: NSListContentConfiguration.Badge) {
            self.properties = properties
            super.init(frame: .zero)
            initalSetup()
            updateBadge()
        }

        let textField = NSTextField(wrappingLabelWithString: "")
        lazy var imageView = BadgeImageView(properties: properties.imageProperties)
        lazy var stackView: NSStackView = {
            let stackView = NSStackView(views: [imageView, textField])
            stackView.orientation = .horizontal
            stackView.alignment = .firstBaseline
            return stackView
        }()

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var stackViewConstraints: [NSLayoutConstraint] = []
        func initalSetup() {
            translatesAutoresizingMaskIntoConstraints = false
            textField.textLayout = .wraps
            textField.maximumNumberOfLines = 1
            textField.isSelectable = false
            stackViewConstraints = addSubview(withConstraint: stackView)
        }
    }

    class BadgeImageView: NSImageView {
        var properties: NSListContentConfiguration.Badge.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                updateProperties()
            }
        }

        init(properties: NSListContentConfiguration.Badge.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            updateProperties()
        }

        override var image: NSImage? {
            didSet {
                isHidden = image == nil
            }
        }

        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            if image?.isSymbolImage == true {
                return intrinsicContentSize
            }

            if let maxWidth = properties.maxWidth, intrinsicContentSize.width > maxWidth {
                intrinsicContentSize.width = maxWidth
            }
            if let maxHeight = properties.maxHeight, intrinsicContentSize.height > maxHeight {
                intrinsicContentSize.height = maxHeight
            }
            return intrinsicContentSize
        }

        func updateProperties() {
            contentTintColor = properties._resolvedTintColor
            symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            imageScaling = properties.scaling
            invalidateIntrinsicContentSize()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
