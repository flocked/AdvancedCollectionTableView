//
//  File.swift
//  
//
//  Created by Florian Zand on 24.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSItemContentViewNS {
    class ItemContentView: NSView {
        let containerView = NSView(frame: CGRect(.zero, CGSize(1, 1)))
        let imageView: NSImageView = NSImageView()
        var view: NSView? = nil {
            didSet {
                if oldValue != self.view {
                    oldValue?.removeFromSuperview()
                    if let newView = self.view {
                        containerView.addSubview(withConstraint: newView)
                        self.overlayView?.sendToFront()
                        self.isHidden = (self.image == nil && self.view == nil)
                    }
                }
            }
        }
        
        var overlayView: NSView? = nil {
            didSet {
                if oldValue != self.overlayView {
                    oldValue?.removeFromSuperview()
                    if let newView = self.overlayView {
                        containerView.addSubview(withConstraint: newView)
                    }
                }
            }
        }
        
        public override func layout() {
            super.layout()
            
            self.containerView.frame.size = self.frame.size
            
            if let imageSize = self.image?.size {
                let size = imageSize.scaled(toHeight: self.frame.size.height)
                let previousFrameSize = self.frame.size
            //    self.containerView.frame.size = size
                self.imageView.frame.size = size
                self.imageView.center = self.center
                Swift.print("scaled", previousFrameSize, imageSize, size, self.imageView.frame.size)
            } else {
           //     self.containerView.frame.size = self.frame.size
          //      self.containerView.frame.origin = .zero
            }
            Swift.print(self.frame.size)
        }
        
        var image: NSImage? {
            get { imageView.image }
            set {
                guard newValue != self.imageView.image else { return }
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
            containerView.backgroundColor = contentProperties._resolvedBackgroundColor
            containerView.borderColor = contentProperties._resolvedBorderColor
            containerView.borderWidth = contentProperties.borderWidth
            containerView.cornerRadius = contentProperties.cornerRadius
            containerView.configurate(using: contentProperties.shadow)
    
            imageView.symbolConfiguration = contentProperties.imageSymbolConfiguration?.nsUI()
            imageView.contentTintColor = contentProperties._resolvedImageTintColor
            imageView.imageScaling = contentProperties.imageScaling == .fit ? .scaleProportionallyUpOrDown : .scaleProportionallyDown
            
            containerView.layer?.scale = CGPoint(x: contentProperties.scaleTransform, y: self.properties.scaleTransform)
        }
        
        public init(properties: NSItemContentConfiguration, view: NSView?, image: NSImage?, overlayView: NSView?) {
            self.properties = properties
            super.init(frame: .zero)
            self.wantsLayer = true
            self.maskToBounds = false
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.maskToBounds = true
          //  self.addSubview(containerView)
            self.addSubview( imageView)
            self.update()
            self.view = view
            self.image = image
            self.overlayView = overlayView
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
