//
//  AdvanceColllectionViewDiffableDataSource+Element.swift
//  NSHostingViewSizeInTableView
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension AdvanceColllectionViewDiffableDataSource {
    /**
     Returns the element at the specified index path.
     
     - Parameters indexPath: The indexPath
     - Returns: The element at the index path or nil if there isn't any element at the index path.
     */
    public func element(for indexPath: IndexPath) ->  Element? {
        if let itemId = self.dataSource.itemIdentifier(for: indexPath) {
            return self.currentSnapshot.itemIdentifiers[id: itemId]
        }
        return nil
    }
    
    public func indexPath(for element: Element) -> IndexPath? {
        return dataSource.indexPath(for: element.id)
    }
    
    func index(for section: Section) -> Int? {
       return sections.firstIndex(of: section)
    }
    
    func section(for index: Int) -> Section? {
        return sections[safe: index]
    }
    
    /// An array of all elements of the last applied snapshot.
    public var allElements: [Element] {
        return self.currentSnapshot.itemIdentifiers
    }
    
    /// An array of the selected elements.
    public var selectedElements: [Element] {
        return self.collectionView.selectionIndexPaths.compactMap({element(for: $0)})
    }
    
    /// An array of elements that are displaying (currently visible).
    public var displayingElements: [Element] {
        self.collectionView.displayingIndexPaths().compactMap({self.element(for: $0)})
    }
    /// An array of elements that are visible.
    public func visibleElements() -> [Element] {
        return self.collectionView.indexPathsForVisibleItems().compactMap({element(for: $0)})
    }
    
    /**
     Returns the element of the specified index path.
     
     - Parameters indexPath: The indexPath
     - Returns: The element at the index path or nil if there isn't any element at the index path.
     */
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
    
    public func collectionViewItem(for element: Element) -> NSCollectionViewItem? {
        if let elementIndexPath = indexPath(for: element) {
            return self.collectionView.item(at: elementIndexPath)
        }
        return nil
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
    
    public func section(at indexPath: IndexPath) -> Section? {
        if (indexPath.section <= self.sections.count-1) {
            return sections[indexPath.section]
        }
        return nil
    }
    
    
    internal func supplementaryView(for section: Section, kind: String) -> (NSView & NSCollectionViewElement)? {
        if let indexPath = self.indexPaths(for: [section]).first {
            return collectionView.supplementaryView(forElementKind: kind, at: indexPath)
        }
        return nil
    }
    
    public func isSelected(at indexPath: IndexPath) -> Bool {
        self.collectionView.selectionIndexPaths.contains(indexPath)
    }
    
    public func isSelected(for element: Element) -> Bool {
        if let indexPath = indexPath(for: element) {
            return isSelected(at: indexPath)
        }
        return false
    }
    
    public func reconfigurateElements(_ elements: [Element]) {
        let indexPaths = elements.compactMap({self.indexPath(for:$0)})
        self.reconfigureItems(at: indexPaths)
    }
    
    public func reconfigureItems(at indexPaths: [IndexPath]) {
        self.collectionView.reconfigureItems(at: indexPaths)
    }
    
    public func reloadItems(at indexPaths: [IndexPath], animated: Bool = false) {
        let elements = indexPaths.compactMap({self.element(for: $0)})
        self.reloadItems(elements, animated: animated)
    }
    
    public func reloadItems(_ elements: [Element], animated: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(elements.ids)
        dataSource.apply(snapshot, animated ? .animated: .withoutAnimation)
    }
    
    public func reloadAllItems(animated: Bool = false, complection: (() -> Void)? = nil) {
        var snapshot = snapshot()
        snapshot.reloadItems(snapshot.itemIdentifiers)
        self.apply(snapshot, animated ? .animated : .usingReloadData)
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
    
    public func scrollTo(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition = []) {
        let indexPaths = Set(self.indexPaths(for: elements))
        self.collectionView.scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
    }
    
   /*
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
    */
    
    public func removeElements( _ elements: [Element]) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(elements)
        self.apply(snapshot, .animated)
    }
    
    
    internal func transactionForRemovingElements(_ elements: [Element]) -> DiffableDataSourceTransaction {
        var snapshot = self.snapshot()
        snapshot.deleteItems(elements)
        let initalSnapshot = self.currentSnapshot
        let difference = initalSnapshot.itemIdentifiers.difference(from: snapshot.itemIdentifiers)
        return DiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: snapshot, difference: difference)
    }
    
    internal func transactionForMovingElements(at indexPaths: [IndexPath], to toIndexPath: IndexPath) -> DiffableDataSourceTransaction? {
        let elements = indexPaths.compactMap({self.element(for: $0)})
        if let toElement = self.element(for: toIndexPath), elements.isEmpty == false {
            var snapshot = self.snapshot()
            elements.forEach({snapshot.moveItem($0, beforeItem: toElement)})
            let initalSnapshot = self.currentSnapshot
            let difference = initalSnapshot.itemIdentifiers.difference(from: snapshot.itemIdentifiers)
            return DiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: snapshot, difference: difference)
        }
        return nil
    }
}
