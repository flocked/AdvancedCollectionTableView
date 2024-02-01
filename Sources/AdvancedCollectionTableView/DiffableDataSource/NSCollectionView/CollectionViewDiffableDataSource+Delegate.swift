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
    class DelegateBridge: NSObject, NSCollectionViewDelegate, NSCollectionViewPrefetching {
        weak var dataSource: CollectionViewDiffableDataSource!
        var draggingIndexPaths: Set<IndexPath> = []

        init(_ dataSource: CollectionViewDiffableDataSource) {
            self.dataSource = dataSource
            super.init()
            self.dataSource.collectionView.delegate = self
            self.dataSource.collectionView.prefetchDataSource = self
        }

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
        
        func collectionView(_: NSCollectionView, draggingSession _: NSDraggingSession, endedAt _: NSPoint, dragOperation _: NSDragOperation) {
            draggingIndexPaths = []
        }

        var canReorderItems = false
        var canDragOutside = false
        
        
        func collectionView(_: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
            Swift.print("willBeginAt", indexPaths.count)
        }
        
        
        func collectionView(_: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
            canReorderItems = false
            canDragOutside = false
            draggingIndexPaths = indexPaths
            if dataSource.dragDropHandlers.outside.canDrag != nil || dataSource.reorderingHandlers.canReorder != nil {
                let items = indexPaths.compactMap { dataSource.element(for: $0) }
                canReorderItems = dataSource.reorderingHandlers.canReorder?(items) == true
                canDragOutside = dataSource.dragDropHandlers.outside.canDrag?(items) == true
            }
            Swift.print("canDragItemsAt", canReorderItems || canDragOutside)
            return canReorderItems || canDragOutside
        }

        func collectionView(_: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
            Swift.print("pasteboardWriterForItemAt")
            if let item = dataSource.element(for: indexPath) {
                if let writing = dataSource.dragDropHandlers.pasteboardValue?(item).nsPasteboardReadWriting {
                    return writing
                }

                let pasteboardItem = NSPasteboardItem()
                pasteboardItem.setString(String(item.id.hashValue), forType: .itemID)
                if canDragOutside {
                    if let image = dataSource.dragDropHandlers.outside.image?(item) {
                        pasteboardItem.tiffImage = image
                    }
                    if let url = dataSource.dragDropHandlers.outside.url?(item) {
                        pasteboardItem.url = url
                    }
                    if let color = dataSource.dragDropHandlers.outside.color?(item) {
                        pasteboardItem.color = color
                    }
                    if let string = dataSource.dragDropHandlers.outside.string?(item) {
                        pasteboardItem.string = string
                    }
                }
                
                return pasteboardItem
            }
            return nil
        }

        func collectionView(_: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            Swift.print("validateDrop")
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                proposedDropOperation.pointee = NSCollectionView.DropOperation.before
            }
            return NSDragOperation.move
        }

        func reorderingDrag(_: NSCollectionView, draggingInfo: NSDraggingInfo, indexPath: IndexPath) -> Bool {
            if canReorderItems, draggingIndexPaths.isEmpty == false, let transaction = dataSource.movingTransaction(at: Array(draggingIndexPaths), to: indexPath) {
                let selectedItems = dataSource.selectedElements
                dataSource.reorderingHandlers.willReorder?(transaction)
                dataSource.apply(transaction.finalSnapshot, .animated)
                dataSource.selectElements(selectedItems, scrollPosition: [])
                dataSource.reorderingHandlers.didReorder?(transaction)
                return true
            }
            return false
        }

        func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation _: NSCollectionView.DropOperation) -> Bool {
            Swift.print("acceptDrop")
            if let draggingSource = draggingInfo.draggingSource as? NSCollectionView, draggingSource == collectionView {
                if reorderingDrag(collectionView, draggingInfo: draggingInfo, indexPath: indexPath) {
                    return true
                }
            }
            
            Swift.print("images", draggingInfo.images?.count ?? "nil", "fileURLs", draggingInfo.fileURLs?.count ?? "nil", "urls", draggingInfo.urls?.count ?? "nil")
            
            var elements: [Element] = []
            if let fileURLs = draggingInfo.fileURLs, let handler = dataSource.dragDropHandlers.inside.fileURLs {
                elements.append(contentsOf: handler(fileURLs))
            }
            if let urls = draggingInfo.urls, let handler = dataSource.dragDropHandlers.inside.urls {
                elements.append(contentsOf: handler(urls))
            }
            if let images = draggingInfo.images, let handler = dataSource.dragDropHandlers.inside.images {
                elements.append(contentsOf: handler(images))
            }
            if let strings = draggingInfo.strings, let handler = dataSource.dragDropHandlers.inside.strings {
                elements.append(contentsOf: handler(strings))
            }
            
            if canDragOutside, let insertElement = dataSource.element(for: indexPath) {
                var acceptsDrop = false
                var snapshot = dataSource.snapshot()
                
                func setupHandler<Value>(_ handler: ((_ values: [Value]) -> [Element])?, _ keyPath: KeyPath<NSDraggingInfo, [Value]?>) {
                    if let handler = handler, let values = draggingInfo[keyPath: keyPath] {
                        let elements = handler(values)
                        if !elements.isEmpty {
                            for element in elements.reversed() {
                                if snapshot.itemIdentifiers.contains(element) {
                                    snapshot.moveItems([element], beforeItem: insertElement)
                                } else {
                                    snapshot.insertItems([element], beforeItem: insertElement)
                                }
                            }
                            acceptsDrop = true
                        }
                    }
                }
                setupHandler(dataSource.dragDropHandlers.inside.strings, \.strings)
                setupHandler(dataSource.dragDropHandlers.inside.fileURLs, \.fileURLs)
                setupHandler(dataSource.dragDropHandlers.inside.urls, \.urls)
                setupHandler(dataSource.dragDropHandlers.inside.images, \.images)
                setupHandler(dataSource.dragDropHandlers.inside.colors, \.colors)

                if acceptsDrop {
                    var transaction: NSDiffableDataSourceTransaction<Section, Element>?
                    if dataSource.dragDropHandlers.inside.needsTransaction {
                        transaction = .init(initial: dataSource.snapshot(), final: snapshot)
                        dataSource.dragDropHandlers.inside.willDrag?(transaction!)
                    }
                    let selectedItems = dataSource.selectedElements
                    dataSource.apply(snapshot, .animated)
                    dataSource.selectElements(selectedItems, scrollPosition: [])
                    if let didDrag = dataSource.dragDropHandlers.inside.didDrag {
                        didDrag(transaction!)
                    }
                }
                return true
            }
            return false
        }

        func collectionView(_: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
            guard let didSelect = dataSource.selectionHandlers.didSelect else { return }
            let items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            if items.isEmpty == false {
                didSelect(items)
            }
        }

        func collectionView(_: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
            guard let didDeselect = dataSource.selectionHandlers.didDeselect else { return }
            let items = indexPaths.compactMap { self.dataSource.element(for: $0) }
            if items.isEmpty == false {
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

        func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
            if let draggingImage = dataSource.dragDropHandlers.draggingImage {
                let items = indexPaths.compactMap { self.dataSource.element(for: $0) }
                if let image = draggingImage(items, event, dragImageOffset.pointee) {
                    return image
                }
            }
            return collectionView.draggingImageForItems(at: indexPaths, with: event, offset: dragImageOffset)
        }
    }
}

extension NSPasteboardItem {
    var itemID: (any Hashable)? {
        get { getAssociatedValue(key: "itemID", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "itemID", object: self)
            if let newValue = newValue, let data = String(newValue.hashValue).data(using: .utf8) {
                self.setData(data, forType: .itemID)
            }
        }
    }
}

extension PasteboardReadWriting {
    var nsPasteboardReadWriting: NSPasteboardWriting? {
        (self as? NSPasteboardWriting) ?? (self as? NSURL)
    }
}
