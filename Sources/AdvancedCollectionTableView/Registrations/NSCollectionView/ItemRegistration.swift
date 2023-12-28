//
//  ItemRegestration.swift
//  
//
//  Created by Florian Zand on 27.04.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSCollectionView {
    // MARK: Creating items
    /**
     Dequeues a configured reusable item object.
     
     - Parameters:
        - registration: The item registration for configuring the cell object. See ``AppKit/NSCollectionView/ItemRegistration``.
        - indexPath: The index path specifying the location of the item. The data source receives this information when it is asked for the item and should just pass it along. This method uses the index path to perform additional configuration based on the item’s position in the collection view.
        - element: The element that provides data for the item.
     
     - returns:A configured reusable item object.
     */
    func makeItem<Item, Element>(using registration: ItemRegistration<Item, Element>, for indexPath: IndexPath, element: Element) -> Item where Item: NSCollectionViewItem {
        return registration.makeItem(self, indexPath, element)
    }
}

public extension NSCollectionView {
    /**
     A registration for the collection view’s items.
     
     Use a item registration to register items with your collection view and configure each item for display. You create a item registration with your item type and data item type as the registration’s generic parameters, passing in a registration handler to configure the item. In the registration handler, you specify how to configure the content and appearance of that type of item.
     
     The following example creates a item registration for items of type `NSCollectionViewItem`. Each items textfield displays its element.
     
     ```swift
     struct GalleryItem {
     let title: String
     let image: NSImage
     }
     
     let itemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem> { item, indexPath, galleryItem in
     
     item.textField.stringValue = galleryItem.title
     item.imageView.image = galleryItem.image
     
     // Gets called whenever the state of the item changes (e.g. on selection)
     item.configurationUpdateHandler = { item, state in
     // Updates the text color based on selection state.
     item.textField.textColor = state.isSelected ? .controlAccentColor : .labelColor
     }
     ```
     
     After you create a item registration, you pass it in to ``AppKit/NSCollectionView/makeItem(using:for:element:)``, which you call from your data source’s item provider.
     
     ```swift
     dataSource = NSCollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) {
     (collectionView: NSCollectionView, indexPath: IndexPath, itemIdentifier: String) -> NSCollectionViewItem? in
     
     return collectionView.makeItem(using: itemRegistration,
     for: indexPath,
     item: itemIdentifier)
     }
     ```
     
     `NSCollectionViewDiffableDataSource` provides a convenient initalizer:
     
     ```swift
     dataSource = NSCollectionViewDiffableDataSource<Section, String>(collectionView: collectionView, itemRegistration: itemRegistration)
     ```
     
     You don’t need to call ``AppKit/NSCollectionView/register(_:)`` or ``AppKit/NSCollectionView/register(_:nib:)``. The collection view registers your item automatically when you pass the item registration to ``AppKit/NSCollectionView/makeItem(using:for:element:)``.
     
     - Important: Do not create your item registration inside a `NSCollectionViewDiffableDataSource.ItemProvider` closure; doing so prevents item reuse.
     */
    struct ItemRegistration<Item, Element> where Item: NSCollectionViewItem  {
        
        private let identifier: NSUserInterfaceItemIdentifier
        private let nib: NSNib?
        private let handler: Handler
        
        // MARK: Creating an item registration
        
        /**
         Creates a item registration with the specified registration handler.
         
         - Parameter handler: The handler to configurate the item.
         */
        public init(handler: @escaping Handler) {
            self.handler = handler
            self.nib = nil
            self.identifier = .init(Item.self)
        }
        
        /**
         Creates a item registration with the specified registration handler and nib file.
         
         - Parameters:
            - nib: The nib of the item.
            - handler: The handler to configurate the item.
         */
        public init(nib: NSNib, handler: @escaping Handler) {
            self.nib = nib
            self.identifier = .init(String(describing: Item.self) + String(describing: nib.self))
            self.handler = handler
        }
        
        /// A closure that handles the item registration and configuration.
        public typealias Handler = ((_ item: Item, _ indexPath: IndexPath, _ itemIdentifier: Element)->(Void))
        
        func makeItem(_ collectionView: NSCollectionView, _ indexPath: IndexPath, _ element: Element) -> Item {
            if isRegistered(collectionView) == false {
                self.register(for: collectionView)
            }
            let item: Item
            if collectionView.isReconfiguratingItems, let existingItem = collectionView.item(at: indexPath) as? Item {
                item = existingItem
            } else {
                item = collectionView.makeItem(withIdentifier: self.identifier, for: indexPath) as! Item
            }
            self.handler(item, indexPath, element)
            return item
        }
        
        func isRegistered(_ collectionView: NSCollectionView) -> Bool {
            collectionView.registeredItemRegistrations.contains(self.identifier)
        }
        
        func register(for collectionView: NSCollectionView) {
            if let nib = self.nib {
                collectionView.register(nib, forItemWithIdentifier: self.identifier)
            } else {
                collectionView.register(Item.self, forItemWithIdentifier: self.identifier)
            }
            collectionView.registeredItemRegistrations.append(self.identifier)
        }
        
        func unregister(for collectionView: NSCollectionView) {
            let any: AnyClass? = nil
            collectionView.register(any, forItemWithIdentifier: self.identifier)
            collectionView.registeredItemRegistrations.remove(self.identifier)
        }
    }
}

extension NSCollectionView {
    var registeredItemRegistrations: [NSUserInterfaceItemIdentifier] {
        get { getAssociatedValue(key: "_registeredItemRegistrations", object: self, initialValue: []) }
        set { set(associatedValue: newValue, key: "_registeredItemRegistrations", object: self)
        }
    }
}
