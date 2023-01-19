//
//  File.swift
//  
//
//  Created by Florian Zand on 21.12.22.
//

import AppKit

extension TableViewDiffableDataSource {
    internal class DelegateBridge<S: HashIdentifiable,  E: HashIdentifiable>: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        weak var dataSource: TableViewDiffableDataSource<S,E>!
        
        func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
            dataSource.columnHandlers.shouldSelect?(tableColumn) ?? true
        }
        
        func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
            dataSource.columnHandlers.didSelect?(tableColumn)
        }
        
        init (_ dataSource: TableViewDiffableDataSource<S,E>) {
            self.dataSource = dataSource
            super.init()
            self.dataSource.tableView.delegate = self
            self.dataSource.tableView.dataSource = self
        }
    }

}

/*
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
 */
