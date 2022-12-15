//
//  NSCollectionView+Register.swift
//  
//
//  Created by Florian Zand on 02.09.22.
//

import AppKit

public extension NSCollectionView {
    /**
     Registers a class for use in creating new collection view items.
     
     Prior to calling the dequeueReusableCell(withReuseIdentifier:for:) method of the collection view, you must use this method or the register(_:forItemWithIdentifier:) method to tell the collection view how to create a new cell of the given type. If a cell of the specified type is not currently in a reuse queue, the collection view uses the provided information to create a new cell object automatically.
     If you previously registered a class or nib file with the same reuse identifier, the class you specify in the cellClass parameter replaces the old entry. You may specify nil for cellClass if you want to unregister the class from the specified reuse identifier.
     
     - Parameters:
       - itemClass: The class of a item that you want to use in the collection view.
    */
    func register<Item: NSCollectionViewItem>(_ itemClass: Item.Type) {
        let identifier = NSUserInterfaceItemIdentifier(String(describing: itemClass.self))
        self.register(itemClass.self, forItemWithIdentifier: identifier)
    }
    
    /**
     Registers a nib file for use in creating new collection view items.
     
     Prior to calling the dequeueReusableCell(withReuseIdentifier:for:) method of the collection view, you must use this method or the register(_:forItemWithIdentifier:) method to tell the collection view how to create a new cell of the given type. If a cell of the specified type is not currently in a reuse queue, the collection view uses the provided information to create a new cell object automatically.
     If you previously registered a class or nib file with the same reuse identifier, the class you specify in the cellClass parameter replaces the old entry. You may specify nil for cellClass if you want to unregister the class from the specified reuse identifier.

     - Parameters:
        - itemClass: The class of a item that you want to use in the collection view.
        - nib: The nib object containing the item object. The nib file must contain only one top-level object and that object must be of the type NSCollectionViewItem.
    */
    func register<Item: NSCollectionViewItem>(_ item: Item.Type, nib: NSNib) {
        let identifier = NSUserInterfaceItemIdentifier(String(describing: Item.self))
        self.register(nib, forItemWithIdentifier: identifier)
    }
    
    /**
     Dequeues a reusable item object located by its type.

     Call this method from your data source object when asked to provide a new item for the collection view. This method dequeues an existing item if one is available or creates a new one based on the class or nib file you previously registered.
     
     
     - Important: You must register a class or nib file using the *register(_:)*, *register(_:nib:)* or *register(_:forItemWithIdentifier:)* method before calling this method.
     If you registered a class for the specified identifier and a new item must be created, this method initializes the item by calling its init(frame:) method. For nib-based items, this method loads the item object from the provided nib file. If an existing item was available for reuse, this method calls the item’s prepareForReuse() method instead.
     
     - Parameters:
        - itemClass: The class of a item that you want to use in the collection view.
        - indexPath: The index path specifying the location of the item. The data source receives this information when it is asked for the item and should just pass it along. This method uses the index path to perform additional configuration based on the item’s position in the collection view.
     
     - Returns: A valid item object.
    */
    func makeItem<Item: NSCollectionViewItem>(_ itemClass: Item.Type, for indexPath: IndexPath) -> Item {
        let identifier = NSUserInterfaceItemIdentifier(String(describing: Item.self))
        return self.makeItem(Item.self, withIdentifier: identifier, for: indexPath)
    }
    
    /**
     Dequeues a reusable item object located by its type.

     Call this method from your data source object when asked to provide a new item for the collection view. This method dequeues an existing item if one is available or creates a new one based on the class or nib file you previously registered.
     
     
     - Important: You must register a class or nib file using the *register(_:)*, *register(_:nib:)* or *register(_:forItemWithIdentifier:)* method before calling this method.
     If you registered a class for the specified identifier and a new item must be created, this method initializes the item by calling its init(frame:) method. For nib-based items, this method loads the item object from the provided nib file. If an existing item was available for reuse, this method calls the item’s prepareForReuse() method instead.
     
     - Parameters:
        - itemClass: The class of a item that you want to use in the collection view.
        - indexPath: The index path specifying the location of the item. The data source receives this information when it is asked for the item and should just pass it along. This method uses the index path to perform additional configuration based on the item’s position in the collection view.
     
     - Returns: A valid item object.
    */
    func makeItem<Item: NSCollectionViewItem>(for indexPath: IndexPath) -> Item {
        let identifier = NSUserInterfaceItemIdentifier(String(describing: Item.self))
        return self.makeItem(Item.self, withIdentifier: identifier, for: indexPath)
    }
    
    internal func makeItem<Item: NSCollectionViewItem>(_ ty: Item.Type, withIdentifier identifier: NSUserInterfaceItemIdentifier, for indexPath: IndexPath) -> Item {
        if let item = self.item(at: indexPath) as? Item {
            return item
        }
        let item = self.makeItem(withIdentifier: identifier, for: indexPath)
        return item as! Item
    }
    
    func register<S>(_ viewClass: S.Type, forSupplementaryViewOfKind kind: NSCollectionView.SupplementaryElementKind) where S: (NSView & NSCollectionViewElement) {
        let identifier = NSUserInterfaceItemIdentifier(String(describing: S.self) + kind)
        self.register(S.self, forSupplementaryViewOfKind: kind, withIdentifier: identifier)
    }
    
    func makeSupplementaryView<S>(ofKind elementKind: NSCollectionView.SupplementaryElementKind, _ viewClass: S.Type, for indexPath: IndexPath) -> S where S: (NSView & NSCollectionViewElement) {
        let identifier = NSUserInterfaceItemIdentifier(String(describing: S.self) + elementKind)
        return self.makeSupplementaryView(ofKind: elementKind, withIdentifier: identifier, for: indexPath)
    }
    
    internal func makeSupplementaryView<S>(ofKind elementKind: NSCollectionView.SupplementaryElementKind, withIdentifier identifier: NSUserInterfaceItemIdentifier, for indexPath: IndexPath) -> S where S: (NSView & NSCollectionViewElement) {
        let view = self.makeSupplementaryView(ofKind: elementKind, withIdentifier: identifier, for: indexPath)
        return view as! S
    }
}
