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
        let imageView: NSImageView = NSImageView()
        var view: NSView? = nil {
            didSet {
                if oldValue != self.view {
                    oldValue?.removeFromSuperview()
                    if let newView = self.view {
                        self.addSubview(withConstraint: newView)
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
                        self.addSubview(withConstraint: newView)
                    }
                }
            }
        }
        
        var image: NSImage? {
            get { imageView.image }
            set {
                self.imageView.image = newValue
                self.imageView.isHidden = newValue == nil
                self.isHidden = (self.image == nil && self.view == nil)
            }
        }
        
        var properties: NSItemContentConfiguration.ContentProperties {
            didSet {
                if oldValue != properties {
                update() }
            }
        }
                
        func update() {
            self.backgroundColor = properties._resolvedBackgroundColor
            self.imageView.symbolConfiguration = properties.imageSymbolConfiguration?.nsUI()
            
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.configurate(using: properties.shadow)
    
            self.imageView.contentTintColor = properties._resolvedImageTintColor
            self.imageView.imageScaling = properties.imageScaling == .fit ? .scaleProportionallyUpOrDown : .scaleProportionallyDown
            self.layer?.scale = CGPoint(x: self.properties.scaleTransform, y: self.properties.scaleTransform)
            
            self.cornerRadius = properties.cornerRadius
        }
        
        public init(properties: NSItemContentConfiguration.ContentProperties, view: NSView?, image: NSImage?, overlayView: NSView?) {
            self.properties = properties
            super.init(frame: .zero)
            self.wantsLayer = true
            self.maskToBounds = false
            self.addSubview(withConstraint: imageView)
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
