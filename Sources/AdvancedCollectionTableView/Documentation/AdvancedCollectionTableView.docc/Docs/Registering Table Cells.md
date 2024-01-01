# Registering Table Cells

Register table view cells with ``AppKit/NSTableView/CellRegistration``.

## Overview

Use a cell registration to register table view cells with your table view and configure each cell for display. You create a cell registration with your cell type and data item type as the registration’s generic parameters, passing in a registration handler to configure the cell. In the registration handler, you specify how to configure the content and appearance of that type of cell.

The following example creates a cell registration for cells of type `NSTableCellView`. It creates a content configuration with a system default style, customizes the content and appearance of the configuration, and then assigns the configuration to the cell.

```swift
let cellRegistration = NSTableView.CellRegistration<NSTableCellView, Int> { tableCell, indexPath, number in
    
    var contentConfiguration = tableCell.defaultContentConfiguration()
    
    contentConfiguration.text = "\(number)"
    contentConfiguration.textProperties.color = .lightGray
    
    tableCell.contentConfiguration = contentConfiguration
}
```

After you create a cell registration, you pass it in to ``AppKit/NSTableView/makeCell(using:forColumn:row:item:)``, which you call from your data source’s cell provider.

```swift
dataSource = NSTableViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
    (tableView: NSTableView, column: NSTableColumn, row: Int, itemIdentifier: Int) -> NSView in
    
    return tableView.makeCell(using: cellRegistration, forColumn: column, row: row, item: itemIdentifier)
}
```
