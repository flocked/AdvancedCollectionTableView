# Registering Collection View Items

Register collection view items with ``AppKit/NSCollectionView/ItemRegistration``.

## Overview

Use an item registration to register items with your collection view and configure each item for display. You create a item registration with your item type and data item type as the registration’s generic parameters, passing in a registration handler to configure the item. In the registration handler, you specify how to configure the content and appearance of that type of item.

The following example creates a item registration for items of type `NSCollectionViewItem`. It creates a content configuration with a system default style, customizes the content and appearance of the configuration, and then assigns the configuration to the item.

```swift
let itemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, Int> { item, indexPath, number in
    
    var contentConfiguration = item.defaultContentConfiguration()
    
    contentConfiguration.text = "\(number)"
    contentConfiguration.textProperties.color = .lightGray
    
    item.contentConfiguration = contentConfiguration
}
```

After you create a item registration, you pass it in to ``AppKit/NSCollectionView/makeItem(using:for:element:)``, which you call from your data source’s item provider.

```swift
dataSource = NSCollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
    (collectionView: NSCollectionView, indexPath: IndexPath, itemIdentifier: Int) -> NSCollectionViewItem? in
    
    return collectionView.makeItem(using: itemRegistration, for: indexPath, item: itemIdentifier)
}
```
