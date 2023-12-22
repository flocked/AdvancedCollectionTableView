//
//  File.swift
//  
//
//  Created by Florian Zand on 22.12.23.
//

import AppKit
import SwiftUI
import FZUIKit


/// A content view for displaying list-based content.
public class NSListContentViewSwiftUI: NSView, NSContentView {
    
    /// Creates a table cell content view with the specified content configuration.
    public init(configuration: NSListContentConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
        self.initialSetup()
        self.updateConfiguration()
    }
    
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSListContentConfiguration {
                _configuration = newValue }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSListContentConfiguration
    }
    
    internal func initialSetup() {
        self.clipsToBounds = false
 
    }
    
    internal var stackViewConstraints: [NSLayoutConstraint] = []
    internal var _configuration: NSListContentConfiguration {
        didSet { if oldValue != _configuration {
            updateConfiguration() } } }

    
    internal func updateConfiguration() {
        
    }
    
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
