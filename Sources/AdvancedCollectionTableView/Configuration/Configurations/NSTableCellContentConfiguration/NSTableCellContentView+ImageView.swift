//
//  NSTableCellContentView+ImageView.swift
//  
//
//  Created by Florian Zand on 28.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSTableCellContentView {
    class CellImageView: NSImageView {
        var properties: NSTableCellContentConfiguration.ImageProperties {
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
                    update()
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
            
            if let imageSize = image?.size {
                var size = imageSize
                if image?.isSymbolImage == true {
                    size.width = size.height * 2.0
                }
                if let maxWidth = properties.maxWidth {
                    size.width = min(maxWidth, size.width)
                }
                if let maxHeight = properties.maxHeight {
                    size.height = min(maxHeight, size.height)
                }
                if widthA == nil {
                    widthA = self.widthAnchor.constraint(equalToConstant: size.width)
                }
                if heightA == nil {
                    heightA = self.heightAnchor.constraint(equalToConstant: size.height)
                }
                widthA?.constant = size.width
                heightA?.constant = size.height
                widthA?.isActive = true
                heightA?.isActive = true
            } else {
                widthA?.isActive = false
                heightA?.isActive = false
            }
            /*
            var width: CGFloat? =  image?.size.width
            var height: CGFloat? =  image?.size.height
            if let maxWidth = properties.maxWidth, let _width = width {
                width = max(_width, maxWidth)
            }
            
            if let maxHeight = properties.maxHeight, let _height = height {
                height = max(_height, maxHeight)
            }
            
            /*
             if let pointSize = self.properties.symbolConfiguration?.font?.pointSize {
             //  width = pointSize * 2
             }
             */
            
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
            */
            
        }
        
        var widthA: NSLayoutConstraint? = nil
        var heightA: NSLayoutConstraint? = nil
        
        init(properties: NSTableCellContentConfiguration.ImageProperties) {
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
