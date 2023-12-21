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

### Creating section header views
- ``sectionHeaderViewProvider-swift.property``
- ``SectionHeaderViewProvider-swift.typealias``

### Identifying items
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
- ``section(forRow:)``
- ``row(for:)-3rckc``
- ``scrollToSection(_:scrollPosition:)``

### Updating data
- ``snapshot()``
- ``apply(_:_:completion:)``

### Configurating
- ``allowsDeleting``
- ``allowsReordering``
- ``defaultRowAnimation``
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
- ``tableViewColumnDidMove(_:)``
- ``tableViewColumnDidResize(_:)``
- ``tableViewSelectionDidChange(_:)``
- ``tableView(_:isGroupRow:)``
- ``tableView(_:rowViewForRow:)``
- ``tableView(_:pasteboardWriterForRow:)``
- ``tableView(_:viewFor:row:)``
- ``tableView(_:selectionIndexesForProposedSelection:)``
- ``tableView(_:shouldReorderColumn:toColumn:)``
- ``tableView(_:rowActionsForRow:edge:)``

- ``numberOfRows(in:)``
- ``tableView(_:draggingSession:endedAt:operation:)``
- ``tableView(_:acceptDrop:row:dropOperation:)``
- ``tableView(_:draggingSession:willBeginAt:forRowIndexes:)``
- ``tableView(_:validateDrop:proposedRow:proposedDropOperation:)``
