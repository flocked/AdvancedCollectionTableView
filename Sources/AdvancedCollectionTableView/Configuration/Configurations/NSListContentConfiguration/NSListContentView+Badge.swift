//
//  TableCellContentView+Badge.swift
//  ItemConfiguration
//
//  Created by Florian Zand on 18.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSListContentView {
    class BadgeView: NSView {
        var properties: NSListContentConfiguration.Badge {
            didSet {
                guard oldValue != properties else { return }
                self.updateBadge()
            }
        }
        
        var verticalConstraint: NSLayoutConstraint? = nil
        var widthConstraint: NSLayoutConstraint? = nil
        
        func updateBadge() {
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.cornerRadius = properties.cornerRadius
            self.backgroundColor = properties._resolvedBackgroundColor
            self.configurate(using: properties.shadowProperties, type: .outer)
            self.textField.font = properties.font
            self.textField.textColor = properties._resolvedColor
            self.imageView.image = properties.image
            self.imageView.properties = properties.imageProperties
            self.imageView.contentTintColor = properties.resolvedImageTintColor
            if let attributedText = properties.attributedText {
                textField.attributedStringValue = NSAttributedString(attributedText)
            } else {
                textField.stringValue = properties.text ?? ""
            }
            textField.isHidden = (properties.text == nil && properties.attributedText == nil)
            
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
        
        init(properties: NSListContentConfiguration.Badge) {
            self.properties = properties
            super.init(frame: .zero)
            self.initalSetup()
            self.updateBadge()
        }
        
        let textField = NSTextField(wrappingLabelWithString: "")
        lazy var imageView = BadgeImageView(properties: properties.imageProperties)
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
            textField.textLayout = .wraps
            textField.maximumNumberOfLines = 1
            textField.isSelectable = false
            stackViewConstraints = self.addSubview(withConstraint: stackView)
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
