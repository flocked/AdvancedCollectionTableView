//
//  NSItemContentView+Badge.swift
//
//
//  Created by Florian Zand on 18.08.23.
//

/*
import AppKit
import FZSwiftUtils
import FZUIKit

extension NSItemContentView {
    class BadgeView: NSView {
        var properties: NSItemContentConfiguration.Badge {
            didSet {
                guard oldValue != properties else { return }
                updateBadge()
            }
        }

        var verticalConstraint: NSLayoutConstraint?
        var horizontalConstraint: NSLayoutConstraint?
        var widthConstraint: NSLayoutConstraint?
        var heightConstraint: NSLayoutConstraint?
        
        func setupBadge() {
            if properties.hasText {
                textField.frame.origin = CGPoint(properties.margins.leading, properties.margins.bottom)
                if properties.image != nil {
                    imageView.frame.centerLeft = textField.frame.centerRight.offset(x: properties.imageToTextPadding)
                    imageView.frame.size = imageView.fittingSize
                    if let view = view {
                        view.frame.centerLeft = imageView.frame.centerRight.offset(x: properties.imageToTextPadding)
                        view.frame.size = view.fittingSize
                    }
                } else if let view = view {
                    view.frame.centerLeft = textField.frame.centerRight.offset(x: properties.imageToTextPadding)
                    view.frame.size = view.fittingSize
                }
            } else if properties.image != nil {
                imageView.frame.origin = CGPoint(properties.margins.leading, properties.margins.bottom)
                imageView.frame.size = imageView.fittingSize
                if let view = view {
                    view.frame.centerLeft = imageView.frame.centerRight.offset(x: properties.imageToTextPadding)
                    view.frame.size = view.fittingSize
                }
            } else if let view = view {
                view.frame.origin = CGPoint(properties.margins.leading, properties.margins.bottom)
                view.frame.size = view.fittingSize
            }
        }

        func updateBadge() {
            widthConstraint?.activate(false)
            heightConstraint?.activate(false)
            widthConstraint = nil
            heightConstraint = nil

            border.color = properties._resolvedBorderColor
            border.width = properties.borderWidth
            backgroundColor = properties._resolvedBackgroundColor
            configurate(using: properties.shadow, type: .outer)

            textField.properties = properties.textProperties
            textField.text(properties.text, attributedText: properties.attributedText)

            if let view = properties.view {
                if view != view {
                    self.view?.removeFromSuperview()
                    self.view = view
                    stackView.addArrangedSubview(view)
                }
            } else {
                view?.removeFromSuperview()
                view = nil
            }

            imageView.image = properties.image
            imageView.properties = properties.imageProperties

            var visualEffect = properties.visualEffect
            visualEffect?.blendingMode = .withinWindow
            visualEffect?.material = .hudWindow
            visualEffect?.material = .popover
            visualEffect?.state = .active
            self.visualEffect = visualEffect

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
            
            switch properties.shape {
            case .roundedRect(let radius):
                cornerRadius = radius
            case .circle:
                if let widthConstraint = widthConstraint {
                    heightConstraint = heightAnchor.constraint(equalToConstant: widthConstraint.constant)
                    heightConstraint?.activate()
                } else {
                    widthConstraint = widthAnchor.constraint(equalToConstant: textField.fittingSize.width + properties.margins.width).activate()
                    heightConstraint = heightAnchor.constraint(equalToConstant: widthConstraint!.constant).activate()
                    widthConstraint = widthAnchor.constraint(equalToConstant: textField.fittingSize.width + properties.margins.width).activate()
                    heightConstraint = heightAnchor.constraint(equalToConstant: widthConstraint!.constant).activate()
                    cornerRadius = widthConstraint!.constant * 0.5
                }
            }
        }

        init(properties: NSItemContentConfiguration.Badge) {
            self.properties = properties
            super.init(frame: .zero)
            initalSetup()
            updateBadge()
        }

        lazy var textField = BadgeTextField(properties: properties.textProperties)
        lazy var imageView = BadgeImageView(properties: properties.imageProperties)
        var view: NSView?
        lazy var stackView: NSStackView = {
            let stackView = NSStackView(views: [imageView, textField])
            stackView.orientation = .horizontal
            textField.alignment = .center
            textField.backgroundColor = .systemYellow.withAlphaComponent(0.1)
            textField.clipsToBounds = true
            textField.drawsBackground = true
            stackView.alignment = .centerY
            return stackView
        }()

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var stackViewConstraints: [NSLayoutConstraint] = []
        func initalSetup() {
            translatesAutoresizingMaskIntoConstraints = false
            stackViewConstraints = addSubview(withConstraint: stackView)
        }
    }

    class BadgeTextField: NSTextField {
        var properties: NSItemContentConfiguration.Badge.TextProperties {
            didSet {
                guard oldValue != properties else { return }
                updateProperties()
            }
        }

        func text(_ text: String?, attributedText: AttributedString?) {
            if let attributedText = attributedText {
                attributedStringValue = NSAttributedString(attributedText)
            } else {
                stringValue = text ?? ""
            }
            isHidden = text == nil && attributedText == nil
        }

        func updateProperties() {
            font = properties.font
            textColor = properties._resolvedTextColor
        }

        init(properties: NSItemContentConfiguration.Badge.TextProperties) {
            self.properties = properties
            super.init(frame: .zero)
            textLayout = .wraps
            isSelectable = false
            drawsBackground = false
            isBezeled = false
            isBordered = false
            maximumNumberOfLines = 1
            updateProperties()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class BadgeImageView: NSImageView {
        var properties: NSItemContentConfiguration.Badge.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                updateProperties()
            }
        }

        init(properties: NSItemContentConfiguration.Badge.ImageProperties) {
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
*/
