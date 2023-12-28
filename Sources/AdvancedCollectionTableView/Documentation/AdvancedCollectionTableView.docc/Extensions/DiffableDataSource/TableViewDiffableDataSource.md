# ``TableViewDiffableDataSource``

## Overview

## Topics

### Creating a diffable data source

- ``init(tableView:cellRegistration:)``
- ``init(tableView:cellRegistrations:)``
- ``init(tableView:cellProvider:)``
- ``CellProvider``

### Creating section header views

- ``sectionHeaderViewProvider-swift.property``
- ``SectionHeaderViewProvider-swift.typealias``
- ``applySectionHeaderViewRegistration(_:)``

### Creating row views

- ``rowViewProvider-swift.property``
- ``RowViewProvider-swift.typealias``
- ``applyRowViewRegistration(_:)``

### Identifying items

- ``items``
- ``selectedItems``
- ``item(forRow:)``
- ``row(for:)-3ouhk``
- ``item(at:)``
- ``selectItems(_:byExtendingSelection:)``
- ``selectItems(in:byExtendingSelection:)``
- ``deselectItems(_:)``
- ``deselectItems(in:)``
- ``scrollToItem(_:scrollPosition:)``

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

- ``menuProvider``
- ``rowActionProvider``

### Supporting reordering

- ``allowsReordering``
- ``reorderingHandlers-swift.property``
- ``ReorderingHandlers-swift.struct``

### Supporting deleting

- ``allowsDeleting``
- ``deletionHandlers-swift.property``
- ``DeletionHandlers-swift.struct``

### Supporting drag and drop

- ``dragDropHandlers-swift.property``
- ``DragDropHandlers-swift.struct``

### Handling row changes

- ``selectionHandlers-swift.property``
- ``SelectionHandlers-swift.struct``
- ``hoverHandlers-swift.property``
- ``HoverHandlers-swift.struct``

### Handling column changes

- ``columnHandlers-swift.property``
- ``ColumnHandlers-swift.struct``

### Data source requirements

- ``numberOfRows(in:)``
- ``tableView(_:acceptDrop:row:dropOperation:)``
- ``tableView(_:draggingSession:endedAt:operation:)``
- ``tableView(_:draggingSession:willBeginAt:forRowIndexes:)``
- ``tableView(_:pasteboardWriterForRow:)``
- ``tableView(_:validateDrop:proposedRow:proposedDropOperation:)``
