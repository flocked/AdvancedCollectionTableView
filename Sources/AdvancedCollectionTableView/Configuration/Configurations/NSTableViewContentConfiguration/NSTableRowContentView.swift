//
//  File.swift
//  
//
//  Created by Florian Zand on 15.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal class NSTableRowContentView: NSView, NSContentView {
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration  {
        get { self._configuration }
        set {
            if let newValue = newValue as? NSTableRowContentConfiguration {
                self._configuration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        return configuration is NSTableRowContentConfiguration
    }
        
    /// Creates a table row content view with the specified content configuration.
    public init(configuration: NSTableRowContentConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
        self.contentView.wantsLayer = true
        self.contentViewConstraits = self.addSubview(withConstraint: contentView)
        self.updateConfiguration()
    }
    
    internal let contentView: NSView = NSView(frame: .zero)
    internal var backgroundView: NSView? = nil {
        didSet {
            if oldValue != self.backgroundView {
                oldValue?.removeFromSuperview()
                if let backgroundView = self.backgroundView {
                    self.contentView.addSubview(withConstraint: backgroundView)
                }
            }
        }
    }
    internal var imageView: NSImageView? = nil
    internal var image: NSImage? = nil {
        didSet {
            if let image = self.image {
                if (imageView == nil) {
                    let imageView = NSImageView(frame: .zero)
                    self.contentView.addSubview(withConstraint: imageView)
                    self.imageView = imageView
                }
                self.imageView?.image = image
            } else {
                imageView?.removeFromSuperview()
                imageView = nil
            }
        }
    }
        
    internal var _configuration: NSTableRowContentConfiguration {
        didSet {
            if oldValue != _configuration {
                self.updateConfiguration()
            }
        }
    }
    
    internal func updateConfiguration() {
        contentView.cornerRadius = _configuration.cornerRadius
        contentView.backgroundColor = _configuration._resolvedBackgroundColor
        contentView.borderColor = _configuration._resolvedBorderColor
        contentView.borderWidth = _configuration.borderWidth
        //   contentView.layer?.contents = configuration.backgroundImage
        //    contentView.layer?.contentsGravity = configuration.imageProperties.scaling
        
        self.image = _configuration.image
        self.backgroundView = _configuration.backgroundView
        
        contentViewConstraits[0].constant = -_configuration.backgroundPadding.bottom
        contentViewConstraits[1].constant = _configuration.backgroundPadding.top
        contentViewConstraits[2].constant = _configuration.backgroundPadding.leading
        contentViewConstraits[3].constant = -_configuration.backgroundPadding.trailing
    }
    
    internal var contentViewConstraits: [NSLayoutConstraint] = []
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
