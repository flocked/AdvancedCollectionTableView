# ``OutlineViewDiffableDataSource``

## Overview

## Topics

### Creating a diffable data source

- ``init(outlineView:cellRegistration:)``
- ``init(outlineView:cellRegistrations:)``
- ``init(outlineView:cellProvider:)``
- ``CellProvider``

### Creating row views

- ``rowViewProvider-swift.property``
- ``RowViewProvider-swift.typealias``
- ``applyRowViewRegistration(_:)``

### Creating group item cell views.

- ``groupItemCellProvider-swift.property``
- ``GroupItemCellProvider-swift.typealias``
- ``applyGroupItemCellRegistration(_:)``
- ``groupItemsAreCollapsable``

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
- ``snapshot(for:)``
- ``emptySnapshot()``
- ``apply(_:_:completion:)``
- ``defaultRowAnimation``

### Configurating user interaction

- ``menuProvider``
- ``rightClickHandler``

### Providing tint configurations

``tintConfigurationProvider``

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

- ``expand(_:expandChildren:)-770uz``
- ``expand(_:expandChildren:)-1v68w``
- ``collapse(_:collapseChildren:)-82w6c``
- ``collapse(_:collapseChildren:)-5f5fu``
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
