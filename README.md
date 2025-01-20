# Advanced NSCollectionView and NSTableView

A framework for NSCollectionView, NSTableView and NSOutlineView. It provides a collection of classes and extensions, many of them being ports of missing UIKit APIs.

**Take a look at the included sample app which demonstrates most features.**

**For a full documentation take a look at the** [Online Documentation](https://swiftpackageindex.com/flocked/AdvancedCollectionTableView/documentation/).

## NSCollectionView ItemRegistration & NSTableView CellRegistration

A registration for collection view items and table cells that greatly simplifies  configurating them. A port of `UICollectionView.CellRegistration`.

```swift
struct GalleryItem {
    let title: String
    let image: NSImage
}

let tableCellRegistration = NSTableView.CellRegistration<NSTableCellView, GalleryItem> { 
    tableCell, column, row, galleryItem in
    
    tableCell.textField.stringValue = galleryItem.title
    tableCell.imageView.image = galleryItem.image
    
    // Gets called whenever the state of the item changes (e.g. on selection)
    tableCell.configurationUpdateHandler = { tableCell, state in
        // Updates the text color based on selection state.
        tableCell.textField.textColor = state.isSelected ? .controlAccentColor : .labelColor
    }
}
```

## NSContentConfiguration

Configurates styling and content for a content view. A port of UIContentConfiguration`.

`NSCollectionviewItem`, `NSTableCellView` and `NSTableRowView` provide `contentConfiguration` where you can apply them to configurate the content of the item/cell.

### NSHostingConfiguration

A content configuration suitable for hosting a hierarchy of SwiftUI views. 

With this configuration you can easily display a SwiftUI view in a collection item and table cell:

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

A content configuration for a table view cell.

![NSListContentConfiguration](https://raw.githubusercontent.com/flocked/AdvancedCollectionTableView/main/Sources/AdvancedCollectionTableView/Documentation/AdvancedCollectionTableView.docc/Resources/NSListContentConfiguration.png)

 ```swift
 var content = tableCell.defaultContentConfiguration()

 // Configure content
 content.text = "Text"
 content.secondaryText = #"SecondaryText\\nImage displays a system image named "photo""#
 content.image = NSImage(systemSymbolName: "photo")

 // Customize appearance
 content.textProperties.font = .body
 content.imageProperties.tintColor = .controlAccentColor

 tableCell.contentConfiguration = content
 ```
 
 ### NSItemContentconfiguration
 
A content configuration for a collection view item.

![NSItemContentconfiguration](https://raw.githubusercontent.com/flocked/AdvancedCollectionTableView/main/Sources/AdvancedCollectionTableView/Documentation/AdvancedCollectionTableView.docc/Resources/NSItemContentConfiguration.png)

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

## NSCollectionView Reconfigure Items

Updates the data for the items without reloading and replacing them. It provides much better performance compared to reloading items. A port of `UICollectionView.reconfigureItems`.

Any item that has been registered via  `ItemRegistration`, or by class using `register(_ itemClass: NSCollectionViewItem.Type)`, can be recofigurated.

```swift
collectionView.reconfigureItems(at: indexPaths)
```

 ## NSTableView Cell Registration by Class

Apple only allows registering `NSTableCellView` using `NSNib`. This framework lets you register table cell class.

```swift
tableView.register(NSTableCellView.self)

let dequeuedTableCell = tableView.makeView(for: NSTableCellView.self)
```

## NSCollectionView- & NSTableViewDiffableDataSource Item Deletion

Enable deleting items via backspace via `DeletingHandlers`:

```swift
// Allow every item to be deleted
dataSource.deletingHandlers.canDelete = { items in return true }

// Update the backing store from the final item identifiers
dataSource.deletingHandlers.didDelete = { [weak self] items, transaction in
    guard let self = self else { return }
         
    self.backingStore = transaction.finalSnapshot.itemIdentifiers
}
```
 
## NSDiffableDataSourceSnapshot Apply Options

 Apple's `apply(_:animatingDifferences:completion:)` provides two options for applying snapshots to a diffable data source depending on `animatingDifferences`:
 - `true` applies a diff of the old and new state and animates updates in the UI.
 - `false`  is equivalent to calling `reloadData()`. It reloads every item.
 
  `NSDiffableDataSourceSnapshotApplyOption`  lets you perform a diff even without animations for much better performance compared to using Apple's `reloadData()`.

It also provides additional options:
- **usingReloadData**: All items get reloaded.
- **animated(withDuration: CGFloat)**: Changes get applied animated.
- **nonAnimated**: Changes get applied immediatly.

 ```swift
diffableDataSource.apply(mySnapshot, .withoutAnimation)

diffableDataSource.apply(mySnapshot, .animated(3.0))
 ```
 
## CollectionViewDiffableDataSource

An extended `NSCollectionViewDiffableDataSource that provides:
 - Reordering items by dragging them via `reorderingHandlers`
 - Deleting items via backspace via `deletingHandlers`
 - Quicklook previews of items via spacebar by providing items conforming to `QuicklookPreviewable`
 - Right click menu provider for selected items
 
 **It includes handlers for:**
 - Prefetching items
 - Selecting items
 - Highlighting items
 - Displaying items
 - Hovering items with the mouse.
 - Pinching of the collection view
  
 ## TableViewDiffableDataSource
 
 Simliar to `CollectionViewDiffableDataSource`.
 
  ## OutlineViewDiffableDataSource
  
  A diffable data source for `NSOutlineView` simliar to `CollectionViewDiffableDataSource`.
 
 Example usage:
 
 ```swift
    let dataSource = OutlineViewDiffableDataSource<String>(outlineView: outlineView, cellRegistration: cellRegistration)
    
    var snapshot = OutlineViewDiffableDataSourceSnapshot<String>()
    let rootItems ["Root 1", "Root 2", "Root 3", "Root 4", "Root 5"]
    snapshot.append(rootItems)
    
    rootItems.forEach { rootItem in
        let childItems = (1...5).map { "\(rootItem).\($0)" }
        snapshot.append(childItems, to: rootItem)
        childItems.forEach { childItem in
            let grandchildItems = (1...5).map { "\(childItem).\($0)" }
            snapshot.append(grandchildItems, to: childItem)
        }
    }
    dataSource.apply(snapshot, .withoutAnimation)
 ```

## Quicklook for NSTableView & NSCollectionView

NSCollectionView/NSTableView `isQuicklookPreviewable` enables quicklook of selected items/cells via spacebar.

There are several ways to provide quicklook previews (see [FZQuicklook](https://github.com/flocked/FZQuicklook) for an extended documentation): 

- Diffable collection view & table view datasource with an `ItemIdentifierType` conforming to `QuicklookPreviewable`:

```swift
struct GalleryItem: QuicklookPreviewable {
    let title: String
    let imageURL: URL
    
    // The file url for the quicklook preview.
    let previewItemURL: URL? {
        return imageURL
    }
    
    // The quicklook preview title displayed on the top of the Quicklook panel.
    let previewItemTitle: String? {
        return title
    }
}

let itemRegistration = NSCollectionView.ItemRegistration<NSCollectionViewItem, GalleryItem>() { collectionItem, indexPath, galleryItem in 
    // configurate …
}
  
collectionView.dataSource = NSCollectionViewDiffableDataSource<Section, GalleryItem>(collectionView: collectionView, itemRegistration: ItemRegistration)

collectionView.isQuicklookPreviewable = true
collectionView.quicklookSelectedItems()
```

- `NSCollectionViewItems`s & `NSTableCellView`s `quicklookPreview: QuicklookPreviewable?` property:

```swift
collectionViewItem.quicklookPreview = URL(fileURLWithPath: "someFile.png")
```

## Installation

Add `AdvancedCollectionTableView` to your app's `Package.swift` file, or selecting `File -> Add Package Dependencies in Xcode:

```swift
.package(url: "https://github.com/flocked/AdvancedCollectionTableView")
```

If you clone the repo, you can run the sample app, which demonstrates most of the API`s.
