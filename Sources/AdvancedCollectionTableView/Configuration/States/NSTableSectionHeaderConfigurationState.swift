//
//  NSTableSectionHeaderConfigurationState.swift
//
//
//  Created by Florian Zand on 02.09.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

/**
 A structure that encapsulates a table view section header state.
 
 A row configuration state encompasses a trait collection along with all of the common states that affect a row’s appearance — view states like selected, focused, or disabled, and row states like editing or swiped. A row configuration state encapsulates the inputs that configure a row for any possible state or combination of states. You use a row configuration state with background and content configurations to obtain the default appearance for a specific state.
 Typically, you don’t create a configuration state yourself. To obtain a configuration state, override the `updateConfiguration(using:)` method in your row subclass and use the state parameter. Outside of this method, you can get a row’s configuration state by using its `configurationState` property.
 You can create your own custom states to add to a row configuration state by defining a custom state key using `NSConfigurationStateCustomKey`.
 */
public struct NSTableSectionHeaderConfigurationState: NSConfigurationState, Hashable {    
    /// A Boolean value that indicates whether the section header is in a enabled state. If displayed in a table view, it reflects the table view`s `isEnabled`.
    public var isEnabled: Bool = true
    
    /// A Boolean value that indicates whether the section header is in a hovered state (the mouse is hovering the row).
    public var isHovered: Bool = false
    
    /// A Boolean value that indicates whether the section header is in a editing state.
    public var isEditing: Bool = false
    
    /// A Boolean value that indicates whether the section header is in a emphasized state. It is `true` if the window that displays the cell is `main`.
    public var isEmphasized: Bool = false
    
    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { return customStates[key] }
        set { customStates[key] = newValue }
    }
    
    internal var customStates = [NSConfigurationStateCustomKey:AnyHashable]()
    
    public init(isEnabled: Bool = true,
                isHovered: Bool = false,
                isEditing: Bool = false,
                isEmphasized: Bool = false) {
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
    }
}

