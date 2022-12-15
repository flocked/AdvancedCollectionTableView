//
//  NSBackgroundView.swift
//  
//
//  Created by Florian Zand on 04.09.22.
//

import AppKit

/**
 The requirements for a background view that you create using a configuration.

 This protocol provides a blueprint for a background view object that renders the background and styling that you define with its configuration. The background view’s configuration encapsulates all of the supported properties and behaviors for background view customization. Setting the background view’s configuration property applies the new configuration to the view, causing the view to render any updates to its appearance.
 */
public protocol NSBackgroundView {
    /**
     The current configuration of the view.

     Setting this property applies the new configuration to the view.
     */
    var configuration: NSBackgroundConfiguration { get set }
    
    /**
     Determines whether the view is compatible with the provided configuration.

     The default implementation assumes the view is compatible with configuration types that match the type of the view’s existing configuration.
     
     - Parameters:
        - configuration: The new configuration to test for compatibility.
     
     - Returns: true if the view supports this configuration being set to its configuration property and is capable of updating itself for the configuration; otherwise, false.
     */
    func supports(_ configuration: NSBackgroundConfiguration) -> Bool
    func sizeThatFits(_ size: CGSize) -> CGSize
    var fittingSize: CGSize { get }
}

public extension NSBackgroundView {
    func supports(_ configuration: NSBackgroundConfiguration) -> Bool {
       return type(of: configuration) == type(of: self.configuration)
    }
}
