# Advanced NSCollectionView & NSTableView

A collection of classes and extensions for NSCollectionView and NSTableView, many of them being ports of modern UIKit.

**For a full documentation take a look at the included documentation accessible via Xcode's documentation browser.**

Take a look at the included example project which demonstrates:
- NSCollectionView `itemRegistration`
- NSTableView `cellRegistration`
- `NSItemContentConfiguration`
- `NSTableCellContentConfiguration`
- `AdvanceColllectionViewDiffableDataSource`
- NSCollectionView `reconfiguratingItems(at: _)`.

## NSCollectionView.ItemRegistration & NSTableView.CellRegistration
A port of `UICollectionView.CellRegistration`. A registration for collection view items and table cells that greatly simplifies  configurating them.
```
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
```
collectionViewItem.contentConfiguration = NSHostingConfiguration {
    HStack {
        Image(systemName: "star").foregroundStyle(.purple)
        Text("Favorites")
        Spacer()
    }
}
```
### NSTableCellContentConfiguration
A content configuration for a table cell.

![NSTableCellContentConfiguration](https://raw.githubusercontent.com/flocked/AdvancedCollectionTableView/main/Sources/AdvancedCollectionTableView/Documentation/NSTableCellContentConfiguration.png)
 ```
 var content = tableCell.defaultContentConfiguration()

 // Configure content.
 content.text = "Text"
 content.secondaryText = #"SecondaryText\\nImage displays a system image named "photo""#
 content.image = NSImage(systemSymbolName: "photo")

 // Customize appearance.
 content.imageProperties.tintColor = .controlAccentColor

 tableCell.contentConfiguration = content
 ```
 
 ### NSItemContentconfiguration
A content configuration for a collectionview item.

![NSItemContentconfiguration](https://raw.githubusercontent.com/flocked/AdvancedCollectionTableView/main/Sources/AdvancedCollectionTableView/Documentation/NSItemContentConfiguration.png)
 ```
 public var content = collectionViewItem.defaultContentConfiguration()

 // Configure content.
 content.text = "Text"
 content.secondaryText = "SecondaryText"
 content.image = NSImage(systemSymbolName: "Astronaut Cat")

 // Customize appearance.
 content.secondaryTextProperties.font = .callout

 collectionViewItem.contentConfiguration = content
 ```

## NSCollectionView reconfigureItems
Updates the data for the items without reloading them (`reloadItems(at: _)`.
```
collectionView.reconfigureItems(at: [IndexPath(item: 1, section: 1)])
```

## NSCollectionView & NSTableViewDiffableDataSource allowsDeleting
`allowsDeleting` enables deleting items and rows via backspace.
 ```
 diffableCollectionViewDataSource.allowsDeleting = true
 ```
 
## NSCollectionView & NSTableViewDiffableDataSource Apply Options
When using NSCollectionView & NSTableViewDiffableDataSource `apply(_ snapshot:, animatingDifferences: Bool)` and `animatingDifferences` is `true` the data source computes the difference between the current state and the new state in the snapshot and the differences in the UI between the current state and new state are animated. If `false` the system resets the UI to reflect the state of the data in the snapshot without computing a diff or animating the changes. Reloading the whole data source can cause huge performance looses.

The new `apply(_ snapshot:, _ option: ApplyOption)` provides an option to apply the new snapshot without animation and reloading.

 ```
 diffableDataSource.apply(mySnapshot, .withoutAnimation)
 ```
 
 It also provides an option to configurate the animation duration.
 ```
 diffableDataSource.apply(mySnapshot, .animated(3.0))
 ```
 
## AdvanceColllectionViewDiffableDataSource
An extended `NSCollectionViewDiffableDataSource that provides:

 - Reordering of items by enabling `allowsReording`and optionally providing blocks to `reorderingHandlers`.
 - Quicklooking of items via spacebar by providing elements conforming to `QuicklookPreviewable`.
 - Handlers for selection of items `selectionHandlers`.
 - Handlers for deletion of items `deletionHandlers`.
 - Handlers for items that get hovered by mouse `hoverHandlers`.
 - Providing a right click menu for selected items via `menuProvider` block.
 - Handler for pinching of the collection view via `pinchHandler`.

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
```
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
