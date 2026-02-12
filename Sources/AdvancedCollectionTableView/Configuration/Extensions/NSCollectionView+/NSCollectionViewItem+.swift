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
        get { getAssociatedValue("backgroundConfiguration") }
        set {
            setAssociatedValue(newValue, key: "backgroundConfiguration")
            setupBackgroundConfiguration(newValue)
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
        .collectionViewItem
    }

    /**
     A Boolean value that determines whether the item automatically updates its background configuration when its state changes.

     When this value is `true`, the item automatically calls  `updated(for:)` on its ``backgroundConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.

     If you override ``updateConfiguration(using:)`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    @objc open var automaticallyUpdatesBackgroundConfiguration: Bool {
        get { getAssociatedValue("automaticallyUpdatesBackgroundConfiguration") ?? true }
        set {
            guard newValue != automaticallyUpdatesBackgroundConfiguration else { return }
            setAssociatedValue(newValue, key: "automaticallyUpdatesBackgroundConfiguration")
            setupObservation()
            if newValue, let backgroundConfiguration = backgroundConfiguration, let backgroundView = backgroundView {
                backgroundView.configuration = backgroundConfiguration.updated(for: configurationState)
            }
        }
    }

    var backgroundView: (NSView & NSContentView)? {
        get { getAssociatedValue("backgroundView") }
        set {
            backgroundView?.removeFromSuperview()
            setAssociatedValue(newValue, key: "backgroundView")
        }
    }

    private func setupBackgroundConfiguration(_ backgroundConfiguration: NSContentConfiguration?) {
        setupObservation()
        if var backgroundConfiguration = backgroundConfiguration {
            if automaticallyUpdatesBackgroundConfiguration {
                backgroundConfiguration = backgroundConfiguration.updated(for: configurationState)
            }
            if let backgroundView = backgroundView, backgroundView.supports(backgroundConfiguration) {
                backgroundView.configuration = backgroundConfiguration
            } else {
                let backgroundView = backgroundConfiguration.makeContentView()
                view.addSubview(withConstraint: backgroundView)
                backgroundView.sendToBack()
                self.backgroundView = backgroundView
            }
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
        get { getAssociatedValue("contentConfiguration") }
        set {
            setAssociatedValue(newValue, key: "contentConfiguration")
            setupContentConfiguration(newValue)
        }
    }

    /**
     A Boolean value that determines whether the item automatically updates its content configuration when its state changes.

     When this value is `true`, the item automatically calls `updated(for:)` on its ``contentConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is `true.

     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the content configuration, disable automatic updates by setting this property to `false`.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue("automaticallyUpdatesContentConfiguration") ?? true }
        set {
            guard newValue != automaticallyUpdatesContentConfiguration else { return }
            setAssociatedValue(newValue, key: "automaticallyUpdatesContentConfiguration")
            setupObservation()
            if newValue, let contentConfiguration = contentConfiguration, let contentView = contentView {
                contentView.configuration = contentConfiguration.updated(for: configurationState)
            }
        }
    }

    var contentView: NSContentView? {
        view as? NSContentView
    }
    
    private func setupContentConfiguration(_ contentConfiguration: NSContentConfiguration?) {
        setupObservation()
        if var contentConfiguration = contentConfiguration {
            if automaticallyUpdatesContentConfiguration {
                contentConfiguration = contentConfiguration.updated(for: configurationState)
            }
            if let contentView = contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                replaceView(with: contentConfiguration.makeContentView())
            }
        } else {
            replaceView(with: NSView())
        }
    }
    
    private func replaceView(with newView: NSView) {
        newView.frame = view.frame
        view.superview?.replaceSubview(view, with: newView)
        view = newView
        setupBackgroundConfiguration(backgroundConfiguration)
        view.setNeedsLayout()
    }

    // MARK: Managing the state

    /**
     The current configuration state of the item.

     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    @objc open var configurationState: NSItemConfigurationState {
        let isSelected = isRightClickSelected == true ? true : isSelected
        let state = NSItemConfigurationState(isSelected: isSelected, highlight: highlightState, isEditing: isEditing, activeState: activeState, isHovered: isHovered, isDragging: isDragging, isReordering: isReordering, isDropTarget: isDropTarget, appearance: view.effectiveAppearance)
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

    func setNeedsAutomaticUpdateConfiguration() {
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
        if let contentView = contentView {
            contentView.configuration = contentView.configuration.updated(for: state)
        }
        if let backgroundView = backgroundView {
            backgroundView.configuration = backgroundView.configuration.updated(for: state)
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
        get { getAssociatedValue("configurationUpdateHandler") }
        set {
            setupObservation()
            setAssociatedValue(newValue, key: "configurationUpdateHandler")
            setNeedsUpdateConfiguration()
        }
    }
    
    /// A Boolean value that indicates whether the item is hovered by the mouse pointer.
    @objc var isHovered: Bool {
        get { getAssociatedValue("isHovered", initialValue: false) }
        set {
            guard newValue != isHovered else { return }
            setAssociatedValue(newValue, key: "isHovered")
            setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    /// A Boolean value that indicates whether the item is the target of a drop operation.
    @objc var isDropTarget: Bool {
        get { getAssociatedValue("isDropTarget", initialValue: false) }
        set {
            guard newValue != isDropTarget else { return }
            setAssociatedValue(newValue, key: "isDropTarget")
            setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    /// A Boolean value that indicates whether the item is reordering.
    @objc var isReordering: Bool {
        get { getAssociatedValue("isReordering", initialValue: false) }
        set {
            guard newValue != isReordering else { return }
            setAssociatedValue(newValue, key: "isReordering")
        }
    }
    
    var isDragging: Bool {
        get { getAssociatedValue("isDragging", initialValue: false) }
        set {
            guard newValue != isReordering else { return }
            setAssociatedValue(newValue, key: "isDragging")
        }
    }
    
    /**
     A Boolean value that indicates whether the item is in an editing state.

     The value of this property is `true` when the text of a list or item content configuration is being edited.
     */
    @objc var isEditing: Bool {
        if let editingView = view.window?.firstResponder as? EditiableView ?? (view.window?.firstResponder as? NSText)?.delegate as? EditiableView, editingView.isEditing, editingView.isDescendant(of: view) {
            return true
        }
        return false
    }

    /// A Boolean value that indicates whether the item is active (it's window is focused).
    @objc var isActive: Bool {
        view.window?.isKeyWindow ?? false
    }
    
    var isRightClickSelected: Bool {
        get { getAssociatedValue("isRightClickSelected") ?? false }
        set { 
            setAssociatedValue(newValue, key: "isRightClickSelected")
            setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    /// A Boolean value that indicates whether the item is focused.
    @objc var isFocused: Bool {
        view.isDescendantFirstResponder
    }
    
    /// A Boolean value that indicates whether the collection view is focused.
    @objc var isCollectionViewFocused: Bool {
        _collectionView?.isDescendantFirstResponder == true
    }
    
    var activeState: NSItemConfigurationState.ActiveState {
        isActive ? isCollectionViewFocused ? .focused : .active : .inactive
    }
    
    var itemObserver: KeyValueObserver<NSCollectionViewItem>? {
        get { getAssociatedValue("itemObserver") }
        set { setAssociatedValue(newValue, key: "itemObserver") }
    }

    func setupObservation() {
        if contentConfiguration != nil || backgroundConfiguration != nil || configurationUpdateHandler != nil {
            guard itemObserver == nil else { return }
            itemObserver = KeyValueObserver(self)
            itemObserver?.add(\.isSelected) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.setNeedsAutomaticUpdateConfiguration()
            }
            itemObserver?.add(\.highlightState) { [weak self] old, new in
                guard let self = self, old != new else { return }
                self.setNeedsAutomaticUpdateConfiguration()
            }
            if let collectionView = _collectionView {
                collectionView.setupObservation()
            } else {
                itemObserver?.add(\.view.superview) { [weak self] _, _ in
                    guard let self = self, let collectionView = self._collectionView else { return }
                    self.itemObserver?.remove(\.view.superview)
                    collectionView.setupObservation()
                }
            }
        } else {
            itemObserver = nil
        }
    }

    /// The `collectionView` property isn't always returning the collection view.
    var _collectionView: NSCollectionView? {
        collectionView ?? view.superview as? NSCollectionView
    }
}

fileprivate extension NSBackgroundConfiguration {
    static let collectionViewItem: Self = {
        var configuration = NSBackgroundConfiguration()
        configuration.cornerRadius = 16.0
        configuration.shadow = .black(opacity: 0.4, radius: 3.0)
        configuration.color = .unemphasizedSelectedContentBackgroundColor
        return configuration
    }()
}

/*
extension NSCollectionViewItem: NSAnimatablePropertyContainer {
    /**
     Returns a proxy object for the collection view item that can be used to initiate implied animations when changing ``contentConfiguration`` and ``backgroundConfiguration``.
     */
    public func animator() -> Self {
        NSObjectProxy(object: self).asObject()
    }
    
    public var animations: [NSAnimatablePropertyKey : Any] {
        get { [:] }
        set { }
    }
    
    public func animation(forKey key: NSAnimatablePropertyKey) -> Any? {
        nil
    }
    
    public static func defaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
        nil
    }
}
*/
