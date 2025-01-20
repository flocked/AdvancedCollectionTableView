# ``OutlineViewDiffableDataSource``

## Overview

## Topics

### Creating a diffable data source

- ``init(outlineView:cellRegistration:)``
- ``init(outlineView:cellProvider:)``
- ``CellProvider``

### Creating group row views.

- ``groupRowCellProvider-swift.property``
- ``GroupRowCellProvider-swift.typealias``
- ``applyGroupRowCellRegistration(_:)``

### Creating row views

- ``rowViewProvider-swift.property``
- ``RowViewProvider-swift.typealias``
- ``applyRowViewRegistration(_:)``

### Identifying items

- ``items``
- ``selectedItems``
- ``visibleItems``
- ``item(forRow:)``
- ``row(for:)``
- ``item(at:)``
- ``reloadItems(_:reloadChildren:animated:)``
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

### Handling expanding/collapsing items

- ``expanionHandlers-swift.property``
- ``ExpanionHandlers-swift.struct``

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

### Supporting protocol requirements

- <doc:OutlineViewDiffableDataSource-Protocol-Implementations>
