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
        
        var draggingIndexPaths: Set<IndexPath> = []
        var canReorderItems = false
        var canDragOutside = false
        var isInserting = false
        var insertIndexPath: IndexPath? = nil {
            didSet {
                guard oldValue != insertIndexPath else { return }
                if let indexPath = oldValue, let item = dataSource.collectionView?.item(at: indexPath) {
                    item.highlightState = .none
                    item.setNeedsAutomaticUpdateConfiguration()
                }
                if let indexPath = insertIndexPath, let item = dataSource.collectionView?.item(at: indexPath) {
                    item.highlightState = .asDropTarget
                    item.setNeedsAutomaticUpdateConfiguration()
                }
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
            draggingIndexPaths = indexPaths

            if dataSource.draggingHandlers.canDrag != nil || dataSource.reorderingHandlers.canReorder != nil || dataSource.reorderingHandlers.insertable {
                let items = indexPaths.compactMap { dataSource.element(for: $0) }
                canReorderItems = dataSource.reorderingHandlers.canReorder?(items) == true || dataSource.reorderingHandlers.canInsert != nil
                canDragOutside = dataSource.draggingHandlers.canDrag?(items) == true
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
        
        func collectionView(_: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
            // Swift.debugPrint("draggingSession willBeginAt", indexPaths.count)
        }
        
        func collectionView(_: NSCollectionView, draggingSession _: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation _: NSDragOperation) {
            // Swift.debugPrint("draggingSession endedAt", screenPoint)
            draggingIndexPaths = []
            insertIndexPath = nil
            isInserting = false
        }
        
        
        
        // MARK: Dropping

        func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            if draggingInfo.draggingSource as? NSCollectionView == dataSource.collectionView,  dataSource.reorderingHandlers.insertable, let canInsert = dataSource.reorderingHandlers.canInsert, proposedDropOperation.pointee == .on {
                if draggingIndexPaths.count == 1, let indexPath = draggingIndexPaths.sorted().first, indexPath == proposedIndexPath.pointee as IndexPath {
                    insertIndexPath = nil
                    return []
                } else if let target = dataSource.element(for: proposedIndexPath.pointee as IndexPath) {
                    isInserting = canInsert( draggingIndexPaths.compactMap { dataSource.element(for: $0) }, target)
                    if isInserting {
                        insertIndexPath = proposedIndexPath.pointee as IndexPath
                    } else {
                        insertIndexPath = nil
                    }
                    return isInserting ? .move : []
                } else {
                    insertIndexPath = nil
                    return []
                }
            } else {
                insertIndexPath = nil
            }
            
            if proposedDropOperation.pointee == .on {
                proposedDropOperation.pointee = .before
            }

            if draggingInfo.draggingSource as? NSCollectionView == dataSource.collectionView {
                var indexPaths = draggingIndexPaths.sorted()
                if let last = indexPaths.last {
                    indexPaths.append(IndexPath(item: last.item+1, section: last.section))
                }
                if indexPaths.contains(proposedIndexPath.pointee as IndexPath) {
                    if draggingIndexPaths.sections.count == 1 {
                        return []
                    }
                }
                return .move
            } else {
                let content = draggingInfo.draggingPasteboard.content()
                if !content.isEmpty, dataSource.droppingHandlers.canDrop?(content) != nil {
                    return .copy
                }
            }
            return []
        }

        func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation _: NSCollectionView.DropOperation) -> Bool {
            if let draggingSource = draggingInfo.draggingSource as? NSCollectionView, draggingSource == collectionView {
                let elements = draggingIndexPaths.compactMap { dataSource.element(for: $0) }
                if canReorderItems, !draggingIndexPaths.isEmpty {
                    if isInserting, let didInsert = dataSource.reorderingHandlers.didInsert, let target = dataSource.element(for: indexPath) {
                        didInsert(elements, target)
                    } else {
                        let transaction = dataSource.movingTransaction(for: elements, to: indexPath)
                        dataSource.reorderingHandlers.willReorder?(transaction)
                        dataSource.apply(transaction.finalSnapshot, dataSource.reorderingHandlers.animates ? .animated : .withoutAnimation)
                        dataSource.selectElements(elements, scrollPosition: [])
                        dataSource.reorderingHandlers.didReorder?(transaction)
                    }
                    return true
                }
            }
            
            let elements = dataSource.droppingHandlers.canDrop?(draggingInfo.draggingPasteboard.content()) ?? []
            if !elements.isEmpty {
                var snapshot = dataSource.snapshot()
                if let item = dataSource.element(for: indexPath) {
                    snapshot.insertItems(elements, beforeItem: item)
                } else if let section = dataSource.sections[safe: indexPath.section] {
                    var indexPath = indexPath
                    indexPath.item -= 1
                    if let item = dataSource.element(for: indexPath) {
                        snapshot.insertItems(elements, afterItem: item)
                    } else {
                        snapshot.appendItems(elements, toSection: section)
                    }
                } else if let section = dataSource.sections.last {
                    snapshot.appendItems(elements, toSection: section)
                }
                var transaction: DiffableDataSourceTransaction<Section, Element>?
                if dataSource.droppingHandlers.needsTransaction {
                    transaction = .init(initial: dataSource.snapshot(), final: snapshot)
                    dataSource.droppingHandlers.willDrop?(transaction!)
                }
                let selectedItems = dataSource.selectedElements
                dataSource.apply(snapshot, dataSource.droppingHandlers.animates ? .animated : .withoutAnimation)
                dataSource.selectElements(selectedItems, scrollPosition: [])
                dataSource.droppingHandlers.didDrop?(transaction!)
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
