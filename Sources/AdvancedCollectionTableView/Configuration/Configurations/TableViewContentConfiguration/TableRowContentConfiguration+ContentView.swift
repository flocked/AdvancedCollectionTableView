//
//  File.swift
//  
//
//  Created by Florian Zand on 15.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSTableRowContentConfiguration {
    internal class ContentView: NSView, NSContentView {
        let contentView: NSView = NSView(frame: .zero)
        var backgroundView: NSView? = nil
        
        var configuration: NSContentConfiguration  {
            get { self.appliedConfiguration }
            set {
                if let newValue = newValue as? NSTableRowContentConfiguration {
                    self.appliedConfiguration = newValue
                }
            }
        }
        
        internal var appliedConfiguration: NSTableRowContentConfiguration {
            didSet {
                if oldValue != appliedConfiguration {
                    self.updateConfiguration(with: self.appliedConfiguration)
                }
            }
        }
        
        internal func updateConfiguration(with configuration: NSTableRowContentConfiguration) {
            contentView.roundedCorners = configuration.roundedCorners
            contentView.cornerRadius = configuration.cornerRadius
            contentView.backgroundColor = configuration.resolvedBackgroundColor()
            
         //   contentView.layer?.contents = configuration.backgroundImage
        //    contentView.layer?.contentsGravity = configuration.imageProperties.scaling
            
            if let backgroundView = configuration.backgroundView {
                if self.backgroundView != backgroundView {
                    self.backgroundView?.removeFromSuperview()
                    self.backgroundView = backgroundView
                    self.contentView.addSubview(withConstraint: backgroundView)
                }
            } else {
                self.backgroundView?.removeFromSuperview()
                self.backgroundView = nil
            }
                        
            contentViewConstraits[0].constant = -configuration.backgroundPadding.bottom
            contentViewConstraits[1].constant = configuration.backgroundPadding.top
            contentViewConstraits[2].constant = configuration.backgroundPadding.leading
            contentViewConstraits[3].constant = configuration.backgroundPadding.trailing
        }
        
        func supports(_ configuration: NSContentConfiguration) -> Bool {
            return configuration is NSTableRowContentConfiguration
        }
        
        var contentViewConstraits: [NSLayoutConstraint] = []
        
        init(configuration: NSTableRowContentConfiguration) {
            self.appliedConfiguration = configuration
            super.init(frame: .zero)
            contentViewConstraits = self.addSubview(withConstraint: contentView)
            contentView.wantsLayer = true
            self.updateConfiguration(with: configuration)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
