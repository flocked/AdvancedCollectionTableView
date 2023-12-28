//
//  NSTableCellConfigurationState.swift
//  
//
//  Created by Florian Zand on 02.09.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import AdvancedCollectionTableViewObjc

/**
 A structure that encapsulates a table view cell state.
 
 You can use a table cell configuration state with content configurations to obtain the default appearance for a specific state.
 
 Typically, you don’t create a configuration state yourself. To obtain a configuration state, use `NSTableCellView` ``AppKit/NSTableCellView/configurationUpdateHandler-swift.property`` or  override the ``AppKit/NSTableCellView/updateConfiguration(using:)`` method in your cell subclass and use the state parameter. Outside of this method, you can get a cell’s configuration state by using its ``AppKit/NSTableCellView/configurationState`` property.
 
 You can create your own custom states to add to a cell configuration state by defining a custom state key using `NSConfigurationStateCustomKey`.
 */
public struct NSTableCellConfigurationState: NSConfigurationState, Hashable {
    /// A Boolean value that indicates whether the cell is in a selected state.
    public var isSelected: Bool = false
    
    /// A Boolean value that indicates whether the cell is in an editing state.
    public var isEditing: Bool = false
    
    /// A Boolean value that indicates whether the cell is in a hovered state (ithe mouse is hovering the cell).
    public var isHovered: Bool = false
    
    /// A Boolean value that indicates whether the cell is in an emphasized state. It is `true` if the window of the cell is `key`.
    public var isEmphasized: Bool = false
    
    /// A Boolean value that indicates whether the cell is in an enabled state. If displayed in a table view, it reflects the table view`s `isEnabled`.
    public var isEnabled: Bool = true
    
    /// A Boolean value that indicates whether the cell is in a focused state.
    var isFocused: Bool = false
    
    /// A Boolean value that indicates whether the cell is in an expanded state.
    var isExpanded: Bool = false
    
    var customStates = [NSConfigurationStateCustomKey:AnyHashable]()
    
    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { return customStates[key] }
        set { customStates[key] = newValue }
    }
    
    public init(isSelected: Bool = false,
                isEditing: Bool = false,
                isEmphasized: Bool = false,
                isHovered: Bool = false,
                isEnabled: Bool = true) {
        self.isSelected = isSelected
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
        self.isHovered = isHovered
        self.isEnabled = true
        self.isFocused = false
        self.isExpanded = false
    }
    
    init(
        isSelected: Bool,
        isEmphasized: Bool,
        isEnabled: Bool,
        isFocused: Bool,
        isHovered: Bool,
        isEditing: Bool,
        isExpanded: Bool,
        customStates: [NSConfigurationStateCustomKey:AnyHashable] = [:]
    ) {
            self.isSelected = isSelected
            self.isEnabled = isEnabled
            self.isFocused = isFocused
            self.isHovered = isHovered
            self.isEditing = isEditing
            self.isExpanded = isExpanded
            self.isEmphasized = isEmphasized
            self.customStates = customStates
        }
}

extension NSTableCellConfigurationState: _ObjectiveCBridgeable {

    public func _bridgeToObjectiveC() -> NSTableCellConfigurationStateObjc {
        let customStates = self.customStates.mapKeys({ $0.rawValue })
        return NSTableCellConfigurationStateObjc(isSelected: self.isSelected, isEditing: self.isEditing, isEmphasized: self.isEmphasized, isHovered: self.isHovered, isEnabled: isEnabled, isFocused: isFocused, isExpanded: isExpanded, customStates: customStates)
    }

    public static func _forceBridgeFromObjectiveC(_ source: NSTableCellConfigurationStateObjc, result: inout NSTableCellConfigurationState?) {
        let customStates = (source.customStates as? [String: AnyHashable] ?? [:]).mapKeys({ NSConfigurationStateCustomKey(rawValue: $0) })
        result = NSTableCellConfigurationState(isSelected: source.isSelected, isEmphasized: source.isEmphasized, isEnabled: source.isEnabled, isFocused: source.isFocused, isHovered: source.isHovered, isEditing: source.isEditing, isExpanded: source.isExpanded, customStates: customStates)
    }
    
    public static func _conditionallyBridgeFromObjectiveC(_ source: NSTableCellConfigurationStateObjc, result: inout NSTableCellConfigurationState?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }
    
    public static func _unconditionallyBridgeFromObjectiveC(_ source: NSTableCellConfigurationStateObjc?) -> NSTableCellConfigurationState {
        if let source = source {
            let customStates = (source.customStates as? [String: AnyHashable] ?? [:]).mapKeys({ NSConfigurationStateCustomKey(rawValue: $0) })
            return NSTableCellConfigurationState(isSelected: source.isSelected, isEmphasized: source.isEmphasized, isEnabled: source.isEnabled, isFocused: source.isFocused, isHovered: source.isHovered, isEditing: source.isEditing, isExpanded: source.isExpanded, customStates: customStates)
        }
        return NSTableCellConfigurationState()
    }
}

/*
 /// The emphasized state.
 public struct EmphasizedState: OptionSet, Hashable {
 public let rawValue: UInt
 /// The window of the item is key.
 public static let isKeyWindow = EmphasizedState(rawValue: 1 << 0)
 /// The collection view of the item is first responder.
 public static let isFirstResponder = EmphasizedState(rawValue: 1 << 1)
 
 /// Creates a units structure with the specified raw value.
 public init(rawValue: UInt) {
 self.rawValue = rawValue
 }
 }
 
 /// The emphasized state.
 public var emphasizedState: EmphasizedState = []
 */
