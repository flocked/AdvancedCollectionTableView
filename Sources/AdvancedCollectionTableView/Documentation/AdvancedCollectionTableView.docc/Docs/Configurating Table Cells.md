# Configurating Table Cells

Configurate the content of a table view cell.

## Overview

The content of a `NSTableCellView` can be configurated by providing a `NSContentConfiguration` to a table cell's ``AppKit/NSTableCellView/contentConfiguration``.

## Topics

### Table cell content configuration

- ``NSListContentConfiguration``
- ``NSListContentView``

``NSListContentConfiguration`` is a content configuration suitable for a table row. It can display a text, secondary text, image and view.

![A list content configuration](NSListContentConfiguration.png)

```swift
var content = tableCell.defaultContentConfiguration()

// Configure content.
content.image = NSImage(systemSymbolName: "star")
content.text = "Favorites"

// Customize appearance.
content.imageProperties.tintColor = .purple

tableCell.contentConfiguration = content
```

### Managing the content

To manage the content of the cell you provide a `NSContentConfiguration` to cells `contentConfiguration`.

- ``AppKit/NSTableCellView/contentConfiguration``
- ``AppKit/NSTableCellView/defaultContentConfiguration()``
- ``AppKit/NSTableCellView/automaticallyUpdatesContentConfiguration``

### Managing the state

`configurationState` provides the current state of a table view cell (e.g. `isSelected` or `isHovered`).

- ``AppKit/NSTableCellView/configurationState``
- ``NSListConfigurationState``
- ``AppKit/NSTableCellView/setNeedsUpdateConfiguration()``
- ``AppKit/NSTableCellView/updateConfiguration(using:)``

### Handling updates to the state

To handle updates of a table view cell’s state, provide a handler to the cells  `configurationUpdateHandler`.

- ``AppKit/NSTableCellView/configurationUpdateHandler-swift.property``
- ``AppKit/NSTableCellView/ConfigurationUpdateHandler-swift.typealias``

**Example usage of the configuration update handler:**

```swift
var content = tableCell.defaultContentConfiguration()
content.image = NSImage(systemSymbolName: "star")
content.imageProperties.tintColor = .black

tableCell.contentConfiguration = content

tableCell.configurationUpdateHandler = { 
    newState in 
    if newState.isSelected {
        content.imageProperties.tintColor = .controlAccentColor
    } else {
        content.imageProperties.tintColor = .black
    }
    tableCell.contentConfiguration = content
}
```
