//
//  NSBackgroundContentView.swift
//
//
//  Created by Florian Zand on 22.06.23.
//


#if os(macOS)
import AppKit
import FZSwiftUtils
import FZUIKit

public class NSBackgroundContentView: NSView, NSContentView {
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { appliedConfiguration }
        set {
            if let newValue = newValue as? NSBackgroundContentConfiguration {
                appliedConfiguration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSBackgroundContentConfiguration
    }
    
    /// Creates a background content view with the specified content configuration.
    public init(configuration: NSBackgroundContentConfiguration) {
        self.appliedConfiguration = configuration
        super.init(frame: .zero)
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        self.contentViewConstraints = self.addSubview(withConstraint: contentView)
        self.updateConfiguration()
    }
    
    internal let contentView = NSView()
    internal var contentViewConstraints: [NSLayoutConstraint] = []
    
    internal var view: NSView? = nil {
        didSet {
            if oldValue != self.view {
                oldValue?.removeFromSuperview()
                if let view = self.view {
                    contentView.addSubview(withConstraint: view)
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
                    contentView.addSubview(withConstraint: imageView)
                }
                self.imageView?.image = image
                self.imageView?.imageScaling = appliedConfiguration.imageScaling
            } else {
                self.imageView?.removeFromSuperview()
                self.imageView = nil
            }
        }
    }
    
    internal var appliedConfiguration: NSBackgroundContentConfiguration {
        didSet { if oldValue != appliedConfiguration {
            self.updateConfiguration() } } }
    
    internal func updateConfiguration() {
        self.view = appliedConfiguration.view
        self.image = appliedConfiguration.image
        
        imageView?.imageScaling = appliedConfiguration.imageScaling
        
        contentView.backgroundColor =  appliedConfiguration._resolvedColor
        contentView.visualEffect = appliedConfiguration.visualEffect
        contentView.cornerRadius = appliedConfiguration.cornerRadius
        
        contentView.configurate(using: appliedConfiguration.shadow, type: .outer)
        contentView.configurate(using: appliedConfiguration.innerShadow, type: .inner)
        contentView.configurate(using: appliedConfiguration.border)

        contentViewConstraints.constant(appliedConfiguration.insets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif

