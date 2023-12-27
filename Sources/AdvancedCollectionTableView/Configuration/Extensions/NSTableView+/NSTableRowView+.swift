//
//  NSTableRowView+.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSTableRowView {
    
    // MARK: Configuring the background
    
    /**
     The current background configuration of the row.
     
     Using a background configuration, you can obtain system default background styling for a variety of different row states. Create a background configuration with one of the default system styles, customize the configuration to match your row’s style as necessary, and assign the configuration to this property.
     
     ```swift
     var backgroundConfiguration = NSBackgroundConfiguration()
     
     // Set a nil background color to use the view's tint color.
     backgroundConfiguration.backgroundColor = nil
     
     rowView.backgroundConfiguration = backgroundConfiguration
     ```
     */
    public var backgroundConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "backgroundConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "backgroundConfiguration", object: self)
            if (newValue != nil) {
                self.observeTableRowView()
            }
            self.configurateBackgroundView()
        }
    }
    
    /**
     A Boolean value that determines whether the row automatically updates its background configuration when its state changes.
     
     When this value is true, the row automatically calls  `updated(for:)` on its ``backgroundConfiguration`` when the row’s ``configurationState`` changes, and applies the updated configuration back to the row. The default value is true.
     
     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the background configuration, disable automatic updates by setting this property to false.
     */
    @objc open var automaticallyUpdatesBackgroundConfiguration: Bool {
        get { getAssociatedValue(key: "automaticallyUpdatesBackgroundConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "automaticallyUpdatesBackgroundConfiguration", object: self)
        }
    }
    
    var configurationBackgroundView: (NSView & NSContentView)?   {
        get { getAssociatedValue(key: "configurationBackgroundView", object: self) }
        set {
            configurationBackgroundView?.removeFromSuperview()
            set(associatedValue: newValue, key: "configurationBackgroundView", object: self)
        }
    }
    
    func configurateBackgroundView() {
        if let backgroundConfiguration = backgroundConfiguration {
            self.backgroundColor = nil
            if var backgroundView = configurationBackgroundView,  backgroundView.supports(backgroundConfiguration) {
                backgroundView.configuration = backgroundConfiguration
            } else {
                configurationBackgroundView?.removeFromSuperview()
                var backgroundView = backgroundConfiguration.makeContentView()
                backgroundView.configuration = backgroundConfiguration
                configurationBackgroundView = backgroundView
                self.addSubview(withConstraint: backgroundView)
            }
        } else {
            configurationBackgroundView = nil
        }
    }
    
    var isMultipleSelected: Bool {
        self.isSelected && self.isPreviousRowSelected && self.isNextRowSelected
    }
    
    /**
     The type of block for handling updates to the row’s configuration using the current state.
     
     - Parameters:
        - row: The table view row to configure.
        - state: The new state to use for updating the row’s configuration.
     */
    public typealias ConfigurationUpdateHandler = (_ rowView: NSTableRowView, _ state: NSTableRowConfigurationState) -> Void
    
    /**
     A block for handling updates to the row’s configuration using the current state.
     
     Set a configuration update handler to update the row’s configuration using the new state in response to a configuration state change:
     
     ```swift
     rowView.configurationUpdateHandler = { rowView, state in
     var content = NSTableRowContentConfiguration.default().updated(for: state)
     content.backgroundColor = nil
     if state.isSelected {
     content.backgroundColor = .controlAccentColor
     }
     rowView.backgroundConfiguration = content
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
    
    // MARK: Managing the state
    
    /**
     The current configuration state of the row.
     
     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    public var configurationState: NSTableRowConfigurationState {
        let state = NSTableRowConfigurationState(isSelected: self.isSelected, isEnabled: self.isEnabled, isHovered: self.isHovered, isEditing: self.isEditing, isEmphasized: self.isEmphasized, isNextRowSelected: self.isNextRowSelected, isPreviousRowSelected: self.isPreviousRowSelected)
        return state
    }
    
    /**
     Informs the row to update its configuration for its current state.
     
     You call this method when you need the row to update its configuration according to the current configuration state. The system calls this method automatically when the row’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     
     If you add custom states to the row’s configuration state, make sure to call this method every time those custom states change.
     */
    @objc open func setNeedsUpdateConfiguration() {
        self.updateConfiguration(using: self.configurationState)
    }
    
    
    // Updates content configuration and background configuration if automatic updating is enabled.
    func setNeedsAutomaticUpdateConfiguration() {
        if isConfigurationUpdatesEnabled {
            if automaticallyUpdatesBackgroundConfiguration {
                setNeedsUpdateConfiguration()
            } else {
                configurationUpdateHandler?(self,  configurationState)
            }
        }
    }
    
    /**
     Updates the row’s configuration using the current state.
     
     Avoid calling this method directly. Instead, use ``setNeedsUpdateConfiguration()`` to request an update.
     Override this method in a subclass to update the row’s configuration using the provided state.
     */
    func updateConfiguration(using state: NSTableRowConfigurationState) {
        if let backgroundConfiguration = self.backgroundConfiguration {
            self.backgroundConfiguration = backgroundConfiguration.updated(for: state)
        }
        cellViews.forEach({$0.setNeedsUpdateConfiguration()})
        configurationUpdateHandler?(self, state)
    }
    
    /**
     A Boolean value that specifies whether the row view is hovered.
     
     A hovered row view has the mouse pointer on it.
     */
    public var isHovered: Bool {
        get { self.tableView?.hoveredRowView == self }
    }
    
    /// A Boolean value that specifies whether the row view is enabled (the table view's `isEnabled` is `true`).
    public var isEnabled: Bool {
        get { self.tableView?.isEnabled ?? true }
    }
    
    /// A Boolean value that specifies whether the current cell is in a editing state.
    var isEditing: Bool {
        get { getAssociatedValue(key: "_isEditing", object: self, initialValue: false) }
        set {
            guard newValue != self.isEditing else { return }
            set(associatedValue: newValue, key: "_isEditing", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    /// A Boolean value that specifies whether the row view is emphasized (the window is key).
    public var isEmphasized: Bool {
        get { self.window?.isKeyWindow ?? false }
    }
    
    var isTableViewFirstResponder: Bool {
        get { self.tableView?.isFirstResponder ?? false }
    }
    
    // A Boolean value that indicates whether automatic updating of the configuration is enabled.
    var isConfigurationUpdatesEnabled: Bool {
        get { getAssociatedValue(key: "automaticUpdateConfigurationEnabled", object: self, initialValue: true) }
        set {  set(associatedValue: newValue, key: "automaticUpdateConfigurationEnabled", object: self) }
    }
    
    @objc func swizzled_PrepareForReuse() {
        self.isConfigurationUpdatesEnabled = false
        self.isEditing = false
        self.isConfigurationUpdatesEnabled = true
    }
    
    func setCellViewsNeedUpdateConfiguration() {
        self.cellViews.forEach({ $0.setNeedsUpdateConfiguration() })
    }
    
    func setCellViewsNeedAutomaticUpdateConfiguration() {
        self.cellViews.forEach({ $0.setNeedsAutomaticUpdateConfiguration() })
    }
    
    var rowObserver: KeyValueObserver<NSTableRowView>? {
        get { getAssociatedValue(key: "rowObserver", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "rowObserver", object: self) }
    }
    
    var needsAutomaticRowHeights: Bool {
        get { getAssociatedValue(key: "needsAutomaticRowHeights", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "needsAutomaticRowHeights", object: self) }
    }
    
    func observeTableRowView() {
        guard rowObserver == nil else { return }
        rowObserver = KeyValueObserver(self)
        rowObserver?.add(\.isSelected) { old, new in
            guard old != new else { return }
            self.configurateBackgroundView()
            self.setNeedsAutomaticUpdateConfiguration()
            self.setCellViewsNeedAutomaticUpdateConfiguration()
        }
        rowObserver?.add(\.superview) { old, new in
            Swift.print("observeTableRowView", self.tableView != nil)
            if self.needsAutomaticRowHeights {
                self.tableView?.usesAutomaticRowHeights = true
            }
            self.tableView?.setupObservation()
        }
        self.setNeedsUpdateConfiguration()
        self.setCellViewsNeedUpdateConfiguration()
    }
}


/*
var isFocused: Bool {
    get { getAssociatedValue(key: "NSTableRowView_isFocused", object: self, initialValue: false) }
    set {
        guard newValue != self.isFocused else { return }
        set(associatedValue: newValue, key: "NSTableRowView_isFocused", object: self)
        self.setNeedsAutomaticUpdateConfiguration()
    }
}

var isReordering: Bool {
    get { getAssociatedValue(key: "NSTableRowView_isReordering", object: self, initialValue: false) }
    set {
        guard newValue != self.isReordering else { return }
        set(associatedValue: newValue, key: "NSTableRowView_isReordering", object: self)
        self.setNeedsAutomaticUpdateConfiguration()
    }
}
*/


/*
 // Updates cell views content configuration.
 func setNeedsCellViewsUpdateConfiguration() {
 self.cellViews.forEach({$0.setNeedsUpdateConfiguration()})
 }
 */
