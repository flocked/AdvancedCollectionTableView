//
//  NSTableCellVew+.swift
//  Coll
//
//  Created by Florian Zand on 14.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableCellView {
    /**
     The current content configuration of the item.

     Using a content configuration, you can set the item’s content and styling for a variety of different item states.
     Setting a content configuration replaces the existing contentView of the item with a new content view instance from the configuration, or directly applies the configuration to the existing content view if the configuration is compatible with the existing content view type.
     The default value is nil. After you set a content configuration to this property, setting this property back to nil replaces the current content view with a new, empty content view.
     */
    var contentConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "NSTableCellVew_contentConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "NSTableCellVew_contentConfiguration", object: self)
            if (newValue != nil) {
                self.swizzleTableCellIfNeeded()
            }
            self.configurateContentView()
        }
    }
    
    /**
     Retrieves a default content configuration for the cell’s style.
     
     The default content configuration has preconfigured default styling, but doesn’t contain any content. After you get the default configuration, you assign your content to it, customize any other properties, and assign it to the cell as the current content configuration.
     
     ```
     var content = cell.defaultContentConfiguration()

     // Configure content.
     content.text = "Favorites"
     content.image = NSImage(systemSymbolName: "star", accessibilityDescription: "star")

     // Customize appearance.
     content.imageProperties.tintColor = .purple

     cell.contentConfiguration = content
     ```
     
     - Returns:A default cell content configuration. The system determines default values for the configuration according to the table view and it’s style.
     */
    func defaultContentConfiguration() -> NSTableCellContentConfiguration {
        return NSTableCellContentConfiguration.default()
    }
    
    /**
     A Boolean value that determines whether the cell automatically updates its content configuration when its state changes.

     When this value is true, the cell automatically calls updated(for:) on its ``contentConfiguration`` when the cell’s ``configurationState`` changes, and applies the updated configuration back to the cell. The default value is true.
     If you override ``updateConfiguration(using:)`` to manually update and customize the content configuration, disable automatic updates by setting this property to false.
     */
    var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue(key: "NSTableCellVew_automaticallyUpdatesContentConfiguration", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "NSTableCellVew_automaticallyUpdatesContentConfiguration", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    internal var contentView: (NSView & NSContentView)?   {
        get { getAssociatedValue(key: "NSTableCellVew_contentView", object: self) }
        set { set(associatedValue: newValue, key: "NSTableCellVew_contentView", object: self)
        }
    }
    
    internal func configurateContentView() {
        if let contentConfiguration = contentConfiguration {
            if var contentView = self.contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                self.contentView?.removeFromSuperview()
                let contentView = contentConfiguration.makeContentView()
                self.contentView = contentView
                self.addSubview(withConstraint: contentView)
            }
        } else {
            self.contentView?.removeFromSuperview()
        }
    }

    /**
     The current configuration state of the cell.

     To add your own custom state, see ``NSConfigurationStateCustomKey``.
     */
    var configurationState: NSTableCellConfigurationState {
        let state = NSTableCellConfigurationState(isSelected: self.isRowSelected, isEnabled: self.isEnabled, isFocused: self.isFocused, isHovered: self.isHovered, isEditing: self.isEditing, isExpanded: false, isEmphasized: self.isEmphasized)
        return state
    }
    
    /**
     Informs the cell to update its configuration for its current state.

     You call this method when you need the cell to update its configuration according to the current configuration state. The system calls this method automatically when the cell’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     If you add custom states to the cell’s configuration state, make sure to call this method every time those custom states change.
     */
    func setNeedsUpdateConfiguration() {
        self.updateConfiguration(using: self.configurationState)
    }
    
    internal func setNeedsAutomaticUpdateConfiguration() {
        if isConfigurationUpdatesEnabled {
            let state = self.configurationState
            if automaticallyUpdatesContentConfiguration, let contentConfiguration = self.contentConfiguration {
                self.contentConfiguration = contentConfiguration.updated(for: state)
            }
            
            /*
             if automaticallyUpdatesContentConfiguration, let backgroundConfiguration = self.backgroundConfiguration {
             self.backgroundConfiguration = backgroundConfiguration.updated(for: state)
             }
             */
            configurationUpdateHandler?(self, state)
        }
    }
    
    /**
     Updates the cell’s configuration using the current state.

     Avoid calling this method directly. Instead, use setNeedsUpdateConfiguration() to request an update.
     Override this method in a subclass to update the cell’s configuration using the provided state.
     */
    func updateConfiguration(using state: NSTableCellConfigurationState) {
        if let contentConfiguration = self.contentConfiguration {
            self.contentConfiguration = contentConfiguration.updated(for: state)
        }
        configurationUpdateHandler?(self, state)
    }
    
    /**
     The type of block for handling updates to the cell’s configuration using the current state.
     
     - Parameters:
        - cell: The table view cell to configure.
        - state: The new state to use for updating the cell’s configuration.
     */
    typealias ConfigurationUpdateHandler = (_ cell: NSTableCellView, _ state: NSTableCellConfigurationState) -> Void

    /**
     A block for handling updates to the cell’s configuration using the current state.

     A configuration update handler provides an alternative approach to overriding ``updateConfiguration(using:)`` in a subclass. Set a configuration update handler to update the cell’s configuration using the new state in response to a configuration state change:
     
     ```
     cell.configurationUpdateHandler = { cell, state in
         var content = NSTableCellContentConfiguration.default().updated(for: state)
         content.text = "Hello world!"
         if state.isDisabled {
             content.textProperties.color = .systemGray
         }
         cell.contentConfiguration = content
     }
     ```
     
     Setting the value of this property calls ``setNeedsUpdateConfiguration()``. The system calls this handler after calling u``pdateConfiguration(using:)``.
     */
    var configurationUpdateHandler: ConfigurationUpdateHandler?  {
        get { getAssociatedValue(key: "NSTableCellVew_configurationUpdateHandler", object: self) }
        set {
            set(associatedValue: newValue, key: "NSTableCellVew_configurationUpdateHandler", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    /**
     A Boolean value that specifies whether the current cell view is hovered.

     A hovered row view has the mouse pointer on it.
     */
    internal var isHovered: Bool {
        get { getAssociatedValue(key: "NSTableCellVew_isHovered", object: self, initialValue: false) }
        set {
            guard newValue != self.isHovered else { return }
            set(associatedValue: newValue, key: "NSTableCellVew_isHovered", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
   internal var isEnabled: Bool {
        get { getAssociatedValue(key: "NSTableCellVew_isEnabled", object: self, initialValue: false) }
        set {
            guard newValue != self.isEnabled else { return }
            set(associatedValue: newValue, key: "NSTableCellVew_isEnabled", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isFocused: Bool {
        get { getAssociatedValue(key: "NSTableCellVew_isFocused", object: self, initialValue: false) }
        set {
            guard newValue != self.isFocused else { return }
            set(associatedValue: newValue, key: "NSTableCellVew_isFocused", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isReordering: Bool {
        get { getAssociatedValue(key: "NSTableCellVew_isReordering", object: self, initialValue: false) }
        set {
            guard newValue != self.isReordering else { return }
            set(associatedValue: newValue, key: "NSTableCellVew_isReordering", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
   internal var isEditing: Bool {
        get { getAssociatedValue(key: "NSTableCellVew_isEditing", object: self, initialValue: false) }
        set {
            guard newValue != self.isEditing else { return }
            set(associatedValue: newValue, key: "NSTableCellVew_isEditing", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSTableCellVew_isEmphasized", object: self, initialValue: false) }
        set {
            guard newValue != self.isEmphasized else { return }
            set(associatedValue: newValue, key: "NSTableCellVew_isEmphasized", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
            
    internal var isConfigurationUpdatesEnabled: Bool {
        get { getAssociatedValue(key: "NSTableCellView_isConfigurationUpdatesEnabled", object: self, initialValue: true) }
        set {  set(associatedValue: newValue, key: "NSTableCellView_isConfigurationUpdatesEnabled", object: self) }
    }
    
    override func prepareForReuse() {
        self.isConfigurationUpdatesEnabled = false
        self.isHovered = false
        self.isEnabled = true
        self.isReordering = false
        self.isEditing = false
        self.isEmphasized = self.tableView?.isEmphasized ?? false
        self.isConfigurationUpdatesEnabled = true
    }
    
    internal var didSwizzleTableCellView: Bool {
        get { getAssociatedValue(key: "NSTableCellVew_didSwizzle", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "NSTableCellVew_didSwizzle", object: self) }
    }
    
    @objc internal func swizzleTableCellIfNeeded(_ shouldSwizzle: Bool = true) {
        Swift.print("swizzleTableCellIfNeeded start")
        if (didSwizzleTableCellView == false) {
            didSwizzleTableCellView = true
            do {
                let hooks = [
                    try  self.hook(#selector(NSTableCellView.viewDidMoveToSuperview),
                                   methodSignature: (@convention(c) (AnyObject, Selector) -> ()).self,
                                   hookSignature: (@convention(block) (AnyObject) -> ()).self) {
                                       store in { (object) in
                                           Swift.print("cell viewDidMoveToSuperview")
                                           self.rowView?.swizzleTableRowViewIfNeeded()
                                           self.tableView?.setupObserverView()
                                           // Add constraints if tableview usesAutomaticRowHeights
                                          /* if self.tableView?.usesAutomaticRowHeights == true, let contentView = self.contentView {
                                               contentView.con
                                           } */
                                           store.original(object, store.selector)
                                       }
                                   },
                ]
               try hooks.forEach({ _ = try (shouldSwizzle) ? $0.apply() : $0.revert() })
            } catch {
                Swift.print(error)
            }
        }
    }
}
