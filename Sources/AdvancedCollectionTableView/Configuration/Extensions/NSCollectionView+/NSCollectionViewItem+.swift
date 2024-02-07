//
//  NSCollectionViewItem+.swift
//
//
//  Created by Florian Zand on 01.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSCollectionViewItem {
    /// Instantiates a view for the item.
    override open func loadView() {
        view = NSView()
    }
}

extension NSCollectionViewItem {
    // MARK: Configuring the background

    /**
     The current background configuration of the item.

     Using a background configuration, you can obtain system default background styling for a variety of different item states. Create a background configuration with one of the default system styles, customize the configuration to match your item’s style as necessary, and assign the configuration to this property.

     ```swift
     var backgroundConfiguration = NSBackgroundConfiguration.listPlainItem()

     // Set a nil background color to use the view's tint color.
     backgroundConfiguration.backgroundColor = nil

     item.backgroundConfiguration = backgroundConfiguration
     ```
     */
    public var backgroundConfiguration: NSContentConfiguration? {
        get { getAssociatedValue(key: "backgroundConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "backgroundConfiguration", object: self)
            observeCollectionItem()
            configurateBackgroundView()
        }
    }

    /**
     Retrieves a default background content configuration.

     ```swift
     var background = item.defaultBackgroundConfiguration()

     // Configure background.
     background.color = .systemGray
     background.cornerRadius = 8.0
     background.shadow = .black

     item.backgroundConfiguration = background
     ```

     - Returns:A default background content configuration.
     */
    public func defaultBackgroundConfiguration() -> NSBackgroundConfiguration {
        var configuration = NSBackgroundConfiguration()
        configuration.cornerRadius = 16.0
        configuration.shadow = .black(opacity: 0.4, radius: 3.0)
        configuration.color = .unemphasizedSelectedContentBackgroundColor
        return configuration
    }

    /**
     A Boolean value that determines whether the item automatically updates its background configuration when its state changes.

     When this value is true, the item automatically calls  `updated(for:)` on its ``backgroundConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.

     If you override ``updateConfiguration(using:)`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    @objc open var automaticallyUpdatesBackgroundConfiguration: Bool {
        get { getAssociatedValue(key: "automaticallyUpdatesBackgroundConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "automaticallyUpdatesBackgroundConfiguration", object: self)
        }
    }

    var backgroundView: (NSView & NSContentView)? {
        get { getAssociatedValue(key: "backgroundView", object: self, initialValue: nil) }
        set {
            backgroundView?.removeFromSuperview()
            set(associatedValue: newValue, key: "backgroundView", object: self)
        }
    }

    func configurateBackgroundView() {
        if var backgroundConfiguration = backgroundConfiguration {
            if automaticallyUpdatesBackgroundConfiguration {
                backgroundConfiguration = backgroundConfiguration.updated(for: configurationState)
            }
            if let backgroundView = backgroundView, backgroundView.supports(backgroundConfiguration) {
                backgroundView.configuration = backgroundConfiguration
            } else {
                let backgroundView = backgroundConfiguration.makeContentView()
                view.addSubview(withConstraint: backgroundView)
                self.backgroundView = backgroundView
            }
            setNeedsAutomaticUpdateConfiguration()
        } else {
            backgroundView = nil
        }
    }

    // MARK: Managing the content

    /**
     The current content configuration of the item.

     Using a content configuration, you can set the item’s content and styling for a variety of different item states.

     Setting a content configuration replaces the existing `view` of the item with a new view instance from the configuration, or directly applies the configuration to the `view` if the configuration is compatible with the existing view type.

     The default value is `nil`. After you set a content configuration to this property, setting this property back to `nil` replaces the current view with a new, empty view.
     */
    public var contentConfiguration: NSContentConfiguration? {
        get { getAssociatedValue(key: "contentConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "contentConfiguration", object: self)
            observeCollectionItem()
            configurateContentView()
        }
    }

    /**
     A Boolean value that determines whether the item automatically updates its content configuration when its state changes.

     When this value is true, the item automatically calls `updated(for:)` on its ``contentConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.

     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the content configuration, disable automatic updates by setting this property to false.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue(key: "automaticallyUpdatesContentConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "automaticallyUpdatesContentConfiguration", object: self)
        }
    }

    var contentView: NSContentView? {
        view as? NSContentView
    }

    func configurateContentView() {
        if var contentConfiguration = contentConfiguration {
            if automaticallyUpdatesContentConfiguration {
                contentConfiguration = contentConfiguration.updated(for: configurationState)
            }
            if let contentView = contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                let previousFrame = view.frame
                view = contentConfiguration.makeContentView()
                view.wantsLayer = true
                view.clipsToBounds = false
                view.frame = previousFrame
                view.setNeedsLayout()
            }
        } else {
            let previousFrame = view.frame
            view = NSView(frame: previousFrame)
        }
        configurateBackgroundView()
    }

    // MARK: Managing the state

    /**
     The current configuration state of the item.

     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    @objc open var configurationState: NSItemConfigurationState {
        let state = NSItemConfigurationState(isSelected: isSelected, highlight: highlightState, isEditing: isEditing, isEmphasized: isEmphasized, isHovered: isHovered)
        return state
    }

    /**
     Informs the item to update its configuration for its current state.

     You call this method when you need the item to update its configuration according to the current configuration state. The system calls this method automatically when the item’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.

     If you add custom states to the item’s configuration state, make sure to call this method every time those custom states change.
     */
    @objc open func setNeedsUpdateConfiguration() {
        updateConfiguration(using: configurationState)
    }

    @objc func setNeedsAutomaticUpdateConfiguration() {
        let state = configurationState
        if automaticallyUpdatesBackgroundConfiguration, let backgroundConfiguration = backgroundConfiguration, let backgroundView = backgroundView {
            backgroundView.configuration = backgroundConfiguration.updated(for: state)
        }
        if automaticallyUpdatesContentConfiguration, let contentConfiguration = contentConfiguration, let contentView = contentView {
            contentView.configuration = contentConfiguration.updated(for: state)
        }
        configurationUpdateHandler?(self, state)
    }

    /**
     Updates the item’s configuration using the current state.

     Avoid calling this method directly. Instead, use ``setNeedsUpdateConfiguration()`` to request an update.

     Override this method in a subclass to update the item’s configuration using the provided state.
     */
    @objc open func updateConfiguration(using state: NSItemConfigurationState) {
        if let contentConfiguration = contentConfiguration {
            self.contentConfiguration = contentConfiguration.updated(for: state)
        }
        if let backgroundConfiguration = backgroundConfiguration {
            self.backgroundConfiguration = backgroundConfiguration.updated(for: state)
        }
        configurationUpdateHandler?(self, state)
    }

    /**
     The type of block for handling updates to the item’s configuration using the current state.

     - Parameters:
        - item: The collection view item to configure.
        - state: The new state to use for updating the item’s configuration.
     */
    public typealias ConfigurationUpdateHandler = (_ item: NSCollectionViewItem, _ state: NSItemConfigurationState) -> Void

    /**
     A block for handling updates to the item’s configuration using the current state.

     A configuration update handler provides an alternative approach to overriding ``updateConfiguration(using:)`` in a subclass. Set a configuration update handler to update the cell’s configuration using the new state in response to a configuration state change:

     ```swift
     item.configurationUpdateHandler = { item, state in
        var content = NSItemContentConfiguration()
        content.text = "Mozart"
        content.image = NSImage(named: "Mozart"")
        if state.isSelected {
            content.contentProperties.borderWidth = 1.0
            content.contentProperties.borderColor = .controlAccentColor
        } else {
            content.contentProperties.borderWidth = 0.0
            content.contentProperties.borderColor = nil
        }
        item.contentConfiguration = content
     }
     ```

     Setting the value of this property calls ``setNeedsUpdateConfiguration()``. The system calls this handler after calling `updateConfiguration(using:)`.
     */
    @objc open var configurationUpdateHandler: ConfigurationUpdateHandler? {
        get { getAssociatedValue(key: "configurationUpdateHandler", object: self) }
        set {
            observeCollectionItem()
            set(associatedValue: newValue, key: "configurationUpdateHandler", object: self)
            setNeedsUpdateConfiguration()
        }
    }

    /**
     A Boolean value that specifies whether the item is hovered.

     A hovered item has the mouse pointer on it's view.
     */
    @objc var isHovered: Bool {
        if let collectionView = collectionView, collectionView.hoveredItem == self {
            if let view = view as? NSItemContentView {
                let location = collectionView.convert(collectionView.hoveredLocation, to: view)
                return view.checkHoverLocation(location)
            }
            return true
        }
        return false
    }

    /**
     A Boolean value that indicates whether the item is in an editing state.

     The value of this property is `true` when the text of a list or item content configuration is currently edited.
     */
    @objc var isEditing: Bool {
        (view as? EdiitingContentView)?.isEditing ?? false
    }

    /**
     A Boolean value that specifies whether the item is emphasized.

     The item is emphasized when it's window is key.
     */
    @objc var isEmphasized: Bool {
        view.window?.isKeyWindow ?? false
    }
    
    /// A Boolean value that specifies whether the collection view and it's items are focused.
    @objc var isFocused: Bool {
        _collectionView?.isFirstResponder ?? false
    }
    
    var itemObserver: KeyValueObserver<NSCollectionViewItem>? {
        get { getAssociatedValue(key: "itemObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "itemObserver", object: self) }
    }

    func observeCollectionItem() {
        if contentConfiguration != nil || backgroundConfiguration != nil || configurationUpdateHandler != nil {
            guard itemObserver == nil else { return }
            itemObserver = KeyValueObserver(self)
            itemObserver?.add(\.isSelected) { old, new in
                guard old != new else { return }
                self.setNeedsAutomaticUpdateConfiguration()
            }
            itemObserver?.add(\.highlightState) { old, new in
                guard old != new else { return }
                self.setNeedsAutomaticUpdateConfiguration()
            }
            if _collectionView?.windowHandlers.isKey == nil {
                itemObserver?.add(\.view.superview) { _, _ in
                    guard self._collectionView != nil else { return }
                    // The collection view is observered to get the hovered (mouse over) collection item. It's much more performant instead of observing/installing a track area on each collection item view.
                    self._collectionView?.setupObservation()
                }
            }
            setNeedsUpdateConfiguration()
        } else {
            itemObserver = nil
        }
    }

    // The `collectionView` property isn't always returning the collection view. This checks all superviews for a `NSCollectionView` object.
    var _collectionView: NSCollectionView? {
        collectionView ?? view.firstSuperview(for: NSCollectionView.self)
    }
}
