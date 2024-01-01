//
//  NSCollectionView+Register.swift
//  
//
//  Created by Florian Zand on 02.09.22.
//

import AppKit

extension NSCollectionView {
    /**
     Registers a class for use in creating new collection view items.
     
     To dequeues the registered item use  ``AppKit/NSCollectionView/makeItem(_:for:)``.
     
     Any item registered with this method can be reconfigurate using ``reconfigureItems(at:)``.
          
     - Parameters:
        - itemClass: The class of a item that you want to use in the collection view.
     */
    public func register<Item: NSCollectionViewItem>(_ item: Item.Type) {
        self.register(item.self, forItemWithIdentifier: .init(item))
    }
    
    /**
     Registers a nib file for use in creating new collection view items.
     
     To dequeues the registered item use ``AppKit/NSCollectionView/makeItem(_:for:)``.
     
     Any item registered with this method can be reconfigurate using ``reconfigureItems(at:)``.
     
     - Parameters:
        - itemClass: The class of a item that you want to use in the collection view.
        - nib: The nib object containing the item object. The nib file must contain only one top-level object and that object must be of the type NSCollectionViewItem.
     */
    public func register<Item: NSCollectionViewItem>(_ item: Item.Type, nib: NSNib) {
        self.register(nib, forItemWithIdentifier: .init(item))
    }
    
    /**
     Dequeues a reusable item object located by its type.
     
     Call this method from your data source object when asked to provide a new item for the collection view. This method dequeues an existing item if one is available or creates a new one based on the class or nib file you previously registered.
     
     - Important: You must register a class or nib file using ``AppKit/NSCollectionView/register(_:)`` or ``AppKit/NSCollectionView/register(_:nib:)`` before calling this method.
     
     - Parameters:
        - itemClass: The class of a item that you want to use in the collection view.
        - indexPath: The index path specifying the location of the item. The data source receives this information when it is asked for the item and should just pass it along. This method uses the index path to perform additional configuration based on the item’s position in the collection view.
     
     - Returns: A valid item object.
     */
    func makeItem<Item: NSCollectionViewItem>(_ itemClass: Item.Type, for indexPath: IndexPath) -> Item {
        return self.makeReconfigurableItem(Item.self, withIdentifier: .init(Item.self), for: indexPath)
    }
    
    /**
     Dequeues a reusable item object located by its type.
     
     Call this method from your data source object when asked to provide a new item for the collection view. This method dequeues an existing item if one is available or creates a new one based on the class or nib file you previously registered.
     
     - Important: You must register a class or nib file using ``AppKit/NSCollectionView/register(_:)`` or ``AppKit/NSCollectionView/register(_:nib:)`` before calling this method.
     
     - Parameters:
        - itemClass: The class of a item that you want to use in the collection view.
        - indexPath: The index path specifying the location of the item. The data source receives this information when it is asked for the item and should just pass it along. This method uses the index path to perform additional configuration based on the item’s position in the collection view.
     
     - Returns: A valid item object.
     */
    public func makeItem<Item: NSCollectionViewItem>(for indexPath: IndexPath) -> Item {
        return self.makeReconfigurableItem(Item.self, withIdentifier: .init(Item.self), for: indexPath)
    }
    
    func makeReconfigurableItem<Item: NSCollectionViewItem>(_ itemClass: Item.Type, withIdentifier identifier: NSUserInterfaceItemIdentifier, for indexPath: IndexPath) -> Item {
        if self.isReconfiguratingItems, let item = self.item(at: indexPath) as? Item {
            return item
        }
        let item = self.makeItem(withIdentifier: identifier, for: indexPath)
        return item as! Item
    }
}

extension NSCollectionView {
    /**
     Registers a class to use when creating new supplementary views in the collection view.
     
     Use this method to register the classes that represent the supplementary views in your collection view. When you request a view using the ``makeSupplementaryView(_:ofKind:for:)`` method, the collection view recycles an existing view with the same type and kind values or creates a new one by instantiating your class and calling the `init(frame:)` method of the resulting object.
     
     The layout object is responsible for defining the kind of supplementary views it supports and how those views are used. For example, the flow layout (`NSCollectionViewFlowLayout` class) lets you specify supplementary views to act as headers and footers for each section.
     
     Typically, you register your supplementary views when initializing your collection view interface. Although you can register new views at any time, you must not call the ``makeSupplementaryView(_:ofKind:for:)`` method until after you register the corresponding view.
     
     - Parameters:
        - viewClass: The view class to use for the supplementary view. This class must be descended from `NSView` and must conform to the `NSCollectionViewElement` protocol. Specify nil to unregister a previously registered class or nib file.
        - kind: The kind of the supplementary view. Layout objects define the kinds of supplementary views they support and are responsible for providing appropriate strings that you can pass for this parameter. This parameter must not be an empty string or nil.
     */
    public func register<SupplementaryView>(_ viewClass: SupplementaryView.Type, forSupplementaryKind kind: NSCollectionView.SupplementaryElementKind) where SupplementaryView: (NSView & NSCollectionViewElement) {
        self.register(SupplementaryView.self, forSupplementaryViewOfKind: kind, withIdentifier: .init(SupplementaryView.self))
    }
    
