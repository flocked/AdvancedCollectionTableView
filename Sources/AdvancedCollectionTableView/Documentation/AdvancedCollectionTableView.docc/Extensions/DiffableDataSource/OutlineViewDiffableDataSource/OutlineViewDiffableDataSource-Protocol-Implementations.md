# Protocol implementations

Access the diffable data source’s implementations of protocol methods.

## Overview

The diffable data source type conforms to `NSOutlineViewDataSource`.

## Topics

### Getting item metrics

- ``OutlineViewDiffableDataSource/outlineView(_:child:ofItem:)``
- ``OutlineViewDiffableDataSource/outlineView(_:numberOfChildrenOfItem:)``
- ``OutlineViewDiffableDataSource/outlineView(_:isItemExpandable:)``

### Reordering items

- ``OutlineViewDiffableDataSource/outlineView(_:draggingSession:willBeginAt:forItems:)``
- ``OutlineViewDiffableDataSource/outlineView(_:draggingSession:endedAt:operation:)``
- ``OutlineViewDiffableDataSource/outlineView(_:validateDrop:proposedItem:proposedChildIndex:)``
- ``OutlineViewDiffableDataSource/outlineView(_:acceptDrop:item:childIndex:)``
- ``OutlineViewDiffableDataSource/outlineView(_:pasteboardWriterForItem:)``
