# ``CollectionViewDiffableDataSource``

## Topics

### Creating a diffable data source

- ``init(collectionView:itemProvider:)``
- ``init(collectionView:itemRegistration:)``
- ``ItemProvider``

### Creating supplementary views

- ``supplementaryViewProvider-swift.property``
- ``SupplementaryViewProvider-swift.typealias``

### Identifying items

- ``items``
- ``selectedItems``
- ``item(for:)``
- ``item(at:)``
- ``indexPath(for:)``
- ``reconfigureItems(_:)``
- ``reloadItems(_:animated:)``
- ``selectItems(_:scrollPosition:addSpacing:)``
- ``selectItems(in:scrollPosition:)``
- ``deselectItems(_:)``
- ``deselectItems(in:scrollPosition:)``
- ``scrollToItems(_:scrollPosition:)``

### Identifying sections

- ``sections``
- ``section(for:)``
- ``index(for:)``
- ``scrollToSection(_:scrollPosition:)``

### Updating data

- ``snapshot()``
- ``apply(_:_:completion:)``

### Configurating user interaction

- ``menuProvider``
- ``pinchHandler``

### Supporting prefetching

- ``prefetchHandlers-swift.property``
- ``PrefetchHandlers-swift.struct``

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
- ``DragdropHandlers-swift.struct``

### Handling item changes

- ``selectionHandlers-swift.property``
- ``SelectionHandlers-swift.struct``

- ``highlightHandlers-swift.property``
- ``HighlightHandlers-swift.struct``

- ``displayHandlers-swift.property``
- ``DisplayHandlers-swift.struct``

- ``hoverHandlers-swift.property``
- ``HoverHandlers-swift.struct``

### Supporting protocol requirements

- <doc:CollectionViewDiffableDataSource---Protocol-Implementations>

