# Advanced CollectionView & TableView

A collection of classes and extensions for NSCollectionView and NSTableView.

## ItemRegistration & CellRegistration
A port of `UICollectionView.CellRegistration`. A registration for collection view items and table cells that greatly simplifies  configurating them.     
```
let itemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, String> { item, indexPath, string in
         item.textField.stringValue = string
}
```

## ContentConfiguration
A port of UIContentConfiguration.
## Advanced DiffableCollectionDataSource

 Many of UIKit 
 
It provides ports for many of the newer UICollectionView & UITableView APIs that are missing for AppKit. Mainly:

- UIContentConfiguration and the corresponding APIs to configurating collection item and table cells / rows.
- UICollectionView.CellRegistration

A registration for collection view items that greatly simplifies configurationing items.

It ports many of the newer UIKit APIs that are m
- 


An package for MacOS that adds iOS:
- ContentConfiguration
- BackgroundConfiguration
- HostingConfiguration
- ConfigurationState

It also adds extensions to NSCollectionView, NSCollectionViewItem, NSTableView, NSTableCellView and NSTableRowView to support the configurations.


An extension to NSCollectionView that adds iOS UICollectionView:
- NSCollectionView ItemRegistration & SupplementaryRegistration

- NSTableView CellRegistration & RowRegistration

- reconfigureItems(at indexPaths: [IndexPath])

It also provides convenience functions for registering and making NSCollectionViewItems.

### Important
You can only reconfigurate items that have been previously registered via provided *ItemRegistration*, *register(_ itemClass: Item.Type)* or *register(_ itemClass: Item.Type, nib: NSNib)*.

## AdvanceColllectionViewDiffableDataSource
An extended NSCollectionViewDiffableDataSource that provides:

 - Reordering of rows by enabling `allowsReording`and optionally providing blocks to `reorderingHandlers`.
 - Deleting of rows by enabling `allowsDeleting`and optionally providing blocks to `DeletionHandlers`.
 - Quicklooking of rows via spacebar by providing elements conforming to `QuicklookPreviewable`.
 - Handlers for selection of rows `selectionHandlers`.
 - Handlers for rows that get hovered by mouse `hoverHandlers`.
 - Providing a right click menu for selected rows via `menuProvider` block.
