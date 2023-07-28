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
      internal let imageView: NSImageView = NSImageView()
        internal var view: NSView? = nil {
            didSet {
                    oldValue?.removeFromSuperview()
                    if let newView = self.view {
                        self.addSubview(withConstraint: newView)
                        self.overlayView?.sendToFront()
                        self.isHidden = (self.image == nil && self.view == nil)
                    }
            }
        }
        
        internal var overlayView: NSView? = nil {
            didSet {
                    oldValue?.removeFromSuperview()
                    if let newView = self.overlayView {
                        self.addSubview(withConstraint: newView)
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
                
        internal func updateConfiguration() {
            self.backgroundColor = contentProperties._resolvedBackgroundColor
            self.borderColor = contentProperties._resolvedBorderColor
            self.borderWidth = contentProperties.borderWidth
            self.cornerRadius = contentProperties.cornerRadius
            self.configurate(using: contentProperties.shadow)
    
            imageView.symbolConfiguration = contentProperties.imageSymbolConfiguration?.nsUI()
            imageView.contentTintColor = contentProperties._resolvedImageTintColor
            imageView.imageScaling = contentProperties.imageScaling == .fit ? .scaleProportionallyUpOrDown : .scaleProportionallyDown
            
            self.image = configuration.image
            
            if configuration.view != self.view {
                self.view = configuration.view
            }
            
            if configuration.overlayView != self.overlayView {
                self.overlayView = configuration.overlayView
            }
            
            self.anchorPoint = CGPoint(0.5, 0.5)
            self.layer?.scale = CGPoint(contentProperties.scaleTransform, contentProperties.scaleTransform)
        }
                
        public init(configuration: NSItemContentConfiguration) {
            self.configuration = configuration
            super.init(frame: .zero)
            self.wantsLayer = true
            self.maskToBounds = true
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
