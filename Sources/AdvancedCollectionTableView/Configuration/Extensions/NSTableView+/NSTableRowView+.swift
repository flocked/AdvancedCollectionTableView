//
//  NSTableRowView+.swift
//
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSTableRowView {
    // MARK: Configuring the content

    /**
     The current content configuration of the row.

     Using a content configuration, you can obtain system default content styling for a variety of different row states. Create a content configuration with one of the default system styles, customize the configuration to match your row’s style as necessary, and assign the configuration to this property.

     ```swift
     var contentConfiguration = NSBackgroundConfiguration()

     // Set a nil background color to use the view's tint color.
     contentConfiguration.backgroundColor = nil

     rowView.contentConfiguration = contentConfiguration
     ```
     */
    public var contentConfiguration: NSContentConfiguration? {
        get { getAssociatedValue("contentConfiguration") }
        set {
            setAssociatedValue(newValue, key: "contentConfiguration")
            observeTableRowView()
            configurateContentView()
        }
    }

    /**
     A Boolean value that determines whether the row automatically updates its content configuration when its state changes.

     When this value is true, the row automatically calls  `updated(for:)` on its ``contentConfiguration`` when the row’s ``configurationState`` changes, and applies the updated configuration back to the row. The default value is true.

     If you override ``updateConfiguration(using:)`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue("automaticallyUpdatesContentConfiguration", initialValue: true) }
        set { setAssociatedValue(newValue, key: "automaticallyUpdatesContentConfiguration")
        }
    }

    var contentView: (NSView & NSContentView)? {
        get { getAssociatedValue("contentView") }
        set {
            contentView?.removeFromSuperview()
            setAssociatedValue(newValue, key: "contentView")
        }
    }

    func configurateContentView() {
        if var contentConfiguration = contentConfiguration {
            if automaticallyUpdatesContentConfiguration {
                contentConfiguration = contentConfiguration.updated(for: configurationState)
            }
            backgroundColor = nil
            if let contentView = contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                contentView?.removeFromSuperview()
                let contentView = contentConfiguration.makeContentView()
                contentView.configuration = contentConfiguration
                self.contentView = contentView
                addSubview(withConstraint: contentView)
            }
        } else {
            contentView = nil
        }
    }

    /**
     The type of block for handling updates to the row’s configuration using the current state.

     - Parameters:
        - row: The table view row to configure.
        - state: The new state to use for updating the row’s configuration.
     */
    public typealias ConfigurationUpdateHandler = (_ rowView: NSTableRowView, _ state: NSListConfigurationState) -> Void

    /**
     A block for handling updates to the row’s configuration using the current state.

     A configuration update handler provides an alternative approach to overriding ``updateConfiguration(using:)`` in a subclass. Set a configuration update handler to update the cell’s configuration using the new state in response to a configuration state change:

     ```swift
     rowView.configurationUpdateHandler = { rowView, state in
     var content = NSTableRowContentConfiguration.default().updated(for: state)
     content.backgroundColor = nil
     if state.isSelected {
     content.backgroundColor = .controlAccentColor
     }
     rowView.contentConfiguration = content
     }
     ```

     Setting the value of this property calls ``setNeedsUpdateConfiguration()``.
     */
    @objc open var configurationUpdateHandler: ConfigurationUpdateHandler? {
        get { getAssociatedValue("configurationUpdateHandler") }
        set {
            setAssociatedValue(newValue, key: "configurationUpdateHandler")
            observeTableRowView()
            setNeedsUpdateConfiguration()
        }
    }

    // MARK: Managing the state

    /**
     The current configuration state of the row.

     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    @objc open var configurationState: NSListConfigurationState {
        let state = NSListConfigurationState(isSelected: isSelected, isEnabled: isEnabled, isHovered: isHovered, isEditing: isEditing, isEmphasized: isEmphasized, isNextSelected: isNextRowSelected, isPreviousSelected: isPreviousRowSelected)
        return state
    }

    /**
     Informs the row to update its configuration for its current state.

     You call this method when you need the row to update its configuration according to the current configuration state. The system calls this method automatically when the row’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.

     If you add custom states to the row’s configuration state, make sure to call this method every time those custom states change.
     */
    @objc open func setNeedsUpdateConfiguration() {
        updateConfiguration(using: configurationState)
    }

    // Updates content configuration and content configuration if automatic updating is enabled.
    func setNeedsAutomaticUpdateConfiguration() {
        if automaticallyUpdatesContentConfiguration {
            setNeedsUpdateConfiguration()
        } else {
            configurationUpdateHandler?(self, configurationState)
        }
    }

    /**
     Updates the row’s configuration using the current state.

     Avoid calling this method directly. Instead, use ``setNeedsUpdateConfiguration()`` to request an update.
     Override this method in a subclass to update the row’s configuration using the provided state.
     */
    @objc open func updateConfiguration(using state: NSListConfigurationState) {
        if let contentConfiguration = contentConfiguration, let contentView = contentView {
            contentView.configuration = contentConfiguration.updated(for: state)
        }
        _cellViews.forEach { $0.setNeedsUpdateConfiguration() }
        configurationUpdateHandler?(self, state)
    }
    
    var _cellViews: [NSTableCellView] {
        if numberOfColumns > 0, let cellView = (view(atColumn: 0) as? NSTableSectionHeaderView)?.cellView {
            return [cellView]
        }
        return cellViews
    }

    /**
     A Boolean value that specifies whether the row view is hovered.

     A hovered row view has the mouse pointer on it.
     */
    @objc var isHovered: Bool {
        tableView?.hoveredRowView == self
    }

    /// A Boolean value that specifies whether the row view is enabled (the table view's `isEnabled` is `true`).
    @objc var isEnabled: Bool {
        tableView?.isEnabled ?? true
    }

    /// A Boolean value that indicates whether the row view is in an editable state. (the text of a content configuration is currently edited).
    @objc var isEditing: Bool {
        (contentView as? EdiitingContentView)?.isEditing ?? false
    }

    /// A Boolean value that specifies whether the row view is emphasized (the window is key).
    @objc var isEmphasized: Bool {
        window?.isKeyWindow ?? false
    }

    func setCellViewsNeedAutomaticUpdateConfiguration() {
        _cellViews.forEach { $0.setNeedsAutomaticUpdateConfiguration() }
    }

    var needsAutomaticRowHeights: Bool {
        get { getAssociatedValue("needsAutomaticRowHeights", initialValue: false) }
        set { setAssociatedValue(newValue, key: "needsAutomaticRowHeights") }
    }
    
    var rowObserver: KeyValueObserver<NSTableRowView>? {
        get { getAssociatedValue("rowObserver", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "rowObserver") }
    }

    func observeTableRowView() {
        guard rowObserver == nil else { return }
        rowObserver = KeyValueObserver(self)
        rowObserver?.add(\.isSelected) { old, new in
            guard old != new else { return }
            self.configurateContentView()
            self.setNeedsAutomaticUpdateConfiguration()
            self.setCellViewsNeedAutomaticUpdateConfiguration()
        }
        rowObserver?.add(\.superview) { _, _ in
            if self.needsAutomaticRowHeights {
                self.tableView?.usesAutomaticRowHeights = true
            }
            self.tableView?.setupObservation()
            self.setCellViewsNeedAutomaticUpdateConfiguration()
        }
        setNeedsUpdateConfiguration()
        setCellViewsNeedAutomaticUpdateConfiguration()
    }
}
