# Advanced CollectionView & TableView

A collection of classes and extensions for NSCollectionView and NSTableView. 

## ItemRegistration & CellRegistration
A port of UICollectionView.CellRegistration. A registration for collection view items / table view cells that greatly simplifies  configurating them.


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

## CollectionViewDiffableDataSource
An extended NSCollectionViewDiffableDataSource that adds:

