//
//  ContentConfigurationView.swift
//
//
//  Created by Florian Zand on 21.02.24.
//

import AppKit
import FZUIKit

/// A view that displays the content view of a `NSContentConfiguration`.
class ContentConfigurationView: NSView {
    
    /// The content view.
    var contentView: (NSView & NSContentView)

    /// The current content configuration.
    public var contentConfiguration: NSContentConfiguration {
        didSet {
            updateContentView()
        }
    }
    
    func updateContentView() {
        if contentView.supports(contentConfiguration) {
            contentView.configuration = contentConfiguration
        } else {
            contentView.removeFromSuperview()
            contentView = contentConfiguration.makeContentView()
            addSubview(withConstraint: contentView)
        }
    }
    
    /// Creates a view with the specified content configuration.
    public init(configuration: NSContentConfiguration) {
        self.contentConfiguration = configuration
        self.contentView = configuration.makeContentView()
        super.init(frame: .zero)
        addSubview(withConstraint: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
