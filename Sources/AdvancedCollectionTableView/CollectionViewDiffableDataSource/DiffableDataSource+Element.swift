//
//  CollectionViewDiffableDataSource+Element.swift
//  NSHostingViewSizeInTableView
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZExtensions

extension CollectionViewDiffableDataSource {
    public var allElements: [Element] {
        return self.currentSnapshot.itemIdentifiers
    }
    
    public var selectionIndexPaths: [IndexPath] {
        return Array(self.collectionView.selectionIndexPaths).sorted()
    }
    
    public var selectedElements: [Element] {
        return self.selectionIndexPaths.compactMap({element(for: $0)})
    }
    
    public var displayingIndexPaths: [IndexPath] {
        return self.collectionView.displayingIndexPaths()
    }
    
    public var displayingElements: [Element] {
        self.displayingIndexPaths.compactMap({self.element(for: $0)})
    }
    
    public var nonSelectionIndexPaths: [IndexPath] {
        return self.collectionView.notSelectedIndexPaths.sorted()
    }
    
    public var nonSelectedElements: [Element] {
        return self.nonSelectionIndexPaths.compactMap({element(for: $0)})
    }
    
    public func indexPathsForVisibleItems() -> [IndexPath] {
        return Array(self.collectionView.indexPathsForVisibleItems())
    }
    
    public func visibleElements() -> [Element] {
        return indexPathsForVisibleItems().compactMap({element(for: $0)})
    }
    
    public func visibleItems() -> [NSCollectionViewItem] {
        return self.collectionView.visibleItems()
    }
        

    public func element(for indexPath: IndexPath) ->  Element? {
        if let itemId = self.dataSource.itemIdentifier(for: indexPath) {
            return self.currentSnapshot.itemIdentifiers[id: itemId]
        }
        return nil
    }
    
    internal func quicklookItems(for elements: [Element]) -> [QuicklookItem] {
        /*
        if let _elements = shouldStartDisplaySpotlightHandlers(self.dataSource.selectedElements) {
            var previewItems: [QuicklookItem] = []
            for _element in _elements {
                if let _elementRect = self.dataSource.frame(for: _element.element) {
                    previewItems.append(QuicklookItem(url: _element.url, frame: _elementRect))
                }
            }
        }
        */
        return []
    }
    
    public func element(at point: CGPoint) -> Element? {
        if let indexPath = self.collectionView.indexPathForItem(at: point) {
            return element(for: indexPath)
        }
        return nil
    }
    
    public func frame(for element: Element) -> CGRect? {
        if let index = indexPath(for: element)?.item {
            return self.collectionView.frameForItem(at: index)
        }
        return nil
    }
    
    public func layoutAttributes(for element: Element) -> NSCollectionViewLayoutAttributes?  {
        if let indexPath = self.indexPath(for: element) {
            return self.collectionView.layoutAttributesForItem(at: indexPath)
        }
        return nil
    }
    
    public func itemView(for element: Element) -> NSCollectionViewItem? {
        if let elementIndexPath = indexPath(for: element) {
            return self.collectionView.item(at: elementIndexPath)
        }
        return nil
    }
    
    public func indexPath(for element: Element) -> IndexPath? {
        return dataSource.indexPath(for: element.id)
    }
    
    public func indexPaths(for elements: [Element]) -> [IndexPath] {
        return elements.compactMap({indexPath(for: $0)})
    }
    
    public func indexPaths(for section: Section) -> [IndexPath] {
        let elements = self.currentSnapshot.itemIdentifiers(inSection: section)
       return self.indexPaths(for: elements)
    }
    
    public func indexPaths(for sections: [Section]) -> [IndexPath] {
        return sections.flatMap({self.indexPaths(for: $0)})
    }
    
    public func section(for element: Element) -> Section? {
        return self.currentSnapshot.sectionIdentifier(containingItem: element)
    }
    
    public func section(for indexPath: IndexPath) -> Section? {
        if (indexPath.section <= self.sections.count-1) {
            return sections[indexPath.section]
        }
        return nil
    }
    
    /*
    public func expandSection(_ section: Section) {
        section.isCollapsed = false
        self.updateCollection(.animated)
    }
    
    public func collapseSection(_ section: Section) {
        section.isCollapsed = true
        self.updateCollection(.animated)
    }
    */
    
    internal func supplementaryHeaderView(for section: Section) -> (NSView & NSCollectionViewElement)? {
        if let sectionIndex = currentSnapshot.indexOfSection(section) {
            let sectionIndexPath = IndexPath(item: 0, section: sectionIndex)
           return collectionView.supplementaryView(forElementKind: NSCollectionView.ElementKind.sectionHeader, at: sectionIndexPath)
        }
        return nil
    }
    
