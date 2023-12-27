//
//  NSTableCellVew+.swift
//  
//
//  Created by Florian Zand on 14.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSTableCellView {
    
    // MARK: Managing the content
    
    /**
     The current content configuration of the cell.
     
     Using a content configuration, you can set the cell’s content and styling for a variety of different cell states. You can get the default configuration using ``defaultContentConfiguration()``, assign your content to the configuration, customize any other properties, and assign it to the view as the current `contentConfiguration`.
     
     Setting a content configuration replaces the view of the cell with a new content view instance from the configuration, or directly applies the configuration to the existing view if the configuration is compatible with the existing content view type.
     
     The default value is `nil`. After you set a content configuration to this property, setting this property back to `nil` replaces the current view with a new, empty view.
     */
    public var contentConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "NSTableCellVew_contentConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "NSTableCellVew_contentConfiguration", object: self)
            if (newValue != nil) {
                self.observeTableCellView()
            }
            self.configurateContentView()
        }
    }
    
    /**
     Retrieves a default content configuration for the cell’s style. The system determines default values for the configuration according to the table view it is presented.
     
     The default content configuration has preconfigured default styling depending on the table view ``AppKit/NSTableView/style`` it gets displayed in, but doesn’t contain any content. After you get the default configuration, you assign your content to it, customize any other properties, and assign it to the cell as the current content configuration.
     
     ```swift
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
    public func defaultContentConfiguration() -> NSListContentConfiguration {
        return NSListContentConfiguration.automatic()
    }
    
    /**
     A Boolean value that determines whether the cell automatically updates its content configuration when its state changes.
     
     When this value is `true`, the cell automatically calls `updated(for:)` on its ``contentConfiguration`` when the cell’s ``configurationState`` changes, and applies the updated configuration back to the cell. The default value is `true`.
     
     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue(key: "automaticallyUpdatesContentConfiguration", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "automaticallyUpdatesContentConfiguration", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    var contentView: (NSView & NSContentView)?   {
        get { getAssociatedValue(key: "_contentView", object: self) }
        set { set(associatedValue: newValue, key: "_contentView", object: self)
        }
    }
    
    
    func configurateContentView() {
        if let contentConfiguration = contentConfiguration {
            if var contentView = self.contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                self.contentView?.removeFromSuperview()
               // self.textField
                let contentView = contentConfiguration.makeContentView()
                self.contentView = contentView
                self.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(withConstraint: contentView)
                self.setNeedsDisplay()
                contentView.setNeedsDisplay()
            }
        } else {
            self.contentView?.removeFromSuperview()
        }
    }
    
    // MARK: Managing the state
    
    /**
     The current configuration state of the cell.
     
     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    public var configurationState: NSTableCellConfigurationState {
        let state = NSTableCellConfigurationState(isSelected: self.isRowSelected, isEditing: self.isEditing, isEmphasized: self.isEmphasized, isHovered: self.isHovered, isEnabled: self.isEnabled)
        return state
    }
    
    /**
     Informs the cell to update its configuration for its current state.
     
     You call this method when you need the cell to update its configuration according to the current configuration state. The system calls this method automatically when the cell’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     
     If you add custom states to the cell’s configuration state, make sure to call this method every time those custom states change.
     */
    @objc open func setNeedsUpdateConfiguration() {
        self.updateConfiguration(using: self.configurationState)
    }
    
    func setNeedsAutomaticUpdateConfiguration() {
        if let contentConfiguration = self.contentConfiguration as? NSListContentConfiguration, contentConfiguration.type == .automatic, let tableView = self.tableView, contentConfiguration.tableViewStyle != tableView.effectiveStyle  {
            let isGroupRow = tableView.delegate?.tableView?(tableView, isGroupRow: tableView.row(for: self)) ?? false
            self.contentConfiguration = contentConfiguration.tableViewStyle(tableView.effectiveStyle, isGroupRow: isGroupRow)
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
    public typealias ConfigurationUpdateHandler = (_ cell: NSTableCellView, _ state: NSTableCellConfigurationState) -> Void
    
    /**
     A block for handling updates to the cell’s configuration using the current state.
     
     Set a configuration update handler to update the cell’s configuration using the new state in response to a configuration state change:
     
     ```swift
     cell.configurationUpdateHandler = { cell, state in
     var content = NSListContentConfiguration.sidebar().updated(for: state)
     content.text = "Hello world!"
     if state.isDisabled {
     content.textProperties.color = .systemGray
     }
     cell.contentConfiguration = content
     }
     ```
     
     Setting the value of this property calls ``setNeedsUpdateConfiguration()``.
     */
    public var configurationUpdateHandler: ConfigurationUpdateHandler?  {
        get { getAssociatedValue(key: "configurationUpdateHandler", object: self) }
        set {
            set(associatedValue: newValue, key: "configurationUpdateHandler", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    
    /**
     A Boolean value that specifies whether the cell view is hovered.
     
     A hovered cell view has the mouse pointer on it.
     */
    public var isHovered: Bool {
        self.rowView?.isHovered ?? false
    }
    
    /// A Boolean value that specifies whether the cell view is emphasized (the window is key).
    public var isEmphasized: Bool {
        self.window?.isKeyWindow ?? false
    }
    
    /// A Boolean value that specifies whether the cell view is enabled (the table view's `isEnabled` is `true`).
    public var isEnabled: Bool {
        get { rowView?.isEnabled ?? true }
    }
    
    public func updateIsGroupRow(_ isGroupRow: Bool, style: NSTableView.Style) {
        if var configuration = contentConfiguration as? NSListContentConfiguration, configuration.type == .automatic  {
            configuration.isGroupRow = isGroupRow
            configuration = configuration.tableViewStyle(style, isGroupRow: isGroupRow)
            self.contentConfiguration = configuration
        }
    }
    
    var isEditing: Bool {
        get { getAssociatedValue(key: "_isEditing", object: self, initialValue: false) }
        set {
            guard newValue != self.isEditing else { return }
            set(associatedValue: newValue, key: "_isEditing", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    var isTableViewFirstResponder: Bool {
        self.rowView?.isTableViewFirstResponder ?? false
    }
    
    var isConfigurationUpdatesEnabled: Bool {
        get { getAssociatedValue(key: "isConfigurationUpdatesEnabled", object: self, initialValue: true) }
        set {  set(associatedValue: newValue, key: "isConfigurationUpdatesEnabled", object: self) }
    }
    
    var tableCellObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "tableCellObserver", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "tableCellObserver", object: self) }
    }
    
    func observeTableCellView() {
        guard tableCellObserver == nil else { return }
        tableCellObserver = self.observeChanges(for: \.superview, handler: {old, new in
            Swift.print("observeTableCellView", self.rowView != nil, self.tableView != nil)
            if self.contentConfiguration is NSListContentConfiguration {
                self.rowView?.needsAutomaticRowHeights = true
                self.tableView?.usesAutomaticRowHeights = true
            }

            if let contentConfiguration = self.contentConfiguration as? NSListContentConfiguration, contentConfiguration.type == .automatic, let tableView = self.tableView, tableView.style == .automatic, contentConfiguration.tableViewStyle != tableView.effectiveStyle  {
                self.setNeedsUpdateConfiguration()
            }
            
            self.rowView?.observeTableRowView()
            self.setNeedsUpdateConfiguration()
        })
    }
}


/*
var isFocused: Bool {
    get { getAssociatedValue(key: "NSTableCellVew_isFocused", object: self, initialValue: false) }
    set {
        guard newValue != self.isFocused else { return }
        set(associatedValue: newValue, key: "NSTableCellVew_isFocused", object: self)
        self.setNeedsAutomaticUpdateConfiguration()
    }
}

var isReordering: Bool {
    get { getAssociatedValue(key: "NSTableCellVew_isReordering", object: self, initialValue: false) }
    set {
        guard newValue != self.isReordering else { return }
        set(associatedValue: newValue, key: "NSTableCellVew_isReordering", object: self)
        self.setNeedsAutomaticUpdateConfiguration()
    }
}
*/


/*
 @objc func swizzled_PrepareForReuse() {
 self.isConfigurationUpdatesEnabled = false
 self.isEnabled = true
 self.isReordering = false
 self.isEditing = false
 // self.isHovered = false
 // self.isEmphasized = self.tableView?.isEmphasized ?? false
 self.isConfigurationUpdatesEnabled = true
 }
 
 var _isEnabled: Bool {
 if let isEnableds = self.contentView?.subviews(type: NSControl.self, depth: .max).compactMap({$0.isEnabled}).uniqued() {
 if isEnableds.count == 1, let isEnabled = isEnableds.first {
 return isEnabled
 }
 }
 return true
 }
 
 func observeIsEnabled() {
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
