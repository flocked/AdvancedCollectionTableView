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
            let items = indexPaths.compactMap({self.dataSource.item(for: $0)})
            self.dataSource.prefetchHandlers.willPrefetch?(items)
        }
        
        func collectionView(_ collectionView: NSCollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
            let items = indexPaths.compactMap({self.dataSource.item(for: $0)})
            self.dataSource.prefetchHandlers.didCancelPrefetching?(items)
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
            self.dataSource.draggingIndexPaths = []
        }
        
        func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexes: IndexSet, with event: NSEvent) -> Bool {
            if let canReorderHandler = self.dataSource.reorderingHandlers.canReorder {
                let items = indexes.compactMap({self.dataSource.item(for: IndexPath(item: $0, section: 0))})
                return canReorderHandler(items)
            } else {
                return self.dataSource.allowsReordering
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
            if let item = self.dataSource.item(for: indexPath) {
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
            self.dataSource.draggingIndexPaths = indexPaths
        }
        
        func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                proposedDropOperation.pointee = NSCollectionView.DropOperation.before
            }
            return NSDragOperation.move
        }
        
        func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
            if (self.dataSource.draggingIndexPaths.isEmpty == false) {
                if let transaction = self.dataSource.movingTransaction(at: Array(self.dataSource.draggingIndexPaths), to: indexPath) {
                    let selectedItems = dataSource.selectedItems
                    self.dataSource.reorderingHandlers.willReorder?(transaction)
                    self.dataSource.apply(transaction.finalSnapshot)
                    self.dataSource.selectItems(selectedItems, scrollPosition: [])
                    self.dataSource.reorderingHandlers.didReorder?(transaction)
                } else {
                    return false
                }
            }
            return true
        }
        
        
        func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
            
        }
        
        func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
            
        }
        
        func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
            /*
             self.dataSource.collectionView.window?.makeFirstResponder(self.dataSource.collectionView)
             
             let items = indexPaths.compactMap({collectionView.item(at: $0)})
             items.forEach({$0.isSelected = true})
             */
            let items = indexPaths.compactMap({self.dataSource.item(for: $0)})
            if (items.isEmpty == false) {
                self.dataSource.selectionHandlers.didSelect?(items)
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
            /*
             self.dataSource.collectionView.window?.makeFirstResponder(self.dataSource.collectionView)
             let items = indexPaths.compactMap({collectionView.item(at: $0)})
             items.forEach({$0.isSelected = false})
             */
            let items = indexPaths.compactMap({self.dataSource.item(for: $0)})
            if (items.isEmpty == false) {
                self.dataSource.selectionHandlers.didDeselect?(items)
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
            if let shouldSelectHandler = self.dataSource.selectionHandlers.shouldSelect {
                let shouldItems = indexPaths.compactMap({self.dataSource.item(for: $0)})
                let returnItems = shouldSelectHandler(shouldItems)
                return Set(returnItems.compactMap({self.dataSource.indexPath(for: $0)}))
            } else {
                return indexPaths
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
            if let shouldDeselectHandler = self.dataSource.selectionHandlers.shouldDeselect {
                let shouldItems = indexPaths.compactMap({self.dataSource.item(for: $0)})
                let returnItems = shouldDeselectHandler(shouldItems)
                return Set(returnItems.compactMap({self.dataSource.indexPath(for: $0)}))
            } else {
                return indexPaths
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, shouldChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) -> Set<IndexPath> {
            if let shouldChangeItems = self.dataSource.highlightHandlers.shouldChange {
                let shouldItems = indexPaths.compactMap({self.dataSource.item(for: $0)})
                let returnItems = shouldChangeItems(shouldItems, highlightState)
                return Set(returnItems.compactMap({self.dataSource.indexPath(for: $0)}))
            } else {
                return indexPaths
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) {
            let items = indexPaths.compactMap({self.dataSource.item(for: $0)})
            self.dataSource.highlightHandlers.didChange?(items, highlightState)
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
            if let draggingImage = self.dataSource.dragDropHandlers.draggingImage {
                let items = indexPaths.compactMap({self.dataSource.item(for: $0)})
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
