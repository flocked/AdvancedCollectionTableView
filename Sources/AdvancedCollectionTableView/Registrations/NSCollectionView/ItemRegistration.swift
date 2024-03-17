//
//  ItemRegistration.swift
//
//
//  Created by Florian Zand on 27.04.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSCollectionView {
    /**
     A registration for the collection view’s items.

     Use a item registration to register items with your collection view and configure each item for display. You create a item registration with your item type and data item type as the registration’s generic parameters, passing in a registration handler to configure the item. In the registration handler, you specify how to configure the content and appearance of that type of item.

     The following example creates a item registration for items of type `NSCollectionViewItem`. It creates a content configuration, customizes the content and appearance of the configuration, and then assigns the configuration to the item.

     ```swift
     struct GalleryItem {
        let title: String
        let image: NSImage
     }

     let itemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem> { item, indexPath, galleryItem in
        var contentConfiguration = NSItemContentConfiguration()

        contentConfiguration.text = galleryItem.title
        contentConfiguration.image = galleryItem.image
        contentConfiguration.textProperties.font = .title1

        item.contentConfiguration = contentConfiguration

        // Gets called whenever the state of the item changes (e.g. on selection)
        item.configurationUpdateHandler = { item, state in
            // Updates the text color based on selection state.
            contentConfiguration.textProperties.color = state.isSelected ? .controlAccentColor : .labelColor
            item.contentConfiguration = contentConfiguration
        }
     }
     ```

     After you create a item registration, you pass it in to ``AppKit/NSCollectionView/makeItem(using:for:element:)``, which you call from your data source’s item provider.

     ```swift
     dataSource = NSCollectionViewDiffableDataSource<Section, GalleryItem>(collectionView: collectionView, handler: {
        collectionView, indexPath, galleryItem in
        return collectionView.makeItem(using: itemRegistration, for: indexPath, element: galleryItem)
     })
     ```

     `NSCollectionViewDiffableDataSource` provides a convenient initalizer:

     ```swift
     dataSource = NSCollectionViewDiffableDataSource(collectionView: collectionView, itemRegistration: itemRegistration)
     ```

     You don’t need to call ``AppKit/NSCollectionView/register(_:)`` or ``AppKit/NSCollectionView/register(_:nib:)``. The collection view registers your item automatically when you pass the item registration to ``AppKit/NSCollectionView/makeItem(using:for:element:)``.

     - Important: Do not create your item registration inside a `NSCollectionViewDiffableDataSource.ItemProvider` closure; doing so prevents item reuse.
     */
    struct ItemRegistration<Item, Element> where Item: NSCollectionViewItem {
        let identifier: NSUserInterfaceItemIdentifier
        let nib: NSNib?
        let handler: Handler

        // MARK: Creating an item registration

        /**
         Creates a item registration with the specified registration handler.

         - Parameter handler: The handler to configurate the item.
         */
        public init(handler: @escaping Handler) {
            self.handler = handler
            nib = nil
            identifier = .init(UUID().uuidString)
        }

        /**
         Creates a item registration with the specified registration handler and nib file.

         - Parameters:
            - nib: The nib of the item.
            - handler: The handler to configurate the item.
         */
        public init(nib: NSNib, handler: @escaping Handler) {
            self.nib = nib
            identifier = .init(UUID().uuidString)
            self.handler = handler
        }

        /// A closure that handles the item registration and configuration.
        public typealias Handler = (_ item: Item, _ indexPath: IndexPath, _ element: Element) -> Void

        func makeItem(_ collectionView: NSCollectionView, _ indexPath: IndexPath, _ element: Element) -> Item {
            if isRegistered(collectionView) == false {
                register(collectionView)
            }
            let item = collectionView.makeItem(withIdentifier: identifier, for: indexPath) as! Item
            handler(item, indexPath, element)
            return item
        }

        func isRegistered(_ collectionView: NSCollectionView) -> Bool {
            collectionView.registeredItemRegistrations.contains(identifier)
        }

        func register(_ collectionView: NSCollectionView) {
            if let nib = nib {
                collectionView.register(nib, forItemWithIdentifier: identifier)
            } else {
                collectionView.register(Item.self, forItemWithIdentifier: identifier)
            }
            collectionView.registeredItemRegistrations.append(identifier)
        }

        func unregister(_ collectionView: NSCollectionView) {
            let any: AnyClass? = nil
            collectionView.register(any, forItemWithIdentifier: identifier)
            collectionView.registeredItemRegistrations.remove(identifier)
        }
    }
}

extension NSCollectionView {
    // MARK: Creating items

    /**
     Dequeues a configured reusable item object.

     - Parameters:
        - registration: The item registration for configuring the cell object. See ``AppKit/NSCollectionView/ItemRegistration``.
        - indexPath: The index path specifying the location of the item. The data source receives this information when it is asked for the item and should just pass it along. This method uses the index path to perform additional configuration based on the item’s position in the collection view.
        - element: The element that provides data for the item.

     - Returns: A configured reusable item object.
     */
    public func makeItem<Item, Element>(using registration: ItemRegistration<Item, Element>, for indexPath: IndexPath, element: Element) -> Item where Item: NSCollectionViewItem {
        registration.makeItem(self, indexPath, element)
    }
}

private extension NSCollectionView {
    var registeredItemRegistrations: [NSUserInterfaceItemIdentifier] {
        get { getAssociatedValue("registeredItemRegistrations", initialValue: []) }
        set { setAssociatedValue(newValue, key: "registeredItemRegistrations")
        }
    }
}