    /**
     Registers a class to use when creating new supplementary views in the collection view.
          
     Use this method to register nib files containing prototype supplementary views in your collection view. When you request a view using ``makeSupplementaryView(_:ofKind:for:)``, the collection view recycles an existing view with the same type and kind values or creates a new one by loading the contents of your nib file.
     
     The layout object is responsible for defining the kind of supplementary views it supports and how those views are used. For example, the flow layout (`NSCollectionViewFlowLayout` class) lets you specify supplementary views to act as headers and footers for each section.
     
     Typically, you register your supplementary views when initializing your collection view interface. Although you can register new views at any time, you must not call the ``makeSupplementaryView(_:ofKind:for:)`` method until after you register the corresponding view.
     
     - Parameters:
        - viewClass: The class of the supplementary view. This class must be descended from `NSView` and must conform to `NSCollectionViewElement`.
        - nib: The nib object containing the supplementary view’s definition. The nib file must contain exactly one `NSView` object at the top level and that view must conform to the `NSCollectionViewElement` protocol. Specify nil to unregister a previously registered class or nib file.
        - kind: The kind of the supplementary view. Layout objects define the kinds of supplementary views they support and are responsible for providing appropriate strings that you can pass for this parameter. This parameter must not be an empty string or nil.
     */
    public func register<SupplementaryView>(_ viewClass: SupplementaryView.Type, nib: NSNib, forSupplementaryKind kind: NSCollectionView.SupplementaryElementKind) where SupplementaryView: (NSView & NSCollectionViewElement) {
        self.register(nib, forSupplementaryViewOfKind: kind, withIdentifier: .init(SupplementaryView.self))
    }
    
    /**
     Creates or returns a reusable supplementary view of the specified type.
     
     This method looks for a recycled supplementary view of the specified type and returns it if one exists. If one does not exist, it creates it using one of the following techniques:
     
     If you registered the supplemtary view using ``register(_:forSupplementaryKind:)`` this method instantiates your view class and returns it. If you used ``register(_:nib:forSupplementaryKind:)``, the method loads the view from the nib file and returns it.
     
     - Parameters:
        - elementKind: The kind of supplementary view to create. This value is defined by the layout object. This parameter must not be an empty string.
        - indexPath: The index path specifying the location of the supplementary view. The data source object receives this information in its `collectionView(_:viewForSupplementaryElementOfKind:at:)` method and you should just pass it along.
     
     - Returns: The supplementary view.
     */
    public func makeSupplementaryView<SupplementaryView>(ofKind elementKind: NSCollectionView.SupplementaryElementKind, for indexPath: IndexPath) -> SupplementaryView where SupplementaryView: (NSView & NSCollectionViewElement) {
        return self.makeSupplementaryView(ofKind: elementKind, withIdentifier: .init(SupplementaryView.self), for: indexPath) as! SupplementaryView
    }
    
    /**
     Creates or returns a reusable supplementary view of the specified type.
     
     This method looks for a recycled supplementary view of the specified type and returns it if one exists. If one does not exist, it creates it using one of the following techniques:
     
     If you registered the supplemtary view using ``register(_:forSupplementaryKind:)`` this method instantiates your view class and returns it. If you used ``register(_:nib:forSupplementaryKind:)``, the method loads the view from the nib file and returns it.

     - Parameters:
        - viewClass: The class of the supplementary view. This class must be descended from `NSView` and must conform to `NSCollectionViewElement`.
        - elementKind: The kind of supplementary view to create. This value is defined by the layout object. This parameter must not be an empty string.
        - indexPath: The index path specifying the location of the supplementary view. The data source object receives this information in its `collectionView(_:viewForSupplementaryElementOfKind:at:)` method and you should just pass it along.
     
     - Returns: The supplementary view.
     */
    func makeSupplementaryView<SupplementaryView>(_ viewClass: SupplementaryView.Type, ofKind elementKind: NSCollectionView.SupplementaryElementKind, for indexPath: IndexPath) -> SupplementaryView where SupplementaryView: (NSView & NSCollectionViewElement) {
        return self.makeSupplementaryView(ofKind: elementKind, withIdentifier: .init(SupplementaryView.self), for: indexPath) as! SupplementaryView
    }
}
