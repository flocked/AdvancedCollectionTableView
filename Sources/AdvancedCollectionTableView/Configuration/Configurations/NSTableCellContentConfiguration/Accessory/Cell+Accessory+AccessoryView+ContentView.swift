//
//  NSTableCellContentView.AccessoriesView.AccessoryVie+ContentView.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSTableCellContentView.AccessoriesView.AccessoryView {
    class ContentView: NSView {
        lazy var imageView: NSImageView = {
            var imageView = NSImageView()
            self.addSubview(withConstraint: imageView)
            return imageView
        }()
        
        var contentView: NSView? = nil {
            didSet {
                if oldValue != self.contentView {
                    oldValue?.removeFromSuperview()
                    if let contentView = self.contentView {
                        self.addSubview(withConstraint: contentView)
                    }
                }
            }
        }
        
        
        var image: NSImage? {
            get { imageView.image }
            set { imageView.image = newValue
                imageView.isHidden = (imageView.image == nil)
            }
        }
        
        var properties: NSTableCellContentConfiguration.Accessory.AccessoryContent.ContentProperties {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        func update() {
            self.imageView.imageScaling = properties.imageScaling
            self.imageView.symbolConfiguration = properties.imageSymbolConfiguration?.nsUI()
            self.imageView.contentTintColor = properties._resolvedImageTintColor
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.backgroundColor = properties._resolvedBackgroundColor
            self.cornerRadius = properties.cornerRadius
            self.isHidden = (self.image == nil && self.contentView == nil)
            
            var width: CGFloat? =  image?.size.width
            var height: CGFloat? =  image?.size.height
            if let maxWidth = properties.contentMaxWidth, let _width = width {
                width = max(_width, maxWidth)
            }
            
            if let maxHeight = properties.contentMaxHeight, let _height = height {
                height = max(_height, maxHeight)
            }
            
            /*
            if let pointSize = self.properties.imageSymbolConfiguration?.font?.pointSize {
                width = pointSize * 2
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
            
        }
        
        var widthA: NSLayoutConstraint? = nil
        var heightA: NSLayoutConstraint? = nil

        init(properties: NSTableCellContentConfiguration.Accessory.AccessoryContent.ContentProperties, view: NSView?, image: NSImage?) {
            self.properties = properties
            super.init(frame: .zero)
            self.update()
            self.contentView = view
            self.image = image
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
