# Advanced CollectionView & TableView

An package for MacOS that adds iOS:
- ContentConfiguration
- BackgroundConfiguration
- HostingConfiguration
- ConfigurationState

It also adds extensions to NSCollectionView, NSCollectionViewItem, NSTableView, NSTableCellView and NSTableRowView to support the configurations.


An extension to NSCollectionView that adds iOS UICollectionView:
- CellRegistration
- SupplementaryRegistration
- reconfigureItems(at indexPaths: [IndexPath])

It also provides convenience functions for registering and making NSCollectionViewItems.

## Important
You can only reconfigurate items that have been previously registered via provided *ItemRegistration*, *register(_ itemClass: Item.Type)* or *register(_ itemClass: Item.Type, nib: NSNib)*.
