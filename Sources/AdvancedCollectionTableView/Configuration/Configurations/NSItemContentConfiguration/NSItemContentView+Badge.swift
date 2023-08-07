//
//  NSItemContentView+Badge.swift
//  
//
//  Created by Florian Zand on 06.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSItemContentView {
    class BadgeView: NSView {
        lazy var textField = ItemTextField(properties: properties.textProperties)
        lazy var imageView = ItemBadgeImageView(properties: properties.imageProperties)
        lazy var stackView: NSStackView = {
            let stackView = NSStackView(views: [self.imageView, self.textField])
            stackView.orientation = .horizontal
            return stackView
        }()
        
        var stackViewConstraints: [NSLayoutConstraint] = []
        var properties: NSItemContentConfiguration.Badge {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        func update() {
            self.stackViewConstraints.constant(properties.padding)
            self.textField.text(properties.text, attributedText: properties.attributedText)
            self.textField.properties = properties.textProperties
            self.imageView.properties = properties.imageProperties
            self.stackView.orientation = properties.imageProperties.position.orientation
            if self.properties.imageProperties.position.imageIsLeading, self.stackView.arrangedSubviews.first != imageView {
                self.stackView.removeArrangedSubview(textField)
                self.stackView.addArrangedSubview(textField)
            } else if self.properties.imageProperties.position.imageIsLeading == false, self.stackView.arrangedSubviews.last != imageView {
                self.stackView.removeArrangedSubview(imageView)
                self.stackView.addArrangedSubview(imageView)
            }
            
            self.imageView.image = properties.image
            self.backgroundColor = properties._resolvedBadgeColor
            self.cornerRadius = properties.cornerRadius
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.configurate(using: properties.shadowProperties)
        }
        
        init(properties: NSItemContentConfiguration.Badge) {
            self.properties = properties
            super.init(frame: .zero)
            self.translatesAutoresizingMaskIntoConstraints = false
            self.maskToBounds = false
            self.stackViewConstraints = self.addSubview(withConstraint: stackView)
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class ItemBadgeImageView: NSImageView {
        var properties: NSItemContentConfiguration.Badge.ImageProperties {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        override var image: NSImage? {
            didSet {
                self.isHidden = (self.image == nil)
                if let image = image {
                    let width = image.alignmentRect.size.height*2.0
                    var origin = self.frame.origin
                    origin.x = width - image.alignmentRect.size.width
                    self.frame.origin = origin
                }
            }
        }
        
        func update() {
            self.imageScaling = properties.scaling
            self.symbolConfiguration = properties.symbolConfiguration?.nsUI()
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.backgroundColor = properties._resolvedBackgroundColor
            self.contentTintColor = properties._resolvedTintColor
            self.cornerRadius = properties.cornerRadius
            
            var width: CGFloat? =  image?.size.width
            var height: CGFloat? =  image?.size.height
            if let maxWidth = properties.maxWidth, let _width = width {
                width = max(_width, maxWidth)
            }
            
            if let maxHeight = properties.maxHeight, let _height = height {
                height = max(_height, maxHeight)
            }
            
            if let width = width {
                widthA = self.widthAnchor.constraint(equalToConstant: width)
                widthA?.isActive = true
            } else {
                widthA?.isActive = false
            }
            
            if let height = height {
                heightA = self.heightAnchor.constraint(equalToConstant: height)
                heightA?.isActive = true
            } else {
                heightA?.isActive = false
            }
            
        }
        
        var widthA: NSLayoutConstraint? = nil
        var heightA: NSLayoutConstraint? = nil
        
        init(properties: NSItemContentConfiguration.Badge.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.imageAlignment = .alignCenter
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
