//
//  NSListContentView+ImageView.swift
//
//
//  Created by Florian Zand on 28.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSListContentView {
    class CellImageView: NSImageView {
        var properties: NSListContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                    update()
            }
        }
        
        var verticalConstraint: NSLayoutConstraint? = nil

        override var image: NSImage? {
            didSet {
                self.isHidden = (self.image == nil)
            }
        }
        
        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            
            if image?.isSymbolImage == true, properties.position.orientation == .horizontal {
                intrinsicContentSize.width = (intrinsicContentSize.height*2.5).rounded(.towardZero)
                return intrinsicContentSize
            }
            
            if let calculatedSize = calculatedSize {
                return calculatedSize
            }
            
            return intrinsicContentSize
        }
                
        var calculatedSize: CGSize?
        
        func update() {
            self.imageScaling = image?.isSymbolImage == true  ? .scaleNone : properties.scaling
            self.symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.backgroundColor = properties._resolvedBackgroundColor
            self.contentTintColor = properties._resolvedTintColor
            self.cornerRadius = properties.cornerRadius
            self.configurate(using: properties.shadowProperties, type: .outer)
            self.invalidateIntrinsicContentSize()
        }
                
        init(properties: NSListContentConfiguration.ImageProperties) {
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
