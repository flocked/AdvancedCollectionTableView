# ``CollectionViewDiffableDataSource``

## Topics

### Creating a Diffable Data Source
- ``init(collectionView:itemProvider:)``
- ``init(collectionView:itemRegistration:)``
- ``ItemProvider``

### Creating Supplementary Views

- ``supplementaryViewProvider-swift.property``
- ``SupplementaryViewProvider-swift.typealias``

### Identifying elements
- ``element(for:)``
- ``indexPath(for:)``
- ``element(at:)``
- ``selectedElements``
- ``reconfigureElements(_:)``
- ``reloadElements(_:animated:)``
- ``scrollToElements(_:scrollPosition:)``

### Identifying sections
- ``section(for:)``
- ``index(for:)``
- ``scrollToSection(_:scrollPosition:)``

### Updating data
- ``snapshot()``
- ``apply(_:_:completion:)``

### Configurating

- ``allowsDeleting``
- ``allowsReordering``
- ``menuProvider``

### Handlers
- ``deletionHandlers-swift.property``
- ``displayHandlers-swift.property``
- ``dragDropHandlers-swift.property``
- ``highlightHandlers-swift.property``
- ``hoverHandlers-swift.property``
- ``reorderingHandlers-swift.property``
- ``selectionHandlers-swift.property``
- ``prefetchHandlers-swift.property``
- ``pinchHandler``
- ``DeletionHandlers-swift.struct``
- ``DisplayHandlers-swift.struct``
- ``DragdropHandlers-swift.struct``
- ``HighlightHandlers-swift.struct``
- ``HoverHandlers-swift.struct``
- ``ReorderingHandlers-swift.struct``
- ``SelectionHandlers-swift.struct``
- ``PrefetchHandlers-swift.struct``

### Data source requirements
- ``collectionView(_:itemForRepresentedObjectAt:)``
- ``collectionView(_:viewForSupplementaryElementOfKind:at:)``
- ``collectionView(_:numberOfItemsInSection:)``
- ``numberOfSections(in:)``
