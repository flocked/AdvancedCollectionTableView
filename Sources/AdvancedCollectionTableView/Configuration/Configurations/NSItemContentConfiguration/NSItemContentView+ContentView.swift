//
//  NSItemContentView+ContentView.swift
//  
//
//  Created by Florian Zand on 24.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSItemContentView {
    class ItemContentView: NSView {
        internal var badgeView: ItemBadgeView? = nil
        internal let imageView: ImageView = ImageView()
        internal var view: NSView? = nil {
            didSet {
                oldValue?.removeFromSuperview()
                if let newView = self.view {
                    self.addSubview(withConstraint: newView)
                    self.overlayView?.sendToFront()
                    self.badgeView?.sendToFront()
                    self.isHidden = (self.image == nil && self.view == nil)
                }
            }
        }
        
        internal var overlayView: NSView? = nil {
            didSet {
                oldValue?.removeFromSuperview()
                if let newView = self.overlayView {
                    self.addSubview(withConstraint: newView)
                    self.badgeView?.sendToFront()
                }
            }
        }
        
        internal var image: NSImage? {
            get { imageView.image }
            set {
                guard newValue != self.imageView.image else { return }
                self.imageView.image = newValue
                self.imageView.isHidden = newValue == nil
                self.isHidden = (self.image == nil && self.view == nil)
            }
        }
        
        public var configuration: NSItemContentConfiguration {
            didSet {
                if oldValue != configuration {
                    updateConfiguration()
                }
            }
        }
        
        internal var contentProperties: NSItemContentConfiguration.ContentProperties {
            return configuration.contentProperties
        }
        
        internal var badge: NSItemContentConfiguration.Badge? {
            return configuration.badge
        }
        
        internal func updateConfiguration() {
            self.backgroundColor = contentProperties._resolvedBackgroundColor
            self.borderColor = contentProperties._resolvedBorderColor
            self.borderWidth = contentProperties.borderWidth
            self.cornerRadius = contentProperties.cornerRadius
            self.imageView.cornerRadius = contentProperties.cornerRadius
            self.view?.cornerRadius = contentProperties.cornerRadius
            self.overlayView?.cornerRadius = contentProperties.cornerRadius
            
            self.configurate(using: contentProperties.shadow)
            
            imageView.symbolConfiguration = contentProperties.imageSymbolConfiguration?.nsUI()
            imageView.contentTintColor = contentProperties._resolvedImageTintColor
            imageView.imageScaling = contentProperties.imageScaling.gravity
            
            self.image = configuration.image
            
            if configuration.view != self.view {
                self.view = configuration.view
            }
            
            if configuration.overlayView != self.overlayView {
                self.overlayView = configuration.overlayView
            }
            
            if configuration.hasBadge, configuration.hasContent, let badge = badge {
                let oldPosition = self.badgeView?.properties.position
                if self.badgeView == nil {
                    self.badgeView = ItemBadgeView(properties: badge)
                    self.addSubview(self.badgeView!)
                }
                self.badgeView?.properties = badge
                if oldPosition != badge.position {
                    self.layoutBadge()
                }
            } else {
                badgeView?.removeFromSuperview()
                badgeView = nil
            }
            
            self.anchorPoint = CGPoint(0.5, 0.5)
            self.layer?.scale = CGPoint(contentProperties.scaleTransform, contentProperties.scaleTransform)
        }
                
        internal func layoutBadge() {
            if let badge = self.badge, let badgeView = self.badgeView {
                badgeView.sendToFront()
                switch badge.position {
                case .bottomLeft, .topLeft:
                    badgeView.frame.origin.x = -(badgeView.frame.size.width*0.33)
                case .bottomRight, .topRight:
                    badgeView.frame.origin.x =
                   self.frame.size.width - (badgeView.frame.size.width*0.66)
                }
                switch badge.position {
                case .bottomLeft, .bottomRight:
                    badgeView.frame.origin.y =  -(badgeView.frame.size.height*0.33)
                case .topLeft, .topRight:
                    badgeView.frame.origin.y = self.frame.size.height - (badgeView.frame.size.height*0.66)
                }
            }
        }
        
        override func layout() {
            super.layout()
            self.imageView.frame.size = self.frame.size
            layoutBadge()
        }
        
        public init(configuration: NSItemContentConfiguration) {
            self.configuration = configuration
            super.init(frame: .zero)
            self.wantsLayer = true
            self.maskToBounds = false
            self.imageView.maskToBounds = true
            //  self.translatesAutoresizingMaskIntoConstraints = false
            //  self.imageView.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview( imageView)
            self.updateConfiguration()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
