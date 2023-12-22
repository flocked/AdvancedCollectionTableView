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
     
     ```
     var backgroundConfiguration = NSBackgroundConfiguration()
     
     // Set a nil background color to use the view's tint color.
     backgroundConfiguration.backgroundColor = nil
     
     rowView.backgroundConfiguration = backgroundConfiguration
     ```
     
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-`nil` value for this property resets the following APIs to nil:
     - `backgroundColor`
     - ``backgroundView``
     - ``selectedBackgroundView``
     - ``multipleSelectionBackgroundView``
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
     If you override ``updateConfiguration(using:)`` to manually update and customize the background configuration, disable automatic updates by setting this property to false.
     */
    @objc open var automaticallyUpdatesBackgroundConfiguration: Bool {
        get { getAssociatedValue(key: "automaticallyUpdatesBackgroundConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "automaticallyUpdatesBackgroundConfiguration", object: self)
        }
    }
    
    /**
     The view that displays behind the row’s other content.
     
     Use this property to assign a custom background view to the row. The background view appears behind the content view and its frame automatically adjusts so that it fills the bounds of the row.
     
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-`nil` value for this property resets ``backgroundConfiguration`` to `nil`.
     */
    @objc open var backgroundView: NSView?   {
        get { getAssociatedValue(key: "backgroundView", object: self) }
        set { 
            guard newValue != backgroundView else { return }
            backgroundView?.removeFromSuperview()
            if newValue != nil {
                self.backgroundConfiguration = nil
            }
            set(associatedValue: newValue, key: "backgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    /**
     The view that displays just above the background view for a selected row.
     
     You can use this view to give a selected row a custom appearance. When the row has a selected state, this view layers above the ``backgroundView``.
     
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-`nil` value for this property resets ``backgroundConfiguration`` to `nil`.
     */
    @objc open var selectedBackgroundView: NSView? {
        get { getAssociatedValue(key: "selectedBackgroundView", object: self) }
        set { 
            guard newValue != selectedBackgroundView else { return }
            selectedBackgroundView?.removeFromSuperview()
            if newValue != nil {
                self.backgroundConfiguration = nil
            }
            set(associatedValue: newValue, key: "selectedBackgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    internal var configurationBackgroundView: (NSView & NSContentView)?   {
        get { getAssociatedValue(key: "configurationBackgroundView", object: self) }
        set {
            configurationBackgroundView?.removeFromSuperview()
            set(associatedValue: newValue, key: "configurationBackgroundView", object: self)
        }
    }
    
    /**
     The view that displays just above the background view for a selected row.
     
     You can use this view to give a selected row a custom appearance. When the row has a selected state, this view layers above the ``backgroundView``.
     
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-`nil` value for this property resets ``backgroundConfiguration`` to `nil`.
     */
    @objc open var multipleSelectionBackgroundView: NSView? {
        get { getAssociatedValue(key: "multipleSelectionBackgroundView", object: self) }
        set { 
            guard newValue != multipleSelectionBackgroundView else { return }
            multipleSelectionBackgroundView?.removeFromSuperview()
            if newValue != nil {
                self.backgroundConfiguration = nil
            }
            set(associatedValue: newValue, key: "multipleSelectionBackgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    internal func configurateBackgroundView() {
        if let backgroundConfiguration = backgroundConfiguration {
            self.backgroundView = nil
            self.selectedBackgroundView = nil
            self.multipleSelectionBackgroundView = nil
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
            if self.isSelected {
                self.backgroundView?.removeFromSuperview()
                if (isMultipleSelected) {
                    if let multipleBackgroundView = self.multipleSelectionBackgroundView {
                        self.selectedBackgroundView?.removeFromSuperview()
                        self.addSubview(withConstraint: multipleBackgroundView)
                    } else if let selectedBackgroundView = self.selectedBackgroundView {
                        self.addSubview(withConstraint: selectedBackgroundView)
                    }
                }
            } else {
                self.selectedBackgroundView?.removeFromSuperview()
                self.multipleSelectionBackgroundView?.removeFromSuperview()
                if let backgroundView = self.backgroundView {
                    self.addSubview(backgroundView)
                }
            }
        }
        self.orderSubviews()
    }
    
    internal func orderSubviews() {
        selectedBackgroundView?.sendToBack()
        multipleSelectionBackgroundView?.sendToBack()
        backgroundView?.sendToBack()
    }
    
    internal var isMultipleSelected: Bool {
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
     
     A configuration update handler provides an alternative approach to overriding ``updateConfiguration(using:)`` in a subclass. Set a configuration update handler to update the row’s configuration using the new state in response to a configuration state change:
     
     ```
     rowView.configurationUpdateHandler = { rowView, state in
     var content = NSTableRowContentConfiguration.default().updated(for: state)
     content.backgroundColor = nil
     if state.isSelected {
     content.backgroundColor = .controlAccentColor
     }
     rowView.backgroundConfiguration = content
     }
     ```
     
     Setting the value of this property calls ``setNeedsUpdateConfiguration()``. The system calls this handler after calling u``pdateConfiguration(using:)``.
     */
    public var configurationUpdateHandler: ConfigurationUpdateHandler?  {
        get { getAssociatedValue(key: "_NSTableRowViewconfigurationUpdateHandler", object: self) }
        set {
            set(associatedValue: newValue, key: "NSTableRowView_configurationUpdateHandler", object: self)
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
    internal func setNeedsAutomaticUpdateConfiguration() {
        if isConfigurationUpdatesEnabled {
            let state = self.configurationState
            
            if automaticallyUpdatesBackgroundConfiguration, let backgroundConfiguration = self.backgroundConfiguration {
                self.backgroundConfiguration = backgroundConfiguration.updated(for: state)
            }
            
            configurationUpdateHandler?(self, state)
        }
    }
    
    /*
     // Updates cell views content configuration.
     internal func setNeedsCellViewsUpdateConfiguration() {
     self.cellViews.forEach({$0.setNeedsUpdateConfiguration()})
     }
     */
    
    /**
     Updates the row’s configuration using the current state.
     
     Avoid calling this method directly. Instead, use ``setNeedsUpdateConfiguration()`` to request an update.
     Override this method in a subclass to update the row’s configuration using the provided state.
     */
    public func updateConfiguration(using state: NSTableRowConfigurationState) {
        if let backgroundConfiguration = self.backgroundConfiguration {
            self.backgroundConfiguration = backgroundConfiguration.updated(for: state)
        }
        configurationUpdateHandler?(self, state)
        cellViews.forEach({$0.setNeedsUpdateConfiguration()})
    }
    
    /**
     A Boolean value that specifies whether the current row view is hovered.
     
     A hovered row view has the mouse pointer on it.
     */
    internal var isHovered: Bool {
        get { self.tableView?.hoveredRowView == self }
    }
    
    internal var isEnabled: Bool {
        get { self.tableView?.isEnabled ?? true }
    }
    
    internal var isFocused: Bool {
        get { getAssociatedValue(key: "NSTableRowView_isFocused", object: self, initialValue: false) }
        set {
            guard newValue != self.isFocused else { return }
            set(associatedValue: newValue, key: "NSTableRowView_isFocused", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isReordering: Bool {
        get { getAssociatedValue(key: "NSTableRowView_isReordering", object: self, initialValue: false) }
        set {
            guard newValue != self.isReordering else { return }
            set(associatedValue: newValue, key: "NSTableRowView_isReordering", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isEditing: Bool {
        get { getAssociatedValue(key: "NSTableRowView_isEditing", object: self, initialValue: false) }
        set {
            guard newValue != self.isEditing else { return }
            set(associatedValue: newValue, key: "NSTableRowView_isEditing", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isTableViewFirstResponder: Bool {
        get { self.tableView?.isFirstResponder ?? false }
    }
    
    internal var isEmphasized: Bool {
        get { self.tableView?.isEmphasized ?? false }
    }
    
    // A Boolean value that indicates whether automatic updating of the configuration is enabled.
    internal var isConfigurationUpdatesEnabled: Bool {
        get { getAssociatedValue(key: "NSTableRowView_automaticUpdateConfigurationEnabled", object: self, initialValue: true) }
        set {  set(associatedValue: newValue, key: "NSTableRowView_automaticUpdateConfigurationEnabled", object: self) }
    }
    
    @objc internal func swizzled_PrepareForReuse() {
        self.isConfigurationUpdatesEnabled = false
        self.isEnabled = true
        self.isReordering = false
        self.isEditing = false
        self.isConfigurationUpdatesEnabled = true
    }
    
    internal func setCellViewsNeedUpdateConfiguration() {
        self.cellViews.forEach({ $0.setNeedsUpdateConfiguration() })
    }
    
    internal func setCellViewsNeedAutomaticUpdateConfiguration() {
        self.cellViews.forEach({ $0.setNeedsAutomaticUpdateConfiguration() })
    }
    
    internal var rowObserver: KeyValueObserver<NSTableRowView>? {
        get { getAssociatedValue(key: "NSTableRowView_rowObserver", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSTableRowView_rowObserver", object: self) }
    }
    
    internal var needsAutomaticRowHeights: Bool {
        get { getAssociatedValue(key: "needsAutomaticRowHeights", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "needsAutomaticRowHeights", object: self) }
    }
    
    internal func observeTableRowView() {
        guard rowObserver == nil else { return }
        rowObserver = KeyValueObserver(self)
        rowObserver?.add(\.isSelected) { old, new in
            guard old != new else { return }
            self.configurateBackgroundView()
            self.setNeedsAutomaticUpdateConfiguration()
            self.setCellViewsNeedAutomaticUpdateConfiguration()
        }
        rowObserver?.add(\.superview) { old, new in
            if self.needsAutomaticRowHeights {
                self.tableView?.usesAutomaticRowHeights = true
            }
            self.tableView?.setupObservation()
        }
        self.setNeedsUpdateConfiguration()
        self.setCellViewsNeedUpdateConfiguration()
    }
}
