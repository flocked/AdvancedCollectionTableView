//
//  File.swift
//  
//
//  Created by Florian Zand on 24.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSItemContentViewNS {
    class ItemContentView: NSView {
      //  let containerView = NSView(frame: CGRect(.zero, CGSize(1, 1)))
        let imageView: NSImageView = NSImageView()
        var view: NSView? = nil {
            didSet {
                    oldValue?.removeFromSuperview()
                    if let newView = self.view {
                        self.addSubview(withConstraint: newView)
                        self.overlayView?.sendToFront()
                        self.isHidden = (self.image == nil && self.view == nil)
                    }
            }
        }
        
        var overlayView: NSView? = nil {
            didSet {
                    oldValue?.removeFromSuperview()
                    if let newView = self.overlayView {
                        self.addSubview(withConstraint: newView)
                    }
            }
        }
        
        var imageSize: CGSize? = nil
        
        var image: NSImage? {
            get { imageView.image }
            set {
                guard newValue != self.imageView.image else { return }
                self.imageSize = newValue?.size
                self.imageView.image = newValue
                self.imageView.isHidden = newValue == nil
                self.isHidden = (self.image == nil && self.view == nil)
            }
        }
        
        var properties: NSItemContentConfiguration {
            didSet {
                if oldValue != properties {
                update() }
            }
        }
        
        var contentProperties: NSItemContentConfiguration.ContentProperties {
            return properties.contentProperties
        }
                
        func update() {
            self.backgroundColor = contentProperties._resolvedBackgroundColor
            self.borderColor = contentProperties._resolvedBorderColor
            self.borderWidth = contentProperties.borderWidth
            self.cornerRadius = contentProperties.cornerRadius
            self.configurate(using: contentProperties.shadow)
    
            imageView.symbolConfiguration = contentProperties.imageSymbolConfiguration?.nsUI()
            imageView.contentTintColor = contentProperties._resolvedImageTintColor
            imageView.imageScaling = contentProperties.imageScaling == .fit ? .scaleProportionallyUpOrDown : .scaleProportionallyDown
            
            self.image = properties.image
            
            if properties.view != self.view {
                self.view = properties.view
            }
            
            if properties.overlayView != self.overlayView {
                self.overlayView = properties.overlayView
            }
            
            self.anchorPoint = CGPoint(0.5, 0.5)
            self.layer?.scale = CGPoint(contentProperties.scaleTransform, contentProperties.scaleTransform)
        }
                
        public init(properties: NSItemContentConfiguration) {
            self.properties = properties
            super.init(frame: .zero)
            self.wantsLayer = true
            self.maskToBounds = true
            self.imageView.maskToBounds = true
          //  self.translatesAutoresizingMaskIntoConstraints = false
          //  self.imageView.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview( imageView)
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
