//
//  CollectionViewDiffableDataSource+Delegate.swift
//  
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZUIKit

extension CollectionViewDiffableDataSource {
    class DelegateBridge: NSObject, NSCollectionViewDelegate, NSCollectionViewPrefetching {
        
        weak var dataSource: CollectionViewDiffableDataSource!
        
        init(_ dataSource: CollectionViewDiffableDataSource) {
            self.dataSource = dataSource
            super.init()
            self.dataSource.collectionView.delegate = self
            self.dataSource.collectionView.prefetchDataSource = self
        }
        
        func collectionView(_ collectionView: NSCollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
            guard let willPrefetch = dataSource.prefetchHandlers.willPrefetch else { return }
            let items = indexPaths.compactMap({self.dataSource.element(for: $0)})
            willPrefetch(items)
        }
        
        func collectionView(_ collectionView: NSCollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
            guard let didCancelPrefetching = dataSource.prefetchHandlers.didCancelPrefetching else { return }
            let items = indexPaths.compactMap({self.dataSource.element(for: $0)})
            didCancelPrefetching(items)
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
            self.dataSource.draggingIndexPaths = []
        }
        
        func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
            if let canReorder = self.dataSource.reorderingHandlers.canReorder {
                let items = indexPaths.compactMap({dataSource.element(for:$0)})
                return canReorder(items)
            } else {
                return self.dataSource.allowsReordering
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
            if let item = self.dataSource.element(for: indexPath) {
                if let writing = self.dataSource.dragDropHandlers.pasteboardValue?(item).nsPasteboardReadWriting {
                    return writing
                }
                
                let pasteboardItem = NSPasteboardItem()
                pasteboardItem.setString(String(item.id.hashValue), forType: .itemID)
                return pasteboardItem
            }
            return nil
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
            dataSource.draggingIndexPaths = indexPaths
        }
        
        func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                proposedDropOperation.pointee = NSCollectionView.DropOperation.before
            }
            return NSDragOperation.move
        }
        
        func internalDrag(_ collectionView: NSCollectionView, draggingInfo: NSDraggingInfo, indexPath: IndexPath) {
            if (self.dataSource.draggingIndexPaths.isEmpty == false) {
                if let transaction = self.dataSource.movingTransaction(at: Array(self.dataSource.draggingIndexPaths), to: indexPath) {
                    let selectedItems = dataSource.selectedElements
                    self.dataSource.reorderingHandlers.willReorder?(transaction)
                    self.dataSource.apply(transaction.finalSnapshot)
                    self.dataSource.selectElements(selectedItems, scrollPosition: [])
                    self.dataSource.reorderingHandlers.didReorder?(transaction)
                }
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
            if let draggingSource = draggingInfo.draggingSource as? NSCollectionView, draggingSource == collectionView {
                internalDrag(collectionView, draggingInfo: draggingInfo, indexPath: indexPath)
            } else if let insertElement = dataSource.element(for: indexPath) {
                var acceptsDrop = false
                var snapshot = dataSource.snapshot()
                if let handler = dataSource.dragDropHandlers.inside.fileURLs, let fileURLs = draggingInfo.fileURLs {
                    let elements = handler(fileURLs)
                    if !elements.isEmpty {
                        snapshot.moveItems(elements, beforeItem: insertElement)
                        acceptsDrop = true
                    }
                }
                if let handler = dataSource.dragDropHandlers.inside.images, let images = draggingInfo.images {
                    let elements = handler(images)
                    if !elements.isEmpty {
                        snapshot.moveItems(elements, beforeItem: insertElement)
                        acceptsDrop = true
                    }
                }
                if let handler = dataSource.dragDropHandlers.inside.string, let string = draggingInfo.string {
                    let element = handler(string)
                    if let element = element {
                        snapshot.moveItems([element], beforeItem: insertElement)
                        acceptsDrop = true
                    }
                }
                if let handler = dataSource.dragDropHandlers.inside.color, let color = draggingInfo.color {
                    let element = handler(color)
                    if let element = element {
                        snapshot.moveItems([element], beforeItem: insertElement)
                        acceptsDrop = true
                    }
                }
                if acceptsDrop {
                    dataSource.apply(snapshot, .animated)
                }
                return acceptsDrop
            }
            return true
        }
        
        func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
            guard let didSelect = dataSource.selectionHandlers.didSelect else { return }
            let items = indexPaths.compactMap({self.dataSource.element(for: $0)})
            if (items.isEmpty == false) {
                didSelect(items)
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
            guard let didDeselect = dataSource.selectionHandlers.didDeselect else { return }
            let items = indexPaths.compactMap({self.dataSource.element(for: $0)})
            if (items.isEmpty == false) {
                didDeselect(items)
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
            guard let shouldSelect = dataSource.selectionHandlers.shouldSelect else { return indexPaths }
                var items = indexPaths.compactMap({self.dataSource.element(for: $0)})
                items = shouldSelect(items)
                return Set(items.compactMap({self.dataSource.indexPath(for: $0)}))
        }
        
        func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
            guard let shouldDeselect = dataSource.selectionHandlers.shouldDeselect else { return indexPaths }
            var items = indexPaths.compactMap({self.dataSource.element(for: $0)})
            items = shouldDeselect(items)
            return Set(items.compactMap({self.dataSource.indexPath(for: $0)}))
        }
        
        func collectionView(_ collectionView: NSCollectionView, shouldChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) -> Set<IndexPath> {
            guard let shouldChangeItems = self.dataSource.highlightHandlers.shouldChange else { return indexPaths }
            var items = indexPaths.compactMap({self.dataSource.element(for: $0)})
            items = shouldChangeItems(items, highlightState)
            return Set(items.compactMap({self.dataSource.indexPath(for: $0)}))
        }
        
        func collectionView(_ collectionView: NSCollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) {
            guard let didChange = dataSource.highlightHandlers.didChange else { return }
            let items = indexPaths.compactMap({self.dataSource.element(for: $0)})
            didChange(items, highlightState)
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
            if let draggingImage = self.dataSource.dragDropHandlers.draggingImage {
                let items = indexPaths.compactMap({self.dataSource.element(for: $0)})
                if let image = draggingImage(items, event, dragImageOffset) {
                    return image
                }
            }
            return collectionView.draggingImageForItems(at: indexPaths, with: event, offset: dragImageOffset)
        }
    }
}

extension PasteboardReadWriting {
    var nsPasteboardReadWriting: NSPasteboardWriting? {
        return (self as? NSPasteboardWriting) ?? (self as? NSURL)
    }
}
