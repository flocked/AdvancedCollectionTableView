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
            
            self.layer?.scale = CGPoint(contentProperties.scaleTransform, contentProperties.scaleTransform)

            /*
            if contentProperties.scaleTransform > 1.0 {
                savedFrame = self.frame
                self.scale(by: contentProperties.scaleTransform)
                self.layer?.scale = CGPoint(contentProperties.scaleTransform, contentProperties.scaleTransform)
            } else {
                self.frame = savedFrame
                self.layer?.scale = CGPoint(contentProperties.scaleTransform, contentProperties.scaleTransform)
      
            }
             */
          //  self.layer?.scale = CGPoint(x: contentProperties.scaleTransform, y: self.properties.scaleTransform)
        }
        internal var savedFrame: CGRect = .zero
        internal var scaledFactor: CGFloat = 0.0
        
        public init(properties: NSItemContentConfiguration, view: NSView?, image: NSImage?, overlayView: NSView?) {
            self.properties = properties
            super.init(frame: .zero)
            self.wantsLayer = true
            self.maskToBounds = true
            self.imageView.maskToBounds = true
          //  self.translatesAutoresizingMaskIntoConstraints = false
          //  self.imageView.translatesAutoresizingMaskIntoConstraints = false
            
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

extension NSView {
    func scale(by factor: CGFloat) {
        let doubleSize = NSSize(width: factor, height: factor)
        self.scaleUnitSquare(to: doubleSize)
        
        let newSize = CGSize(factor * self.frame.width, factor * self.frame.height)
        var newOrigin = self.frame.origin
        Swift.print(factor, newSize)
        Swift.print("newOrigin.x", self.frame.size.width - (self.frame.size.width / factor))
        Swift.print("-----")
        newOrigin.x -= self.frame.size.width - (self.frame.size.width / factor)
        newOrigin.y -= self.frame.size.height - (self.frame.size.height / factor)
        self.frame = CGRect(newOrigin, newSize)
        
       // self.layer?.transform = CATransform3DMakeScale(factor, factor, 1.0)
    }
    
    func scale(by factor: CGFloat, animateDuration: CGFloat) {
        // Set the scale of the view to 2
        let doubleSize = NSSize(width: factor, height: factor)
        self.scaleUnitSquare(to: doubleSize)
        
        let newSize = CGSize(factor * self.frame.width, factor * self.frame.height)
        var newOrigin = self.frame.origin
        newOrigin.x -= (newSize.width - self.frame.size.width)
        newOrigin.y -= (newSize.height - self.frame.size.height)
                
        // Set the frame to the scaled frame
        self.frame = CGRect(
            x: self.frame.origin.x,
            y: self.frame.origin.y,
            width: factor * self.frame.width,
            height: factor * self.frame.height
        )
        
        // Create the scale animation
        let animation = CABasicAnimation()
        let duration = 1

        animation.duration = animateDuration
        animation.fromValue = CATransform3DMakeScale(1.0, 1.0, 1.0)
        animation.toValue = CATransform3DMakeScale(factor, factor, 1.0)

        // Trigger the scale animation
        self.layer?.add(animation, forKey: "transform")
                
        // Add a simultaneous translation animation to keep the
        // view center static during the zoom animation
        NSAnimationContext.runAnimationGroup({ context in
            // Match the configuration of the scale animation
            context.duration = animateDuration
            context.timingFunction = CAMediaTimingFunction(
                name: CAMediaTimingFunctionName.linear)
            var origin = self.frame.origin
            // Translate the frame
            origin.x -= self.frame.size.width - (self.frame.size.width / factor)
            origin.y -= self.frame.size.height - (self.frame.size.height / factor)

            // Trigger the animation
            self.animator().frame.origin = newOrigin
        })
    }
}
