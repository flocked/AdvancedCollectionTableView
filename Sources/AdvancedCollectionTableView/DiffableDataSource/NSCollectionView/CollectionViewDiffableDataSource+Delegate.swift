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
        var draggingElements: [Element] = []
        
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
            draggingElements = []
            draggingIndexPaths = indexPaths
            if dataSource.draggingHandlers.canDrag != nil || dataSource.reorderingHandlers.canReorder != nil {
                let items = indexPaths.compactMap { dataSource.element(for: $0) }
                canReorderItems = dataSource.reorderingHandlers.canReorder?(items) == true
                canDragOutside = dataSource.draggingHandlers.canDrag?(items) == true
            }
            Swift.debugPrint("canDragItemsAt", canReorderItems || canDragOutside)
            return canReorderItems || canDragOutside
        }

        func collectionView(_: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
            Swift.debugPrint("pasteboardWriterForItemAt")
            if canDragOutside, let element = dataSource.element(for: indexPath), let contents = dataSource.draggingHandlers.pasteboardContent?(element) {
                if !contents.isEmpty {
                    draggingElements.append(element)
                }
                let pasteboardItem = NSPasteboardItem(contents: contents)
                pasteboardItem.setString(String(element.id.hashValue), forType: .itemID)
                return pasteboardItem
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
            Swift.debugPrint("draggingSession willBeginAt", indexPaths.count)
        }
        
        func collectionView(_: NSCollectionView, draggingSession _: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation _: NSDragOperation) {
            Swift.debugPrint("draggingSession endedAt", screenPoint)
            if !draggingElements.isEmpty {
                dataSource.draggingHandlers.didDrag?(draggingElements)
            }
            draggingElements = []
            draggingIndexPaths = []
        }
        
        // MARK: Dropping

        func collectionView(_: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            Swift.debugPrint("validateDrop")
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                proposedDropOperation.pointee = NSCollectionView.DropOperation.before
            }
            return NSDragOperation.move
        }

        func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation _: NSCollectionView.DropOperation) -> Bool {
            debugPrint("acceptDrop")
            // Reordering Elements
            if let draggingSource = draggingInfo.draggingSource as? NSCollectionView, draggingSource == collectionView {
                if canReorderItems, !draggingIndexPaths.isEmpty, let transaction = dataSource.movingTransaction(at: Array(draggingIndexPaths), to: indexPath) {
                    let selectedItems = dataSource.selectedElements
                    dataSource.reorderingHandlers.willReorder?(transaction)
                    dataSource.apply(transaction.finalSnapshot, .animated)
                    dataSource.selectElements(selectedItems, scrollPosition: [])
                    dataSource.reorderingHandlers.didReorder?(transaction)
                    return true
                }
            }
            
            // Dropping Files
            var elements = dataSource.droppingHandlers.canDrop?(draggingInfo.contents) ?? []
            if !elements.isEmpty, let insertElement = dataSource.element(for: indexPath) {
                var snapshot = dataSource.snapshot()
                
                for element in elements.reversed() {
                    if snapshot.itemIdentifiers.contains(element) {
                        snapshot.moveItems([element], beforeItem: insertElement)
                    } else {
                        snapshot.insertItems([element], beforeItem: insertElement)
                    }
                }
                var transaction: DiffableDataSourceTransaction<Section, Element>?
                if dataSource.droppingHandlers.needsTransaction {
                    transaction = .init(initial: dataSource.snapshot(), final: snapshot)
                    dataSource.droppingHandlers.willDrag?(transaction!)
                }
                let selectedItems = dataSource.selectedElements
                dataSource.apply(snapshot, .animated)
                dataSource.selectElements(selectedItems, scrollPosition: [])
                dataSource.droppingHandlers.didDrag?(transaction!)
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

extension NSPasteboardItem {
    var itemID: (any Hashable)? {
        get { getAssociatedValue("itemID", initialValue: nil) }
        set { setAssociatedValue(newValue, key: "itemID")
            if let newValue = newValue, let data = String(newValue.hashValue).data(using: .utf8) {
                self.setData(data, forType: .itemID)
            }
        }
    }
    
    convenience init(contents: [PasteboardContent]) {
        self.init()
        tiffImage = contents.images.first
        url = contents.urls.first
        fileURL = contents.fileURLs.first
        color = contents.colors.first
        string = contents.strings.first
    }
}

extension NSDraggingInfo {
    var contents: [PasteboardContent] {
        var contents: [PasteboardContent] = []
        contents.append(contentsOf: fileURLs ?? [])
        contents.append(contentsOf: urls ?? [])
        contents.append(contentsOf: images ?? [])
        contents.append(contentsOf: colors ?? [])
        contents.append(contentsOf: strings ?? [])
        contents.append(contentsOf: draggingPasteboard.pasteboardItems ?? [])
        return contents
    }
}

extension NSPasteboardItem {
    var contents: [PasteboardContent] {
        var contents: [PasteboardContent?] = [fileURL, url, tiffImage, color, string]
        return contents.compactMap({ $0 })
    }
}
