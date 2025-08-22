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

extension NSListContentView {
    class ListImageView: NSView {
        let imageView = ImageView()
        
        var imageScaling: NSListContentConfiguration.ImageProperties.ImageScaling = .scaleToFit {
            didSet {
                guard oldValue != imageScaling else { return }
                imageView.imageScaling = imageScaling.scaling
                setNeedsLayout()
            }
        }
        
        var image: NSImage? {
            get { imageView.image }
            set {
                imageView.image = newValue
                isHidden = newValue == nil
                setNeedsLayout()
            }
        }
        
        var properties: NSListContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                update()
            }
        }
        
        func update() {
            imageScaling = properties.scaling
            imageView.symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            imageView.border = properties.resolvedBorder()
            imageView.backgroundColor = properties.resolvedBackgroundColor()
            imageView.contentTintColor = properties.resolvedTintColor()
            imageView.cornerRadius = properties.cornerRadius
            imageView.outerShadow = properties.resolvedShadow()
            imageView.toolTip = properties.toolTip
            imageView._reservedLayoutSize = properties.reservedLayoutSize
            invalidateIntrinsicContentSize()
        }
        
        override func layout() {
            super.layout()
            
            if imageScaling == .scaleToFill, let imageSize = image?.size {
                imageView.frame.size = imageSize.scaled(toFill: bounds.size)
                imageView.center = bounds.center
            } else {
                imageView.frame = bounds
            }
        }
        
        override var fittingSize: NSSize {
            imageView.fittingSize
        }
        
        override func alignmentRect(forFrame frame: NSRect) -> NSRect {
            imageView.alignmentRect(forFrame: frame)
        }

        override func frame(forAlignmentRect alignmentRect: NSRect) -> NSRect {
            imageView.frame(forAlignmentRect: alignmentRect)
        }
        
        override var firstBaselineOffsetFromTop: CGFloat {
            imageView.firstBaselineOffsetFromTop
        }
        
        override var lastBaselineOffsetFromBottom: CGFloat {
            imageView.lastBaselineOffsetFromBottom
        }
        
        override var baselineOffsetFromBottom: CGFloat {
            imageView.baselineOffsetFromBottom
        }
        
        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = imageView.intrinsicContentSize
            
            intrinsicContentSize = intrinsicContentSize.clamped(min: imageView._reservedLayoutSize ?? .zero)
            
            if imageView._reservedLayoutSize?.width == 0, image?.isSymbolImage == true, properties.position.orientation == .horizontal {
                intrinsicContentSize.width = (intrinsicContentSize.height * 2.5).rounded(.towardZero)
                return intrinsicContentSize
            }
            
            if imageView._reservedLayoutSize?.width == NSListContentConfiguration.ImageProperties.standardDimension {
                // intrinsicContentSize.width = intrinsicContentSize.width.c
            }
            
            if let calculatedSize = calculatedSize {
                return calculatedSize
            }
            
            return intrinsicContentSize
        }
        
        var verticalConstraint: NSLayoutConstraint?
        
        var calculatedSize: CGSize? {
            didSet { invalidateIntrinsicContentSize() }
        }
        
        init(properties: NSListContentConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            wantsLayer = true
            addSubview(imageView)
            update()
        }
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension NSListContentView.ListImageView {
    class ImageView: NSImageView {
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
            var lastSymbolFont: SymbolFont = .default
            var symbolSize = CGSize(25.0, 20.0)
            var observations: [KeyValueObservation] = []
            var needsSymbolSizeUpdate = false
            
            override var cellSize: NSSize {
                guard let reservedLayoutSize = reservedLayoutSize, let image = image else { return super.cellSize }
                var cellSize = reservedLayoutSize
                if cellSize.width == 0 || cellSize.height == 0 {
                    if image.isSymbolImage {
                        updateSymbolSize()
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
                super.draw(withFrame: imageRect, in: controlView)
            }
            
            func updateSymbolSize() {
                guard needsSymbolSizeUpdate else { return }
                let symbolFont = symbolFont
                needsSymbolSizeUpdate = false
                guard symbolFont != lastSymbolFont else { return }
                lastSymbolFont = symbolFont
                symbolSize = Self.symbolSizes[symbolFont] ?? Self.symbolSizes[.default]!
            }
            
            static let symbolSizes: [SymbolFont: CGSize] = {
                if let url = Bundle.module.url(forResource: "fontSizes"), let data = try? Data(contentsOf: url), let sizes = try? JSONDecoder().decode([SymbolFont: CGSize].self, from: data) {
                    return sizes
                }
                return [.default : CGSize(25.0, 20.0)]
            }()
            
            func setupObservations(for imageView: NSImageView) {
                observations += imageView.observeChanges(for: \.image) { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.needsSymbolSizeUpdate = true
                }
                observations += imageView.observeChanges(for: \.symbolConfiguration) { [weak self] old, new in
                    guard let self = self else { return }
                    self.needsSymbolSizeUpdate = true
                }
            }
            
            var symbolConfiguration: NSImage.SymbolConfiguration? {
                if #available(macOS 12.0, *) {
                    return (controlView as? NSImageView)?.symbolConfiguration ?? image?.symbolConfiguration
                } else {
                    return (controlView as? NSImageView)?.symbolConfiguration
                }
            }
            
            var symbolFont: SymbolFont {
                if let configuration = symbolConfiguration {
                    return SymbolFont(configuration.pointSize, configuration.scale, configuration.weight)
                }
                return .default
            }
        }
    }
}

fileprivate extension NSImage.SymbolConfiguration {
    var pointSize: CGFloat {
        get { value(forKey: "pointSize") ?? 0.0 }
        set { setIvarValue(Double(newValue), of: "_pointSize") }
    }
    
    var scale: NSImage.SymbolScale {
        guard let rawValue: Int = value(forKey: "scale"), rawValue != -1 else {
                return .default }
        return NSUIImage.SymbolScale(rawValue: rawValue) ?? .default
    }
    
    var weight: NSFont.Weight {
        guard let weight: Double = value(forKey: "weight") else { return .regular }
        return NSUISymbolWeight(rawValue: weight)
    }
}

fileprivate struct SymbolFont: Hashable, Codable {
    let size: CGFloat
    let scale: Int
    let weight: CGFloat
    
    init(_ size: CGFloat, _ scale: NSImage.SymbolScale, _ weight: NSFont.Weight) {
        self.size = size
        self.scale = scale.rawValue
        self.weight = (weight == .unspecified ? .regular : weight).rawValue
    }
    
    static let `default` = Self(13.0, .default, .regular)
}
