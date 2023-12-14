//
//  AdvanceCollectionViewDiffableDataSource+Element.swift
//  NSHostingViewSizeInTableView
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension AdvanceCollectionViewDiffableDataSource {
    /// All current sections in the collection view.
    internal var sections: [Section] { currentSnapshot.sectionIdentifiers }
    
    /// All current elements in the collection view.
    internal var allElements: [Element] {
        return self.currentSnapshot.itemIdentifiers
    }

    /// An array of the selected elements.
    public var selectedElements: [Element] {
        return self.collectionView.selectionIndexPaths.compactMap({element(for: $0)})
    }
    
    /**
     Returns the element at the specified index path in the collection view.
     
     - Parameter indexPath: The indexPath
     - Returns: The element at the index path or nil if there isn't any element at the index path.
     */
    public func element(for indexPath: IndexPath) ->  Element? {
        if let itemId = self.dataSource.itemIdentifier(for: indexPath) {
            return self.currentSnapshot.itemIdentifiers[id: itemId]
        }
        return nil
    }
    
    /// Returns the index path for the specified element in the collection view.
    public func indexPath(for element: Element) -> IndexPath? {
        return dataSource.indexPath(for: element.id)
    }
    
    /// Returns the index for the section in the collection view.
    public func index(for section: Section) -> Int? {
        return sections.firstIndex(of: section)
    }
    
    /// Returns the section at the index in the collection view.
    public func section(for index: Int) -> Section? {
        return sections[safe: index]
    }
    
    /**
     Returns the element at the specified point.
     
     - Parameter point: The point in the collection view’s bounds that you want to test.
     - Returns: The element at the specified point or `nil` if no element was found at that point.
     */
    public func element(at point: CGPoint) -> Element? {
        if let indexPath = self.collectionView.indexPathForItem(at: point) {
            return element(for: indexPath)
        }
        return nil
    }
    
    /// Updates the data for the elements you specify, preserving the existing collection view items for the elements.
    public func reconfigureElements(_ elements: [Element]) {
        let indexPaths = elements.compactMap({self.indexPath(for:$0)})
        self.collectionView.reconfigureItems(at: indexPaths)
    }
    
    /// Reloads the specified elements.
    public func reloadElements(_ elements: [Element], animated: Bool = false) {
        var snapshot = dataSource.snapshot()
        snapshot.reloadItems(elements.ids)
        dataSource.apply(snapshot, animated ? .animated: .withoutAnimation)
    }
    
    /// Selects all collection view items of the specified elements.
    internal func selectElements(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition, addSpacing: CGFloat? = nil) {
        let indexPaths = Set(elements.compactMap({indexPath(for: $0)}))
        self.collectionView.selectItems(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    
    /// Deselects all collection view items of the specified elements.
    internal func deselectElements(_ elements: [Element]) {
        let indexPaths = Set(elements.compactMap({indexPath(for: $0)}))
        self.collectionView.deselectItems(at: indexPaths)
    }
    
    /// Selects all collection view items of the elements in the specified sections.
    internal func selectElements(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let elements = self.elements(for: sections)
        self.selectElements(elements, scrollPosition: scrollPosition)
    }
    
    /// Deselects all collection view items of the elements in the specified sections.
    internal func deselectElements(in sections: [Section], scrollPosition: NSCollectionView.ScrollPosition) {
        let indexPaths = sections.flatMap({self.indexPaths(for: $0)})
        self.collectionView.deselectItems(at: Set(indexPaths))
    }
    
    /// Scrolls the collection view to the specified elements.
    public func scrollToElements(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition = []) {
        let indexPaths = Set(self.indexPaths(for: elements))
        self.collectionView.scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    /// Scrolls the collection view to the specified section.
    public func scrollToSection(_ section: Section, scrollPosition: NSCollectionView.ScrollPosition = []) {
        guard let index = index(for: section) else { return }
        let indexPaths = Set([IndexPath(item: 0, section: index)])
        self.collectionView.scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
    }
    
    /// An array of elements that are displaying (currently visible).
    internal var displayingElements: [Element] {
        self.collectionView.displayingIndexPaths().compactMap({self.element(for: $0)})
    }
    
    /// The collection view item for the specified element.
    internal func item(for element: Element) -> NSCollectionViewItem? {
        if let indexPath = indexPath(for: element) {
            return self.collectionView.item(at: indexPath)
        }
        return nil
    }
    
    /// The frame of the collection view item for the specified element.
    internal func itemFrame(for element: Element) -> CGRect? {
        if let indexPath = indexPath(for: element) {
            return self.collectionView.frameForItem(at: indexPath)
        }
        return nil
    }
    
    internal func indexPaths(for elements: [Element]) -> [IndexPath] {
        return elements.compactMap({indexPath(for: $0)})
    }
    
    internal func indexPaths(for section: Section) -> [IndexPath] {
        let elements = self.currentSnapshot.itemIdentifiers(inSection: section)
        return self.indexPaths(for: elements)
    }
    
    internal func indexPaths(for sections: [Section]) -> [IndexPath] {
        return sections.flatMap({self.indexPaths(for: $0)})
    }
    
    internal func elements(for sections: [Section]) -> [Element] {
        let currentSnapshot = self.currentSnapshot
        return sections.flatMap({currentSnapshot.itemIdentifiers(inSection: $0)})
    }
    
    internal func section(for element: Element) -> Section? {
        return self.currentSnapshot.sectionIdentifier(containingItem: element)
    }
    
    internal func section(at indexPath: IndexPath) -> Section? {
        if (indexPath.section <= self.sections.count-1) {
            return sections[indexPath.section]
        }
        return nil
    }
    
    internal func isSelected(at indexPath: IndexPath) -> Bool {
        self.collectionView.selectionIndexPaths.contains(indexPath)
    }
    
    internal func isSelected(for element: Element) -> Bool {
        if let indexPath = indexPath(for: element) {
            return isSelected(at: indexPath)
        }
        return false
    }
    
    internal func removeElements( _ elements: [Element]) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(elements)
        self.apply(snapshot, .animated)
    }
    
    internal func transactionForRemovingElements(_ elements: [Element]) -> DiffableDataSourceTransaction<Section, Element> {
        var snapshot = self.snapshot()
        snapshot.deleteItems(elements)
        let initalSnapshot = self.currentSnapshot
        let difference = initalSnapshot.itemIdentifiers.difference(from: snapshot.itemIdentifiers)
        return DiffableDataSourceTransaction(initialSnapshot: initalSnapshot, finalSnapshot: snapshot, difference: difference)
    }
    
    internal func transactionForMovingElements(at indexPaths: [IndexPath], to toIndexPath: IndexPath) -> DiffableDataSourceTransaction<Section, Element>? {
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
