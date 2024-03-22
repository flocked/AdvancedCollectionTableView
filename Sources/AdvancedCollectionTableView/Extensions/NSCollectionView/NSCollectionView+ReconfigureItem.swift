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

     - Parameters:
        - indexPaths: An array of `IndexPath` objects identifying the items you want to update.
     */
    public func reconfigureItems(at indexPaths: [IndexPath]) {
        Self.swizzleMakeItem()
        guard let dataSource = dataSource else { return }
        isReconfiguratingItems = true
        let visibleIndexPaths = indexPathsForVisibleItems()
        let indexPaths = indexPaths.filter({visibleIndexPaths.contains($0)})
        for indexPath in indexPaths {
            dataSource.collectionView(self, itemForRepresentedObjectAt: indexPath)
        }
        isReconfiguratingItems = false
    }

    var isReconfiguratingItems: Bool {
        get { getAssociatedValue("isReconfiguratingItems", initialValue: false) }
        set { setAssociatedValue(newValue, key: "isReconfiguratingItems")
        }
    }
    
    static var didSwizzleMakeItem: Bool {
        get { getAssociatedValue("didSwizzleMakeItem", initialValue: false) }
        set { setAssociatedValue(newValue, key: "didSwizzleMakeItem") }
    }

    @objc static func swizzleMakeItem() {
        guard didSwizzleMakeItem == false else { return }
        do {
            try Swizzle(NSCollectionView.self) {
                #selector(makeItem(withIdentifier:for:)) <-> #selector(swizzled_makeItem(withIdentifier:for:))
            }
            didSwizzleMakeItem = true
        } catch {
            Swift.debugPrint(error)
        }
    }
    
    @objc func swizzled_makeItem(withIdentifier identifier: NSUserInterfaceItemIdentifier, for indexPath: IndexPath) -> NSCollectionViewItem {
        if isReconfiguratingItems, let item = self.item(at: indexPath) {
            return item
        }
        return self.swizzled_makeItem(withIdentifier: identifier, for: indexPath)
    }
}
