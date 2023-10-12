# Configurating Collection View Items


## Overview

`AdvancedCollectionTableView` provides an easy way to configurate collection view items.

The content of a `NSCollectionViewItem` can be configurated by providing a `NSContentConfiguration` to an item's ``AppKit/NSCollectionViewItem/contentConfiguration``.

## Item content configuration

``NSItemContentConfiguration`` is a content configuration suitable for a collection view item. It displays content (image/view) with a text and secondary text.

![An item content configuration](NSItemContentConfiguration.png)

```swift
var content = NSItemContentConfiguration()

// Configure content.
content.image = NSImage(named: "Mozart")
content.text = "Mozart"
content.secondaryText = "A genius composer"

// Customize appearance.
content.textProperties.font = .body

collectionViewItem.contentConfiguration = content
```

- ``NSItemContentConfiguration``
- ``NSItemContentView``

## Managing the content

- ``AppKit/NSCollectionViewItem/contentConfiguration``
- ``AppKit/NSCollectionViewItem/defaultContentConfiguration()``
- ``AppKit/NSCollectionViewItem/automaticallyUpdatesContentConfiguration``

## Configuring the background

- ``AppKit/NSCollectionViewItem/backgroundConfiguration``
- ``AppKit/NSCollectionViewItem/automaticallyUpdatesContentConfiguration``
- ``AppKit/NSCollectionViewItem/backgroundView``
- ``AppKit/NSCollectionViewItem/selectedBackgroundView``

## Managing the state
``NSItemConfigurationState`` provides the current state of an item (e.g. isSelected, highlightState…). It can be accessed via an item's ``AppKit/NSCollectionViewItem/configurationState``.


To handle updates of an item’s state, provide a block to ``AppKit/NSCollectionViewItem/configurationUpdateHandler-swift.property``.

Set a configuration update handler to update the item’s configuration using the new state in response to a configuration state change.

```swift
collectionViewItem.configurationUpdateHandler = { item, state in
   var content = NSItemContentConfiguration()
   content.text = "Mozart"
   content.image = NSImage(named: "Mozart"")
   if state.isSelected {
       content.contentProperties.borderWidth = 1.0
       content.contentProperties.borderColor = .controlAccentColor
   } else {
       content.contentProperties.borderWidth = 0.0
       content.contentProperties.borderColor = nil
   }
    collectionViewItem.contentConfiguration = content
}
```

- ``AppKit/NSCollectionViewItem/configurationState``
- ``NSItemConfigurationState``
- ``AppKit/NSCollectionViewItem/setNeedsUpdateConfiguration()``
- ``AppKit/NSCollectionViewItem/updateConfiguration(using:)``
- ``AppKit/NSCollectionViewItem/configurationUpdateHandler-swift.property``
- ``AppKit/NSCollectionViewItem/ConfigurationUpdateHandler-swift.typealias``
