//
//  NSTableCellVew+.swift
//  
//
//  Created by Florian Zand on 14.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableCellView {
    
    // MARK: Managing the content
    
    /**
     The current content configuration of the cell.
     
     Using a content configuration, you can set the cell’s content and styling for a variety of different item states.
     Setting a content configuration replaces the existing contentView of the cell with a new content view instance from the configuration, or directly applies the configuration to the existing content view if the configuration is compatible with the existing content view type.
     The default value is nil. After you set a content configuration to this property, setting this property back to nil replaces the current content view with a new, empty content view.
     */
    var contentConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "NSTableCellVew_contentConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "NSTableCellVew_contentConfiguration", object: self)
            if (newValue != nil) {
                self.observeTableCellView()
                self.tableView?.usesAutomaticRowHeights = true
            }
            self.configurateContentView()
        }
    }
    
    /**
     Retrieves a default content configuration for the cell’s style. The system determines default values for the configuration according to the table view and it’s style.
     
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
        return NSTableCellContentConfiguration.automatic()
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
    
    internal var tableView: NSTableView? {
        self.firstSuperview(for: NSTableView.self)
    }
    
    internal func configurateContentView() {
        if let contentConfiguration = contentConfiguration {
            if var contentView = self.contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                self.contentView?.removeFromSuperview()
                let contentView = contentConfiguration.makeContentView()
                self.contentView = contentView
                self.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(withConstraint: contentView)
                self.setNeedsDisplay()
                contentView.setNeedsDisplay()
                if let tableView = tableView {
                   let row = tableView.row(for: self)
                    Swift.print("tableView found", row)
                    if row != -1 {
                        tableView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
                    }
                }
            }
        } else {
            self.contentView?.removeFromSuperview()
        }
    }
    
    // MARK: Managing the state
    
    /**
     The current configuration state of the cell.
     
     To add your own custom state, see ``NSConfigurationStateCustomKey``.
     */
    var configurationState: NSTableCellConfigurationState {
        let state = NSTableCellConfigurationState(isSelected: self.isRowSelected, isEmphasized: self.isEmphasized, isEnabled: self.isEnabled, isFocused: self.isFocused, isHovered: self.isHovered, isEditing: self.isEditing, isExpanded: false)
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
        if let contentConfiguration = self.contentConfiguration as? NSTableCellContentConfiguration, contentConfiguration.type == .automatic, let tableView = self.tableView, tableView.style == .automatic, contentConfiguration.tableViewStyle != tableView.effectiveStyle  {
            self.contentConfiguration = contentConfiguration.tableViewStyle(tableView.effectiveStyle)
        }
        
        if isConfigurationUpdatesEnabled {
            let state = self.configurationState
            if automaticallyUpdatesContentConfiguration, let contentConfiguration = self.contentConfiguration {
                self.contentConfiguration = contentConfiguration.updated(for: state)
            }
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
     var content = NSTableCellContentConfiguration.sidebar().updated(for: state)
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
    
    internal var isHovered: Bool {
        self.rowView?.isHovered ?? false
    }
    
    internal var isEmphasized: Bool {
        self.rowView?.isEmphasized ?? false
    }
    
    internal var isTableViewFirstResponder: Bool {
        self.rowView?.isTableViewFirstResponder ?? false
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
    
    internal var isConfigurationUpdatesEnabled: Bool {
        get { getAssociatedValue(key: "NSTableCellView_isConfigurationUpdatesEnabled", object: self, initialValue: true) }
        set {  set(associatedValue: newValue, key: "NSTableCellView_isConfigurationUpdatesEnabled", object: self) }
    }
    
    internal var tableCellObserver: KeyValueObserver<NSTableCellView>? {
        get { getAssociatedValue(key: "NSTableCellView_tableCellObserver", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSTableCellView_tableCellObserver", object: self) }
    }
    
    internal func observeTableCellView() {
        guard tableCellObserver == nil else { return }
        tableCellObserver = KeyValueObserver(self)
        tableCellObserver?.add(\.superview) { old, new in
            if self.contentConfiguration != nil {
                self.tableView?.usesAutomaticRowHeights = true
            }
            
            if let contentConfiguration = self.contentConfiguration as? NSTableCellContentConfiguration, contentConfiguration.type == .automatic, let tableView = self.tableView, tableView.style == .automatic, contentConfiguration.tableViewStyle != tableView.effectiveStyle  {
                self.setNeedsUpdateConfiguration()
            }
            
            self.rowView?.observeTableRowView()
            self.tableView?.setupObservingView()
            self.setNeedsUpdateConfiguration()
        }
    }
    
    /*
     @objc internal func swizzled_PrepareForReuse() {
     self.isConfigurationUpdatesEnabled = false
     self.isEnabled = true
     self.isReordering = false
     self.isEditing = false
     // self.isHovered = false
     // self.isEmphasized = self.tableView?.isEmphasized ?? false
     self.isConfigurationUpdatesEnabled = true
     }
     
     internal var _isEnabled: Bool {
     if let isEnableds = self.contentView?.subviews(type: NSControl.self, depth: .max).compactMap({$0.isEnabled}).uniqued() {
     if isEnableds.count == 1, let isEnabled = isEnableds.first {
     return isEnabled
     }
     }
     return true
     }
     
     internal func observeIsEnabled() {
     guard let controls = self.contentView?.subviews(type: NSControl.self, depth: .max) else { return }
     for control in controls {
     if let observer: NSKeyValueObservation = getAssociatedValue(key: "isEnabledObserver", object: control) {
     
     } else {
     let observer = control.observeChanges(for: \.isEnabled, handler: { old, new in
     guard old != new else { return }
     
     })
     set(associatedValue: observer, key: "NSTableCellView_tableCellObserver", object: control)
     }
     }
     }
     */
}
