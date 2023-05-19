//
//  NSContentView.swift
//  
//
//  Created by Florian Zand on 03.09.22.
//

import AppKit

/**
 The requirements for a content view that you create using a configuration.

 This protocol provides a blueprint for a content view object that renders the content and styling that you define with its configuration. The content view’s configuration encapsulates all of the supported properties and behaviors for content view customization. Setting the content view’s configuration property applies the new configuration to the view, causing the view to render any updates to its appearance.
 */
public protocol NSContentView {
    /**
     The current configuration of the view.

     Setting this property applies the new configuration to the view.
     */
    var configuration: NSContentConfiguration { get set }
    
    /**
     Determines whether the view is compatible with the provided configuration.

     The default implementation assumes the view is compatible with configuration types that match the type of the view’s existing configuration.
     
     - Parameters:
        - configuration: The new configuration to test for compatibility.
     
     - Returns: true if the view supports this configuration being set to its configuration property and is capable of updating itself for the configuration; otherwise, false.
     */
    func supports(_ configuration: NSContentConfiguration) -> Bool
    func sizeThatFits(_ size: CGSize) -> CGSize
    var fittingSize: CGSize { get }
}

public extension NSContentView {
    func supports(_ configuration: NSContentConfiguration) -> Bool {
       return type(of: configuration) == type(of: self.configuration)
    }
}
