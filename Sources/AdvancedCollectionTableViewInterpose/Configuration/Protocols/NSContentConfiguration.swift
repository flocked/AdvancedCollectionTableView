//
//  NSContentConfiguration.swift
//  
//
//  Created by Florian Zand on 02.09.22.
//

import AppKit

/**
 The requirements for an object that provides the configuration for a content view.

 This protocol provides a blueprint for a content configuration object, which encompasses default styling and content for a content view. The content configuration encapsulates all of the supported properties and behaviors for content view customization. You use the configuration to create the content view.
 */
public protocol NSContentConfiguration {
    /**
     Creates a new instance of the content view using this configuration.
     */
    func makeContentView() -> NSView & NSContentView
    
    /**
     Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you haven’t customized.
     */
    func updated(for state: NSConfigurationState) -> Self
}
