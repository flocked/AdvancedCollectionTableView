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
        /// The widths of the symbol
        static var symbolWidths: [CGFloat: [CGFloat]] = [:]
        var properties: NSTableCellContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                    update()
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
        
        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            if let symbolHeight = symbolHeight {
                intrinsicContentSize.width = Self.symbolWidths[symbolHeight]?.max() ??  intrinsicContentSize.width
            } else {
                if let maxWidth = properties.maximumWidth, intrinsicContentSize.width > maxWidth {
                    intrinsicContentSize.width = maxWidth
                }
                if let maxHeight = properties.maximumHeight, intrinsicContentSize.height > maxHeight {
                    intrinsicContentSize.height = maxHeight
                }
            }
            return intrinsicContentSize
        }
        
        internal var symbolHeight: CGFloat?
        
        func update() {
            if let image = image, image.isSymbolImage == true {
                let imageSize = image.size
                self.symbolHeight = imageSize.height
                if var symbolWidths = Self.symbolWidths[imageSize.height] {
                    symbolWidths.append(imageSize.width)
                    Self.symbolWidths[imageSize.height] = symbolWidths.uniqued()
                } else {
                    Self.symbolWidths[imageSize.height] = [imageSize.width]
                }
            } else {
                self.symbolHeight = nil
            }
            self.imageScaling = properties.scaling
            self.symbolConfiguration = properties.symbolConfiguration?.nsUI()
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.backgroundColor = properties._resolvedBackgroundColor
            self.contentTintColor = properties._resolvedTintColor
            self.cornerRadius = properties.cornerRadius
   
            self.invalidateIntrinsicContentSize()
        }
                
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
