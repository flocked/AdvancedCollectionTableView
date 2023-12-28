//
//  File.swift
//  
//
//  Created by Florian Zand on 28.12.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import AdvancedCollectionTableViewObjc

/**
 A structure that encapsulates a table view row state.
 
 A row configuration state encompasses a trait collection along with all of the common states that affect a row’s appearance — view states like selected, focused, or disabled, and row states like editing or swiped. A row configuration state encapsulates the inputs that configure a row for any possible state or combination of states. You use a row configuration state with background and content configurations to obtain the default appearance for a specific state.
 Typically, you don’t create a configuration state yourself. To obtain a configuration state, override the `updateConfiguration(using:)` method in your row subclass and use the state parameter. Outside of this method, you can get a row’s configuration state by using its `configurationState` property.
 You can create your own custom states to add to a row configuration state by defining a custom state key using `NSConfigurationStateCustomKey`.
 */
public struct NSListConfigurationState: NSConfigurationState, Hashable {
    
    /// A Boolean value that indicates whether the row is in a selected state.
    public var isSelected: Bool = false
    
    /// A Boolean value that indicates whether the row is in an enabled state. If displayed in a table view, it reflects the table view`s `isEnabled`.
    public var isEnabled: Bool = true
    
    /// A Boolean value that indicates whether the row is in a hovered state (the mouse is hovering the row).
    public var isHovered: Bool = false
    
    /// A Boolean value that indicates whether the row is in an editing state.
    public var isEditing: Bool = false
    
    /// A Boolean value that indicates whether the row is in an emphasized state. It is `true` if the window of the row view is `key`.
    public var isEmphasized: Bool = false
    
    /// A Boolean value that indicates whether the next row is in a selected state.
    public var isNextRowSelected: Bool = false
    
    /// A Boolean value that indicates whether the previous row is in a selected state.
    public var isPreviousRowSelected: Bool = false
    
    /// A Boolean value that indicates whether the row is in a focused state.
    var isFocused: Bool = false
    
    /// A Boolean value that indicates whether the row is in an expanded state.
    var isExpanded: Bool = false
    
    var customStates = [NSConfigurationStateCustomKey:AnyHashable]()
    
    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { return customStates[key] }
        set { customStates[key] = newValue }
    }
    
    public init(isSelected: Bool = false,
                isEnabled: Bool = true,
                isHovered: Bool = false,
                isEditing: Bool = false,
                isEmphasized: Bool = false,
                isNextRowSelected: Bool = false,
                isPreviousRowSelected: Bool = false) {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
        self.isNextRowSelected = isNextRowSelected
        self.isPreviousRowSelected = isPreviousRowSelected
    }
    
    init(isSelected: Bool,
                isEnabled: Bool,
                isHovered: Bool,
                isEditing: Bool,
                isEmphasized: Bool,
                isNextRowSelected: Bool,
         isPreviousRowSelected: Bool,
         customStates: [NSConfigurationStateCustomKey:AnyHashable]
    ) {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
        self.isNextRowSelected = isNextRowSelected
        self.isPreviousRowSelected = isPreviousRowSelected
        self.customStates = customStates
    }
}
