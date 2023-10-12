# ``AdvanceCollectionViewDiffableDataSource``

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

### Configurating
- ``allowsDeleting``
- ``allowsReordering``
- ``prefetchHandlers-swift.property``
- ``PrefetchHandlers-swift.struct``
- ``selectionHandlers-swift.property``
- ``SelectionHandlers-swift.struct``
- ``highlightHandlers-swift.property``
- ``HighlightHandlers-swift.struct``
- ``deletionHandlers-swift.property``
- ``DeletionHandlers-swift.struct``
- ``reorderingHandlers-swift.property``
- ``ReorderingHandlers-swift.struct``
- ``hoverHandlers-swift.property``
- ``HoverHandlers-swift.struct``
- ``displayHandlers-swift.property``
- ``DisplayHandlers-swift.struct``
- ``dragdropHandlers-swift.property``
- ``DragdropHandlers-swift.struct``
- ``menuProvider``
- ``pinchHandler``

### Updating data
- ``snapshot()``
- ``apply(_:_:completion:)``

### Data source requirements
- ``collectionView(_:itemForRepresentedObjectAt:)``
- ``collectionView(_:viewForSupplementaryElementOfKind:at:)``
- ``collectionView(_:numberOfItemsInSection:)``
- ``numberOfSections(in:)``
