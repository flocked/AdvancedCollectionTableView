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
            // Swift.debugPrint("canDragItemsAt", canReorderItems, canDragOutside)
            return canReorderItems || canDragOutside
        }

        func collectionView(_: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
            // Swift.debugPrint("pasteboardWriterForItemAt")
            if canReorderItems || canDragOutside, let element = dataSource.element(for: indexPath) {
                let pasteboardItem = NSPasteboardItem()
                pasteboardItem.setString(String(element.id.hashValue), forType: .itemID)
                pasteboardItem.contents = dataSource.draggingHandlers.pasteboardContent?(element) ?? []
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
            // Swift.debugPrint("draggingSession willBeginAt", indexPaths.count)
        }
        
        func collectionView(_: NSCollectionView, draggingSession _: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation _: NSDragOperation) {
            // Swift.debugPrint("draggingSession endedAt", screenPoint)
            if !draggingElements.isEmpty {
                dataSource.draggingHandlers.didDrag?(draggingElements)
            }
            draggingElements = []
            draggingIndexPaths = []
        }
        
        // MARK: Dropping

        func collectionView(_: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                proposedDropOperation.pointee = NSCollectionView.DropOperation.before
            }
            if let draggingSource = draggingInfo.draggingSource as? NSCollectionView, draggingSource == dataSource.collectionView {
                return NSDragOperation.move
            } else if !draggingInfo.contents.isEmpty {
                return NSDragOperation.copy
            }
            return []
        }

        func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation _: NSCollectionView.DropOperation) -> Bool {
            // debugPrint("acceptDrop")
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
            
            let elements = dataSource.droppingHandlers.canDrop?(draggingInfo.contents) ?? []
            if !elements.isEmpty {
                var snapshot = dataSource.snapshot()
                if let item = dataSource.element(for: indexPath) {
                    snapshot.insertItems(elements, beforeItem: item)
                } else if let section = dataSource.section(at: indexPath) {
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
                dataSource.apply(snapshot, .animated)
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

class IdentifiablePasteboardItem<Element: Identifiable & Hashable>: NSPasteboardItem {
    let element: Element
    init(_ element: Element) {
        self.element = element
        super.init()
        setString(String(element.id.hashValue), forType: .itemID)
    }
    
    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
}

extension NSPasteboardItem {
    var contents: [PasteboardContent] {
        get {
            var contents: [PasteboardContent?] = [fileURL, url, tiffImage, color, string]
            return contents.compactMap({ $0 })
        }
        set {
            tiffImage = newValue.images.first
            url = newValue.urls.first
            fileURL = newValue.fileURLs.first
            color = newValue.colors.first
            string = newValue.strings.first
        }
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
