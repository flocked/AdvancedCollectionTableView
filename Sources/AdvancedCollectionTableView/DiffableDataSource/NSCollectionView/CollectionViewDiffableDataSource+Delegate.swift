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
        var canDragDelete = false
        var dragDeleteItemSize: CGSize = .zero
        var canReorderItems = false
        var canDragOutside = false
        var draggingElements: [Element] = []
        var draggingIndexPaths: Set<IndexPath> = []
        var droppingElements: [Element] = []
        var dropIntoElement: Element? {
            didSet {
                guard oldValue != dropIntoElement else { return }
                if let element = dropIntoElement, let item = dataSource.item(for: element) {
                    item.isDropTarget = true
                }
                if let element = oldValue, let item = dataSource.item(for: element) {
                    item.isDropTarget = false
                }
            }
        }
        // var dropValidationIndexPath: IndexPath? = nil
        var didReorder = false
        
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
            guard dataSource.draggingHandlers.canDrag != nil || dataSource.reorderingHandlers.canReorder != nil else { return false }
            draggingElements = indexPaths.compactMap { dataSource.element(for: $0) }
            draggingIndexPaths = indexPaths
            canReorderItems = dataSource.reorderingHandlers.canReorder?(draggingElements) == true
            canDragOutside = dataSource.draggingHandlers.isDraggable ?  (dataSource.draggingHandlers.canDrag?(draggingElements) == true) : false
            if dataSource.deletingHandlers.isDeletableByDraggingOutside {
                dragDeleteElements = dataSource.deletingHandlers.canDelete?(draggingElements) ?? []
            }
            return canReorderItems || canDragOutside || !dragDeleteElements.isEmpty
        }

        func collectionView(_: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
            // Swift.debugPrint("pasteboardWriterForItemAt")
            if canReorderItems || canDragOutside, let element = dataSource.element(for: indexPath) {
                return NSPasteboardItem(for: element, content: canDragOutside ? dataSource.draggingHandlers.pasteboardContent?(element) : nil)
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
        
        func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
            guard !dragDeleteElements.isEmpty, let frame = dataSource.collectionView.window?.convertToScreen(dataSource.collectionView.convert(dataSource.collectionView.bounds, to: nil)) else { return }
            if dragDeleteItemSize == .zero {
                dragDeleteItemSize = dragDeleteElements.compactMap({ dataSource.indexPath(for: $0) }).compactMap({ dataSource.collectionView.frameForItem(at: $0)?.size }).min() ?? .zero
            }
            canDragDelete = false
            if !frame.contains(screenPoint), dragDeleteItemSize != .zero {
                let distance = frame.outsideDistance(of: screenPoint)
                canDragDelete = distance.x >= dragDeleteItemSize.width || distance.y >= dragDeleteItemSize.height
            }
            let cursor: NSCursor = canDragDelete ? .disappearingItem : .arrow
            if NSCursor.current != cursor {
                cursor.set()
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
            draggingElements.compactMap({ dataSource.item(for: $0) }).forEach({ item in
                item.isDragging = true
                item.isReordering = canReorderItems
                item.setNeedsAutomaticUpdateConfiguration()
            })
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
            if !didReorder, !draggingElements.isEmpty {
                if canDragDelete, !dragDeleteElements.isEmpty {
                    let transaction = dataSource.currentSnapshot.deleteTransaction(dragDeleteElements)
                    dataSource.deletingHandlers.willDelete?(dragDeleteElements, transaction)
                    dataSource.apply(transaction.finalSnapshot, dataSource.deletingHandlers.animates ? .animated : .withoutAnimation)
                    dataSource.deletingHandlers.didDelete?(dragDeleteElements, transaction)
                    if NSCursor.current == NSCursor.disappearingItem {
                        NSCursor.arrow.set()
                    }
                } else if dataSource.draggingHandlers.isDraggable, !draggingElements.isEmpty {
                    dataSource.draggingHandlers.didDrag?(draggingElements)
                }
            }
            
            canReorderItems = false
            canDragOutside = false
            canDragDelete = false
            dragDeleteElements = []
            dragDeleteItemSize = .zero
            dropIntoElement = nil
            droppingElements = []
            didReorder = false
            draggingElements.compactMap({ dataSource.item(for: $0) }).forEach({ item in
                item.isDragging = false
                item.isReordering = false
                item.setNeedsAutomaticUpdateConfiguration()
            })
            draggingElements = []
            draggingIndexPaths = []
            // dropValidationIndexPath = nil
        }
        
        
        // MARK: Dropping
                
        func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            droppingElements = []
            if draggingInfo.draggingSource as? NSCollectionView === dataSource.collectionView {
                dropIntoElement = nil
                return validateReordering(collectionView, draggingInfo,  proposedIndexPath, proposedDropOperation)
            } else if proposedDropOperation.pointee == .on {
                return validateDropInto(draggingInfo, proposedIndexPath.pointee as IndexPath)
            } else if proposedDropOperation.pointee == .before {
                dropIntoElement = nil
                return validateDrop(draggingInfo)
            }
            return []
        }
        
        func validateDropInto(_ draggingInfo: NSDraggingInfo, _ proposedIndexPath: IndexPath) -> NSDragOperation {
            guard dataSource.droppingHandlers.isDroppableInto, let handler = dataSource.droppingHandlers.canDropInto, let element = dataSource.element(for: proposedIndexPath) else { return [] }
            let content = draggingInfo.draggingPasteboard.content
            dropIntoElement = !content.isEmpty && handler(content, element) ? element : nil
            return dropIntoElement != nil ? .copy : []
        }
        
        func validateDrop(_ draggingInfo: NSDraggingInfo) -> NSDragOperation {
            guard let canDrop = dataSource.droppingHandlers.canDrop, let elementsHandler = dataSource.droppingHandlers.elements else { return [] }
            let content = draggingInfo.draggingPasteboard.content
            if !content.isEmpty && canDrop(content) {
                droppingElements = elementsHandler(content)
            }
            return !droppingElements.isEmpty ? .copy : []
        }
        
        func validateReordering(_ collectionView: NSCollectionView, _ draggingInfo: NSDraggingInfo, _ proposedIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, _ proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            guard !draggingElements.isEmpty, canReorderItems else { return [] }
            
            let _proposedIndexPath = proposedIndexPath.pointee as IndexPath
            let location = draggingInfo.location(in: collectionView)
            var indexPaths = draggingIndexPaths.sorted()
            if indexPaths.count == 1, let last = indexPaths.last, _proposedIndexPath == last {
                return []
            }
            if let last = indexPaths.last {
              //  indexPaths.append(IndexPath(item: last.item+1, section: last.section))
            }
            if indexPaths.contains(_proposedIndexPath) {
                if draggingIndexPaths.sections.count == 1 {
                  //  return []
                }
            }
            if proposedDropOperation.pointee == .on {
                if let frame = collectionView.frameForItem(at: _proposedIndexPath) {
                    if location.x > frame.minX + (frame.width/2.0), collectionView.numberOfItems(inSection: _proposedIndexPath.section) > _proposedIndexPath.item + 1 {
                        proposedIndexPath.pointee = IndexPath(item: _proposedIndexPath.item + 1, section: _proposedIndexPath.section) as NSIndexPath
                    } else {
                        if let last = indexPaths.last {
                            indexPaths.append(IndexPath(item: last.item+1, section: last.section))
                        }
                        if indexPaths.contains(_proposedIndexPath) {
                            if draggingIndexPaths.sections.count == 1 {
                                return []
                            }
                        }
                        let indexPath = IndexPath(item: _proposedIndexPath.item+1, section: _proposedIndexPath.section)
                        if indexPaths.count == 1, let last = indexPaths.last, last == indexPath {
                          //  return []
                        }
                    }
                }
                proposedDropOperation.pointee = .before
            }
            return .move
            
/*
 let previousIndexPath = dropValidationIndexPath
 dropValidationIndexPath = proposedDropOperation.pointee == .before ? _proposedIndexPath : nil
            if dataSource.reorderingHandlers.droppable, let canDrop = dataSource.reorderingHandlers.canDrop, proposedDropOperation.pointee == .on {
                if draggingIndexPaths.count == 1, let indexPath = draggingIndexPaths.sorted().first, indexPath == _proposedIndexPath {
                    dropIndexPath = nil
                    return []
                } else if let target = dataSource.element(for: _proposedIndexPath), previousIndexPath != _proposedIndexPath {
                    dropIndexPath = canDrop( draggingIndexPaths.compactMap { dataSource.element(for: $0) }, target) ? _proposedIndexPath : nil
                    return dropIndexPath != nil ? .move : []
                } else {
                    dropIndexPath = nil
                    return []
                }
            }
            */
        }

        func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
            if draggingInfo.draggingSource as? NSCollectionView === collectionView {
                guard !draggingElements.isEmpty else { return false }
                if dropOperation == .before {
                    let transaction = dataSource.moveTransaction(draggingElements, to: indexPath)
                    dataSource.reorderingHandlers.willReorder?(transaction)
                    dataSource.apply(transaction.finalSnapshot, dataSource.reorderingHandlers.animates ? .animated : .withoutAnimation)
                    dataSource.selectElements(draggingElements, scrollPosition: [])
                    didReorder = true
                    return true
                } else {
                    
                    return false
                }
            } else if dropOperation == .on, let element = dropIntoElement {
                let content = draggingInfo.draggingPasteboard.content
                dataSource.droppingHandlers.didDropInto?(content, element)
                return true
            } else if dropOperation == .before, !droppingElements.isEmpty {
                let content = draggingInfo.draggingPasteboard.content
                let transaction: DiffableDataSourceTransaction<Section, Element> = dataSource.dropTransaction(droppingElements, indexPath: indexPath)
                dataSource.droppingHandlers.willDrop?(content, droppingElements, transaction)
                dataSource.apply(transaction.finalSnapshot, dataSource.droppingHandlers.animates ? .animated : .withoutAnimation)
                dataSource.selectElements(droppingElements, scrollPosition: [])
                dataSource.droppingHandlers.didDrop?(content, droppingElements, transaction)
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
    
    /*
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        draggingElements = indexPaths.compactMap({ dataSource.element(for: $0) })
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
     */
}

fileprivate extension CGRect {
    func outsideDistance(of point: CGPoint) -> CGPoint {
        let dx: CGFloat
        let dy: CGFloat

        if point.x < minX {
            dx = minX - point.x
        } else if point.x > maxX {
            dx = point.x - maxX
        } else {
            dx = 0.0
        }

        if point.y < minY {
            dy = minY - point.y
        } else if point.y > maxY {
            dy = point.y - maxY
        } else {
            dy = 0.0
        }

        return CGPoint(x: dx, y: dy)
    }
}
