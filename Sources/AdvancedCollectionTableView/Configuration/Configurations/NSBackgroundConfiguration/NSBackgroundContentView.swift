//
//  File.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public class NSBackgroundContentView: NSView, NSContentView {
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSBackgroundConfiguration {
                _configuration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSBackgroundConfiguration
    }
    
    /// Creates a background content view with the specified content configuration.
    public init(configuration: NSBackgroundConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
        self.maskToBounds = false
        self.updateConfiguration()
    }
    
    internal var view: NSView? = nil {
        didSet {
            if oldValue != self.view {
                oldValue?.removeFromSuperview()
                if let view = self.view {
                    self.addSubview(withConstraint: view)
                }
            }
        }
    }
    internal var imageView: ImageView? = nil
    internal var image: NSImage? {
        get { imageView?.image }
        set {
            guard newValue != imageView?.image else { return }
            if let image = newValue {
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
        }
    }
    
    internal var _configuration: NSBackgroundConfiguration {
        didSet { if oldValue != _configuration {
            self.updateConfiguration() } } }
    
    internal func updateConfiguration() {
        self.view = _configuration.view
        self.image = _configuration.image
        
        self.backgroundColor =  _configuration._resolvedColor
        
        self.visualEffect = _configuration.visualEffect
        self.cornerRadius = _configuration.cornerRadius
        
        self.configurate(using: _configuration.shadow)
        self.configurate(using: _configuration.border)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


