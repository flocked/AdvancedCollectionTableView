//
//  NSTableRowView+.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZExtensions
// import AdvancedCollectionTableViewObjC

public extension NSTableRowView {
    /**
     The array of cell views embedded in the current row.
     
     This array contains zero or more NSTableCellView objects that represent the cell views embedded in the current row view’s content.
     */
    var cellViews: [NSTableCellView] {
        (0..<self.numberOfColumns).compactMap({self.view(atColumn: $0) as? NSTableCellView})
    //    self.subviews.compactMap({$0 as? NSTableCellView})
    }
    
    /**
     The table view that displays the current row view.

     The table view that displays the current row view. The value of this property is nil when the row view is not displayed in a table view.
     */
    var tableView: NSTableView? {
        self.firstSuperview(for: NSTableView.self)
    }
    
    var contentView: NSView?   {
        get { getAssociatedValue(key: "_contentView", object: self) }
        set {
            if let newValue = newValue {
                if (newValue != self.contentView) {
                    self.contentView?.removeFromSuperview()
                    self.addSubview(withConstraint: newValue)
                }
            } else {
                self.contentView?.removeFromSuperview()
            }
            set(associatedValue: newValue, key: "_contentView", object: self)
        }
    }
    
    /**
     Retrieves a default content configuration for the row’s style.
     
     The default content configuration has preconfigured default styling, but doesn’t contain any content. After you get the default configuration, you assign your content to it, customize any other properties, and assign it to the cell as the current content configuration.
     
     ```
     var content = rowView.defaultContentConfiguration()

     // Configure content.
     content.backgroundColor = .controlAccentColor
     content.cornerRadius = 4.0

     rowView.contentConfiguration = content
     ```
     
     - Returns:A default row content configuration. The system determines default values for the configuration according to the table view and it’s style.
     */
    func defaultContentConfiguration() -> NSTableRowContentConfiguration {
        return NSTableRowContentConfiguration.default()
    }
    
