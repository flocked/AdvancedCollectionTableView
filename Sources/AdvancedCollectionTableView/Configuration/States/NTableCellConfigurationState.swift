//
//  State.swift
//  IListContentConfiguration
//
//  Created by Florian Zand on 02.09.22.
//

import AppKit
import FZExtensions

/**
 A structure that encapsulates a cell’s state.

 A cell configuration state encompasses a trait collection along with all of the common states that affect a cell’s appearance — view states like selected, focused, or disabled, and cell states like editing or swiped. A cell configuration state encapsulates the inputs that configure a cell for any possible state or combination of states. You use a cell configuration state with background and content configurations to obtain the default appearance for a specific state.
 Typically, you don’t create a configuration state yourself. To obtain a configuration state, override the updateConfiguration(using:) method in your cell subclass and use the state parameter. Outside of this method, you can get a cell’s configuration state by using its configurationState property.
 You can create your own custom states to add to a cell configuration state by defining a custom state key using NSConfigurationStateCustomKey.
 */
public struct NSTableCellConfigurationState: NSConfigurationState, Hashable {
    /// A Boolean value that indicates whether the cell is in a selected state.
    public var isSelected: Bool = false
    
    /// A Boolean value that indicates whether the cell is in a selectable state.
    ///
    public var isSelectable: Bool = false
    /// A Boolean value that indicates whether the cell is in a disabled state.
    ///
    public var isDisabled: Bool = false
    
    /// A Boolean value that indicates whether the cell is in a focused state.
    public var isFocused: Bool = false
    
    /// A Boolean value that indicates whether the cell is in a hovered state (if the mouse is above the cell).
    public var isHovered: Bool = false
    
    /// A Boolean value that indicates whether the cell is in a editing state.
    public var isEditing: Bool = false
    
    /// A Boolean value that indicates whether the cell is in a expanded state.
    public var isExpanded: Bool = false
    
    /// A Boolean value that indicates whether the cell is in a emphasized state.
    public var isEmphasized: Bool = false

    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { return customStates[key] }
        set { customStates[key] = newValue }
    }
    
    internal var customStates = [NSConfigurationStateCustomKey:AnyHashable]()
}

