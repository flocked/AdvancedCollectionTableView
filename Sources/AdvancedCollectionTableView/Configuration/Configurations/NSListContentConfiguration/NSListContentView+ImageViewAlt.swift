//
//  NSList+ImageV.swift
//  
//
//  Created by Florian Zand on 21.08.25.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

/*
extension NSListContentView {
    class ListImageView: NSImageView {
        override var image: NSImage? {
            didSet { isHidden = image == nil }
        }
        
        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize

            intrinsicContentSize = intrinsicContentSize.clamped(min: _reservedLayoutSize ?? .zero)
            
            if _reservedLayoutSize?.width == 0, image?.isSymbolImage == true, properties.position.orientation == .horizontal {
                intrinsicContentSize.width = (intrinsicContentSize.height * 2.5).rounded(.towardZero)
                return intrinsicContentSize
            }
            
            if _reservedLayoutSize?.width == NSListContentConfiguration.ImageProperties.standardDimension {
               // intrinsicContentSize.width = intrinsicContentSize.width.c
            }

            if let calculatedSize = calculatedSize {
                return calculatedSize
            }

            return intrinsicContentSize
        }
        
        var properties: NSListContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                update()
            }
        }
        
        func update() {
            imageScaling = .scaleNone
            symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            border = properties.resolvedBorder()
            backgroundColor = properties.resolvedBackgroundColor()
            contentTintColor = properties.resolvedTintColor()
            cornerRadius = properties.cornerRadius
            outerShadow = properties.resolvedShadow()
            toolTip = properties.toolTip
            _reservedLayoutSize = properties.reservedLayoutSize
            invalidateIntrinsicContentSize()
        }
        
        init(properties: NSListContentConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            wantsLayer = true
            update()
        }
        
        var verticalConstraint: NSLayoutConstraint?
        
        var calculatedSize: CGSize? {
            didSet {
                invalidateIntrinsicContentSize()
            }
        }
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var _reservedLayoutSize: CGSize? {
            get { (cell as? ImageCell)?.reservedLayoutSize }
            set {
                guard var newValue = newValue else { return }
                if newValue.width == NSListContentConfiguration.ImageProperties.standardDimension {
                    newValue.width = 36.0
                }
                if newValue.height == NSListContentConfiguration.ImageProperties.standardDimension {
                    newValue.height = 9.0
                }
                (cell as? ImageCell)?.reservedLayoutSize = newValue
            }
        }
        
        override class var cellClass: AnyClass? {
            get { ImageCell.self }
            set { }
        }
        
        private class ImageCell: NSImageCell {
            var reservedLayoutSize: CGSize? = .zero
            var symbolConfiguration: NSImage.SymbolConfiguration? {
                if #available(macOS 12.0, *) {
                    return (controlView as? NSImageView)?.symbolConfiguration ?? image?.symbolConfiguration
                } else {
                    return (controlView as? NSImageView)?.symbolConfiguration
                }
            }
            
            override var cellSize: NSSize {
                guard let reservedLayoutSize = reservedLayoutSize, let image = image else { return super.cellSize }
                var cellSize = reservedLayoutSize
                if cellSize.width == 0 || cellSize.height == 0 {
                    if image.isSymbolImage {
                        let symbolSize = CGSize(width: 36, height: 16)
                        if cellSize.width == 0 { cellSize.width = symbolSize.width }
                        if cellSize.height == 0 { cellSize.height = symbolSize.height }
                    } else {
                        if cellSize.width == 0 { cellSize.width = image.size.width }
                        if cellSize.height == 0 { cellSize.height = image.size.height }
                    }
                }
                return cellSize
            }
            
            override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
                guard reservedLayoutSize != nil, let image = image else {
                    super.draw(withFrame: cellFrame, in: controlView)
                    return
                }
                let reservedSize = cellSize
                var imageRect: CGRect = CGRect(.zero, image.size)
                switch imageAlignment {
                case .alignLeft, .alignTopLeft, .alignBottomLeft:
                    imageRect.origin.x = cellFrame.origin.x
                case .alignRight, .alignTopRight, .alignBottomRight:
                    imageRect.origin.x = cellFrame.maxX - reservedSize.width
                case .alignCenter, .alignTop, .alignBottom:
                    imageRect.origin.x = cellFrame.midX - (reservedSize.width / 2.0)
                default:
                    imageRect.origin.x = cellFrame.origin.x
                }
                switch imageAlignment {
                case .alignBottom, .alignBottomLeft, .alignBottomRight:
                    imageRect.origin.y = cellFrame.origin.y
                case .alignTop, .alignTopLeft, .alignTopRight:
                    imageRect.origin.y = cellFrame.maxY - reservedSize.height
                case .alignCenter, .alignLeft, .alignRight:
                    imageRect.origin.y = cellFrame.midY - (reservedSize.height / 2.0)
                default:
                    imageRect.origin.y = cellFrame.origin.y
                }
                imageRect.origin.x += (reservedSize.width - image.size.width) / 2
                imageRect.origin.y += (reservedSize.height - image.size.height) / 2
               // image.draw(in: imageRect)
                Swift.print("draw", imageRect)
                super.draw(withFrame: imageRect, in: controlView)
            }
        }
    }
}
*/
