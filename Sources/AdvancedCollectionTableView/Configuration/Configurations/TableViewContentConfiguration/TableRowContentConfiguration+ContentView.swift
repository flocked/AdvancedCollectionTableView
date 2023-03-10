//
//  File.swift
//  
//
//  Created by Florian Zand on 15.12.22.
//

import AppKit
import FZExtensions

extension NSTableRowContentConfiguration {
    internal class ContentView: NSView, NSContentView {
        let contentView: NSView = NSView(frame: .zero)
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
                self.updateConfiguration(with: self.appliedConfiguration)
            }
        }
        
        internal func updateConfiguration(with configuration: NSTableRowContentConfiguration) {
            contentView.roundedCorners = configuration.roundedCorners
            contentView.cornerRadius = configuration.cornerRadius
            contentView.backgroundColor = configuration.resolvedBackgroundColor()
            contentView.layer?.contents = configuration.backgroundImage
            contentView.layer?.contentsGravity = configuration.imageProperties.scaling
            
            contentViewConstraits[0].constant = -configuration.backgroundPadding.bottom
            contentViewConstraits[1].constant = configuration.backgroundPadding.top
            contentViewConstraits[2].constant = configuration.backgroundPadding.leading
            contentViewConstraits[3].constant = configuration.backgroundPadding.trailing
        }
        
        func supports(_ configuration: NSContentConfiguration) -> Bool {
            return (configuration as? NSTableRowContentConfiguration) != nil
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
