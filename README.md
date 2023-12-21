# Advanced NSCollectionView & NSTableView

A collection of classes and extensions for NSCollectionView and NSTableView, many of them being ports of modern UIKit.

**For a full documentation take a look at the included documentation accessible via Xcode's documentation browser.**

Take a look at the included example project which demonstrates:
- NSCollectionView `itemRegistration`
- NSTableView `cellRegistration`
- `NSItemContentConfiguration`
- `NSListContentConfiguration`
- `CollectionViewDiffableDataSource`
- NSCollectionView `reconfiguratingItems(at: _)`.

## NSCollectionView.ItemRegistration & NSTableView.CellRegistration

A port of `UICollectionView.CellRegistration`. A registration for collection view items and table cells that greatly simplifies  configurating them.

```swift
struct GalleryItem {
    let title: String
    let image: NSImage
}

let itemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem> { 
    item, indexPath, galleryItem in

    item.textField.stringValue = galleryItem.title
    item.imageView.image = galleryItem.image
    
    // Gets called whenever the state of the item changes (e.g. on selection)
    item.configurationUpdateHandler = { item, state in
        // Updates the text color based on selection state.
        item.textField.textColor = state.isSelected ? .controlAccentColor : .labelColor
    }
}
```

## ContentConfiguration

A port of UIContentConfiguration that allows configurating NSCollectionView items and NSTableView cells via content configurations.

### NSHostingConfiguration

A content configuration suitable for hosting a hierarchy of SwiftUI views.

```swift
collectionViewItem.contentConfiguration = NSHostingConfiguration {
    HStack {
        Image(systemName: "star").foregroundStyle(.purple)
        Text("Favorites")
        Spacer()
    }
}
```
### NSListContentConfiguration

A content configuration for a table cell.

![NSListContentConfiguration](https://raw.githubusercontent.com/flocked/AdvancedCollectionTableView/main/Sources/AdvancedCollectionTableView/Documentation/Resources/NSListContentConfiguration.png)

 ```swift
 var content = tableCell.defaultContentConfiguration()

 // Configure content
 content.text = "Text"
 content.secondaryText = #"SecondaryText\\nImage displays a system image named "photo""#
 content.image = NSImage(systemSymbolName: "photo")

 // Customize appearance
 content.imageProperties.tintColor = .controlAccentColor

 tableCell.contentConfiguration = content
 ```
 
 ### NSItemContentconfiguration
 
A content configuration for a collectionview item.

![NSItemContentconfiguration](https://raw.githubusercontent.com/flocked/AdvancedCollectionTableView/main/Sources/AdvancedCollectionTableView/Documentation/Resources/NSItemContentConfiguration.png)

 ```swift
 public var content = collectionViewItem.defaultContentConfiguration()

 // Configure content
 content.text = "Text"
 content.secondaryText = "SecondaryText"
 content.image = NSImage(systemSymbolName: "Astronaut Cat")

 // Customize appearance
 content.secondaryTextProperties.font = .callout

 collectionViewItem.contentConfiguration = content
 ```

## NSCollectionView reconfigureItems

Updates the data for the items without reloading and replacing them (`reloadItems(at: _)`. For optimal performance, choose to reconfigure items instead of reloading items unless you have an explicit need to replace the existing item with a new item.

Any item that has been registered via  `ItemRegistration`, or by class using `register(_ itemClass: NSCollectionViewItem.Type)`, can be recofigurated.

```swift
collectionView.reconfigureItems(at: [IndexPath(item: 1, section: 1)])
```

## NSCollectionView & NSTableViewDiffableDataSource allowsDeleting

`allowsDeleting` enables deleting of items and rows via backspace.

 ```swift
 diffableCollectionViewDataSource.allowsDeleting = true
 ```
 
## NSDiffableDataSourceSnapshot Apply Options

When using Apple's  `apply(_ snapshot:, animatingDifferences: Bool)` to apply a snapshot to a diffable datasource, it either animates changes (animatingDifferences = true) or uses `reloadedData` (animatingDifferences = false), which reloads every items and leads to bad performance.

`NSDiffableDataSourceSnapshotApplyOptions`provides additional options:
- **usingReloadData**: All items get reloaded.
- **animated(withDuration: CGFloat)**: Changes get applied animated.
- **nonAnimated**: Changes get applied immediatly.

 ```swift
 diffableDataSource.apply(mySnapshot, .withoutAnimation)
 
  diffableDataSource.apply(mySnapshot, .animated(3.0))
 ```
 
## CollectionViewDiffableDataSource

An extended `NSCollectionViewDiffableDataSource that provides:

 - Reordering of items by enabling `allowsReordering`.
 - Deleting of items by enabling  `allowsDeleting`.
 - Quicklook of items via spacebar by providing elements conforming to `QuicklookPreviewable`.
 - A right click menu provider for selected items via `menuProvider`.

 ### Handlers
 
 - Prefetching of items via `prefetchHandlers`.
 - Reordering of items via `reorderingHandlers`.
 - Deleting of items via `deletionHandlers`.
 - Selecting of items via `selectionHandlers`.
 - Highlight state of items via `highlightHandlers`.
 - Displayed items via `displayHandlers`.
 - Items that are hovered by mouse via `hoverHandlers`.
 - Drag and drop of files from and to the collection view via `dragDropHandlers`.
 - Pinching of the collection view via `pinchHandler`.
  
 ## TableViewDiffableDataSource
 
 Simliar to CollectionViewDiffableDataSource. *Work in progress.*

## Quicklook for NSTableView & NSCollectionView

NSCollectionView/NSTableView `isQuicklookPreviewable` enables quicklook of selected items/cells via spacebar.

There are several ways to provide quicklook previews (see [FZQuicklook](https://github.com/flocked/FZQuicklook) for an extended documentation on how to provide them): 

- NSCollectionViewItems's & NSTableCellView's `var quicklookPreview: QuicklookPreviewable?`
```
collectionViewItem.quicklookPreview = URL(fileURLWithPath: "someFile.png")
```
- NSCollectionView's datasource `collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath)` & NSTableView's datasource `tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int)`
```
func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
    let galleryItem = galleryItems[indexPath.item]
    return galleryItem.fileURL
}
```
- A NSCollectionViewDiffableDataSource & NSTableViewDiffableDataSource with an ItemIdentifierType conforming to `QuicklookPreviewable`
```swift
struct GalleryItem: QuicklookPreviewable {
    let title: String
    let imageURL: URL
    
    // The file url for quicklook preview.
    let previewItemURL: URL? {
    return imageURL
    }
    
    // The quicklook preview title displayed on the top of the Quicklook panel.
    let previewItemTitle: String? {
    return title
    }
}

let itemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem>() {
    collectionViewItem, indexPath, galleryItem in 
    // configurate collectionViewItem …
}
  
collectionView.dataSource = NSCollectionViewDiffableDataSource<Section, GalleryItem>(collectionView: collectionView, itemRegistration: ItemRegistration)

collectionView.quicklookSelectedItems()
```
