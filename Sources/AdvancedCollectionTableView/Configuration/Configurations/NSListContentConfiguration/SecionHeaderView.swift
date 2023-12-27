//
//  File.swift
//  
//
//  Created by Florian Zand on 27.12.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

open class SectionHeaderCell: NSView {
    
    // MARK: Managing the content
    
    /**
     The current content configuration of the cell.
     
     Using a content configuration, you can set the cell’s content and styling for a variety of different cell states. You can get the default configuration using ``defaultContentConfiguration()``, assign your content to the configuration, customize any other properties, and assign it to the view as the current `contentConfiguration`.
     
     Setting a content configuration replaces the view of the cell with a new content view instance from the configuration, or directly applies the configuration to the existing view if the configuration is compatible with the existing content view type.
     
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
    open func defaultContentConfiguration() -> NSListContentConfiguration {
        return NSListContentConfiguration.automaticRow()
    }
    
    /**
     A Boolean value that determines whether the cell automatically updates its content configuration when its state changes.
     
     When this value is `true`, the cell automatically calls `updated(for:)` on its ``contentConfiguration`` when the cell’s ``configurationState`` changes, and applies the updated configuration back to the cell. The default value is `true`.
     
     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool = true {
        didSet {
            self.setNeedsUpdateConfiguration()

        }
    }
    
    /**
     Informs the cell to update its configuration for its current state.
     
     You call this method when you need the cell to update its configuration according to the current configuration state. The system calls this method automatically when the cell’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     
     If you add custom states to the cell’s configuration state, make sure to call this method every time those custom states change.
     */
    @objc open func setNeedsUpdateConfiguration() {
        self.updateConfiguration(using: NSTableRowConfigurationState())
    }
    
    /// The row of the cell.
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
        
        if isConfigurationUpdatesEnabled {
            let state = NSTableRowConfigurationState()
            if automaticallyUpdatesContentConfiguration, let contentConfiguration = self.contentConfiguration {
                self.contentConfiguration = contentConfiguration.updated(for: state)
            }
        }
    }
    
    var isConfigurationUpdatesEnabled: Bool = true
    
    /**
     Updates the cell’s configuration using the current state.
     
     Avoid calling this method directly. Instead, use setNeedsUpdateConfiguration() to request an update.
     Override this method in a subclass to update the cell’s configuration using the provided state.
     */
    open func updateConfiguration(using state: NSTableRowConfigurationState) {
        if let contentConfiguration = self.contentConfiguration {
            self.contentConfiguration = contentConfiguration.updated(for: state)
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
    
    var tableCellObserver: KeyValueObserver<SectionHeaderCell>? = nil
    
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
        tableCellObserver?.add(\.superview, handler: {old, new in
            Swift.print("SectionHeaderCell", self.superview ?? "nil", self.tableView ?? "nil")
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
        
        tableCellObserver?.add(\.superview?.superview, handler: {old, new in
            guard old != new, let tableView = new as? NSTableView, var configuration = self.contentConfiguration as? NSListContentConfiguration, configuration.type == .automaticRow else { return }
            Swift.print("SectionHeaderCell superview1", tableView.style.rawValue, new ?? "nil")
            self.tableStyleObserver = tableView.observeChanges(for: \.style, handler: { old, style in
                guard old != style else { return }
                Swift.print("observeChanges", style)
                configuration = configuration.tableViewStyle(style, isGroupRow: true)
                self.contentConfiguration = configuration
            })
            configuration = configuration.tableViewStyle(tableView.style, isGroupRow: true)
            self.contentConfiguration = configuration
        })
    }
}
