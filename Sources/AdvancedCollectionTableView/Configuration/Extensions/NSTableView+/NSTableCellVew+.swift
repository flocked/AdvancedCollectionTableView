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
    public var contentConfiguration: NSContentConfiguration? {
        get { getAssociatedValue("contentConfiguration") }
        set {
            let newValue = (newValue as? NSListContentConfiguration)?.updated(for: self) ?? newValue
            setAssociatedValue(newValue, key: "contentConfiguration")
            observeCellView()
            configurateContentView()
            if newValue is AutomaticHeightSizable {
                observeWillMoveToRowView()
            }
        }
    }

    /**
     Retrieves a default content configuration for the cell’s style. The system determines default values for the configuration according to the table view it is presented and if it is used as table row cell or section header cell.

     The default content configuration has preconfigured default styling depending on the table view `style` it gets displayed in, but doesn’t contain any content. After you get the default configuration, you assign your content to it, customize any other properties, and assign it to the cell as the current content configuration.

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
        NSListContentConfiguration.automatic()
    }

    /**
     A Boolean value that determines whether the cell automatically updates its content configuration when its state changes.

     When this value is `true`, the cell automatically calls `updated(for:)` on its ``contentConfiguration`` when the cell’s ``configurationState`` changes, and applies the updated configuration back to the cell. The default value is `true`.

     If you override ``updateConfiguration(using:)`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue("automaticallyUpdatesContentConfiguration", initialValue: true) }
        set {
            guard newValue != automaticallyUpdatesContentConfiguration else { return }
            setAssociatedValue(newValue, key: "automaticallyUpdatesContentConfiguration")
            if newValue, let contentConfiguration = contentConfiguration, let contentView = contentView {
                contentView.configuration = contentConfiguration.updated(for: configurationState)
            }
        }
    }

    func configurateContentView() {
        if var contentConfiguration = contentConfiguration {
            if automaticallyUpdatesContentConfiguration {
                contentConfiguration = contentConfiguration.updated(for: configurationState)
            }
            if let contentView = contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                contentView = contentConfiguration.makeContentView()
                translatesAutoresizingMaskIntoConstraints = false
                addSubview(withConstraint: contentView!)
                /*
                if let contentView = contentView as? NSListContentView {
                    textField = contentView.textField
                    imageView = contentView.imageView
                } else {
                    textField = nil
                    imageView = nil
                }
                 */
                 
            }
            setNeedsDisplay()
            contentView?.setNeedsDisplay()
        } else {
            contentView = nil
        }
    }

    // MARK: Managing the state

    /**
     The current configuration state of the table cell.

     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    @objc open var configurationState: NSListConfigurationState {
        let rowView = rowView
        let tableView = tableView
        let activeState = tableView?.activeState ?? .inactive
        let isEditing = tableView?.editingView?.isDescendant(of: self) == true
        return NSListConfigurationState(isSelected: rowView?.isSelected ?? false, isEnabled: rowView?.isEnabled ?? true, isHovered: rowView?.isHovered ?? false, isEditing: isEditing, activeState: activeState, isReordering: rowView?.isReordering ?? false, isDropTarget: rowView?.isDropTarget ?? false, isNextSelected: rowView?.isNextRowSelected ?? false, isPreviousSelected: rowView?.isPreviousRowSelected ?? false, appearance: effectiveAppearance)
    }

    /**
     Informs the table cell to update its configuration for its current state.

     You call this method when you need the table cell to update its configuration according to the current configuration state. The system calls this method automatically when the cell’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.

     If you add custom states to the table cell’s configuration state, make sure to call this method every time those custom states change.
     */
    @objc open func setNeedsUpdateConfiguration() {
        updateConfiguration(using: configurationState)
    }

    func setNeedsAutomaticUpdateConfiguration() {
        if automaticallyUpdatesContentConfiguration {
            setNeedsUpdateConfiguration()
        } else {
            configurationUpdateHandler?(self, configurationState)
        }
    }

    /**
     Updates the cell’s configuration using the current state.

     Avoid calling this method directly. Instead, use ``setNeedsUpdateConfiguration()`` to request an update.

     Override this method in a subclass to update the cell’s configuration using the provided state.
     */
    @objc open func updateConfiguration(using state: NSListConfigurationState) {
        if let contentConfiguration = contentConfiguration, let contentView = contentView {
            contentView.configuration = contentConfiguration.updated(for: state)
        }
        configurationUpdateHandler?(self, state)
    }

    /**
     The type of block for handling updates to the cell’s configuration using the current state.

     - Parameters:
        - cell: The table view cell to configure.
        - state: The new state to use for updating the cell’s configuration.
     */
    public typealias ConfigurationUpdateHandler = (_ cell: NSTableCellView, _ state: NSListConfigurationState) -> Void

    /**
     A block for handling updates to the cell’s configuration using the current state.

     A configuration update handler provides an alternative approach to overriding ``updateConfiguration(using:)`` in a subclass. Set a configuration update handler to update the cell’s configuration using the new state in response to a configuration state change:

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
    @objc open var configurationUpdateHandler: ConfigurationUpdateHandler? {
        get { getAssociatedValue("configurationUpdateHandler") }
        set {
            setAssociatedValue(newValue, key: "configurationUpdateHandler")
            observeCellView()
            setNeedsUpdateConfiguration()
        }
    }
    
    /**
     A Boolean value that specifies whether the cell view is hovered.

     A hovered cell view has the mouse pointer on it.
     */
    @objc var isHovered: Bool {
        rowView?.isHovered ?? false
    }

    /// A Boolean value that specifies whether the cell view is active (it's window is focused).
    @objc var isActive: Bool {
        window?.isKeyWindow ?? false
    }
    
    /// A Boolean value that indicates whether the item is focused.
    @objc var isFocused: Bool {
        isDescendantFirstResponder
    }
    
    /// A Boolean value that indicates whether the collection view and it's items are focused.
    @objc var isTableViewFocused: Bool {
        tableView?.isDescendantFirstResponder == true
    }
    
    var activeState: NSListConfigurationState.ActiveState {
        isActive ? isTableViewFocused ? .focused : .active : .inactive
    }

    /// A Boolean value that specifies whether the cell view is enabled (the table view's `isEnabled` is `true`).
    @objc var isEnabled: Bool {
        tableView?.isEnabled ?? true
    }

    /// A Boolean value that indicates whether the cell is in an editable state. (the text of a content configuration is currently edited).
    @objc var isEditing: Bool {
        if let editingView = window?.firstResponder as? EditiableView ?? (window?.firstResponder as? NSText)?.delegate as? EditiableView, editingView.isEditing, editingView.isDescendant(of: self) {
            return true
        }
        return false
    }

    var isNextRowSelected: Bool {
        rowView?.isNextRowSelected ?? false
    }

    var isPreviousRowSelected: Bool {
        rowView?.isPreviousRowSelected ?? false
    }
    
    var isGroupRowCell: Bool {
        guard let rowView = rowView else { return false }
        let isGroup = rowView.identifier != "_GroupCellRowView" ? rowView.isGroupRowStyle : (rowView.superview as? NSTableRowView)?.isGroupRowStyle == true
        return rowView.identifier != "_GroupCellRowView" ? rowView.isGroupRowStyle : (rowView.superview as? NSTableRowView)?.isGroupRowStyle == true
    }
    
    var isReordering: Bool {
        rowView?.isReordering ?? false
    }
    
    var isDropTarget: Bool {
        rowView?.isDropTarget ?? false
    }
    
    var contentView: (NSView & NSContentView)? {
        get { getAssociatedValue("_contentView") }
        set { 
            contentView?.removeFromSuperview()
            setAssociatedValue(newValue, key: "_contentView")
        }
    }
    
    func updateContentConfigurationStyle() {
        if let configuration = (contentConfiguration as? NSListContentConfiguration)?.updated(for: self) {
            setAssociatedValue(configuration, key: "contentConfiguration")
            NSAnimationContext.performWithoutAnimation {
                self.contentView?.configuration = configuration
            }
        }
    }

    func observeCellView() {
        if contentConfiguration != nil || configurationUpdateHandler != nil {
            guard tableViewObservation == nil else { return }
            tableViewObservation = observeChanges(for: \.window) { [weak self] _, window in
                guard window != nil, let self = self, let tableView = self.tableView else { return }
                tableView.setupObservation()
                self.updateContentConfigurationStyle()
                self.setNeedsAutomaticUpdateConfiguration()
                guard let rowView = self.rowView else { return }
                rowView.translatesAutoresizingMaskIntoConstraints = false
                rowView.observeSelection()
            }
        } else {
            tableViewObservation = nil
        }
    }
    
    var tableViewObservation: KeyValueObservation? {
        get { getAssociatedValue("tableViewObservation") }
        set { setAssociatedValue(newValue, key: "tableViewObservation") }
    }
    
    func observeWillMoveToRowView() {
        guard !isMethodHooked(#selector(NSView.viewWillMove(toSuperview:))) else { return }
        tableView?.enableAutomaticRowHeights()
        do {
            try hookBefore(#selector(NSView.viewWillMove(toSuperview:)), closure: {
                object, selector, superview in
                (superview as? NSTableRowView)?.observeWillMoveToTableView()
            } as @convention(block) (AnyObject, Selector, NSView?) -> ())
        } catch {
            Swift.print(error)
        }
    }
}
