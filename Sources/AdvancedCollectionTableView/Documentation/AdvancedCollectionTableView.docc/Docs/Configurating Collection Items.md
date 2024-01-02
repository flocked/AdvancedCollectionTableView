# Configurating Collection View Items

Configurate the content and background of a collection view item.

## Overview

The content and background of a `NSCollectionViewItem` can be configurated by providing a `NSContentConfiguration` to an item's ``AppKit/NSCollectionViewItem/contentConfiguration`` and ``AppKit/NSCollectionViewItem/backgroundConfiguration``.

## Item content configuration

- ``NSItemContentConfiguration``
- ``NSItemContentView``

``NSItemContentConfiguration`` is a content configuration suitable for a collection view item. It displays an image and/or view with a text and secondary text.

![An item content configuration](NSItemContentConfiguration.png)

```swift
var content = NSItemContentConfiguration()

// Configure content.
content.image = NSImage(named: "Mozart")
content.text = "Mozart"
content.secondaryText = "A genius composer"

// Customize appearance.
content.textProperties.font = .body
content.secondaryTextProperties.font = .caption1

collectionViewItem.contentConfiguration = content
```

## Managing the content

To manage the content of the item you provide a `NSContentConfiguration` to items `contentConfiguration`.

- ``AppKit/NSCollectionViewItem/contentConfiguration``
- ``AppKit/NSCollectionViewItem/automaticallyUpdatesContentConfiguration``

## Configuring the background

To configurate the background of the item you provide a `NSContentConfiguration` to items `backgroundConfiguration`.

- ``AppKit/NSCollectionViewItem/backgroundConfiguration``
- ``AppKit/NSCollectionViewItem/automaticallyUpdatesContentConfiguration``

## Managing the state

`configurationState` provides the current state of an item (e.g. `isSelected` or `highlightState).

- ``AppKit/NSCollectionViewItem/configurationState``
- ``AppKit/NSCollectionViewItem/configurationUpdateHandler-swift.property``

### Handling updates to the state

To handle updates of an item’s state, provide a handler to the items `configurationUpdateHandler`.

- ``NSItemConfigurationState``
- ``AppKit/NSCollectionViewItem/ConfigurationUpdateHandler-swift.typealias``

**Example usage of the configuration update handler:**

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
