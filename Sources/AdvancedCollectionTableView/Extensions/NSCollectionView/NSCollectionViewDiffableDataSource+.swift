//
//  NSCollectionViewDiffableDataSource+.swift
//
//
//  Created by Florian Zand on 16.03.25.
//

import AppKit
import FZSwiftUtils

extension NSCollectionViewDiffableDataSource {
    /// The item provider of the datasource.
    public var itemProvider: ItemProvider {
        typealias itemProviderBlock = @convention(block) (NSCollectionView, IndexPath, Any) -> NSCollectionViewItem?
        guard let object: NSObject = getIvarValue(for: "_impl"), let cellProvider: itemProviderBlock = object.getIvarValue(for: "_collectionViewItemProvider") else { return { _,_,_ in return nil } }
        return cellProvider
    }
    
    /// Creates a new collection view item for the specified item identifier using the item provider.
    public func createItem(for itemIdentifier: ItemIdentifierType) -> NSCollectionViewItem? {
        itemProvider(collectionView, IndexPath(item: 0, section: 0), itemIdentifier)
    }
    
    /// Returns a preview image of the collection view item for the specified element.
    public func previewImage(for item: ItemIdentifierType) -> NSImage? {
        _previewImage(for: item, size: nil)
    }
    
    /// Returns a preview image of the collection view item for the specified element and item size.
    public func previewImage(for item: ItemIdentifierType, size: CGSize) -> NSImage? {
        _previewImage(for: item, size: size)
    }
    
    private func _previewImage(for item: ItemIdentifierType, size: CGSize? = nil, width: CGFloat? = nil, height: CGFloat? = nil) -> NSImage? {
        guard let item = createItem(for: item) else { return nil }
        if width != nil || height != nil {
            item.view.frame.size = item.view.systemLayoutSizeFitting(width: width, height: height)
            item.view.frame.size.width = width ?? item.view.frame.size.width
            item.view.frame.size.height = height ?? item.view.frame.size.height
        } else {
            item.view.frame.size = size ?? collectionView.frameForItem(at: IndexPath(item: 0, section: 0))?.size ?? CGSize(512, 512)
        }
        return item.view.renderedImage
    }
    
    private var collectionView: NSCollectionView {
        guard let object: NSObject = getIvarValue(for: "_impl"), let collectionView: NSCollectionView =  object.getIvarValue(for: "_nsCollectionView") else { return NSCollectionView() }
        return collectionView
    }
}
