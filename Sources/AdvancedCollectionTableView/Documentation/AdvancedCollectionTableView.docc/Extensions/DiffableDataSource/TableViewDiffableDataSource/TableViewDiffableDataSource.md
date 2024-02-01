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
- ``reloadItems(_:animated:)``
- ``reconfigureItems(_:)``
- ``selectItems(_:byExtendingSelection:)``
- ``selectItems(in:byExtendingSelection:)``
- ``deselectItems(_:)``
- ``deselectItems(in:)``
- ``scrollToItem(_:)``

### Identifying sections

- ``sections``
- ``section(for:)``
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

### Previewing items

- ``isQuicklookPreviewable``
- ``quicklookItems(_:current:)``

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

### Supporting protocol requirements

- <doc:TableViewDiffableDataSource---Protocol-Implementations>
