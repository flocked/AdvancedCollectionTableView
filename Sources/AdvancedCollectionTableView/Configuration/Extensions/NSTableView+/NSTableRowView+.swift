//
//  NSTableRowView+.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit


public extension NSTableRowView {
    /**
     The current background configuration of the item.
     
     Using a background configuration, you can obtain system default background styling for a variety of different item states. Create a background configuration with one of the default system styles, customize the configuration to match your item’s style as necessary, and assign the configuration to this property.
     
     ```
     var backgroundConfiguration = NSBackgroundConfiguration.listPlainItem()
     
     // Set a nil background color to use the view's tint color.
     backgroundConfiguration.backgroundColor = nil
     
     item.backgroundConfiguration = backgroundConfiguration
     ```
     
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-nil value for this property resets the following APIs to nil:
     - ``backgroundColor``
     - ``backgroundView``
     - ``selectedBackgroundView``
     */
    var backgroundConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "NSTableRowVew_backgroundConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "NSTableRowVew_backgroundConfiguration", object: self)
            if (newValue != nil) {
                self.swizzleTableRowViewIfNeeded()
            }
            self.configurateBackgroundView()
        }
    }
    
    /**
     A Boolean value that determines whether the item automatically updates its background configuration when its state changes.
     
     When this value is true, the item automatically calls  ``updated(for:)`` on its ``backgroundConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.
     If you override ``updateConfiguration(using:)`` to manually update and customize the background configuration, disable automatic updates by setting this property to false.
     */
    var automaticallyUpdatesBackgroundConfiguration: Bool {
        get { getAssociatedValue(key: "NSTableRowVew_automaticallyUpdatesBackgroundConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "NSTableRowVew_automaticallyUpdatesBackgroundConfiguration", object: self)
        }
    }
    
    /**
     The view that displays behind the item’s other content.
     
     Use this property to assign a custom background view to the item. The background view appears behind the content view and its frame automatically adjusts so that it fills the bounds of the item.
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-nil value for this property resets ``backgroundConfiguration`` to nil.
     */
    var backgroundView: NSView?   {
        get { getAssociatedValue(key: "NSTableRowVew_backgroundView", object: self) }
        set { set(associatedValue: newValue, key: "NSTableRowVew_backgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    /**
     The view that displays just above the background view for a selected item.
     
     You can use this view to give a selected item a custom appearance. When the item has a selected state, this view layers above the ``backgroundView`` and behind the ``contentView``.
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-nil value for this property resets ``backgroundConfiguration`` to nil.
     */
    var selectedBackgroundView: NSView? {
        get { getAssociatedValue(key: "NSTableRowVew_selectedBackgroundView", object: self) }
        set { set(associatedValue: newValue, key: "NSTableRowVew_selectedBackgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    internal var configurationBackgroundView: (NSView & NSContentView)?   {
        get { getAssociatedValue(key: "NSTableRowVew_configurationBackgroundView", object: self) }
        set {
            self.configurationBackgroundView?.removeFromSuperview()
            set(associatedValue: newValue, key: "NSTableRowVew_configurationBackgroundView", object: self)
        }
    }
    
    /**
     The view that displays just above the background view for a selected item.
     
     You can use this view to give a selected item a custom appearance. When the item has a selected state, this view layers above the ``backgroundView`` and behind the ``contentView``.
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-nil value for this property resets ``backgroundConfiguration`` to nil.
     */
    var multipleSelectionBackgroundView: NSView? {
        get { getAssociatedValue(key: "NSTableRowVew_multipleSelectionBackgroundView", object: self) }
        set { set(associatedValue: newValue, key: "NSTableRowVew_multipleSelectionBackgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    internal func configurateBackgroundView() {
        if let backgroundConfiguration = backgroundConfiguration {
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
            self.selectedBackgroundView?.removeFromSuperview()
            self.selectedBackgroundView = nil
            self.multipleSelectionBackgroundView?.removeFromSuperview()
            self.multipleSelectionBackgroundView = nil
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
            configurationBackgroundView?.removeFromSuperview()
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
        get { getAssociatedValue(key: "_NSTableRowViewconfigurationUpdateHandler", object: self) }
        set {
            set(associatedValue: newValue, key: "NSTableRowView_configurationUpdateHandler", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    /**
     The current configuration state of the row.
     
     To add your own custom state, see ``NSConfigurationStateCustomKey``.
     */
    var configurationState: NSTableRowConfigurationState {
        let state = NSTableRowConfigurationState(isSelected: self.isSelected, isEnabled: self.isEnabled, isFocused: self.isFocused, isHovered: self.isHovered, isEditing: self.isEditing, isExpanded: false, isEmphasized: self.isEmphasized, isNextRowSelected: self.isNextRowSelected, isPreviousRowSelected: self.isPreviousRowSelected)
        return state
    }
    
    /**
     Informs the row to update its configuration for its current state.
     
     You call this method when you need the row to update its configuration according to the current configuration state. The system calls this method automatically when the row’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     If you add custom states to the row’s configuration state, make sure to call this method every time those custom states change.
     */
    func setNeedsUpdateConfiguration() {
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
    func updateConfiguration(using state: NSTableRowConfigurationState) {
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
        get { getAssociatedValue(key: "NSTableRowView_isHovered", object: self, initialValue: false) }
        set {
            guard newValue != self.isHovered else { return }
            set(associatedValue: newValue, key: "NSTableRowView_isHovered", object: self)
            self.cellViews.forEach({ $0.isHovered = newValue })
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isEnabled: Bool {
        get { getAssociatedValue(key: "NSTableRowView_isEnabled", object: self, initialValue: false) }
        set {
            guard newValue != self.isEnabled else { return }
            set(associatedValue: newValue, key: "NSTableRowView_isEnabled", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
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
    
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSTableRowView_isEmphasized", object: self, initialValue: false) }
        set {
            guard newValue != self.isEmphasized else { return }
            set(associatedValue: newValue, key: "NSTableRowView_isEmphasized", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    // A Boolean value that indicates whether automatic updating of the configuration is enabled.
    internal var isConfigurationUpdatesEnabled: Bool {
        get { getAssociatedValue(key: "NSTableRowView_automaticUpdateConfigurationEnabled", object: self, initialValue: true) }
        set {  set(associatedValue: newValue, key: "NSTableRowView_automaticUpdateConfigurationEnabled", object: self) }
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
    
    internal var didSwizzleTableRowView: Bool {
        get { getAssociatedValue(key: "NSTableRowView_didSwizzle", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "NSTableRowView_didSwizzle", object: self)
        }
    }
    
    internal func setCellViewsNeedUpdateConfiguration() {
        self.cellViews.forEach({ $0.setNeedsUpdateConfiguration() })
    }
    
    internal func setCellViewsNeedAutomaticUpdateConfiguration() {
        self.cellViews.forEach({ $0.setNeedsAutomaticUpdateConfiguration() })
    }
    
    var tableViewObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSTableRowView_tableViewObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSTableRowView_tableViewObserver", object: self)
        }
    }
        
    @objc internal func swizzleTableRowViewIfNeeded(_ shouldSwizzle: Bool = true) {
        Swift.print("swizzleTableRowViewIfNeeded start")
        if (didSwizzleTableRowView == false) {
            didSwizzleTableRowView = true
            if (self.tableViewObserver == nil) {
                self.tableViewObserver = self.observe(\.superview, options: [.new]) { object, change in
                    Swift.print("Row.superview")
                }
            }
            
            do {
                let hooks = [
                    try  self.hook(#selector(NSTableRowView.viewDidMoveToSuperview),
                                   methodSignature: (@convention(c) (AnyObject, Selector) -> ()).self,
                                   hookSignature: (@convention(block) (AnyObject) -> ()).self) {
                                       store in { (object) in
                                           Swift.print("NSTableRowView viewDidMoveToSuperview")
                                           self.tableView?.setupObserverView()
                                           store.original(object, store.selector)
                                       }
                                   },
                    
                    try  self.hook(#selector(setter: isSelected),
                                   methodSignature: (@convention(c) (AnyObject, Selector, Bool) -> ()).self,
                                   hookSignature: (@convention(block) (AnyObject, Bool) -> ()).self) {
                                       store in { (object, isSelected) in
                                           Swift.print("row.isSelected swizzled", isSelected)
                                           if self.isSelected != isSelected {
                                                   self.configurateBackgroundView()
                                                   self.setNeedsAutomaticUpdateConfiguration()
                                               self.setCellViewsNeedAutomaticUpdateConfiguration()
                                           }
                                           store.original(object, store.selector, isSelected)
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
