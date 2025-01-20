# ``TableViewDiffableDataSource``

## Overview

## Topics

### Creating a diffable data source

- ``init(tableView:cellRegistration:)``
- ``init(tableView:cellRegistrations:)``
- ``init(tableView:cellProvider:)``
- ``CellProvider``

### Creating section header views

- ``sectionHeaderCellProvider-swift.property``
- ``SectionHeaderCellProvider-swift.typealias``
- ``applySectionHeaderRegistration(_:)``

### Creating row views

- ``rowViewProvider-swift.property``
- ``RowViewProvider-swift.typealias``
- ``applyRowViewRegistration(_:)``

### Identifying items

- ``items``
- ``selectedItems``
- ``visibleItems``
- ``item(forRow:)``
- ``row(for:)-3ouhk``
- ``item(at:)``
- ``reloadItems(_:animated:)``
- ``reconfigureItems(_:)``
- ``selectItems(_:byExtendingSelection:)``
- ``selectItems(in:byExtendingSelection:)``
- ``deselectItems(_:)``
- ``deselectItems(in:)``
- ``scrollToItem(_:)``

### Identifying sections

- ``sections``
- ``row(for:)-3rckc``
- ``scrollToSection(_:)``

### Updating data

- ``snapshot()``
- ``emptySnapshot()``
- ``apply(_:_:completion:)``
- ``defaultRowAnimation``

### Configurating user interaction

- ``menuProvider``
- ``rightClickHandler``
- ``rowActionProvider``

### Displaying empty view

- ``emptyView``
- ``emptyContentConfiguration``
- ``emptyHandler``

### Supporting reordering items

- ``reorderingHandlers-swift.property``
- ``ReorderingHandlers-swift.struct``

### Supporting deleting items

- ``deletingHandlers-swift.property``
- ``DeletingHandlers-swift.struct``

### Handling selecting items

- ``selectionHandlers-swift.property``
- ``SelectionHandlers-swift.struct``

### Handling hovering items

- ``hoverHandlers-swift.property``
- ``HoverHandlers-swift.struct``

### Handling column changes

- ``columnHandlers-swift.property``
- ``ColumnHandlers-swift.struct``

### Sorting items

- ``setSortComparator(_:forColumn:activate:)``
- ``setSortComparators(_:forColumn:activate:)``

### Previewing items

- ``isQuicklookPreviewable``
- ``quicklookItems(_:current:)``

### Managing drag interactions

- ``draggingHandlers-swift.property``
- ``DraggingHandlers-swift.struct``

### Managing drop interactions

- ``droppingHandlers-swift.property``
- ``DroppingHandlers-swift.struct``

### Supporting protocol requirements

- <doc:TableViewDiffableDataSource-Protocol-Implementations>
