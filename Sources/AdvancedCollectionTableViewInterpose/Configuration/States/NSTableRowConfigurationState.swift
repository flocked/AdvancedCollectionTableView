//
//  State.swift
//  IListContentConfiguration
//
//  Created by Florian Zand on 02.09.22.
//

import AppKit
import FZExtensions

/**
 A structure that encapsulates a row’s state.

 A row configuration state encompasses a trait collection along with all of the common states that affect a row’s appearance — view states like selected, focused, or disabled, and row states like editing or swiped. A row configuration state encapsulates the inputs that configure a row for any possible state or combination of states. You use a row configuration state with background and content configurations to obtain the default appearance for a specific state.
 Typically, you don’t create a configuration state yourself. To obtain a configuration state, override the ``updateConfiguration(using:)`` method in your row subclass and use the state parameter. Outside of this method, you can get a row’s configuration state by using its ``configurationState`` property.
 You can create your own custom states to add to a row configuration state by defining a custom state key using ``NSConfigurationStateCustomKey``.
 */
public struct NSTableRowConfigurationState: NSConfigurationState, Hashable {
    /// A Boolean value that indicates whether the row is in a selected state.
    public var isSelected: Bool = false
    /// A Boolean value that indicates whether the row is in a selectable state.
    public var isSelectable: Bool = false
    /// A Boolean value that indicates whether the row is in a disabled state.
    public var isDisabled: Bool = false
    /// A Boolean value that indicates whether the row is in a focused state.
    public var isFocused: Bool = false
    /// A Boolean value that indicates whether the row is in a hovered state (if the mouse is above the row).
    public var isHovered: Bool = false
    /// A Boolean value that indicates whether the row is in a editing state.
    public var isEditing: Bool = false
    /// A Boolean value that indicates whether the row is in a expanded state.
    public var isExpanded: Bool = false
    /// A Boolean value that indicates whether the row is in a emphasized state.
    public var isEmphasized: Bool = false
    /// A Boolean value that indicates whether the next row is in a selected state.
    public var isNextRowSelected: Bool = false
    /// A Boolean value that indicates whether the previous row is in a selected state.
    public var isPreviousRowSelected: Bool = false

    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { return customStates[key] }
        set { customStates[key] = newValue }
    }
    
    internal var customStates = [NSConfigurationStateCustomKey:AnyHashable]()
    
    public init(isSelected: Bool = false,
         isSelectable: Bool = false,
         isDisabled: Bool = false,
         isFocused: Bool = false,
         isHovered: Bool = false,
         isEditing: Bool = false,
         isExpanded: Bool = false,
         isEmphasized: Bool = false,
         isNextRowSelected: Bool = false,
         isPreviousRowSelected: Bool = false) {
        self.isSelected = isSelected
        self.isSelectable = isSelectable
        self.isDisabled = isDisabled
        self.isFocused = isFocused
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isExpanded = isExpanded
        self.isEmphasized = isEmphasized
        self.isNextRowSelected = isNextRowSelected
        self.isPreviousRowSelected = isPreviousRowSelected
    }
}

