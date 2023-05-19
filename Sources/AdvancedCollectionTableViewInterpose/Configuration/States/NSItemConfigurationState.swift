//
//  State.swift
//  IListContentConfiguration
//
//  Created by Florian Zand on 02.09.22.
//

import Foundation
import AppKit

/**
 A structure that encapsulates a item’s state.

 A item configuration state encompasses a trait collection along with all of the common states that affect a item’s appearance — view states like selected, focused, or disabled, and item states like editing or swiped. A item configuration state encapsulates the inputs that configure a item for any possible state or combination of states. You use a item configuration state with background and content configurations to obtain the default appearance for a specific state.
 Typically, you don’t create a configuration state yourself. To obtain a configuration state, override the ``updateConfiguration(using:)`` method in your item subclass and use the state parameter. Outside of this method, you can get a item’s configuration state by using its ``configurationState`` property.
 You can create your own custom states to add to a item configuration state by defining a custom state key using ``NSConfigurationStateCustomKey``.
 */
public struct NSItemConfigurationState: NSConfigurationState, Hashable {
    /// A Boolean value that indicates whether the item is in a selected state.
    public var isSelected: Bool = false
    /// A Boolean value that indicates whether the item is in a selectable state.
    public var isSelectable: Bool = false
    /// A Boolean value that indicates whether the item is in a disabled state.
    public var isDisabled: Bool = false
    /// A Boolean value that indicates whether the item is in a focused state.
    public var isFocused: Bool = false
    /// A Boolean value that indicates whether the item is in a hovered state (if the mouse is above the item).
    public var isHovered: Bool = false
    /// A Boolean value that indicates whether the item is in a editing state.
    public var isEditing: Bool = false
    /// A Boolean value that indicates whether the item is in a expanded state.
    public var isExpanded: Bool = false
    /// A value that indicates  the items highlight state.
    public var highlight: NSCollectionViewItem.HighlightState = .none
    /// A Boolean value that indicates whether the item is in a emphasized state.
    public var isEmphasized: Bool = false
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
         highlight: NSCollectionViewItem.HighlightState = .none,
         isEmphasized: Bool = false) {
        self.isSelected = isSelected
        self.isSelectable = isSelectable
        self.isDisabled = isDisabled
        self.isFocused = isFocused
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isExpanded = isExpanded
        self.highlight = highlight
        self.isEmphasized = isEmphasized
    }
}

