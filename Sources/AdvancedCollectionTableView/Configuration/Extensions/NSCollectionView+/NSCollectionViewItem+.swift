//
//  NSCollectionView.swift
//  NSListContentConfiguration
//
//  Created by Florian Za    nd on 01.11.22.
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
    public var backgroundConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "_backgroundConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "_backgroundConfiguration", object: self)
            if (newValue != nil) {
                self.observeCollectionItem()
                self.configurateBackgroundView()
            }
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
    public func  defaultBackgroundConfiguration() -> NSBackgroundConfiguration {
        var configuration = NSBackgroundConfiguration()
        configuration.cornerRadius = 4.0
        configuration.color = .unemphasizedSelectedContentBackgroundColor
        return configuration
    }
    
    /**
     A Boolean value that determines whether the item automatically updates its background configuration when its state changes.
     
     When this value is true, the item automatically calls  `updated(for:)` on its ``backgroundConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.
     
     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the background configuration, disable automatic updates by setting this property to false.
     */
    @objc open var automaticallyUpdatesBackgroundConfiguration: Bool {
        get { getAssociatedValue(key: "_automaticallyUpdatesBackgroundConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "_automaticallyUpdatesBackgroundConfiguration", object: self)
        }
    }
        
    var backgroundConfigurationView: (NSView & NSContentView)?   {
        get { getAssociatedValue(key: "backgroundConfigurationView", object: self, initialValue: nil) }
        set { 
            backgroundConfigurationView?.removeFromSuperview()
            set(associatedValue: newValue, key: "backgroundConfigurationView", object: self) }
    }
    
    func configurateBackgroundView() {
        if let backgroundConfiguration = backgroundConfiguration {
            if var backgroundView = backgroundConfigurationView,  backgroundView.supports(backgroundConfiguration) {
                backgroundView.configuration = backgroundConfiguration
            } else {
                let backgroundView = backgroundConfiguration.makeContentView()
                self.view.addSubview(withConstraint: backgroundView)
                backgroundConfigurationView = backgroundView
            }
        } else {
            backgroundConfigurationView = nil
        }
    }
    
    // MARK: Managing the content
    
    /**
     The current content configuration of the item.
     
     Using a content configuration, you can set the item’s content and styling for a variety of different item states.
     
     Setting a content configuration replaces the existing `view` of the item with a new view instance from the configuration, or directly applies the configuration to the `view` if the configuration is compatible with the existing view type.
     
     The default value is `nil`. After you set a content configuration to this property, setting this property back to `nil` replaces the current view with a new, empty view.
     */
    public var contentConfiguration: NSContentConfiguration?   {
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
     
     ```swift
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
    public func  defaultContentConfiguration() -> NSItemContentConfiguration {
        return NSItemContentConfiguration()
    }
    
    /**
     A Boolean value that determines whether the item automatically updates its content configuration when its state changes.
     
     When this value is true, the item automatically calls `updated(for:)` on its ``contentConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.
     
     If you provide ``configurationUpdateHandler-swift.property`` to manually update and customize the content configuration, disable automatic updates by setting this property to false.
     */
    @objc open var automaticallyUpdatesContentConfiguration: Bool {
        get { getAssociatedValue(key: "_automaticallyUpdatesContentConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "_automaticallyUpdatesContentConfiguration", object: self)
        }
    }
    
    var contentView: NSContentView? {
        get { self.view as? NSContentView }
    }
    
    func configurateContentView() {
        if let contentConfiguration = contentConfiguration {
            if var contentView = contentView, contentView.supports(contentConfiguration) {
                contentView.configuration = contentConfiguration
            } else {
                self.cachedLayoutAttributes = nil
                let previousFrame = self.view.frame
                self.view = contentConfiguration.makeContentView()
                self.view.wantsLayer = true
                self.view.clipsToBounds = false
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
     
     To add your own custom state, see `NSConfigurationStateCustomKey`.
     */
    public var configurationState: NSItemConfigurationState {
        let state = NSItemConfigurationState(isSelected: self.isSelected, highlight: self.highlightState, isEditing: self.isEditing, isEmphasized: self.isEmphasized, isHovered: self.isHovered)
        /*
         if let listConfiguration = self.collectionView?.listConfiguration {
         state["listSelectionAppearance"] = listConfiguration.resolvedSelectionAppearance
         }
         */
        return state
    }
    
    /**
     Informs the item to update its configuration for its current state.
     
     You call this method when you need the item to update its configuration according to the current configuration state. The system calls this method automatically when the item’s ``configurationState`` changes, as well as in other circumstances that may require an update. The system might combine multiple requests into a single update.
     
     If you add custom states to the item’s configuration state, make sure to call this method every time those custom states change.
     */
    @objc open func setNeedsUpdateConfiguration() {
        self.updateConfiguration(using: self.configurationState)
    }
    
    @objc open func setNeedsAutomaticUpdateConfiguration() {
        let state = self.configurationState
        
        if automaticallyUpdatesBackgroundConfiguration, var backgroundConfiguration = self.backgroundConfiguration {
            self.backgroundConfiguration = backgroundConfiguration.updated(for: state)
            //  self.configurateBackgroundView(configuration: backgroundConfiguration.updated(for: state))
        }
        
        if automaticallyUpdatesContentConfiguration, let contentConfiguration = self.contentConfiguration {
            self.contentConfiguration = contentConfiguration.updated(for: state)
            //  self.configurateContentView(configuration: contentConfiguration.updated(for: state))
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
    public typealias ConfigurationUpdateHandler = (_ item: NSCollectionViewItem, _ state: NSItemConfigurationState) -> Void
    
    
    /**
     A block for handling updates to the item’s configuration using the current state.
     
     Set a configuration update handler to update the item’s configuration using the new state in response to a configuration state change:
     
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
     
     Setting the value of this property calls ``setNeedsUpdateConfiguration()``.
     */
   public var configurationUpdateHandler: ConfigurationUpdateHandler?  {
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
    @objc open var previousItem: NSCollectionViewItem? {
        if let indexPath = self.collectionView?.indexPath(for: self), indexPath.item - 1 >= 0 {
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            return self.collectionView?.item(at: previousIndexPath)
        }
        return nil
    }
    
    /// The next item in the collection view.
    @objc open var nextItem: NSCollectionViewItem? {
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
            self._collectionView?.setupObservation()
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
}

extension NSCollectionViewItem {
    open override func loadView() {
        self.view = NSView()
    }
}


/*
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
*/


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
 Swift.debugPrint(error)
 }
 }
 */
