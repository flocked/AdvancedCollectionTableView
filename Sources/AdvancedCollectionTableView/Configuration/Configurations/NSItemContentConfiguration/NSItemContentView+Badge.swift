//
//  TableCellContentView+Badge.swift
//  ItemConfiguration
//
//  Created by Florian Zand on 18.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSItemContentView {
    class BadgeView: NSView {
        var properties: NSItemContentConfiguration.Badge {
            didSet {
                guard oldValue != properties else { return }
                self.updateBadge()
            }
        }
        
        var verticalConstraint: NSLayoutConstraint? = nil
        var horizontalConstraint: NSLayoutConstraint? = nil
        var widthConstraint: NSLayoutConstraint? = nil
        
        func updateBadge() {
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.cornerRadius = properties.cornerRadius
            self.backgroundColor = properties._resolvedBackgroundColor
            self.configurate(using: properties.shadowProperties, type: .outer)
            
            self.textField.properties = properties.textProperties
            self.textField.text(properties.text, attributedText: properties.attributedText)
            
            if let view = properties.view {
                if self.view != view {
                    self.view?.removeFromSuperview()
                    self.view = view
                    stackView.addArrangedSubview(view)
                }
            } else {
                self.view?.removeFromSuperview()
                self.view = nil
            }

            self.imageView.image = properties.image
            self.imageView.properties = properties.imageProperties
            
            var visualEffect = properties.visualEffect
            visualEffect?.blendingMode = .withinWindow
            visualEffect?.material = .hudWindow
            visualEffect?.material = .popover
            visualEffect?.state = .active
            self.visualEffect = visualEffect
                        
            stackViewConstraints.constant(properties.margins)
            self.stackView.spacing = properties.imageToTextPadding
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
                    widthConstraint = self.widthAnchor.constraint(equalToConstant: maxWidth)
                }
                widthConstraint?.constant = maxWidth
                widthConstraint?.activate()
            } else {
                widthConstraint?.activate(false)
                widthConstraint = nil
            }
        }
        
        init(properties: NSItemContentConfiguration.Badge) {
            self.properties = properties
            super.init(frame: .zero)
            self.initalSetup()
            self.updateBadge()
        }
        
        lazy var textField = BadgeTextField(properties: properties.textProperties)
        lazy var imageView = BadgeImageView(properties: properties.imageProperties)
        var view: NSView? = nil
        lazy var stackView: NSStackView = {
            let stackView = NSStackView(views: [imageView, textField])
            stackView.orientation = .horizontal
            stackView.alignment = .firstBaseline
            return stackView
        }()
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var stackViewConstraints: [NSLayoutConstraint] = []
        func initalSetup() {
            self.translatesAutoresizingMaskIntoConstraints = false
            stackViewConstraints = self.addSubview(withConstraint: stackView)
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
                self.attributedStringValue = NSAttributedString(attributedText)
            } else {
                self.stringValue = text ?? ""
            }
            self.isHidden = text == nil && attributedText == nil
        }
        
        func updateProperties() {
            self.font = properties.font
            self.textColor = properties._resolvedTextColor
        }
        
        init(properties: NSItemContentConfiguration.Badge.TextProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.textLayout = .wraps
            self.isSelectable = false
            self.drawsBackground = false
            self.isBezeled = false
            self.isBordered = false
            self.maximumNumberOfLines = 1
            self.updateProperties()
        }
        
        required init?(coder: NSCoder) {
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
            self.updateProperties()
        }
        
        override var image: NSImage? {
            didSet {
                self.isHidden = self.image == nil
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
            self.contentTintColor = properties._resolvedTintColor
            self.symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            self.imageScaling = properties.scaling
            self.invalidateIntrinsicContentSize()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
