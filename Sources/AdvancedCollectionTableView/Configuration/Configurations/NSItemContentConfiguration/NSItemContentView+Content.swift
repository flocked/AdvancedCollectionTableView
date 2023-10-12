//
//  ItemContentView+Content.swift
//  ItemConfiguration
//
//  Created by Florian Zand on 07.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSItemContentView {
    class ItemContentView: NSView {
        typealias Badge = NSItemContentConfiguration.Badge
        var configuration: NSItemContentConfiguration {
            didSet { if oldValue != configuration {
                updateConfiguration() } } }
        
        var contentProperties: NSItemContentConfiguration.ContentProperties {
            return configuration.contentProperties
        }
        
        let imageView: ImageView = ImageView()
        var badgeViews: [BadgeView] = []
        
        var view: NSView? = nil {
            didSet {
                oldValue?.removeFromSuperview()
                if let newView = self.view {
                    self.addSubview(withConstraint: newView)
                    self.overlayView?.sendToFront()
                    self.badgeViews.forEach({$0.sendToFront()})
                }
            }
        }
        
        var overlayView: NSView? = nil {
            didSet {
                oldValue?.removeFromSuperview()
                if let newView = self.overlayView {
                    self.addSubview(withConstraint: newView)
                    self.badgeViews.forEach({$0.sendToFront()})
                }
            }
        }
        
        var image: NSImage? {
            get { imageView.image }
            set {
                guard newValue != self.image else { return }
                self.imageView.image = newValue
                self.imageView.isHidden = newValue == nil
            }
        }
        
        
        func updateBadges() {
            let badges = configuration.badges.filter({$0.isVisible})
            if configuration.hasContent {
                let badgeViewsNeeded = badges.count - badgeViews.count
                if badgeViewsNeeded > 0 {
                    for i in 0..<badgeViewsNeeded {
                        let badgeView = BadgeView(properties: badges[i])
                        self.badgeViews.append(badgeView)
                        self.addSubview(badgeView)
                    }
                } else if badgeViewsNeeded < 0 {
                    for _ in 0..<(-badgeViewsNeeded) {
                        self.badgeViews.last?.removeFromSuperview()
                        self.badgeViews.removeLast()
                    }
                }
                guard badges.count == badgeViews.count else { return }
                for value in zip(badges, badgeViews) {
                    value.1.properties = value.0
                }
                self.layoutBadges()
            } else {
                self.badgeViews.forEach({$0.removeFromSuperview()})
                self.badgeViews.removeAll()
            }
        }
        
        override func layoutSubtreeIfNeeded() {
            super.layoutSubtreeIfNeeded()
            Swift.print("layoutSubtreeIfNeeded", self.frame.size)
        }
        
        var previousFrameSize: CGSize = .zero
        override func layout() {
            super.layout()
        //    Swift.print("layout", self.frame.size)
            invalidateIntrinsicContentSize()
            self.imageView.frame.size = self.bounds.size
            /*
             if let imageSize = image?.size, contentProperties.imageScaling.shouldResize {
             var size = self.frame.size
             if let superviewWidth = self.superview?.frame.size.width {
             size.width = superviewWidth - configuration.margins.width
             }
             var newIntrinsicSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
             switch (contentProperties.maxWidth, contentProperties.maxHeight) {
             case (.some(let maxWidth), .some(let maxHeight)):
             let width = min(maxWidth, size.width)
             let height = min(maxHeight, size.height)
             let imagesize = imageSize.scaled(toFit: CGSize(width, height))
             newIntrinsicSize.width = imagesize.width
             newIntrinsicSize.height =  imagesize.height
             case (.some(let maxWidth), nil):
             let imagesize = imageSize.scaled(toWidth: min(maxWidth, size.width))
             newIntrinsicSize.width = imagesize.width
             newIntrinsicSize.height = imagesize.height
             case (nil, .some(let maxHeight)):
             let imagesize = imageSize.scaled(toHeight: min(maxHeight, size.height))
             Swift.print("maxHeight", self.frame.size, imagesize)
             newIntrinsicSize.width = imagesize.width
             newIntrinsicSize.height = imagesize.height
             case (nil, nil):
             let imagesize = imageSize.scaled(toFit: size)
             newIntrinsicSize.width = imagesize.width
             }
             if newIntrinsicSize != intrinsicSize {
             intrinsicSize = newIntrinsicSize
             Swift.print("invalidateIntrinsicContentSize", self.intrinsicSize)
             self.invalidateIntrinsicContentSize()
             }
             } else {
             intrinsicSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
             var size = self.frame.size
             if let superviewWidth = self.superview?.frame.size.width {
             size.width = superviewWidth - configuration.margins.width
             }
             
             if let maxWidth = contentProperties.maxWidth, size.width > maxWidth {
             intrinsicSize.width = maxWidth
             }
             
             /*
              var newWidth: CGFloat? = nil
              var newHeight: CGFloat? = nil
              if let maxWidth = contentProperties.maxWidth, size.width > maxWidth {
              newWidth = maxWidth
              }
              
              if let maxHeight = contentProperties.maxHeight, size.height > maxHeight {
              newHeight = maxHeight
              }
              
              if newWidth != self.width || newHeight != self.height {
              self.width = newWidth
              self.height = newHeight
              Swift.print("invalidateIntrinsicContentSize", self.height ?? "")
              self.invalidateIntrinsicContentSize()
              }
              */
             Swift.print("invalidateIntrinsicContentSize", self.intrinsicSize)
             self.invalidateIntrinsicContentSize()
             }
             */
        }
        
        func layoutBadges(elements: [(badge: Badge, badgeView: BadgeView)]) {
            var elements = elements
            let element = elements.removeFirst()
            let firstBadge = element.badge
            let firstBadgeView = element.badgeView
            self.layoutBadge(firstBadge, badgeView: firstBadgeView)
        }
        
        func layoutBadges() {
            let badges = configuration.badges.filter({$0.isVisible}).sorted(by: \.position.rawValue)
            guard configuration.hasBadges, badges.count == badgeViews.count else { return }
            let badgeViews = self.badgeViews.sorted(by: \.properties.position.rawValue)
            for value in zip(badges, badgeViews) {
                self.layoutBadge(value.0, badgeView: value.1)
            }
        }
        
        func layoutBadge(_ badge: Badge, badgeView: BadgeView) {
            badgeView.horizontalConstraint?.activate(false)
            badgeView.verticalConstraint?.activate(false)
            badgeView.widthConstraint?.activate(false)
            
         //   let constant = -(2*(badge.type.spacing ?? 0))
         //   badgeView.widthConstraint = badgeView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, constant: constant).activate()
            
            let badgeSize = badgeView.fittingSize
            switch badge.position {
                case .topLeft, .top, .topRight:
                    badgeView.verticalConstraint = badgeView.topAnchor.constraint(equalTo: self.topAnchor, constant: badge.type.spacing ?? -(badgeSize.height * 0.33)).activate()
                case .centerLeft, .center, .centerRight:
                    badgeView.verticalConstraint = badgeView.centerYAnchor.constraint(equalTo: self.centerYAnchor).activate()
                case .bottomLeft, .bottom, .bottomRight:
                badgeView.verticalConstraint = badgeView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: badge.type.spacing.reverse ?? (badgeSize.height * 0.33)).activate()
                
                }
                
                switch badge.position {
                case .topLeft, .centerLeft, .bottomLeft:
                    badgeView.horizontalConstraint = badgeView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: badge.type.spacing ?? -(badgeSize.width * 1.33)).activate()
                case .topRight, .centerRight, .bottomRight:
                    badgeView.horizontalConstraint = badgeView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant:  badge.type.spacing.reverse ?? badgeSize.width * 1.33).activate()
                case .top, .center, .bottom:
                    badgeView.horizontalConstraint = badgeView.centerXAnchor.constraint(equalTo: self.centerXAnchor).activate()
                    
                }
        }
        
        var centerYConstraint: NSLayoutConstraint? = nil
        var intrinsicSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
        override var intrinsicContentSize: NSSize {
            if self.frame.size == .zero {
               // Swift.print("intrinsicContentSize", CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric))
                return CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
            }
            
            var intrinsicContentSize = CGSize(NSView.noIntrinsicMetric, NSView.noIntrinsicMetric)
            var size = self.frame.size
            if let superviewWidth = self.superview?.frame.size.width {
                size.width = superviewWidth - configuration.margins.width
            }
            if let imageSize = image?.size, contentProperties.imageScaling.shouldResize {
                switch (contentProperties.maximumWidth, contentProperties.maximumHeight) {
                case (.some(let maxWidth), .some(let maxHeight)):
                    let width = min(maxWidth, size.width)
                    let height = min(maxHeight, size.height)
                    let imagesize = imageSize.scaled(toFit: CGSize(width, height))
                    intrinsicContentSize.width = imagesize.width
                    intrinsicContentSize.height =  imagesize.height
                case (.some(let maxWidth), nil):
                    let imagesize = imageSize.scaled(toWidth: min(maxWidth, size.width))
                    intrinsicContentSize.width = imagesize.width
                    intrinsicContentSize.height = imagesize.height
                case (nil, .some(let maxHeight)):
                    let imagesize = imageSize.scaled(toHeight: min(maxHeight, size.height))
               //     Swift.print("maxHei", imageSize, imagesize, self.frame.size)
                    intrinsicContentSize.width = imagesize.width
                    intrinsicContentSize.height = imagesize.height
                case (nil, nil):
                    let imagesize = imageSize.scaled(toFit: size)
                    intrinsicContentSize.width = imagesize.width
                }
            //    Swift.print("intrinsicContentSize", intrinsicContentSize)
                return intrinsicContentSize
            } else {
                if let imageSize = self.image?.size, configuration.contentProperties.imageScaling == .none {
                    
                    if imageSize.width < size.width {
                        intrinsicContentSize.width = imageSize.width
                    }
                    
                    if imageSize.height < size.height {
                        intrinsicContentSize.height = imageSize.height
                    }
                }
                
                if let maxWidth = contentProperties.maximumWidth {
                    if intrinsicContentSize.width != -1 {
                        if intrinsicContentSize.width > maxWidth {
                            intrinsicContentSize.width = maxWidth
                        }
                    } else if size.width > maxWidth {
                        intrinsicContentSize.width = maxWidth
                    }
                }
                
                if let maxHeight = contentProperties.maximumHeight {
                    if intrinsicContentSize.height != -1 {
                        if intrinsicContentSize.height > maxHeight {
                            intrinsicContentSize.height = maxHeight
                        }
                    } else if size.height > maxHeight {
                        intrinsicContentSize.height = maxHeight
                    }
                }
                
                Swift.print("intrinsicContentSize", intrinsicContentSize)
                return intrinsicContentSize
            }
        }
        
        func updateConfiguration() {
            self.backgroundColor = contentProperties._resolvedBackgroundColor
            self.borderColor = contentProperties._resolvedBorderColor
            self.borderWidth = contentProperties.resolvedBorderWidth
            self.cornerRadius = contentProperties.cornerRadius
            self.imageView.cornerRadius = contentProperties.cornerRadius
            self.overlayView?.cornerRadius = contentProperties.cornerRadius
            self.view?.cornerRadius = contentProperties.cornerRadius
            
            self.imageView.cornerRadius = contentProperties.cornerRadius
            self.view?.cornerRadius = contentProperties.cornerRadius
            self.overlayView?.cornerRadius = contentProperties.cornerRadius
            
            self.configurate(using: contentProperties.shadow)
            
            self.imageView.tintColor = contentProperties._resolvedImageTintColor
            self.imageView.imageScaling = contentProperties.imageScaling.gravity
            self.imageView.symbolConfiguration = contentProperties.imageSymbolConfiguration?.nsSymbolConfiguration()
            self.image = configuration.image
            
            if configuration.view != self.view {
                self.view = configuration.view
            }
            
            if configuration.overlayView != self.overlayView {
                self.overlayView = configuration.overlayView
            }
            
            self.isHidden = configuration.hasContent == false
            self.updateBadges()
            
            self.anchorPoint = CGPoint(0.5, 0.5)
            self.layer?.scale = CGPoint(contentProperties.scaleTransform, contentProperties.scaleTransform)
            
            self.clipsToBounds = false
            self.imageView.clipsToBounds = false
            self.imageView.maskToBounds = true
            self.overlayView?.clipsToBounds = false
            self.overlayView?.maskToBounds = true
            self.view?.clipsToBounds = false
            self.view?.maskToBounds = true
            
            self.invalidateIntrinsicContentSize()
        }
        
        init(configuration: NSItemContentConfiguration) {
            self.configuration = configuration
            super.init(frame: .zero)
            self.maskToBounds = false
            self.addSubview(imageView)
            self.updateConfiguration()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension OptionalProtocol where Wrapped == CGFloat {
    internal var reverse: CGFloat? {
        if let optional = self.optional {
            return -optional
        }
        return nil
    }
}
