//
//  NSListContentView+ImageView.swift
//
//
//  Created by Florian Zand on 28.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

internal extension NSListContentView {
    class ListImageView: NSImageView {
        var properties: NSListContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                    update()
            }
        }
   
        override var image: NSImage? {
            didSet {
                isHidden = (image == nil)
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
        var verticalConstraint: NSLayoutConstraint? = nil
        
        func update() {
            imageScaling = image?.isSymbolImage == true  ? .scaleNone : properties.scaling.imageScaling
            symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            borderColor = properties._resolvedBorderColor
            borderWidth = properties.borderWidth
            backgroundColor = properties._resolvedBackgroundColor
            contentTintColor = properties._resolvedTintColor
            cornerRadius = properties.cornerRadius
            configurate(using: properties.shadow, type: .outer)
            invalidateIntrinsicContentSize()
        }

        init(properties: NSListContentConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            wantsLayer = true
            imageAlignment = .alignCenter
            update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
