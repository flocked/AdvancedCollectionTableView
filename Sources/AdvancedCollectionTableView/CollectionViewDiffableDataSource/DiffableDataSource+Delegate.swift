//
//  CollectionViewDiffableDataSource+Delegate.swift
//  Coll
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit

extension CollectionViewDiffableDataSource {
    internal class DelegateBridge<S: HashIdentifiable,  E: HashIdentifiable>: NSObject, NSCollectionViewDelegate, NSCollectionViewPrefetching {
        weak var dataSource: CollectionViewDiffableDataSource<S,E>!
        
        init (_ dataSource: CollectionViewDiffableDataSource<S,E>) {
            self.dataSource = dataSource
            super.init()
            self.dataSource.collectionView.delegate = self
            self.dataSource.collectionView.prefetchDataSource = self
        }
        
        public func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
            self.dataSource.draggingIndexPaths = []
        }
        
        public func collectionView(_ collectionView: NSCollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
            let elements = indexPaths.compactMap({self.dataSource.element(for: $0)})
            self.dataSource.prefetchHandlers.willPrefetch?(elements)
        }
        
        public func collectionView(_ collectionView: NSCollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
            let elements = indexPaths.compactMap({self.dataSource.element(for: $0)})
            self.dataSource.prefetchHandlers.didCancelPrefetching?(elements)
        }
        
        public func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexes: IndexSet, with event: NSEvent) -> Bool {
            if let canReorderHandler = self.dataSource.reorderHandlers.canReorder {
                let elements = indexes.compactMap({self.dataSource.element(for: IndexPath(item: $0, section: 0))})
                return canReorderHandler(elements)
            } else {
                return self.dataSource.allowsReordering
            }
        }
        
        public func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
            if let elementID = self.dataSource.element(for: indexPath)?.id {
                let item = NSPasteboardItem()
                item.setString(String(elementID.hashValue), forType: self.dataSource.pasteboardType)
                return item
            } else {
                return nil
            }
            
        }
        
        public func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
            self.dataSource.draggingIndexPaths = indexPaths
        }
        
        public func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
            if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
                proposedDropOperation.pointee = NSCollectionView.DropOperation.before
            }
            return NSDragOperation.move
        }
        
        public func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
            if (self.dataSource.draggingIndexPaths.isEmpty == false) {
                self.dataSource.moveElements(at: Array(self.dataSource.draggingIndexPaths), to: indexPath)
            }
            return true
        }
        
        public func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
            
        }
        
        public func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
            
        }
        
        public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
            /*
             self.dataSource.collectionView.window?.makeFirstResponder(self.dataSource.collectionView)
             
             let items = indexPaths.compactMap({collectionView.item(at: $0)})
             items.forEach({$0.isSelected = true})
             */
            let elements = indexPaths.compactMap({self.dataSource.element(for: $0)})
            if (elements.isEmpty == false) {
                self.dataSource.selectionHandlers.didSelect?(elements)
            }
        }
        
        public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
            /*
             self.dataSource.collectionView.window?.makeFirstResponder(self.dataSource.collectionView)
             let items = indexPaths.compactMap({collectionView.item(at: $0)})
             items.forEach({$0.isSelected = false})
             */
            let elements = indexPaths.compactMap({self.dataSource.element(for: $0)})
            if (elements.isEmpty == false) {
                self.dataSource.selectionHandlers.didDeselect?(elements)
            }
        }
        
        public func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
            if let shouldSelectHandler = self.dataSource.selectionHandlers.shouldSelect {
                let shouldElements = indexPaths.compactMap({self.dataSource.element(for: $0)})
                let returnElements = shouldSelectHandler(shouldElements)
                return Set(returnElements.compactMap({self.dataSource.indexPath(for: $0)}))
            } else {
                return indexPaths
            }
        }
        
        public func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
            if let shouldDeselectHandler = self.dataSource.selectionHandlers.shouldDeselect {
                let shouldElements = indexPaths.compactMap({self.dataSource.element(for: $0)})
                let returnElements = shouldDeselectHandler(shouldElements)
                return Set(returnElements.compactMap({self.dataSource.indexPath(for: $0)}))
            } else {
                return indexPaths
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, shouldChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) -> Set<IndexPath> {
            if let shouldChangeItems = self.dataSource.highlightHandlers.shouldChangeItems {
                let shouldElements = indexPaths.compactMap({self.dataSource.element(for: $0)})
                let returnElements = shouldChangeItems(shouldElements, highlightState)
                return Set(returnElements.compactMap({self.dataSource.indexPath(for: $0)}))
            } else {
                return indexPaths
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, didChangeItemsAt indexPaths: Set<IndexPath>, to highlightState: NSCollectionViewItem.HighlightState) {
            let elements = indexPaths.compactMap({self.dataSource.element(for: $0)})
            self.dataSource.highlightHandlers.didChangeItems?(elements, highlightState)
        }
        
        func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
            if let draggingImage = self.dataSource.dragDropHandlers.draggingImage {
                let elements = indexPaths.compactMap({self.dataSource.element(for: $0)})
                if let image = draggingImage(elements, event, dragImageOffset) {
                    return image
                }
            }
            return collectionView.draggingImageForItems(at: indexPaths, with: event, offset: dragImageOffset)
        }
    }
}
