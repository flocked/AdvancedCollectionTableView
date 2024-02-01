# Protocol implementations

Access the diffable data source’s implementations of protocol methods.

## Overview

The diffable data source type conforms to `NSTableViewDataSource`.

## Topics

### Getting item metrics

- ``TableViewDiffableDataSource/numberOfRows(in:)``

### Reordering items

- ``TableViewDiffableDataSource/tableView(_:pasteboardWriterForRow:)``
- ``TableViewDiffableDataSource/tableView(_:validateDrop:proposedRow:proposedDropOperation:)``
- ``TableViewDiffableDataSource/tableView(_:draggingSession:willBeginAt:forRowIndexes:)``
- ``TableViewDiffableDataSource/tableView(_:acceptDrop:row:dropOperation:)``
- ``TableViewDiffableDataSource/tableView(_:draggingSession:endedAt:operation:)``
