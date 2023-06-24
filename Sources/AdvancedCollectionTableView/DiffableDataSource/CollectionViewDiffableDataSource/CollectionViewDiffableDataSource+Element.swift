//
//  CollectionViewDiffableDataSource+Element.swift
//  NSHostingViewSizeInTableView
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import FZQuicklook

extension CollectionViewDiffableDataSource {
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
    
    
    /*
    internal func quicklookItems(for elements: [Element]) -> [QuicklookItem] {
        return elements.compactMap({$0 as? QLPreviewable}).filter({$0.previewContent != nil}).compactMap({QuicklookItem(content: $0.previewContent!, title: $0.previewItemTitle, frame: $0.previewItemFrame , transitionImage: $0.previewItemTransitionImage)})
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
    }
     */
    
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
    
    public func section(at indexPath: IndexPath) -> Section? {
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
    
    public func reloadAllItems(animated: Bool = false, complection: (() -> Void)? = nil) {
        var snapshot = snapshot()
        snapshot.reloadItems(snapshot.itemIdentifiers)
        if animated {
            self.apply(snapshot, animatingDifferences: true)
        } else {
            self.applySnapshotUsingReloadData(snapshot, completion: complection)
        }
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
    
    public func scrollTo(_ elements: [Element], scrollPosition: NSCollectionView.ScrollPosition = []) {
        let indexPaths = Set(self.indexPaths(for: elements))
        self.collectionView.scrollToItems(at: indexPaths, scrollPosition: scrollPosition)
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

/*
extension CollectionViewDiffableDataSource: PreviewableDataSource where Element: QLPreviewable {
    public func qlPreviewable(for indexPath: IndexPath) -> QLPreviewable? {
        Swift.print("collectionView qlPreviewable")
        if let previable = self.element(for: indexPath), let item = self.itemView(for: previable) {
            return QuicklookItem(content: previable.previewItemURL, title: previable.previewItemTitle, frame: item.view.frame, transitionImage: item.view.renderedImage)
        }
        return nil
    }
}
 */


public extension NSCollectionViewDiffableDataSource {
    
    var allowsDeletingg: Bool {
        get { getAssociatedValue(key: "NSCollectionViewDiffableDataSource_allowsDeletingg", object: self, initialValue: true) }
        set {
            set(associatedValue: newValue, key: "NSCollectionViewDiffableDataSource_allowsDeletingg", object: self)
            self.setupKeyDownMonitor()
        }
    }
    
    var keyDownMonitor: Any? {
        get { getAssociatedValue(key: "NSCollectionViewDiffableDataSource_keyDownMonitor", object: self, initialValue: nil) }
        set {  set(associatedValue: newValue, key: "NSCollectionViewDiffableDataSource_keyDownMonitor", object: self) }
    }
    
    func setupKeyDownMonitor () {
        if allowsDeletingg {
            if keyDownMonitor == nil {
                keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: { [weak self] event in
                    guard let self = self else { return event }
                    self.swizzledKeyDown(with: event)
                    return event
                })
            }
        } else {
            keyDownMonitor = nil
        }
    }
    
    func swizzledKeyDown(with event: NSEvent) {
        /*
        (NSApp.keyWindow?.firstResponder as? NSCollectionView)?.dataSource == self
        guard self.collectionView.window?.firstResponder == self else { return }
        if isQuicklookPreviewable, event.keyCode == 49 {
            if QuicklookPanel.shared.isVisible == false {
                self.quicklookSelectedRows()
            }
        }
         */
    }
    
    
}
