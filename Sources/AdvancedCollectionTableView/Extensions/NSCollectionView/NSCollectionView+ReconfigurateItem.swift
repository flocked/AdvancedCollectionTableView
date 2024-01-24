//
//  NSCollectionView+ReconfigurateItem.swift
//
//
//  Created by Florian Zand on 18.05.22.
//

import AppKit
import FZSwiftUtils

extension NSCollectionView {
    /**
     Updates the data for the items at the index paths you specify, preserving existing items.

     To update the contents of existing (including prefetched) items without replacing them with new items, use this method instead of `reloadItems(at:)`. For optimal performance, choose to reconfigure items instead of reloading items unless you have an explicit need to replace the existing item with a new item.

     Your item provider must dequeue the same type of item for the provided index path, and must return the same existing item for a given index path. Because this method reconfigures existing items, the collection view doesn’t item `prepareForReuse()` for each item dequeued. If you need to return a different type of item for an index path, use reloadItems(at:) instead.

     - Important: You can only reconfigurate items that have been registered via  ``ItemRegistration``, or by their class using ``register(_:)`` or ``register(_:nib:)``.

     - Parameters:
        - indexPaths: An array of `IndexPath` objects identifying the items you want to update.
     */
    public func reconfigureItems(at indexPaths: [IndexPath]) {
        isReconfiguratingItems = true
        let visibleIndexPaths = indexPathsForVisibleItems()
        for indexPath in indexPaths {
            if visibleIndexPaths.contains(indexPath) {
                dataSource?.collectionView(self, itemForRepresentedObjectAt: indexPath)
            }
        }
        isReconfiguratingItems = false
    }

    var isReconfiguratingItems: Bool {
        get { getAssociatedValue(key: "isReconfiguratingItems", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "isReconfiguratingItems", object: self)
        }
    }
}
