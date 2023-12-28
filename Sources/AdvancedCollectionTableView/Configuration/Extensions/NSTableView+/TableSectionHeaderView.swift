//
//  SectionHeaderView.swift
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
    open var contentConfiguration: NSContentConfiguration? = nil  {
        didSet {
            if (contentConfiguration != nil) {
                self.observeTableCellView()
            }
            self.configurateContentView()
        }
    }
    
    /**
     Retrieves a default content configuration for the section header view’s style. The system determines default values for the configuration according to the table view it is presented.
     
     The default content configuration has preconfigured default styling depending on the table view ``AppKit/NSTableView/style`` it gets displayed in, but doesn’t contain any content. After you get the default configuration, you assign your content to it, customize any other properties, and assign it to the section header view as the current content configuration.
     
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
        return NSListContentConfiguration.automaticRow()
    }
    
    /**
     A Boolean value that determines whether the section header view automatically updates its content configuration when its state changes.
     
     When this value is `true`, the section header view automatically calls `updated(for:)` on its ``contentConfiguration`` when the section header view’s ``configurationState`` changes, and applies the updated configuration back to the section header view. The default value is `true`.
     
     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool = true {
        didSet {
            self.setNeedsUpdateConfiguration()

        }
    }
    
    /**
     The current configuration state of the section header view.
     
     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    public var configurationState: NSTableCellConfigurationState {
        let state = NSTableCellConfigurationState(isSelected: false, isEditing: isEditing, isEmphasized: isEmphasized, isHovered: isHovered, isEnabled: isEnabled)
        return state
    }
    
    var isEditing: Bool {
        (contentView as? EdiitingContentView)?.isEditing ?? false
    }
    
    /**
     A Boolean value that specifies whether the section header view is hovered.
     
     A hovered cell view has the mouse pointer on it.
     */
    public var isHovered: Bool {
        self.rowView?.isHovered ?? false
    }
    
    /// A Boolean value that specifies whether the section header view is emphasized (the window is key).
    public var isEmphasized: Bool {
        self.window?.isKeyWindow ?? false
    }
    
    /// A Boolean value that specifies whether the section header view is enabled (the table view's `isEnabled` is `true`).
    public var isEnabled: Bool {
        get { rowView?.isEnabled ?? true }
    }

    
    /**
     Informs the section header view to update its configuration for its current state.
     
     You call this method when you need the section header view to update its configuration according to the current configuration state. The system calls this method automatically when the section header view’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     
     If you add custom states to the section header view’s configuration state, make sure to call this method every time those custom states change.
     */
    @objc open func setNeedsUpdateConfiguration() {
        self.updateConfiguration(using: configurationState)
    }
    
    /// The row of the section header view.
    var row: Int? {
        guard let tableView = self.tableView else { return nil }
        var row = tableView.row(for: self)
        if row == -1 {
            row = 0
        }
        return row
    }
    
    func setNeedsAutomaticUpdateConfiguration() {
        if let contentConfiguration = self.contentConfiguration as? NSListContentConfiguration, contentConfiguration.type == .automaticRow, let tableView = self.tableView, contentConfiguration.tableViewStyle != tableView.effectiveStyle, let row = self.row {
            let isGroupRow = tableView.delegate?.tableView?(tableView, isGroupRow: row) ?? false
            self.contentConfiguration = contentConfiguration.tableViewStyle(tableView.effectiveStyle, isGroupRow: isGroupRow)
        }
        
        if configurationUpdatingIsEnabled {
            let state = configurationState
            if automaticallyUpdatesContentConfiguration, let contentConfiguration = self.contentConfiguration {
                self.contentConfiguration = contentConfiguration.updated(for: state)
            }
            configurationUpdateHandler?(self, state)
        }
    }
    
    var configurationUpdatingIsEnabled: Bool = true
    
    /**
     Updates the section header view’s configuration using the current state.
     
     Avoid calling this method directly. Instead, use setNeedsUpdateConfiguration() to request an update.
     Override this method in a subclass to update the section header view’s configuration using the provided state.
     */
    open func updateConfiguration(using state: NSTableCellConfigurationState) {
        if let contentConfiguration = self.contentConfiguration {
            self.contentConfiguration = contentConfiguration.updated(for: state)
        }
        configurationUpdateHandler?(self, state)
    }
    
    /**
     The type of block for handling updates to the section header view’s configuration using the current state.
     
     - Parameters:
        - sectionHeaderView: The section header view to configure.
        - state: The new state to use for updating the section header view’s configuration.
     */
    public typealias ConfigurationUpdateHandler = (_ sectionHeaderView: NSTableSectionHeaderView, _ state: NSTableCellConfigurationState) -> Void
    
    /**
     A block for handling updates to the section header view’s configuration using the current state.
     
     Set a configuration update handler to update the section header view’s configuration using the new state in response to a configuration state change:
     
     ```swift
     sectionHeaderView.configurationUpdateHandler = { headerView, state in
     
     }
     ```
     
     Setting the value of this property calls ``setNeedsUpdateConfiguration()``.
     */
    public var configurationUpdateHandler: ConfigurationUpdateHandler? = nil {
        didSet {
            self.setNeedsUpdateConfiguration()
        }
    }
    
    var contentView: (NSView & NSContentView)?  = nil
    
    
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
    
    var tableCellObserver: KeyValueObserver<NSTableSectionHeaderView>? = nil
    
    var rowView: NSTableRowView? {
        return firstSuperview(for: NSTableRowView.self)
    }

    var tableView: NSTableView? {
        firstSuperview(for: NSTableView.self)
    }
    
    var tableStyleObserver: NSKeyValueObservation? = nil
    
    func observeTableCellView() {
        guard tableCellObserver == nil else { return }
        tableCellObserver = KeyValueObserver(self)
        tableCellObserver?.add(\.superview, handler: { old, new in
            Swift.print("section supervie1", self.superview ?? "nil", self.tableView ?? "nil")
            if self.contentConfiguration is NSListContentConfiguration {
                self.rowView?.needsAutomaticRowHeights = true
                self.tableView?.usesAutomaticRowHeights = true
            }

            if let contentConfiguration = self.contentConfiguration as? NSListContentConfiguration, contentConfiguration.type == .automaticRow, let tableView = self.tableView, tableView.style == .automatic, contentConfiguration.tableViewStyle != tableView.effectiveStyle  {
                self.setNeedsUpdateConfiguration()
            }
            self.rowView?.observeTableRowView()
            self.setNeedsUpdateConfiguration()
        })
        
        tableCellObserver?.add(\.superview?.superview, handler: { [weak self] old, new in
            guard let self = self, let tableView = self.tableView, let contentConfiguration = self.contentConfiguration as? NSListContentConfiguration, contentConfiguration.type == .automaticRow, contentConfiguration.tableViewStyle != tableView.effectiveStyle else {
                return
            }
            self.contentConfiguration = contentConfiguration.tableViewStyle(tableView.effectiveStyle, isGroupRow: true)

            

            
            
            Swift.print(self.tableView?.style.rawValue ?? "nil", self.tableView?.effectiveStyle.rawValue ?? "nil")
            Swift.print("section superview2", new ?? "nil", self.tableView ?? "nil")
        })
    }
}
