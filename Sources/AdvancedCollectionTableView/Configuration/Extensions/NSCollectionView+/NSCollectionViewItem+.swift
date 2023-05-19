//
//  NSCollectionView.swift
//  NSListContentConfiguration
//
//  Created by Florian Za    nd on 01.11.22.
//

import AppKit
import FZExtensions
import InterposeKit

public extension NSCollectionViewItem {
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
        get { getAssociatedValue(key: "NSCollectionItem_backgroundConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "NSCollectionItem_backgroundConfiguration", object: self)
            if (newValue != nil) {
                self.collectionView?.observeWindowState()
              //  self.collectionView?.swizzleCollectionViewTrackingArea()
                self.swizzleCollectionItemIfNeeded()
            }
            self.configurateBackgroundView()
        }
    }
    
    /**
     A Boolean value that determines whether the item automatically updates its background configuration when its state changes.

     When this value is true, the item automatically calls  ``updated(for:)`` on its ``backgroundConfiguration`` when the item’s ``configurationState`` changes, and applies the updated configuration back to the item. The default value is true.
     If you override ``updateConfiguration(using:)`` to manually update and customize the background configuration, disable automatic updates by setting this property to false.
     */
    var automaticallyUpdatesBackgroundConfiguration: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_automaticallyUpdatesBackgroundConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "NSCollectionItem_automaticallyUpdatesBackgroundConfiguration", object: self)
        }
    }
    
    /**
     The view that displays behind the item’s other content.

     Use this property to assign a custom background view to the item. The background view appears behind the content view and its frame automatically adjusts so that it fills the bounds of the item.
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-nil value for this property resets ``backgroundConfiguration`` to nil.
     */
    var backgroundView: NSView?   {
        get { getAssociatedValue(key: "NSCollectionItem_backgroundView", object: self) }
        set { set(associatedValue: newValue, key: "NSCollectionItem_backgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    /**
     The view that displays just above the background view for a selected item.

     You can use this view to give a selected item a custom appearance. When the item has a selected state, this view layers above the ``backgroundView`` and behind the ``contentView``.
     A background configuration is mutually exclusive with background views, so you must use one approach or the other. Setting a non-nil value for this property resets ``backgroundConfiguration`` to nil.
     */
    var selectedBackgroundView: NSView? {
        get { getAssociatedValue(key: "NSCollectionItem_selectedBackgroundView", object: self) }
        set { set(associatedValue: newValue, key: "NSCollectionItem_selectedBackgroundView", object: self)
            self.configurateBackgroundView()
        }
    }
    
    internal var configurationBackgroundView: (NSView & NSContentView)?   {
        get { getAssociatedValue(key: "NSCollectionItem_configurationBackgroundView", object: self) }
        set {
            self.configurationBackgroundView?.removeFromSuperview()
            set(associatedValue: newValue, key: "NSCollectionItem_configurationBackgroundView", object: self)
        }
    }
    
    internal func configurateBackgroundView() {
        if let backgroundConfiguration = backgroundConfiguration {
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
            self.selectedBackgroundView?.removeFromSuperview()
            self.selectedBackgroundView = nil
            if var backgroundView = configurationBackgroundView,  backgroundView.supports(backgroundConfiguration) {
                backgroundView.configuration = backgroundConfiguration
            } else {
                configurationBackgroundView?.removeFromSuperview()
                var backgroundView = backgroundConfiguration.makeContentView()
                backgroundView.configuration = backgroundConfiguration
                configurationBackgroundView = backgroundView
                self.view.addSubview(withConstraint: backgroundView)
            }
        } else {
            configurationBackgroundView?.removeFromSuperview()
            configurationBackgroundView = nil
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
    
    /**
     The current content configuration of the item.

     Using a content configuration, you can set the item’s content and styling for a variety of different item states.
     Setting a content configuration replaces the existing ``contentView`` of the item with a new content view instance from the configuration, or directly applies the configuration to the existing content view if the configuration is compatible with the existing content view type.
     The default value is nil. After you set a content configuration to this property, setting this property back to nil replaces the current content view with a new, empty content view.
     */
    var contentConfiguration: NSContentConfiguration?   {
        get { getAssociatedValue(key: "NSCollectionItem_contentConfiguration", object: self) }
        set {
            set(associatedValue: newValue, key: "NSCollectionItem_contentConfiguration", object: self)
            if (newValue != nil) {
                self.collectionView?.observeWindowState()
                self.collectionView?.installTrackingArea()
            //    self.collectionView?.swizzleCollectionViewTrackingArea()
                self.swizzleCollectionItemIfNeeded()
            }
            self.configurateContentView()
        }
    }
    
    /**
     Retrieves a default content configuration for the item’s style.
     
     The default content configuration has preconfigured default styling, but doesn’t contain any content. After you get the default configuration, you assign your content to it, customize any other properties, and assign it to the item as the current content configuration.
     
     ```
     var content = item.defaultContentConfiguration()

     // Configure content.
     content.text = "Favorites"
     content.image = NSImage(systemSymbolName: "star", accessibilityDescription: "star")

     // Customize appearance.
     content.imageProperties.tintColor = .purple

     citemell.contentConfiguration = content
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
        get { getAssociatedValue(key: "NSCollectionItem_automaticallyUpdatesContentConfiguration", object: self, initialValue: true) }
        set { set(associatedValue: newValue, key: "NSCollectionItem_automaticallyUpdatesContentConfiguration", object: self)
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
                self.view = contentConfiguration.makeContentView()
                self.view.wantsLayer = true
                self.didSwizzleCollectionItemView = false
                self.swizzleCollectionItemViewIfNeeded()
            }
        } else {
            self.cachedLayoutAttributes = nil
            self.view = NSView()
            self.didSwizzleCollectionItemView = false
            self.swizzleCollectionItemViewIfNeeded()
        }
        self.configurateBackgroundView()
    }
        
    /**
     The current configuration state of the item.
     
     To add your own custom state, see ``NSConfigurationStateCustomKey``.
     */
    var configurationState: NSItemConfigurationState {
        self.collectionView?.observeWindowState()
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
        if self.automaticConfigurationUpdateIsEnabled {
            let state = self.configurationState
            
            if automaticallyUpdatesBackgroundConfiguration, let backgroundConfiguration = self.backgroundConfiguration {
                self.backgroundConfiguration = backgroundConfiguration.updated(for: state)
            }
            
            if automaticallyUpdatesContentConfiguration, let contentConfiguration = self.contentConfiguration {
                self.contentConfiguration = contentConfiguration.updated(for: state)
            }
            
            configurationUpdateHandler?(self, state)
        }
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
        get { getAssociatedValue(key: "NSCollectionItem_configurationUpdateHandler", object: self) }
        set {
            set(associatedValue: newValue, key: "NSCollectionItem_configurationUpdateHandler", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
                
    func sizeThatFits(_ size: CGSize) -> CGSize {
        if let contentView = self.contentView {
            return contentView.sizeThatFits(size)
        }
        return self.sizeThatFits(size)
    }
    
    var fittingSize: CGSize {
        return self.view.fittingSize
    }
    
    func sizeToFit() {
        self.view.frame.size = fittingSize
    }
    
    func sizeToFit(_ size: CGSize) {
        self.view.frame.size = sizeThatFits(size)
    }
    
    internal var indexPath: IndexPath? {
        return collectionView?.indexPath(for: self)
    }
    
    internal var layoutAttributes: NSCollectionViewLayoutAttributes? {
        if let indexPath = indexPath {
            return  collectionView?.layoutAttributesForItem(at: indexPath)
        }
        return nil
    }
    
    var layoutInvalidationContext: NSCollectionViewLayoutInvalidationContext? {
        guard let collectionView = collectionView, let indexPath = collectionView.indexPath(for: self) else { return nil }
                
        let context = InvalidationContext(invalidateEverything: false)
        context.invalidateItems(at: [indexPath])
        return context
    }
    
    func invalidateSelfSizing() {
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
        get { getAssociatedValue(key: "NSCollectionItem_isHovered", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionItem_isHovered", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
   internal var isEnabled: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_isEnabled", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionItem_isEnabled", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isFocused: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_isFocused", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionItem_isFocused", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isReordering: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_isReordering", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionItem_isReordering", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
   internal var isEditing: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_isEditing", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionItem_isEditing", object: self)
            self.setNeedsAutomaticUpdateConfiguration()
        }
    }
    
    internal var isEmphasized: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_isEmphasized", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSCollectionItem_isEmphasized", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
    
    var previousItem: NSCollectionViewItem? {
        if let indexPath = self.collectionView?.indexPath(for: self), indexPath.item - 1 >= 0 {
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            return self.collectionView?.item(at: previousIndexPath)
        }
        return nil
    }
    
    var nextItem: NSCollectionViewItem? {
        if let indexPath = self.collectionView?.indexPath(for: self), indexPath.item + 1 < (self.collectionView?.numberOfItems(inSection: indexPath.section) ?? -10) {
            let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            return self.collectionView?.item(at: nextIndexPath)
        }
        return nil
    }
    
    internal var cachedLayoutAttributes: NSCollectionViewLayoutAttributes?   {
        get { getAssociatedValue(key: "_cachedLayoutAttributes", object: self) }
        set {
            set(associatedValue: newValue, key: "_cachedLayoutAttributes", object: self)
        }
    }
            
     internal var didSwizzleCollectionItem: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_didSwizzle", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSCollectionItem_didSwizzle", object: self) }
    }
        

    @objc internal func swizzleCollectionItemIfNeeded(_ shouldSwizzle: Bool = true) {
        if (didSwizzleCollectionItem == false) {
            didSwizzleCollectionItem = true
            do {
                let hooks = [
                    try  self.hook(#selector(NSCollectionViewItem.viewDidLoad),
                                           methodSignature: (@convention(c) (AnyObject, Selector) -> ()).self,
                                           hookSignature: (@convention(block) (AnyObject) -> ()).self) {
                    store in { (object) in
                        store.original(object, store.selector)
                        self.swizzled_viewDidLayout()
                    }
                },
                    try  self.hook(#selector(NSCollectionViewItem.prepareForReuse),
                                           methodSignature: (@convention(c) (AnyObject, Selector) -> ()).self,
                                           hookSignature: (@convention(block) (AnyObject) -> ()).self) {
                    store in { (object) in
                        self.swizzled_PrepareForReuse()
                        store.original(object, store.selector)
                    }
                },
                    try  self.hook(#selector(NSCollectionViewItem.apply(_:)),
                                           methodSignature: (@convention(c) (AnyObject, Selector, NSCollectionViewLayoutAttributes) -> ()).self,
                                           hookSignature: (@convention(block) (AnyObject, NSCollectionViewLayoutAttributes) -> ()).self) {
                    store in { (object, layoutAttributes) in
                        self.swizzled_apply(layoutAttributes)
                        store.original(object, store.selector, layoutAttributes)
                    }
                },
                    try  self.hook(#selector(NSCollectionViewItem.preferredLayoutAttributesFitting(_:)),
                                           methodSignature: (@convention(c) (AnyObject, Selector, NSCollectionViewLayoutAttributes) -> (NSCollectionViewLayoutAttributes)).self,
                                           hookSignature: (@convention(block) (AnyObject, NSCollectionViewLayoutAttributes) -> (NSCollectionViewLayoutAttributes)).self) {
                    store in { (object, layoutAttributes) in
                        if (self.backgroundConfiguration != nil || self.contentConfiguration != nil) {
                            return self.swizzled_preferredLayoutAttributesFitting(layoutAttributes) } else {
                               return store.original(object, store.selector, layoutAttributes)
                            }
                    }
                },
                    try  self.hook(#selector(setter: isSelected),
                                           methodSignature: (@convention(c) (AnyObject, Selector, Bool) -> ()).self,
                                           hookSignature: (@convention(block) (AnyObject, Bool) -> ()).self) {
                    store in { (object, isSelected) in
                        if self.isSelected != isSelected, (self.collectionView?.isSelectable ?? true) {
                                store.original(object, store.selector, isSelected)
                                self.configurateBackgroundView()
                                self.setNeedsAutomaticUpdateConfiguration()
                        }
                    }
                },
                    try  self.hook(#selector(setter: highlightState),
                                   methodSignature: (@convention(c) (AnyObject, Selector, NSCollectionViewItem.HighlightState) -> ()).self,
                                           hookSignature: (@convention(block) (AnyObject, NSCollectionViewItem.HighlightState) -> ()).self) {
                    store in { (object, highlightState) in
                         store.original(object, store.selector, highlightState)
                        self.setNeedsAutomaticUpdateConfiguration()
                    }
                },
                    ]
                try hooks.forEach({ _ = try (shouldSwizzle) ? $0.apply() : $0.revert() })
            } catch {
                Swift.print(error)
            }
        }
    }
    
    internal var didSwizzleCollectionItemView: Bool {
       get { getAssociatedValue(key: "NSCollectionItem_didSwizzleView", object: self, initialValue: false) }
       set {  set(associatedValue: newValue, key: "NSCollectionItem_didSwizzleView", object: self) }
   }
    
    @objc internal func swizzleCollectionItemViewIfNeeded(_ shouldSwizzle: Bool = true) {
        if (didSwizzleCollectionItemView == false) {
            didSwizzleCollectionItemView = true
            do {
                let hooks = [
                        try  self.view.hook(#selector(NSView.viewDidMoveToSuperview),
                                       methodSignature: (@convention(c) (AnyObject, Selector) -> ()).self,
                                       hookSignature: (@convention(block) (AnyObject) -> ()).self) {
                                           store in { (object) in
                                               Swift.print("viewDidMoveToSuperview")
                                               
                                               if let collectionView = self.view.firstSuperview(for: NSCollectionView.self) {
                                                   Swift.print("viewDidMoveToSuperview collectionView", collectionView)
                                                   collectionView.observeWindowState()
                                                   collectionView.installTrackingArea()
                                                   
                                         //         collectionView.swizzleCollectionViewTrackingArea()
                                               }
                                               /*
                                               self.collectionView?.observeWindowState()
                                               self.collectionView?.installTrackingArea()
                                               self.collectionView?.swizzleCollectionViewTrackingArea()
                                               */
                                               store.original(object, store.selector)
                                           }
                                       },
                    ]
                try hooks.forEach({ _ = try (shouldSwizzle) ? $0.apply() : $0.revert() })
            } catch {
                Swift.print(error)
            }
        }
    }
    
    @objc var swizzled_isSelected: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_isSelected", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSCollectionItem_isSelected", object: self) }
    }
    
    internal var automaticConfigurationUpdateIsEnabled: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_automaticConfigurationUpdateIsEnabled", object: self, initialValue: true) }
        set {  set(associatedValue: newValue, key: "NSCollectionItem_automaticConfigurationUpdateIsEnabled", object: self) }
    }
            
    @objc internal func swizzled_PrepareForReuse() {
        self.automaticConfigurationUpdateIsEnabled = false
        self.isHovered = false
        self.isEnabled = true
        self.isReordering = false
        self.isEditing = false
        self.isEmphasized = self.collectionView?.isEmphasized ?? false
        self.automaticConfigurationUpdateIsEnabled = true
    }
    
    @objc internal func swizzled_apply(_ layoutAttributes: NSCollectionViewLayoutAttributes) {
        self.cachedLayoutAttributes = layoutAttributes
    }
    
    @objc internal func swizzled_preferredLayoutAttributesFitting(_ layoutAttributes: NSCollectionViewLayoutAttributes) -> NSCollectionViewLayoutAttributes {
            let width = layoutAttributes.size.width
            var fittingSize = self.sizeThatFits(CGSize(width: width, height: .infinity))
            fittingSize.width = width
            layoutAttributes.size = fittingSize
            return layoutAttributes
        /*
         let width = layoutAttributes.size.width
         let modifiedAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
         Swift.print("modi", layoutAttributes.size, modifiedAttributes.size)
         var fittingSize = self.sizeThatFits(CGSize(width: width, height: .infinity))
         fittingSize.width = width
         modifiedAttributes.frame.size = fittingSize
         return modifiedAttributes
         */
    }
    
    @objc internal func swizzled_viewDidLayout() {
        switch collectionView?.selfSizingInvalidation {
        case .enabled:
            if let cachedLayoutAttributes = cachedLayoutAttributes {
                if (self.view.frame != cachedLayoutAttributes.frame) {
                    Swift.print("Not the same. InvalidateSelfSizing")
                    invalidateSelfSizing()
                }
            }
        case .enabledIncludingConstraints:
            Swift.print("")
        default:
            break
        }
    }
    
     override var view: NSView {
         get {
             if (self.nibName != nil) {
                 return super.view
             } else {
                 if (self.isViewLoaded == false) {
                     if (self.overrides(#selector(NSCollectionViewItem.loadView))) {
                         self.loadView()
                     }
                     if (self.isViewLoaded == false) {
                         let newView = NSView()
                         super.view = newView
                     }
                 }
                 return super.view
             }
         }
        set {
            super.view = newValue
        }
    }
}
