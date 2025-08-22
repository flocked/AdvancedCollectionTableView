//
//  NSListContentView+ImageViewAlt1.swift
//  
//
//  Created by Florian Zand on 22.08.25.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

/*
extension NSListContentView {
    class ListImageView: ImageView {
        var properties: NSListContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                update()
            }
        }

        override var image: NSImage? {
            didSet { isHidden = image == nil }
        }

        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize

            intrinsicContentSize = intrinsicContentSize.clamped(min: _reservedLayoutSize)
            
            if _reservedLayoutSize.width == 0, image?.isSymbolImage == true, properties.position.orientation == .horizontal {
                intrinsicContentSize.width = (intrinsicContentSize.height * 2.5).rounded(.towardZero)
                return intrinsicContentSize
            }
            
            if _reservedLayoutSize.width == NSListContentConfiguration.ImageProperties.standardDimension {
               // intrinsicContentSize.width = intrinsicContentSize.width.c
            }

            if let calculatedSize = calculatedSize {
                return calculatedSize
            }

            return intrinsicContentSize
        }

        var calculatedSize: CGSize? {
            didSet {
                invalidateIntrinsicContentSize()
            }
        }

        var verticalConstraint: NSLayoutConstraint?
        var _reservedLayoutSize: CGSize = .zero {
            didSet {
                if _reservedLayoutSize.width == NSListContentConfiguration.ImageProperties.standardDimension {
                    _reservedLayoutSize.width = 36.0
                }
                if _reservedLayoutSize.height == NSListContentConfiguration.ImageProperties.standardDimension {
                    _reservedLayoutSize.height = 9.0
                }
            }
        }

        func update() {
            imageScaling = image?.isSymbolImage == true ? .none : properties.scaling.imageScaling
            symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            border = properties.resolvedBorder()
            backgroundColor = properties.resolvedBackgroundColor()
            tintColor = properties.resolvedTintColor()
            cornerRadius = properties.cornerRadius
            outerShadow = properties.resolvedShadow()
            toolTip = properties.toolTip
            _reservedLayoutSize = properties.reservedLayoutSize
            reservedLayoutSize
            invalidateIntrinsicContentSize()
        }

        init(properties: NSListContentConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            wantsLayer = true
            imageAlignment = .alignCenter
            update()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
 */