    public func isItemSelected(at indexPath: IndexPath) -> Bool {
        self.collectionView.selectionIndexPaths.contains(indexPath)
    }
    
    public func isItemSelected(_ element: Element) -> Bool {
        if let indexPath = indexPath(for: element) {
            return isItemSelected(at: indexPath)
        }
        return false
    }
    
    public func reconfigurateItems(for elements: [Element]) {
        let indexPaths = elements.compactMap({self.indexPath(for:$0)})
        self.reconfigurateItems(at: indexPaths)
    }
    
    public func reconfigurateItems(at indexPaths: [IndexPath]) {
        self.collectionView.reconfigurateItems(at: indexPaths)
    }
    
    public func reloadItems(at indexPaths: [IndexPath], animated: Bool = false) {
        let elements = indexPaths.compactMap({self.element(for: $0)})
        self.reloadItems(elements, animated: animated)
    }
    
    public func reloadItems(_ elements: [Element], animated: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(elements.ids)
        dataSource.apply(snapshot, animated ? .animated : nil)
    }
    
    public func reloadAllItems(complection: (() -> Void)? = nil) {
        var snapshot = snapshot()
        snapshot.reloadItems(snapshot.itemIdentifiers)
        self.applySnapshotUsingReloadData(snapshot, completion: complection)
    }
    
    
    public func selectAll() {
        self.collectionView.selectAll(nil)
    }
    
    
    public func deselectAll() {
        self.collectionView.deselectAll(nil)
    }
    
    public func selectItems(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let indexPaths = sections.flatMap({self.indexPaths(for: $0)})
        self.selectItems(at: indexPaths,  scrollPosition: scrollPosition)
    }
    
    public func deselectItems(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let indexPaths = sections.flatMap({self.indexPaths(for: $0)})
        self.collectionView.deselectItems(at: Set(indexPaths))
    }
    
    public func selectItems(at indexPaths: [IndexPath], scrollPosition: NSCollectionView.ScrollPosition) {
        self.collectionView.selectItems(at: Set(indexPaths), scrollPosition: scrollPosition)
    }
    
    public func selectElements(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition, addSpacing: CGFloat? = nil) {
        self.selectItems(at: indexPaths(for: elements), scrollPosition: scrollPosition)
    }
    
    public func deselectItems(at indexPaths: [IndexPath]) {
        self.collectionView.deselectItems(at: Set(indexPaths))
    }
    
    public func deselectElements(_ elements: [Element]) {
        self.deselectItems(at: indexPaths(for: elements))
    }
        
    public func scrollToItems(at indexPaths: [IndexPath], positioned: NSCollectionView.ScrollPosition = .centeredVertically) {
        self.collectionView.scrollToItems(at: Set(indexPaths), scrollPosition: positioned)
    }
    
    public func scrollTo(_ element: Element, positioned: NSCollectionView.ScrollPosition = .centeredVertically) {
        self.scrollTo([element], positioned: positioned)
    }
    
    public func scrollTo(_ elements: [Element], positioned: NSCollectionView.ScrollPosition = .centeredVertically) {
        if let topMostIndexPath = self.indexPaths(for: elements).sorted(by: {$0.item < $1.item}).first, var origin = self.collectionView.frameForItem(at: topMostIndexPath)?.origin {
            if (origin.x > 50) {
                origin.x = origin.x - 50
            }
        }
    }
    
    public func moveElement( _ element: Element, before beforeElement: Element) {
        var snapshot = self.snapshot()
        snapshot.moveItem(element, beforeItem: beforeElement)
        self.apply(snapshot)
    }
    
    public func moveElement( _ element: Element, after afterElement: Element) {
        var snapshot = self.snapshot()
        snapshot.moveItem(element, afterItem: afterElement)
        self.apply(snapshot)
    }
    
    public func moveElements( _ elements: [Element], before beforeElement: Element) {
        var snapshot = self.snapshot()
        elements.forEach({snapshot.moveItem($0, beforeItem: beforeElement)})
        self.apply(snapshot)
    }
    
    public func moveElements( _ elements: [Element], after afterElement: Element) {
        var snapshot = self.snapshot()
        elements.forEach({snapshot.moveItem($0, afterItem: afterElement)})
        self.apply(snapshot)
    }
    
    public func moveElements(at indexPaths: [IndexPath], to toIndexPath: IndexPath) {
        let elements = indexPaths.compactMap({self.element(for: $0)})
        if let toElement = self.element(for: toIndexPath), elements.isEmpty == false {
            self.moveElements(elements, before: toElement)
        }
    }
    
    public func removeElements( _ elements: [Element]) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(elements)
        self.apply(snapshot)
    }
    
}