    /**
     The current content configuration of the row.

     Using a content configuration, you can set the row’s content and styling for a variety of different row states.
     Setting a content configuration replaces the existing contentView of the row with a new content view instance from the configuration, or directly applies the configuration to the existing content view if the configuration is compatible with the existing content view type.
     The default value is nil. After you set a content configuration to this property, setting this property back to nil replaces the current content view with a new, empty content view.
     */
    var contentConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "_contentConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "_contentConfiguration", object: self)
            if (contentConfiguration != nil) {
                Self.swizzle()
            }
            self.configurateContentView()
        }
    }
    
    /**
     A Boolean value that determines whether the row automatically updates its content configuration when its state changes.

     When this value is true, the row automatically calls updated(for:) on its ``contentConfiguration`` when the row’s ``configurationState`` changes, and applies the updated configuration back to the row. The default value is true.
     If you override ``updateConfiguration(using:)`` to manually update and customize the content configuration, disable automatic updates by setting this property to false.
     */
    var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue(key: "_automaticallyUpdatesContentConfiguration", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "_automaticallyUpdatesContentConfiguration", object: self)
        }
    }
    
    internal func configurateContentView() {
        if let contentConfiguration = contentConfiguration {
            if  var contentView = self.contentView as? NSContentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                let contentView = contentConfiguration.makeContentView()
                self.contentView = contentView
            }
        } else {
            self.contentView?.removeFromSuperview()
        }
    }
    
    /**
     The type of block for handling updates to the row’s configuration using the current state.
     
     - Parameters:
        - row: The table view row to configure.
        - state: The new state to use for updating the row’s configuration.
     */
    typealias ConfigurationUpdateHandler = (_ rowView: NSTableRowView, _ state: NSTableRowConfigurationState) -> Void
    
    /**
     A block for handling updates to the row’s configuration using the current state.

     A configuration update handler provides an alternative approach to overriding ``updateConfiguration(using:)`` in a subclass. Set a configuration update handler to update the row’s configuration using the new state in response to a configuration state change:
     
     ```
     rowView.configurationUpdateHandler = { rowView, state in
         var content = NSTableRowContentConfiguration.default().updated(for: state)
         content.backgroundColor = nil
         if state.isSelected {
             content.backgroundColor = .controlAccentColor
         }
         rowView.contentConfiguration = content
     }
     ```
     
     Setting the value of this property calls ``setNeedsUpdateConfiguration()``. The system calls this handler after calling u``pdateConfiguration(using:)``.
     */
    var configurationUpdateHandler: ConfigurationUpdateHandler?  {
        get { getAssociatedValue(key: "_configurationUpdateHandler", object: self) }
        set {
            set(associatedValue: newValue, key: "_configurationUpdateHandler", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    /**
     The current configuration state of the row.

     To add your own custom state, see ``NSConfigurationStateCustomKey``.
     */
    var configurationState: NSTableRowConfigurationState {
        let state = NSTableRowConfigurationState(isSelected: self.isSelected, isSelectable: true, isDisabled: self.isDisabled, isFocused: self.isFocused, isHovered: self.isHovered, isEditing: self.isEditing, isExpanded: false, isEmphasized: self.isEmphasized, isNextRowSelected: self.isNextRowSelected, isPreviousRowSelected: self.isPreviousRowSelected)
        return state
    }
    
    /**
     Informs the row to update its configuration for its current state.

     You call this method when you need the row to update its configuration according to the current configuration state. The system calls this method automatically when the row’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     If you add custom states to the row’s configuration state, make sure to call this method every time those custom states change.
     */
    func setNeedsUpdateConfiguration(updateCellViews: Bool = true) {
        if (updateCellViews == true) {
            setNeedsCellViewsUpdateConfiguration()
        }
        self.updateConfiguration(using: self.configurationState)
    }
    
    internal func setNeedsCellViewsUpdateConfiguration() {
        self.cellViews.forEach({$0.setNeedsUpdateConfiguration()})
    }
    
    /**
     Updates the row’s configuration using the current state.

     Avoid calling this method directly. Instead, use ``setNeedsUpdateConfiguration()`` to request an update.
     Override this method in a subclass to update the row’s configuration using the provided state.
     */
    func updateConfiguration(using state: NSTableRowConfigurationState) {
        if let contentConfiguration = self.contentConfiguration {
            self.contentConfiguration = contentConfiguration.updated(for: state)
        }
        cellViews.forEach({$0.setNeedsUpdateConfiguration()})
        configurationUpdateHandler?(self, state)
    }
    
    internal func updateCellConfigurations() {
        
    }
    
    /**
     A Boolean value that specifies whether the current row view is hovered.

     A hovered row view has the mouse pointer on it.
     */
    internal var isHovered: Bool {
        get { getAssociatedValue(key: "_isHovered", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isHovered", object: self)
            self.setNeedsUpdateConfiguration()
            self.cellViews.forEach({$0.isHovered = newValue})
        }
    }
    
   internal var isDisabled: Bool {
        get { getAssociatedValue(key: "_isDisabled", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isDisabled", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    internal var isFocused: Bool {
        get { getAssociatedValue(key: "_isFocused", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isFocused", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    internal var isReordering: Bool {
        get { getAssociatedValue(key: "_isReordering", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isReordering", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
   internal var isEditing: Bool {
        get { getAssociatedValue(key: "_isEditing", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isEditing", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "_isEmphasized", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isEmphasized", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
     
    static internal var didSwizzle: Bool {
        get { getAssociatedValue(key: "_didSwizzle", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_didSwizzle", object: self)
        }
    }
        
    @objc dynamic func swizzled_setIsSelected(_ isSelected: Bool) {
        let didChange = (self.isSelected != isSelected)
        self.swizzled_setIsSelected(isSelected)
        if (didChange) {
            self.setNeedsUpdateConfiguration()
        }
    }
    
    @objc static internal func swizzle() {
        if (didSwizzle == false) {
            didSwizzle = true
            do {
                try Swizzle(NSTableRowView.self) {
                    #selector(setter: isSelected) <-> #selector(swizzled_setIsSelected)
                }
            } catch {
                Swift.print(error)
            }
        }
    }
}
