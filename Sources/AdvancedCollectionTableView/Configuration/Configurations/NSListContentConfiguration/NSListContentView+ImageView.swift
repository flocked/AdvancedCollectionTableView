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
    class CellImageView: ImageView {
        var properties: NSListContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                update()
            }
        }
        
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
        var verticalConstraint: NSLayoutConstraint? = nil
        
        func update() {
            self.imageScaling = image?.isSymbolImage == true  ? .center : properties.scaling.contentsGravity
            self.symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.backgroundColor = properties._resolvedBackgroundColor
            self.tintColor = properties._resolvedTintColor
            self.cornerRadius = properties.cornerRadius
            self.configurate(using: properties.shadow, type: .outer)
            self.invalidateIntrinsicContentSize()
        }
        
        class ObserveImageView: NSImageView {
            var backgroundStyleHandler: ((NSView.BackgroundStyle)->())? = nil
            override func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
                backgroundStyleHandler?(backgroundStyle)
            }
        }
        
        let observerImageView = ObserveImageView()
        init(properties: NSListContentConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.addSubview(observerImageView)
            observerImageView.backgroundStyleHandler = { backgroundStyle in
                if backgroundStyle == .emphasized {
                    self.layer?.firstSublayer(type: ImageLayer.self)?.tintColor = .alternateSelectedControlTextColor
                    Swift.print("emphasized", self.layer?.firstSublayer(type: ImageLayer.self)?.tintColor == .alternateSelectedControlTextColor)
                } else {
                    self.layer?.firstSublayer(type: ImageLayer.self)?.tintColor = self.tintColor?.resolvedColor(for: self)
                }
            }
            self.wantsLayer = true
          //  self.imageAlignment = .alignCenter
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
