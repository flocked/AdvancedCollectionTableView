# Configurating Collection Items

Configurate the content and background of a collection view item.

## Overview

The content and background of a `NSCollectionViewItem` can be configurated by providing a `NSContentConfiguration` to an item's ``AppKit/NSCollectionViewItem/contentConfiguration`` and ``AppKit/NSCollectionViewItem/backgroundConfiguration``.

## Item content configuration

- ``NSItemContentConfiguration``
- ``NSItemContentView``

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

- ``AppKit/NSCollectionViewItem/configurationState``
- ``AppKit/NSCollectionViewItem/configurationUpdateHandler-swift.property``
- ``NSItemConfigurationState``
- ``AppKit/NSCollectionViewItem/ConfigurationUpdateHandler-swift.typealias``

``NSItemConfigurationState`` provides the current state of an item (e.g. `isSelected` or `highlightState). It can be accessed via an item's ``AppKit/NSCollectionViewItem/configurationState``.


To handle updates of an item’s state, provide a handler to ``AppKit/NSCollectionViewItem/configurationUpdateHandler-swift.property``.

```swift
var content = NSItemContentConfiguration()
content.text = "Mozart"
content.image = NSImage(named: "Mozart")

collectionViewItem.contentConfiguration = content

collectionViewItem.configurationUpdateHandler = { item, state in
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
