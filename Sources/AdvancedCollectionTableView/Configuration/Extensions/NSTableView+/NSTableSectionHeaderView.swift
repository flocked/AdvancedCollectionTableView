//
//  NSTableSectionHeaderView.swift
//
//
//  Created by Florian Zand on 27.12.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

/**
 The view shown for a section header in a table view.

 `NSTableSectionHeaderView` is responsible for displaying attributes associated with the section header.
 */
open class NSTableSectionHeaderView: NSView {
    // MARK: Managing the content

    /**
     The current content configuration of the section header view.

     Using a content configuration, you can set the section header view’s content and styling for a variety of different section header view states. You can get the default configuration using ``defaultContentConfiguration()``, assign your content to the configuration, customize any other properties, and assign it to the view as the current `contentConfiguration`.

     Setting a content configuration replaces the view of the section header view with a new content view instance from the configuration, or directly applies the configuration to the existing view if the configuration is compatible with the existing content view type.

     The default value is `nil`. After you set a content configuration to this property, setting this property back to `nil` replaces the current view with a new, empty view.
     */
    open var contentConfiguration: NSContentConfiguration? {
        didSet {
            observeSectionHeaderView()
            configurateContentView()
        }
    }

    /**
     Retrieves a default content configuration for the section header view’s style. The system determines default values for the configuration according to the table view it is presented.

     The default content configuration has preconfigured default styling depending on the table view `style` it gets displayed in, but doesn’t contain any content. After you get the default configuration, you assign your content to it, customize any other properties, and assign it to the section header view as the current content configuration.

     ```swift
     var content = section header view.defaultContentConfiguration()

     // Configure content.
     content.text = "Favorites"
     content.image = NSImage(systemSymbolName: "star", accessibilityDescription: "star")

     // Customize appearance.
     content.imageProperties.tintColor = .purple

     section header view.contentConfiguration = content
     ```

     - Returns:A default section header view content configuration. The system determines default values for the configuration according to the table view and it’s style.
     */
    open func defaultContentConfiguration() -> NSListContentConfiguration {
        NSListContentConfiguration.automaticHeader()
    }

    /**
     A Boolean value that determines whether the section header view automatically updates its content configuration when its state changes.

     When this value is `true`, the section header view automatically calls `updated(for:)` on its ``contentConfiguration`` when the section header view’s ``configurationState`` changes, and applies the updated configuration back to the section header view. The default value is `true`.

     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool = true {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    /**
     The current configuration state of the section header view.

     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    @objc open var configurationState: NSListConfigurationState {
        let state = NSListConfigurationState(isSelected: false, isEnabled: isEnabled, isHovered: isHovered, isEditing: isEditing, isEmphasized: isEmphasized, isNextSelected: false, isPreviousSelected: false)
        return state
    }

    /**
     Informs the section header view to update its configuration for its current state.

     You call this method when you need the section header view to update its configuration according to the current configuration state. The system calls this method automatically when the section header view’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.

     If you add custom states to the section header view’s configuration state, make sure to call this method every time those custom states change.
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
     Updates the section header view’s configuration using the current state.

     Avoid calling this method directly. Instead, use setNeedsUpdateConfiguration() to request an update.
     Override this method in a subclass to update the section header view’s configuration using the provided state.
     */
    @objc open func updateConfiguration(using state: NSListConfigurationState) {
        if let contentConfiguration = contentConfiguration, let contentView = contentView {
            contentView.configuration = contentConfiguration.updated(for: state)
        }
        configurationUpdateHandler?(self, state)
    }

    /**
     The type of block for handling updates to the section header view’s configuration using the current state.

     - Parameters:
     - sectionHeaderView: The section header view to configure.
     - state: The new state to use for updating the section header view’s configuration.
     */
    public typealias ConfigurationUpdateHandler = (_ sectionHeaderView: NSTableSectionHeaderView, _ state: NSListConfigurationState) -> Void

    /**
     A block for handling updates to the section header view’s configuration using the current state.

     Set a configuration update handler to update the section header view’s configuration using the new state in response to a configuration state change:

     ```swift
     sectionHeaderView.configurationUpdateHandler = { headerView, state in

     }
     ```

     Setting the value of this property calls ``setNeedsUpdateConfiguration()``. The system calls this handler after calling `updateConfiguration(using:)`.
     */
    @objc open var configurationUpdateHandler: ConfigurationUpdateHandler? {
        didSet {
            observeSectionHeaderView()
            setNeedsUpdateConfiguration()
        }
    }

    /**
     A Boolean value that indicates whether the section header view is in an editing state.

     The value of this property is `true` when the text of a list or item content configuration is currently edited.
     */
    @objc var isEditing: Bool {
        (contentView as? EdiitingContentView)?.isEditing ?? false
    }

    /**
     A Boolean value that specifies whether the section header view is hovered.

     A hovered cell view has the mouse pointer on it.
     */
    @objc var isHovered: Bool = false {
        didSet {
            guard oldValue != isHovered else { return }
            setNeedsAutomaticUpdateConfiguration()
        }
    }

    /**
     A Boolean value that specifies whether the section header view is emphasized.

     The section header view is emphasized when it's window is key.
     */
    @objc var isEmphasized: Bool = false {
        didSet {
            guard oldValue != isEmphasized else { return }
            setNeedsAutomaticUpdateConfiguration()
        }
    }

    /**
     A Boolean value that specifies whether the section header view is enabled.

     The value of this property is `true` when the table view`s `isEnabled` is `true`.
     */
    @objc var isEnabled: Bool {
        tableView?.isEnabled ?? true
    }

    var contentView: (NSView & NSContentView)?

    func configurateContentView() {
        if var contentConfiguration = contentConfiguration {
            if automaticallyUpdatesContentConfiguration {
                contentConfiguration = contentConfiguration.updated(for: configurationState)
            }
            if let contentView = contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                self.contentView?.removeFromSuperview()
                // self.textField
                let contentView = contentConfiguration.makeContentView()
                self.contentView = contentView
                translatesAutoresizingMaskIntoConstraints = false
                addSubview(withConstraint: contentView)
                setNeedsDisplay()
                contentView.setNeedsDisplay()
            }
        } else {
            contentView?.removeFromSuperview()
        }
    }

    var tableView: NSTableView? {
        firstSuperview(for: NSTableView.self)
    }

    var sectionHeaderObserver: KeyValueObserver<NSTableSectionHeaderView>?

    func observeSectionHeaderView() {
        if contentConfiguration != nil || configurationUpdateHandler != nil {
            guard windowHandlers.isKey == nil else { return }
            windowHandlers.isKey = { isKey in
                self.isEmphasized = isKey
            }

            mouseHandlers.exited = { _ in
                self.isHovered = false
            }

            mouseHandlers.entered = { _ in
                self.isHovered = true
            }
            
            guard sectionHeaderObserver == nil else { return }
            sectionHeaderObserver = KeyValueObserver(self)
            sectionHeaderObserver?.add(\.superview?.superview, handler: { [weak self] _, _ in
                guard let self = self, let tableViewStyle = self.tableView?.effectiveStyle, let contentConfiguration = self.contentConfiguration as? NSListContentConfiguration, contentConfiguration.type == .automaticRow, contentConfiguration.tableViewStyle != tableViewStyle else {
                    return
                }
                self.contentConfiguration = contentConfiguration.applyTableViewStyle(tableViewStyle, isHeader: true)
            })
        } else {
            windowHandlers.isKey = nil
            mouseHandlers.exited = nil
            mouseHandlers.entered = nil
            sectionHeaderObserver = nil
        }
    }
}
