//
//  File.swift
//  
//
//  Created by Florian Zand on 08.04.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public struct NSBackgroundConfiguration: NSContentConfiguration {
    public func makeContentView() -> NSView & NSContentView {
        ContentView(configuration: self)
    }
    
    public func updated(for state: NSConfigurationState) -> NSBackgroundConfiguration {
        return self
    }
    
     var customView: NSView? = nil
     var cornerRadius: CGFloat = 0.0
     var backgroundInsets: NSDirectionalEdgeInsets = .zero
  //   var edgesAddingLayoutMarginsToBackgroundInsets: NSDirectionalRectEdge
     var backgroundColor: NSColor? = nil
     var backgroundColorTransformer: NSConfigurationColorTransformer? = nil
     public func resolvedBackgroundColor(for color: NSColor) -> NSColor {
        return backgroundColorTransformer?(color) ?? color
     }
     var visualEffect: ContentConfiguration.VisualEffect? = nil
    
    var border: ContentConfiguration.Border = .none()
    
     var image: NSImage? = nil
        var imageScaling: CALayerContentsGravity = .center
}

internal extension NSBackgroundConfiguration {
    class ContentView: NSView, NSContentView {
        var customView: NSView? = nil
        var imageView: ImageView? = nil
        var configuration: NSContentConfiguration {
            get { _configuration }
            set { if let newValue = newValue as? NSBackgroundConfiguration {
                _configuration = newValue
            } }  }
        
        var _configuration: NSBackgroundConfiguration {
            didSet {  self.updateConfiguration() } }
        
        func updateConfiguration() {
            if let customView = _configuration.customView {
                if (self.customView != customView) {
                    self.customView?.removeFromSuperview()
                    self.customView = customView
                    self.addSubview(withConstraint: customView)
                }
            } else {
                self.customView?.removeFromSuperview()
                self.customView = nil
            }
            
            if let image = _configuration.image {
                if (self.imageView == nil) {
                    let imageView = ImageView()
                    self.imageView = imageView
                    self.addSubview(withConstraint: imageView)
                }
                self.imageView?.image = image
                self.imageView?.imageScaling = _configuration.imageScaling
            } else {
                self.imageView?.removeFromSuperview()
                self.imageView = nil
            }
            
            self.backgroundColor = _configuration.backgroundColor
            if let backgroundColor = _configuration.backgroundColor {
                self.borderColor = _configuration.resolvedBackgroundColor(for: backgroundColor)
            } else {
                self.borderColor = nil
            }
            self.borderWidth = _configuration.border.width
            if let borderColor = _configuration.border.color {
                self.borderColor = _configuration.border.resolvedColor(for: borderColor)
            } else {
                self.borderColor = nil
            }
            
            self.visualEffect = _configuration.visualEffect
            self.cornerRadius = _configuration.cornerRadius

        }
        
        init(configuration: NSBackgroundConfiguration) {
            self._configuration = configuration
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

