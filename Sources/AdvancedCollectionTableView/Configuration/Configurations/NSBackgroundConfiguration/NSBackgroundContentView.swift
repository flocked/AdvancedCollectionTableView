//
//  File.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal class NSBackgroundContentView: NSView, NSContentView {
    internal var customView: NSView? = nil
    internal var imageView: ImageView? = nil
    
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set { if let newValue = newValue as? NSBackgroundConfiguration {
            _configuration = newValue
        } }  }
    
    internal var _configuration: NSBackgroundConfiguration {
        didSet {  self.updateConfiguration() } }
    
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSBackgroundConfiguration
    }
    
    internal func updateConfiguration() {
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
        
        self.backgroundColor =  _configuration._resolvedColor
        self.borderWidth = _configuration.border.width
        self.borderColor = _configuration._resolvedBorderColor
        
        self.visualEffect = _configuration.visualEffect
        self.cornerRadius = _configuration.cornerRadius
        
    }
    
    public init(configuration: NSBackgroundConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


