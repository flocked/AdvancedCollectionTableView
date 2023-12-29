//
//  NSListConfigurationState.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import AdvancedCollectionTableViewObjc

/**
 A structure that encapsulates a state for an individual element that appears in a list.
    
 A list configuration state encompasses the common states that affect the appearance of the list element — states like selected, emphasized, or enabled. You can use it to update the appearance.
 
 The configuration state is used with `NSTableCellView`, `NSTableRowView` and `NSTableSectionHeaderView`.
 
 Typically, you don’t create a configuration state yourself. To obtain a configuration state either use the list element's `configurationUpdateHandler` or override its `updateConfiguration(using:)` method in a subclass and use the state parameter. Outside of this method, you can get the configuration state by using its `configurationState` property.
 
 You can create your own custom states to add to a list configuration state by defining a custom state key using `NSConfigurationStateCustomKey`.
 */
public struct NSListConfigurationState: NSConfigurationState, Hashable {
    
    /// A Boolean value that indicates whether the list element is in a selected state.
    public var isSelected: Bool = false
    
    /// A Boolean value that indicates whether the list element is in an enabled state. If displayed in a table view, it reflects the table view`s `isEnabled`.
    public var isEnabled: Bool = true
    
    /// A Boolean value that indicates whether the list element is in a hovered state (the mouse is hovering the row).
    public var isHovered: Bool = false
    
    /// A Boolean value that indicates whether the list element is in an editing state.
    public var isEditing: Bool = false
    
    /// A Boolean value that indicates whether the list element is in an emphasized state. It is `true` if the window of the row view is `key`.
    public var isEmphasized: Bool = false
    
    /// A Boolean value that indicates whether the next list element is in a selected state.
    public var isNextSelected: Bool = false
    
    /// A Boolean value that indicates whether the previous list element is in a selected state.
    public var isPreviousSelected: Bool = false
    
    /// A Boolean value that indicates whether the list element is in a focused state.
    var isFocused: Bool = false
    
    /// A Boolean value that indicates whether the list element is in an expanded state.
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
                isNextSelected: Bool = false,
                isPreviousSelected: Bool = false) {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
        self.isNextSelected = isNextSelected
        self.isPreviousSelected = isPreviousSelected
    }
    
    init(isSelected: Bool,
         isEnabled: Bool,
         isHovered: Bool,
         isEditing: Bool,
         isEmphasized: Bool,
         isNextSelected: Bool,
         isPreviousSelected: Bool,
         customStates: [NSConfigurationStateCustomKey:AnyHashable]
    ) {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
        self.isNextSelected = isNextSelected
        self.isPreviousSelected = isPreviousSelected
        self.customStates = customStates
    }
}

extension NSListConfigurationState: _ObjectiveCBridgeable {

    public func _bridgeToObjectiveC() -> NSListConfigurationStateObjc {
        let customStates = self.customStates.mapKeys({ $0.rawValue })
        return NSListConfigurationStateObjc(isSelected: self.isSelected, isEditing: self.isEditing, isEmphasized: self.isEmphasized, isHovered: self.isHovered, isEnabled: isEnabled, isFocused: isFocused, isExpanded: isExpanded, isNextSelected: isNextSelected, isPreviousSelected: isPreviousSelected, customStates: customStates)
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSListConfigurationStateObjc, result: inout NSListConfigurationState?) {
        let customStates = (source.customStates as? [String: AnyHashable] ?? [:]).mapKeys({ NSConfigurationStateCustomKey(rawValue: $0) })
        result = NSListConfigurationState(isSelected: source.isSelected, isEnabled: source.isEnabled, isHovered: source.isHovered, isEditing: source.isEditing, isEmphasized: source.isEmphasized, isNextSelected: source.isNextSelected, isPreviousSelected: source.isPreviousSelected, customStates: customStates)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: NSListConfigurationStateObjc, result: inout NSListConfigurationState?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSListConfigurationStateObjc?) -> NSListConfigurationState {
        if let source = source {
            var result: NSListConfigurationState?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return NSListConfigurationState()
    }
}
