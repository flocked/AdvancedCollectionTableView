# ``TableViewDiffableDataSource``

## Overview

## Topics

### Creating a diffable data source

- ``init(outlineView:cellRegistration:)``
- ``init(outlineView:cellProvider:)``
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
- ``deselectItems(_:)``
- ``scrollToItem(_:)``

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

### Previewing items

- ``isQuicklookPreviewable``
- ``quicklookItems(_:current:)``

### Supporting deleting items

- ``deletingHandlers-swift.property``
- ``DeletingHandlers-swift.struct``

### Handling selecting items

- ``selectionHandlers-swift.property``
- ``SelectionHandlers-swift.struct``

### Handling expanding/collapsing items

- ``expansionHandlers-swift.property``
- ``ExpansionHandlers-swift.struct``

### Handling hovering items

- ``hoverHandlers-swift.property``
- ``HoverHandlers-swift.struct``

### Handling column changes

- ``columnHandlers-swift.property``
- ``ColumnHandlers-swift.struct``

### Supporting protocol requirements

- <doc:OutlineViewDiffableDataSource---Protocol-Implementations>
