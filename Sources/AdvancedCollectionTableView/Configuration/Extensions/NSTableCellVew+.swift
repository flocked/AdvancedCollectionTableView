//
//  NSTableCellVew+.swift
//  Coll
//
//  Created by Florian Zand on 14.11.22.
//

import AppKit
import FZExtensions

@available(macOS 12.0, *)
public extension NSTableCellView {
    var rowView: NSTableRowView? {
       return self.firstSuperview(for: NSTableRowView.self)
    }
    
    var tableView: NSTableView? {
        self.firstSuperview(for: NSTableView.self)
    }
    
    var contentView: NSView?   {
        get { getAssociatedValue(key: "_contentView", object: self) }
        set {
            if let newValue = newValue {
                if (newValue != self.contentView) {
                    self.contentView?.removeFromSuperview()
                    self.addSubview(withConstraint: newValue)
                }
            } else {
                self.contentView?.removeFromSuperview()
            }
            set(associatedValue: newValue, key: "_contentView", object: self)
        }
    }
    
    /**
     The current content configuration of the item.

     Using a content configuration, you can set the item’s content and styling for a variety of different item states.
     Setting a content configuration replaces the existing contentView of the item with a new content view instance from the configuration, or directly applies the configuration to the existing content view if the configuration is compatible with the existing content view type.
     The default value is nil. After you set a content configuration to this property, setting this property back to nil replaces the current content view with a new, empty content view.
     */
    var contentConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "_contentConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "_contentConfiguration", object: self)
            if (contentConfiguration != nil) {
                Self.swizzle()
            }
            self.configurateContentView()
        }
    }
    
    /**
     Retrieves a default content configuration for the cell’s style.
     
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
        return NSTableCellContentConfiguration()
    }
    
    /**
     A Boolean value that determines whether the cell automatically updates its content configuration when its state changes.

     When this value is true, the cell automatically calls updated(for:) on its contentConfiguration when the cell’s configurationState changes, and applies the updated configuration back to the cell. The default value is true.
     If you override updateConfiguration(using:) to manually update and customize the content configuration, disable automatic updates by setting this property to false.
     */
    var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue(key: "_automaticallyUpdatesContentConfiguration", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "_automaticallyUpdatesContentConfiguration", object: self)
        }
    }
    
    internal func configurateContentView() {
        if let contentConfiguration = contentConfiguration {
            if  var contentView = self.contentView as? NSContentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                let contentView = contentConfiguration.makeContentView()
                self.contentView = contentView
            }
        } else {
            self.contentView?.removeFromSuperview()
        }
    }
    
    /**
     The current configuration state of the cell.

     To add your own custom state, see NSConfigurationStateCustomKey.
     */
    var configurationState: NSTableCellConfigurationState {
        let state = NSTableCellConfigurationState(isSelected: self.rowView?.isSelected ?? false, isSelectable: self.isSelectable, isDisabled: self.isDisabled, isFocused: self.isFocused, isHovered: self.isHovered, isEditing: self.isEditing, isExpanded: false, isEmphasized: self.isEmphasized)
        return state
    }
    
    /**
     Informs the cell to update its configuration for its current state.

     You call this method when you need the cell to update its configuration according to the current configuration state. The system calls this method automatically when the cell’s configurationState changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     If you add custom states to the cell’s configuration state, make sure to call this method every time those custom states change.
     */
    func setNeedsUpdateConfiguration() {
        self.updateConfiguration(using: self.configurationState)
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

     A configuration update handler provides an alternative approach to overriding updateConfiguration(using:) in a subclass. Set a configuration update handler to update the cell’s configuration using the new state in response to a configuration state change:
     
     ```
     cell.configurationUpdateHandler = { cell, state in
         var content = NSTableCellContentConfiguration.default().updated(for: state)
         content.text = "Hello world!"
         if state.isDisabled {
             content.textProperties.color = .systemGray
         }
         cell.contentConfiguration = content
     }
     ```
     
     Setting the value of this property calls setNeedsUpdateConfiguration(). The system calls this handler after calling updateConfiguration(using:).
     */
    var configurationUpdateHandler: ConfigurationUpdateHandler?  {
        get { getAssociatedValue(key: "_configurationUpdateHandler", object: self) }
        set {
            set(associatedValue: newValue, key: "_configurationUpdateHandler", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    internal var isHovered: Bool {
        get { getAssociatedValue(key: "_isHovered", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isHovered", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
   internal var isDisabled: Bool {
        get { getAssociatedValue(key: "_isDisabled", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isDisabled", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    internal var isFocused: Bool {
        get { getAssociatedValue(key: "_isFocused", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isFocused", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    internal var isReordering: Bool {
        get { getAssociatedValue(key: "_isReordering", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isReordering", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
   internal var isEditing: Bool {
        get { getAssociatedValue(key: "_isEditing", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isEditing", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "_isEmphasized", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isEmphasized", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    /*
    override var isSelectable: Bool {
        get { getAssociatedValue(key: "_isSelectable", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_isSelectable", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    */
    
    static internal var didSwizzle: Bool {
        get { getAssociatedValue(key: "_didSwizzle", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "_didSwizzle", object: self)
        }
    }
    
    @objc static internal func swizzle() {
        
        if (didSwizzle == false) {
            didSwizzle = true
            /*
            Swizzle(NSCollectionViewCell.self) {
            #selector(viewDidLayout) <-> #selector(swizzled_viewDidLayout)
                #selector(apply(_:)) <-> #selector(swizzled_apply(_:))
                #selector(preferredLayoutAttributesFitting(_:)) <-> #selector(swizzled_preferredLayoutAttributesFitting(_:))
            }
             */
        }
    }
    
}
