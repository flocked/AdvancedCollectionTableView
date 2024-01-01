# ``CollectionViewDiffableDataSource``

## Topics

### Creating a diffable data source

- ``init(collectionView:itemProvider:)``
- ``init(collectionView:itemRegistration:)``
- ``ItemProvider``

### Creating supplementary views

- ``supplementaryViewProvider-swift.property``
- ``SupplementaryViewProvider-swift.typealias``

### Identifying elements

- ``elements``
- ``selectedElements``
- ``element(for:)``
- ``element(at:)``
- ``indexPath(for:)``
- ``reconfigureElements(_:)``
- ``reloadElements(_:animated:)``
- ``selectElements(_:scrollPosition:addSpacing:)``
- ``selectElements(in:scrollPosition:)``
- ``deselectElements(_:)``
- ``deselectElements(in:scrollPosition:)``
- ``scrollToElements(_:scrollPosition:)``

### Identifying sections

- ``sections``
- ``section(for:)``
- ``index(for:)``
- ``scrollToSection(_:scrollPosition:)``

### Updating data

- ``snapshot()``
- ``emptySnapshot()``
- ``apply(_:_:completion:)``

### Configurating user interaction

- ``menuProvider``
- ``pinchHandler``

### Previewing elements

- ``quicklookElements(_:current:)``

### Supporting prefetching elements

- ``prefetchHandlers-swift.property``
- ``PrefetchHandlers-swift.struct``

### Supporting reordering elements

- ``allowsReordering``
- ``reorderingHandlers-swift.property``
- ``ReorderingHandlers-swift.struct``

### Supporting deleting elements

- ``allowsDeleting``
- ``deletionHandlers-swift.property``
- ``DeletionHandlers-swift.struct``

### Supporting drag and drop

- ``dragDropHandlers-swift.property``
- ``DragDropHandlers-swift.struct``

### Handling selecting elements

- ``selectionHandlers-swift.property``
- ``SelectionHandlers-swift.struct``

### Handling displaying elements

- ``displayHandlers-swift.property``
- ``DisplayHandlers-swift.struct``

### Handling hovering elements

- ``hoverHandlers-swift.property``
- ``HoverHandlers-swift.struct``

### Handling highlighting elements

- ``highlightHandlers-swift.property``
- ``HighlightHandlers-swift.struct``

### Supporting protocol requirements

- <doc:CollectionViewDiffableDataSource---Protocol-Implementations>

