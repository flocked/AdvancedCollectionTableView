//
//  NSCollectionView.swift
//  NSListContentConfiguration
//
//  Created by Florian Za    nd on 01.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSCollectionViewItem {
    
    // MARK: Configuring the background
    
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
        get { getAssociatedValue(key: "_backgroundConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "_backgroundConfiguration", object: self)
            if (newValue != nil) {
                self.observeCollectionItem()
                
            }
            self.configurateBackgroundView()
        }
    }
    
    /**
     Retrieves a default background content configuration.
     ```
     var background = item.defaultBackgroundConfiguration()
     
     // Configure background.
     background.color = .systemGray
     background.cornerRadius = 8.0
     background.shadow = .black
     
     item.backgroundConfiguration = background
     ```
     
     - Returns:A default background content configuration.
     */
    func  defaultBackgroundConfiguration() -> NSBackgroundConfiguration {
        return NSBackgroundConfiguration()
    }
    
    /**
     A Boolean value that determines whether the item automatically updates its background configuration when its state changes.
     
     When this value is true, the item automatically calls  ``updated(for:)`` on its ``backgroundConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.
     If you override ``updateConfiguration(using:)`` to manually update and customize the background configuration, disable automatic updates by setting this property to false.
     */
    var automaticallyUpdatesBackgroundConfiguration: Bool {
        get { getAssociatedValue(key: "_automaticallyUpdatesBackgroundConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "_automaticallyUpdatesBackgroundConfiguration", object: self)
        }
    }
    
    /**
     The view that displays behind the item’s other content.
     
     Use this property to assign a custom background view to the item. The background view appears behind the content view and its frame automatically adjusts so that it fills the bounds of the item.
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-nil value for this property resets ``backgroundConfiguration`` to nil.
     */
    var backgroundView: NSView?   {
        get { getAssociatedValue(key: "_backgroundView", object: self) }
        set { set(associatedValue: newValue, key: "_backgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    /**
     The view that displays just above the background view for a selected item.
     
     You can use this view to give a selected item a custom appearance. When the item has a selected state, this view layers above the ``backgroundView`` and behind the ``contentView``.
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-nil value for this property resets ``backgroundConfiguration`` to nil.
     */
    var selectedBackgroundView: NSView? {
        get { getAssociatedValue(key: "_selectedBackgroundView", object: self) }
        set { set(associatedValue: newValue, key: "_selectedBackgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    internal var configurationBackgroundView: (NSView & NSContentView)?   {
        self.backgroundView as? (NSView & NSContentView)
    }
    
    internal func configurateBackgroundView() {
        if let backgroundConfiguration = backgroundConfiguration {
            self.selectedBackgroundView?.removeFromSuperview()
            self.selectedBackgroundView = nil
            if var backgroundView = configurationBackgroundView,  backgroundView.supports(backgroundConfiguration) {
                backgroundView.configuration = backgroundConfiguration
            } else {
                self.backgroundView?.removeFromSuperview()
                var backgroundView = backgroundConfiguration.makeContentView()
                backgroundView.configuration = backgroundConfiguration
                self.view.addSubview(withConstraint: backgroundView)
                self.backgroundView = backgroundView
            }
        } else {
            if self.isSelected {
                self.backgroundView?.removeFromSuperview()
                if let selectedBackgroundView = self.selectedBackgroundView {
                    self.view.addSubview(withConstraint: selectedBackgroundView)
                }
            } else {
                self.selectedBackgroundView?.removeFromSuperview()
                if let backgroundView = self.backgroundView {
                    self.view.addSubview(withConstraint: backgroundView)
                }
                
            }
        }
        self.orderSubviews()
    }
    
    internal func orderSubviews() {
        selectedBackgroundView?.sendToBack()
        backgroundView?.sendToBack()
    }
    
    // MARK: Managing the content
    
    /**
     The current content configuration of the item.
     
     Using a content configuration, you can set the item’s content and styling for a variety of different item states.
     Setting a content configuration replaces the existing ``contentView`` of the item with a new content view instance from the configuration, or directly applies the configuration to the existing content view if the configuration is compatible with the existing content view type.
     The default value is nil. After you set a content configuration to this property, setting this property back to nil replaces the current content view with a new, empty content view.
     */
    var contentConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "_contentConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "_contentConfiguration", object: self)
            if (newValue != nil) {
                self.observeCollectionItem()
                
            }
            self.configurateContentView()
        }
    }
    
    /**
     Retrieves a default item content configuration.
     
     The default content configuration has preconfigured default styling, but doesn’t contain any content. After you get the default configuration, you assign your content to it, customize any other properties, and assign it to the item as the current content configuration.
     
     ```
     var content = item.defaultContentConfiguration()
     
     // Configure content.
     content.text = "Favorites"
     content.image = NSImage(systemSymbolName: "star", accessibilityDescription: "star")
     
     // Customize appearance.
     content.contentProperties.tintColor = .purple
     
     item.contentConfiguration = content
     ```
     
     - Returns:A default item content configuration. The system determines default values for the configuration according to the collection view and it’s style.
     */
    func  defaultContentConfiguration() -> NSItemContentConfiguration {
        return NSItemContentConfiguration()
    }
    
    /**
     A Boolean value that determines whether the item automatically updates its content configuration when its state changes.
     
     When this value is true, the item automatically calls ``updated(for:)`` on its ``contentConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.
     If you override ``updateConfiguration(using:)`` to manually update and customize the content configuration, disable automatic updates by setting this property to false.
     */
    var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue(key: "_automaticallyUpdatesContentConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "_automaticallyUpdatesContentConfiguration", object: self)
        }
    }
    
    internal var contentView: NSContentView? {
        self.view as? NSContentView
    }
    
    internal func configurateContentView() {
        if let contentConfiguration = contentConfiguration {
            if var contentView = contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                self.cachedLayoutAttributes = nil
                let previousFrame = self.view.frame
                self.view = contentConfiguration.makeContentView()
                self.view.wantsLayer = true
                self.view.maskToBounds = false
                self.view.frame = previousFrame
                self.view.setNeedsLayout()
            }
        } else {
            self.cachedLayoutAttributes = nil
            let previousFrame = self.view.frame
            self.view = NSView()
            self.view.frame = previousFrame
        }
        self.configurateBackgroundView()
    }
    
    // MARK: Managing the state
    
    /**
     The current configuration state of the item.
     
     To add your own custom state, see ``NSConfigurationStateCustomKey``.
     */
    var configurationState: NSItemConfigurationState {
        let state = NSItemConfigurationState(isSelected: self.isSelected, isEnabled: self.isEnabled, isFocused: self.isFocused, isHovered: self.isHovered, isEditing: self.isEditing, isExpanded: false, highlight: self.highlightState, isEmphasized: self.isEmphasized)
        /*
         if let listConfiguration = self.collectionView?.listConfiguration {
         state["listSelectionAppearance"] = listConfiguration.resolvedSelectionAppearance
         }
         */
        return state
    }
    
    /**
     Informs the item to update its configuration for its current state.
     
     You call this method when you need the item to update its configuration according to the current configuration state. The system calls this method automatically when the item’s ``configurationState()`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     If you add custom states to the item’s configuration state, make sure to call this method every time those custom states change.
     */
    func setNeedsUpdateConfiguration() {
        self.updateConfiguration(using: self.configurationState)
    }
    
    internal func setNeedsAutomaticUpdateConfiguration() {
        let state = self.configurationState
        
        if automaticallyUpdatesBackgroundConfiguration, let backgroundConfiguration = self.backgroundConfiguration {
            self.backgroundConfiguration = backgroundConfiguration.updated(for: state)
        }
        
        if automaticallyUpdatesContentConfiguration, let contentConfiguration = self.contentConfiguration {
            self.contentConfiguration = contentConfiguration.updated(for: state)
        }
        
        configurationUpdateHandler?(self, state)
    }
    
    /**
     Updates the item’s configuration using the current state.
     
     Avoid calling this method directly. Instead, use ``setNeedsUpdateConfiguration()`` to request an update.
     Override this method in a subclass to update the item’s configuration using the provided state.
     */
    func updateConfiguration(using state: NSItemConfigurationState) {
        if let contentConfiguration = self.contentConfiguration {
            self.contentConfiguration = contentConfiguration.updated(for: state)
        }
        if let backgroundConfiguration = self.backgroundConfiguration {
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
    typealias ConfigurationUpdateHandler = (_ item: NSCollectionViewItem, _ state: NSItemConfigurationState) -> Void
    
    
    /**
     A block for handling updates to the item’s configuration using the current state.
     
     A configuration update handler provides an alternative approach to overriding ``updateConfiguration(using:)`` in a subclass. Set a configuration update handler to update the item’s configuration using the new state in response to a configuration state change:
     
     ```
     item.configurationUpdateHandler = { item, state in
     var content = UIListContentConfiguration.item().updated(for: state)
     content.text = "Hello world!"
     if state.isDisabled {
     content.textProperties.color = .systemGray
     }
     item.contentConfiguration = content
     }
     ```
     
     Setting the value of this property calls ``setNeedsUpdateConfiguration()``. The system calls this handler after calling ``updateConfiguration(using:)``.
     */
    var configurationUpdateHandler: ConfigurationUpdateHandler?  {
        get { getAssociatedValue(key: "_configurationUpdateHandler", object: self) }
        set {
            if(newValue != nil) {
                self.observeCollectionItem()
            }
            set(associatedValue: newValue, key: "_configurationUpdateHandler", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    internal var indexPath: IndexPath? {
        return _collectionView?.indexPath(for: self)
    }
    
    internal var layoutAttributes: NSCollectionViewLayoutAttributes? {
        if let indexPath = indexPath {
            return  collectionView?.layoutAttributesForItem(at: indexPath)
        }
        return nil
    }
    
    internal var layoutInvalidationContext: NSCollectionViewLayoutInvalidationContext? {
        guard let collectionView = collectionView, let indexPath = collectionView.indexPath(for: self) else { return nil }
        
        let context = InvalidationContext(invalidateEverything: false)
        context.invalidateItems(at: [indexPath])
        return context
    }
    
    internal func invalidateSelfSizing() {
        guard let invalidationContext = layoutInvalidationContext, let collectionView = collectionView, let collectionViewLayout = collectionView.collectionViewLayout else { return }
        
        self.view.invalidateIntrinsicContentSize()
        
        collectionViewLayout.invalidateLayout(with: invalidationContext)
        collectionView.layoutSubtreeIfNeeded()
    }
    
    internal class InvalidationContext: NSCollectionViewLayoutInvalidationContext {
        public override var invalidateEverything: Bool {
            return _invalidateEverything
        }
        
        private var _invalidateEverything: Bool
        
        public init(invalidateEverything: Bool) {
            self._invalidateEverything = invalidateEverything
        }
    }
    
    internal var isHovered: Bool {
        get { collectionView?.hoveredItem == self }
    }
    
    internal var isEnabled: Bool {
        get { getAssociatedValue(key: "_isEnabled", object: self, initialValue: false) }
        set {
            guard newValue != self.isEnabled else { return }
            set(associatedValue: newValue, key: "_isEnabled", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isFocused: Bool {
        get { getAssociatedValue(key: "_isFocused", object: self, initialValue: false) }
        set {
            guard newValue != self.isFocused else { return }
            set(associatedValue: newValue, key: "_isFocused", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isReordering: Bool {
        get { getAssociatedValue(key: "_isReordering", object: self, initialValue: false) }
        set {
            guard newValue != self.isReordering else { return }
            set(associatedValue: newValue, key: "_isReordering", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isEditing: Bool {
        get { getAssociatedValue(key: "_isEditing", object: self, initialValue: false) }
        set {
            guard newValue != self.isEditing else { return }
            set(associatedValue: newValue, key: "_isEditing", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isEmphasized: Bool {
        get { self._collectionView?.isEmphasized ?? false }
    }
    
    /// The previous item in the collection view.
    var previousItem: NSCollectionViewItem? {
        if let indexPath = self.collectionView?.indexPath(for: self), indexPath.item - 1 >= 0 {
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            return self.collectionView?.item(at: previousIndexPath)
        }
        return nil
    }
    
    /// The next item in the collection view.
    var nextItem: NSCollectionViewItem? {
        if let indexPath = self.collectionView?.indexPath(for: self), indexPath.item + 1 < (self.collectionView?.numberOfItems(inSection: indexPath.section) ?? -10) {
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            return self.collectionView?.item(at: nextIndexPath)
        }
        return nil
    }
    
    internal var itemObserver: KeyValueObserver<NSCollectionViewItem>? {
        get { getAssociatedValue(key: "_itemObserver", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "_itemObserver", object: self) }
    }
    
    internal func observeCollectionItem() {
        guard self.itemObserver == nil else { return }
        self.itemObserver = KeyValueObserver(self)
        self.itemObserver?.add(\.isSelected) { old, new in
            guard old != new else { return }
            self.setNeedsAutomaticUpdateConfiguration()
        }
        self.itemObserver?.add(\.highlightState) { old, new in
            guard old != new else { return }
            self.setNeedsAutomaticUpdateConfiguration()
        }
        
        self.itemObserver?.add(\.view.superview) { old, new in
            guard self._collectionView != nil else { return }
            // The collection view is observered to get the hovered (mouse over) collection item. It's much more performant instead of observing/installing a track area on each collection item view.
            self._collectionView?.setupObservingView()
        }
        self.setNeedsUpdateConfiguration()
    }
    
    // The `collectionView` property isn't always returning the collection view. This checks all superviews for a `NSCollectionView` object.
    internal var _collectionView: NSCollectionView? {
        self.collectionView ?? self.view.firstSuperview(for: NSCollectionView.self)
    }
    
    internal var cachedLayoutAttributes: NSCollectionViewLayoutAttributes?   {
        get { getAssociatedValue(key: "_cachedLayoutAttributes", object: self) }
        set {
            set(associatedValue: newValue, key: "_cachedLayoutAttributes", object: self)
        }
    }
    
    /*
     @objc internal func swizzled_PrepareForReuse() {
     self.isConfigurationUpdatesEnabled = false
     self.isHovered = false
     self.isEnabled = true
     self.isReordering = false
     self.isEditing = false
     self.isConfigurationUpdatesEnabled = true
     }
     
     static var didSwizzlePrepareForReuse: Bool {
     get { getAssociatedValue(key: "NSCollectionViewItem_didSwizzlePrepareForReuse", object: self, initialValue: false) }
     set { set(associatedValue: newValue, key: "NSCollectionViewItem_didSwizzlePrepareForReuse", object: self) }
     }
     static func swizzlePrepareForReuse() {
     guard didSwizzlePrepareForReuse == false else { return }
     didSwizzlePrepareForReuse = true
     do {
     _ = try Swizzle(NSCollectionViewItem.self) {
     #selector(prepareForReuse) <-> #selector(swizzled_PrepareForReuse)
     }
     } catch {
     Swift.print(error)
     }
     }
     */
}

extension NSCollectionViewItem {
    open override func loadView() {
        self.view = NSView()
    }
}
