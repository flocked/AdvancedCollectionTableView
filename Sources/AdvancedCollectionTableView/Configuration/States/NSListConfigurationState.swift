//
//  NSListConfigurationState.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

/**
 A structure that encapsulates a state for an individual item that appears in a list.

 A list configuration state encompasses the common states that affect the appearance of the list item — states like selected, emphasized, or enabled. You can use it to update the appearance.

 The configuration state is used with `NSTableCellView`, `NSTableRowView` and `NSTableSectionHeaderView`.

 Typically, you don’t create a configuration state yourself. To obtain a configuration state either use the list item's `configurationUpdateHandler` or override its `updateConfiguration(using:)` method in a subclass and use the state parameter. Outside of this method, you can get the configuration state by using its `configurationState` property.

 You can create your own custom states to add to a list configuration state by defining a custom state key using `NSConfigurationStateCustomKey`.
 */
public struct NSListConfigurationState: NSConfigurationState, Hashable {
    /// A Boolean value that indicates whether the list item is selected.
    public var isSelected: Bool = false

    /**
     A Boolean value that indicates whether the list item is enabled.

     The value of this property is `true`, if it's table view `isEnabled` is `true`.
     */
    public var isEnabled: Bool = true

    /**
     A Boolean value that indicates whether the list item is in a hovered state.

     The value of this property is `true`, if the mouse is hovering the item.
     */
    public var isHovered: Bool = false

    /**
     A Boolean value that indicates whether the list item is in an editing state.

     The value of this property is `true`, if the text of a list or item content configuration is being edited.
     */
    public var isEditing: Bool = false

    /**
     A Boolean value that indicates whether the list item is in an emphasized state.

     The value of this property is `true`, if it's window is key.
     */
    public var isEmphasized: Bool = false

    /// A Boolean value that indicates whether the next list item is in a selected state.
    public var isNextSelected: Bool = false

    /// A Boolean value that indicates whether the previous list item is in a selected state.
    public var isPreviousSelected: Bool = false

    /// A Boolean value that indicates whether the list item is in a focused state.
    var isFocused: Bool = false

    /// A Boolean value that indicates whether the list item is in an expanded state.
    var isExpanded: Bool = false
    
    /// A Boolean value that indicates whether the list item is reordering.
    var isReordering: Bool = false

    var customStates = [NSConfigurationStateCustomKey: AnyHashable]()

    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { customStates[key] }
        set { customStates[key] = newValue }
    }

    public init(isSelected: Bool = false,
                isEnabled: Bool = true,
                isHovered: Bool = false,
                isEditing: Bool = false,
                isEmphasized: Bool = false,
                isNextSelected: Bool = false,
                isPreviousSelected: Bool = false)
    {
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
         isReordering: Bool,
         customStates: [NSConfigurationStateCustomKey: AnyHashable])
    {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
        self.isNextSelected = isNextSelected
        self.isPreviousSelected = isPreviousSelected
        self.isReordering = isReordering
        self.customStates = customStates
    }
}

extension NSListConfigurationState: ReferenceConvertible {
    /// The Objective-C type for this state.
    public typealias ReferenceType = __NSListConfigurationStateObjcNew

    public var description: String {
        """
        NSListConfigurationState(
            isSelected: \(isSelected)
            isEnabled: \(isEnabled)
            isHovered: \(isHovered)
            isEditing: \(isEditing)
            isEmphasized: \(isEmphasized)
            isNextSelected: \(isNextSelected)
            isPreviousSelected: \(isPreviousSelected)
            customStates: \(customStates)
        )
        """
    }

    public var debugDescription: String {
        description
    }

    public func _bridgeToObjectiveC() -> __NSListConfigurationStateObjcNew {
        return __NSListConfigurationStateObjcNew(isSelected: isSelected, isEnabled: isEnabled, isHovered: isHovered, isEditing: isEditing, isEmphasized: isEmphasized, isNextSelected: isNextSelected, isPreviousSelected: isPreviousSelected, isFocused: isFocused, isExpanded: isExpanded, isReordering: isReordering, customStates: customStates)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __NSListConfigurationStateObjcNew, result: inout NSListConfigurationState?) {
        result = NSListConfigurationState(isSelected: source.isSelected, isEnabled: source.isEnabled, isHovered: source.isHovered, isEditing: source.isEditing, isEmphasized: source.isEmphasized, isNextSelected: source.isNextSelected, isPreviousSelected: source.isPreviousSelected, isReordering: source.isReordering, customStates: source.customStates)
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __NSListConfigurationStateObjcNew, result: inout NSListConfigurationState?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __NSListConfigurationStateObjcNew?) -> NSListConfigurationState {
        if let source = source {
            var result: NSListConfigurationState?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return NSListConfigurationState()
    }
}

/// The `Objective-C` class for ``NSListConfigurationState``.
public class __NSListConfigurationStateObjcNew: NSObject, NSCopying {
    var isSelected: Bool
    var isEnabled: Bool
    var isHovered: Bool
    var isEditing: Bool
    var isEmphasized: Bool
    var isNextSelected: Bool
    var isPreviousSelected: Bool
    var isFocused: Bool
    var isExpanded: Bool
    var isReordering: Bool
    var customStates:[NSConfigurationStateCustomKey: AnyHashable]

    init(isSelected: Bool, isEnabled: Bool, isHovered: Bool, isEditing: Bool, isEmphasized: Bool, isNextSelected: Bool, isPreviousSelected: Bool, isFocused: Bool, isExpanded: Bool, isReordering: Bool, customStates: [NSConfigurationStateCustomKey: AnyHashable]) {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isEmphasized = isEmphasized
        self.isNextSelected = isNextSelected
        self.isPreviousSelected = isPreviousSelected
        self.isFocused = isFocused
        self.isExpanded = isExpanded
        self.isReordering = isReordering
        self.customStates = customStates
        super.init()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __NSListConfigurationStateObjcNew(isSelected: isSelected, isEnabled: isEnabled, isHovered: isHovered, isEditing: isEditing, isEmphasized: isEmphasized, isNextSelected: isNextSelected, isPreviousSelected: isPreviousSelected, isFocused: isFocused, isExpanded: isExpanded, isReordering: isReordering, customStates: customStates)
    }
}
