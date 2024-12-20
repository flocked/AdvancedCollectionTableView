//
//  CollectionViewDiffableDataSource+Delegate.swift
//
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension CollectionViewDiffableDataSource {
    class Delegate: NSObject, NSCollectionViewDelegate, NSCollectionViewPrefetching {
        weak var dataSource: CollectionViewDiffableDataSource!
        
        var dragDeleteElements: [Element] = []
        var dragDeleteObservation: KeyValueObservation?
        var dragDistanceIsMatched = false
        var canReorderItems = false
        var canDragOutside = false
        var canDropItems = false
        var dropValidationIndexPath: IndexPath? = nil
        var dropTargetIndexPath: IndexPath? = nil {
            didSet {
                guard oldValue != dropTargetIndexPath else { return }
                if let indexPath = oldValue, let item = dataSource.collectionView?.item(at: indexPath) {
                    item.isDropTarget = false
                }
                if let indexPath = dropTargetIndexPath, let item = dataSource.collectionView?.item(at: indexPath) {
                    item.isDropTarget = true
                }
            }
        }
        var draggingIndexPaths: Set<IndexPath> = [] {
            didSet {
                guard draggingIndexPaths != oldValue else { return }
                oldValue.forEach({ dataSource.collectionView?.item(at: $0)?.isReordering = false })
                draggingIndexPaths.forEach({ dataSource.collectionView?.item(at: $0)?.isReordering = true })
            }
        }
        
        init(_ dataSource: CollectionViewDiffableDataSource) {
            self.dataSource = dataSource
            super.init()
            dataSource.collectionView.delegate = self
            dataSource.collectionView.prefetchDataSource = self
        }
        
        // MARK: Prefetching

        func collectionView(_: NSCollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
            guard let willPrefetch = dataSource.prefetchHandlers.willPrefetch else { return }
            let items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            willPrefetch(items)
        }

        func collectionView(_: NSCollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
            guard let didCancelPrefetching = dataSource.prefetchHandlers.didCancelPrefetching else { return }
            let items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            didCancelPrefetching(items)
        }
                
        // MARK: Dragging
        
        func collectionView(_: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
            canReorderItems = false
            canDragOutside = false
            if dataSource.draggingHandlers.canDrag != nil || dataSource.reorderingHandlers.canReorder != nil || dataSource.reorderingHandlers.droppable {
                let items = indexPaths.compactMap { dataSource.element(for: $0) }
                canReorderItems = dataSource.reorderingHandlers.canReorder?(items) == true || dataSource.reorderingHandlers.canDrop != nil
                canDragOutside = dataSource.draggingHandlers.canDrag?(items) == true
                if canReorderItems {
                    draggingIndexPaths = indexPaths
                }
            }
            // Swift.debugPrint("canDragItemsAt", canReorderItems, canDragOutside)
            return canReorderItems || canDragOutside
        }

        func collectionView(_: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
            // Swift.debugPrint("pasteboardWriterForItemAt")
            if canReorderItems || canDragOutside, let element = dataSource.element(for: indexPath) {
                return NSPasteboardItem(for: element, content: dataSource.draggingHandlers.pasteboardContent?(element))
            }
            return nil
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
            if let draggingImage = dataSource.draggingHandlers.draggingImage {
                let items = indexPaths.compactMap { self.dataSource.element(for: $0) }
                if let image = draggingImage(items, event, dragImageOffset.pointee) {
                    return image
                }
            }
            return collectionView.draggingImageForItems(at: indexPaths, with: event, offset: dragImageOffset)
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
            dragDeleteElements = []
            dragDistanceIsMatched = false
            if dataSource.deletingHandlers.isDeletableByDraggingOutside, let elementsToDelete = dataSource.deletingHandlers.canDelete?(indexPaths.compactMap({dataSource.element(for: $0)})), !elementsToDelete.isEmpty {
                let view = collectionView.enclosingScrollView ?? collectionView
                let width = view.bounds.width*0.3
                dragDeleteElements = elementsToDelete
                dragDeleteObservation = NSApplication.shared.observeChanges(for: \.currentEvent) { [weak self] _, event in
                    guard let self = self else { return }
                    if let event = NSEvent.current, event.type == .leftMouseDragged {
                        let distance = view.bounds.distance(from: event.location(in: view))
                        self.dragDistanceIsMatched = distance > width
                        let cursor: NSCursor = self.dragDistanceIsMatched ? .disappearingItem : .arrow
                        if NSCursor.current != cursor {
                            cursor.set()
                        }
                    } else {
                        self.dragDeleteObservation = nil
                    }
                }
            }
        }
        
        func collectionView(_: NSCollectionView, draggingSession _: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation _: NSDragOperation) {
            // Swift.debugPrint("draggingSession endedAt", screenPoint)
            if !dragDeleteElements.isEmpty, dragDistanceIsMatched {
                let transaction = dataSource.currentSnapshot.deleteTransaction(dragDeleteElements)
                dataSource.deletingHandlers.willDelete?(dragDeleteElements, transaction)
                dataSource.apply(transaction.finalSnapshot, dataSource.deletingHandlers.animates ? .animated : .withoutAnimation)
                dataSource.deletingHandlers.didDelete?(dragDeleteElements, transaction)
                if NSCursor.current == NSCursor.disappearingItem {
                    NSCursor.arrow.set()
                }
            }
            
            dragDeleteObservation = nil
            draggingIndexPaths = []
            dropTargetIndexPath = nil
            dropValidationIndexPath = nil
            canReorderItems = false
            canDragOutside = false
            dragDistanceIsMatched = false
            dragDeleteElements = []
        }
        
        
        // MARK: Dropping
                
        func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            let proposedIndexPath = proposedIndexPath.pointee as IndexPath
            let previousIndexPath = dropValidationIndexPath
            dropValidationIndexPath = proposedDropOperation.pointee == .before ? proposedIndexPath : nil
            dropTargetIndexPath = nil
            canDropItems = false
            
            if draggingInfo.draggingSource as? NSCollectionView == dataSource.collectionView {
                if dataSource.reorderingHandlers.droppable, let canDrop = dataSource.reorderingHandlers.canDrop, proposedDropOperation.pointee == .on {
                    if draggingIndexPaths.count == 1, let indexPath = draggingIndexPaths.sorted().first, indexPath == proposedIndexPath {
                        dropTargetIndexPath = nil
                        return []
                    } else if let target = dataSource.element(for: proposedIndexPath), previousIndexPath != proposedIndexPath {
                        dropTargetIndexPath = canDrop( draggingIndexPaths.compactMap { dataSource.element(for: $0) }, target) ? proposedIndexPath : nil
                        return dropTargetIndexPath != nil ? .move : []
                    } else {
                        dropTargetIndexPath = nil
                        return []
                    }
                }
                if dataSource.reorderingHandlers.canReorder != nil {
                    var indexPaths = draggingIndexPaths.sorted()
                    if let last = indexPaths.last {
                        indexPaths.append(IndexPath(item: last.item+1, section: last.section))
                    }
                    if indexPaths.contains(proposedIndexPath) {
                        if draggingIndexPaths.sections.count == 1 {
                            return []
                        }
                    }
                    if proposedDropOperation.pointee == .on {
                        proposedDropOperation.pointee = .before
                    }
                    return .move
                }
            }
            if let canDrop = dataSource.droppingHandlers.canDrop {
                let content = draggingInfo.draggingPasteboard.content()
                dropTargetIndexPath = proposedDropOperation.pointee == .on ? proposedIndexPath : nil
                Swift.print("CHECK", proposedDropOperation.pointee == .on)
                let target = proposedDropOperation.pointee == .on ? dataSource.element(for: proposedIndexPath) : nil
                if !content.isEmpty, canDrop(content, target) == true {
                    canDropItems = true
                    return .copy
                }
            }
            return []
        }

        func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation _: NSCollectionView.DropOperation) -> Bool {
            if draggingInfo.draggingSource as? NSCollectionView == collectionView {
                let elements = draggingIndexPaths.compactMap { dataSource.element(for: $0) }
                if canReorderItems, !draggingIndexPaths.isEmpty {
                    draggingIndexPaths = []
                    if dropTargetIndexPath != nil, let didDrop = dataSource.reorderingHandlers.didDrop, let target = dataSource.element(for: indexPath) {
                        dropTargetIndexPath = nil
                        didDrop(elements, target)
                    } else {
                        let transaction = dataSource.moveTransaction(elements, to: indexPath)
                        dataSource.reorderingHandlers.willReorder?(transaction)
                        dataSource.apply(transaction.finalSnapshot, dataSource.reorderingHandlers.animates ? .animated : .withoutAnimation)
                        dataSource.selectElements(elements, scrollPosition: [])
                    }
                    return true
                }
            } else if canDropItems {
                let content = draggingInfo.draggingPasteboard.content()
                var elements: [Element] = []
                var target: Element? = nil
                var transaction: DiffableDataSourceTransaction<Section, Element>? = nil
                
                if let dropTargetIndexPath = dropTargetIndexPath {
                    target = dataSource.element(for: dropTargetIndexPath)
                } else {
                    elements = dataSource.droppingHandlers.elements?(content) ?? []
                }
                if !elements.isEmpty {
                    transaction = dataSource.dropTransaction(elements, indexPath: indexPath)
                }
                dataSource.droppingHandlers.willDrop?(content, target, transaction)
                if let transaction = transaction {
                    dataSource.apply(transaction.finalSnapshot, dataSource.droppingHandlers.animates ? .animated : .withoutAnimation)
                    dataSource.selectElements(elements, scrollPosition: [])
                }
                dataSource.droppingHandlers.didDrop?(content, target, transaction)
                canDropItems = false
                return true
            }
            return false
        }
        
        // MARK: Selecting
        
        func collectionView(_: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
            guard let didSelect = dataSource.selectionHandlers.didSelect else { return }
            let items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            if !items.isEmpty {
                didSelect(items)
            }
        }

        func collectionView(_: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
            guard let didDeselect = dataSource.selectionHandlers.didDeselect else { return }
            let items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            if !items.isEmpty {
                didDeselect(items)
            }
        }
        

        func collectionView(_: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
            guard let shouldSelect = dataSource.selectionHandlers.shouldSelect else { return indexPaths }
            var items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            items = shouldSelect(items)
            return Set(items.compactMap { self.dataSource.indexPath(for: $0) })
        }

        func collectionView(_: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
            guard let shouldDeselect = dataSource.selectionHandlers.shouldDeselect else { return indexPaths }
            var items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            items = shouldDeselect(items)
            return Set(items.compactMap { self.dataSource.indexPath(for: $0) })
        }
        
        // MARK: Highlighting

        func collectionView(_: NSCollectionView, shouldChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) -> Set<IndexPath> {
            guard let shouldChangeItems = dataSource.highlightHandlers.shouldChange else { return indexPaths }
            var items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            items = shouldChangeItems(items, highlightState)
            return Set(items.compactMap { self.dataSource.indexPath(for: $0) })
        }

        func collectionView(_: NSCollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) {
            guard let didChange = dataSource.highlightHandlers.didChange else { return }
            let items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            didChange(items, highlightState)
        }
    }
}
