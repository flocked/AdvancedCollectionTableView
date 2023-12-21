# ``AdvanceTableViewDiffableDataSource``

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
- ``row(for:)-3tih3``
- ``item(at:)``
- ``selectedItems``
- ``scrollToItem(_:scrollPosition:)``
- ``selectItems(_:byExtendingSelection:)``
- ``selectItems(in:byExtendingSelection:)``
- ``deselectItems(_:)``
- ``deselectItems(in:)``

### Identifying sections
- ``section(forRow:)``
- ``row(for:)-8fkk``
- ``scrollToSection(_:scrollPosition:)``

### Configurating
- ``defaultRowAnimation``
- ``allowsDeleting``
- ``allowsReordering``
- ``menuProvider``
- ``rowActionProvider``
- ``selectionHandlers-swift.property``
- ``SelectionHandlers-swift.struct``
- ``reorderingHandlers-swift.property``
- ``ReorderingHandlers-swift.struct``
- ``deletionHandlers-swift.property``
- ``DeletionHandlers-swift.struct``
- ``columnHandlers-swift.property``
- ``ColumnHandlers-swift.struct``
- ``dragDropHandlers-swift.property``
- ``DragdropHandlers-swift.struct``
- ``hoverHandlers-swift.property``
- ``HoverHandlers-swift.struct``

### Updating data
- ``snapshot()``
- ``apply(_:_:completion:)``

### Data source requirements
- ``numberOfRows(in:)``
- ``tableViewColumnDidMove(_:)``
- ``tableViewColumnDidResize(_:)``
- ``tableViewSelectionDidChange(_:)``
- ``tableView(_:isGroupRow:)``
- ``tableView(_:rowViewForRow:)``
- ``tableView(_:pasteboardWriterForRow:)``
- ``tableView(_:viewFor:row:)``
- ``tableView(_:quicklookPreviewForRow:)``
- ``tableView(_:selectionIndexesForProposedSelection:)``
- ``tableView(_:shouldReorderColumn:toColumn:)``
- ``tableView(_:rowActionsForRow:edge:)``
- ``tableView(_:draggingSession:endedAt:operation:)``
- ``tableView(_:acceptDrop:row:dropOperation:)``
- ``tableView(_:draggingSession:willBeginAt:forRowIndexes:)``
- ``tableView(_:validateDrop:proposedRow:proposedDropOperation:)``
