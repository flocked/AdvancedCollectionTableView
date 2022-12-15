//
//  NSConfigurationState.swift
//  
//
//  Created by Florian Zand on 03.09.22.
//

import Foundation

/**
 The requirements for an object that encapsulates a view’s state.

 This protocol provides a blueprint for a configuration state object, which encompasses a trait collection along with all of the common states that affect a view’s appearance. A configuration state encapsulates the inputs that configure a view for any possible state or combination of states. You use a configuration state with background and content configurations to obtain the default appearance for a specific state.
 Typically, you don’t create a configuration state yourself. To obtain a configuration state, override the ``updateConfiguration(using:)`` method in your view subclass and use the state parameter. Outside of this method, you can get a view’s configuration state by using its ``configurationState`` property.
 For more information, see ``NSItemConfigurationState``.
 */
public protocol NSConfigurationState {
    subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? { get set }
}

/**
 A key that defines a custom state for a view.

 Create a custom state key if you want to define a custom state to include in a configuration state.
 
 ```
 // Declare a custom key for a custom isArchived state.
 extension NSConfigurationStateCustomKey {
     static let isArchived = NSConfigurationStateCustomKey("com.my-app.MyItem.isArchived")
 }

 // Declare an extension on the cell state structure to provide a typed property for this custom state.
 extension UIItemConfigurationState {
     var isArchived: Bool {
         get { return self[.isArchived] as? Bool ?? false }
         set { self[.isArchived] = newValue }
     }
 }

 class MyCell: NSCollectionViewItem {
     // This is an existing custom property of the cell.
     var isArchived: Bool {
         didSet {
             // Ensure that an update is performed whenever this property changes.
             if oldValue != isArchived {
                 setNeedsUpdateConfiguration()
             }
         }
     }

     override var configurationState: NSItemConfigurationState {
         // Get the structure with the system properties set by calling super.
         var state = super.configurationState

         // Set the custom property on the state.
         state.isArchived = self.isArchived
         return state
     }
 ```
 */
public struct NSConfigurationStateCustomKey: Hashable, RawRepresentable {
    /**
     Creates a custom state key.
     */
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    /**
     Creates a custom state key with the specified raw value.
     */
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var rawValue: String
    public typealias RawValue = String
}

extension NSConfigurationStateCustomKey: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}
