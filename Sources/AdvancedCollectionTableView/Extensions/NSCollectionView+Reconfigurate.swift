//
//  NSCollectionView+Reconfigurate.swift
//  
//
//  Created by Florian Zand on 18.05.22.
//

import AppKit

public extension NSCollectionView {
    /**
     Updates the data for the items at the index paths you specify, preserving existing items.
     
     To update the contents of existing (including prefetched) items without replacing them with new items, use this method instead of reloadItems(at:). For optimal performance, choose to reconfigure items instead of reloading items unless you have an explicit need to replace the existing item with a new item.
     Your item provider must dequeue the same type of item for the provided index path, and must return the same existing item for a given index path. Because this method reconfigures existing items, the collection view doesn’t item prepareForReuse() for each item dequeued. If you need to return a different type of item for an index path, use reloadItems(at:) instead.
     
     - Important: You can only reconfigurate items that have been previously registered via  *NSCollectionView.ItemRegistration*, *register(_:)* or *register(_:, nib:)*.
     
     - Parameters:
       - indexPaths: An array of IndexPath objects identifying the items you want to update.
    */
    func reconfigurateItems(at indexPaths: [IndexPath]) {
        let visibleIndexPaths = self.indexPathsForVisibleItems()
        for indexPath in indexPaths {
            if (visibleIndexPaths.contains(indexPath)) {
                self.dataSource?.collectionView(self, itemForRepresentedObjectAt: indexPath)
            }
        }
    }
}
