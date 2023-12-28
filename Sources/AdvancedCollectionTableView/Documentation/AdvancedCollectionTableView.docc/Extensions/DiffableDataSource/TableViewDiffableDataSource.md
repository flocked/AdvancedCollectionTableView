# ``TableViewDiffableDataSource``

## Overview

## Topics

### Creating a diffable data source

- ``init(tableView:cellProvider:)``
- ``init(tableView:cellRegistrations:)``
- ``init(tableView:cellRegistration:)``
- ``CellProvider``

### Creating row views

- ``rowViewProvider-swift.property``
- ``RowViewProvider-swift.typealias``
- ``applyRowViewRegistration(_:)``

### Creating section header views

- ``sectionHeaderViewProvider-swift.property``
- ``SectionHeaderViewProvider-swift.typealias``
- ``applySectionHeaderViewRegistration(_:)``

### Identifying items

- ``items``
- ``item(forRow:)``
- ``row(for:)-3ouhk``
- ``item(at:)``
- ``selectedItems``
- ``scrollToItem(_:scrollPosition:)``
- ``selectItems(_:byExtendingSelection:)``
- ``selectItems(in:byExtendingSelection:)``
- ``deselectItems(_:)``
- ``deselectItems(in:)``

### Identifying sections

- ``sections``
- ``section(forRow:)``
- ``row(for:)-3rckc``
- ``scrollToSection(_:scrollPosition:)``

### Updating data

- ``snapshot()``
- ``apply(_:_:completion:)``
- ``defaultRowAnimation``

### Configurating user interaction

- ``allowsDeleting``
- ``allowsReordering``
- ``menuProvider``
- ``rowActionProvider``

### Handlers

- ``columnHandlers-swift.property``
- ``deletionHandlers-swift.property``
- ``dragDropHandlers-swift.property``
- ``hoverHandlers-swift.property``
- ``reorderingHandlers-swift.property``
- ``selectionHandlers-swift.property``
- ``ColumnHandlers-swift.struct``
- ``DeletionHandlers-swift.struct``
- ``DragDropHandlers-swift.struct``
- ``HoverHandlers-swift.struct``
- ``ReorderingHandlers-swift.struct``
- ``SelectionHandlers-swift.struct``

### Data source requirements

- ``numberOfRows(in:)``
- ``tableView(_:acceptDrop:row:dropOperation:)``
- ``tableView(_:draggingSession:endedAt:operation:)``
- ``tableView(_:draggingSession:willBeginAt:forRowIndexes:)``
- ``tableView(_:pasteboardWriterForRow:)``
- ``tableView(_:validateDrop:proposedRow:proposedDropOperation:)``
