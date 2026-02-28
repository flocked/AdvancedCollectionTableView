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
    public var isSelected: Bool = false {
        didSet { self["isSelected"] = isSelected }
    }

    /**
     A Boolean value that indicates whether the list item is enabled.

     The value of this property is `true`, if it's table view `isEnabled` is `true`.
     */
    public var isEnabled: Bool = true

    /// A Boolean value that indicates whether the mouse is hovering the item.
    public var isHovered: Bool = false

    /**
     A Boolean value that indicates whether the list item is in an editing state.

     The value of this property is `true`, if the text of a list or item content configuration is being edited.
     */
    public var isEditing: Bool = false
    
    /**
     A Boolean value that indicates whether the list item is currently in an emphasized state.
     
     The value of this property is `true`, if the list item is active in the current environment, such as when it's window is key and  it's table view is focused.
     */
    public var isEmphasized: Bool = false

    /// A Boolean value that indicates whether the next list item is in a selected state.
    public var isNextSelected: Bool = false

    /// A Boolean value that indicates whether the previous list item is in a selected state.
    public var isPreviousSelected: Bool = false
    
    /// A Boolean value that indicates whether the list item is dragging.
    public var isDragging: Bool = false
    
    /// A Boolean value that indicates whether the list item is reordering.
    public var isReordering: Bool = false
    
    /// A Boolean value that indicates whether the list item is the target of a drop operation.
    public var isDropTarget: Bool = false
    
    /// The appearance of the list item.
    public var appearance: NSAppearance?

    /// A Boolean value that indicates whether the list item is in a focused state.
    var isFocused: Bool = false

    /// A Boolean value that indicates whether the list item is in an expanded state.
    var isExpanded: Bool = false
    
    var isActive: Bool { isEmphasized }

    var customStates = [NSConfigurationStateCustomKey: AnyHashable]()

    /// Accesses custom states by key.
    public subscript(key: NSConfigurationStateCustomKey) -> AnyHashable? {
        get { customStates[key] }
        set { customStates[key] = newValue }
    }

    /*
    public init(isSelected: Bool = false,
                isEnabled: Bool = true,
                isHovered: Bool = false,
                isEditing: Bool = false,
                isActive: Bool = false,
                isReordering: Bool = false,
                isDropTarget: Bool = false,
                isNextSelected: Bool = false,
                isPreviousSelected: Bool = false)
    {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isActive = isActive
        self.isReordering = isReordering
        self.isDropTarget = isDropTarget
        self.isNextSelected = isNextSelected
        self.isPreviousSelected = isPreviousSelected
        self["activeState"] = activeState.rawValue
        self["isSelected"] = isSelected
    }
    */
    
    /**
     Creates a list configuration state.
     
     Typically, you don’t create a configuration state yourself. To obtain a list configuration state, override the ``AppKit/NSTableCellView/updateConfiguration(using:)`` method in your table cell or row view subclass and use the state parameter. Outside of this method, you can get a table cell or row view’s configuration state by using its ``AppKit/NSTableCellView/configurationState`` property.
     */
    public init() {
        
    }
    
    init(isSelected: Bool = false,
                isEnabled: Bool = true,
                isHovered: Bool = false,
                isEditing: Bool = false,
                isEmphasized: Bool = false,
                isDragging: Bool = false,
                isReordering: Bool = false,
                isDropTarget: Bool = false,
                isNextSelected: Bool = false,
                isPreviousSelected: Bool = false,
                appearance: NSAppearance? = nil)
    {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isDragging = isDragging
        self.isReordering = isReordering
        self.isDropTarget = isDropTarget
        self.isNextSelected = isNextSelected
        self.isPreviousSelected = isPreviousSelected
        self["isSelected"] = isSelected
    }

    init(isSelected: Bool,
         isEnabled: Bool,
         isHovered: Bool,
         isEditing: Bool,
         isNextSelected: Bool,
         isPreviousSelected: Bool,
         isDragging: Bool,
         isReordering: Bool,
         isDropTarget: Bool,
         appearance: NSAppearance?,
         customStates: [NSConfigurationStateCustomKey: AnyHashable])
    {
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isHovered = isHovered
        self.isEditing = isEditing
        self.isNextSelected = isNextSelected
        self.isPreviousSelected = isPreviousSelected
        self.isDragging = isDragging
        self.isReordering = isReordering
        self.isDropTarget = isDropTarget
        self.appearance = appearance
        self.customStates = customStates
        self["isSelected"] = isSelected
    }
}

extension NSListConfigurationState: ReferenceConvertible {
    /// The Objective-C type for this state.
    public typealias ReferenceType = __NSListConfigurationStateObjc

    public var description: String {
        """
        NSListConfigurationState(
            isSelected: \(isSelected)
            isEnabled: \(isEnabled)
            isEditing: \(isEditing)
            isHovered: \(isHovered)
            isEmphasized: \(isEmphasized)
            isDragging: \(isDragging)
            isDropTarget: \(isDropTarget)
            isReordering: \(isReordering)
            isNextSelected: \(isNextSelected)
            isPreviousSelected: \(isPreviousSelected)
            appearance: \(appearance?.name.rawValue ?? "-")
            customStates: \(customStates)
        )
        """
    }

    public var debugDescription: String {
        description
    }

    public func _bridgeToObjectiveC() -> __NSListConfigurationStateObjc {
        return __NSListConfigurationStateObjc(state: self)
    }

    public static func _forceBridgeFromObjectiveC(_ source: __NSListConfigurationStateObjc, result: inout NSListConfigurationState?) {
        result = source.state
    }

    public static func _conditionallyBridgeFromObjectiveC(_ source: __NSListConfigurationStateObjc, result: inout NSListConfigurationState?) -> Bool {
        _forceBridgeFromObjectiveC(source, result: &result)
        return true
    }

    public static func _unconditionallyBridgeFromObjectiveC(_ source: __NSListConfigurationStateObjc?) -> NSListConfigurationState {
        if let source = source {
            var result: NSListConfigurationState?
            _forceBridgeFromObjectiveC(source, result: &result)
            return result!
        }
        return NSListConfigurationState()
    }
}

/// The `Objective-C` class for ``NSListConfigurationState``.
public class __NSListConfigurationStateObjc: NSObject, NSCopying {
    let state: NSListConfigurationState

    init(state: NSListConfigurationState) {
        self.state = state
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        __NSListConfigurationStateObjc(state: state)
    }
}
