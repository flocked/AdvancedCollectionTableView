//
//  NSCollectionViewDiffableDataSource+.swift
//  
//
//  Created by Florian Zand on 02.09.22.
//

import AppKit

public extension NSCollectionViewDiffableDataSource {
    /**
     Creates a diffable data source with the specified item provider, and connects it to the specified collection view.
     
     - Parameters:
        - collectionView: The initialized collection view object to connect to the diffable data source.
        - itemRegistration: A item registration that creates, configurate and returns each of the items for the collection view from the data the diffable data source provides.
     */
    convenience init<I: NSCollectionViewItem>(collectionView: NSCollectionView, itemRegistration: NSCollectionView.ItemRegistration<I, ItemIdentifierType>) {
        self.init(collectionView: collectionView, itemProvider:  {
            tCollectionView, indexPath, element in
            return  tCollectionView.makeItem(using: itemRegistration, for: indexPath, element: element)
        })
    }
    
    /**
     Creates a diffable data source with the specified item provider, and connects it to the specified collection view.
     
     - Parameters:
        - collectionView: The initialized collection view object to connect to the diffable data source.
        - itemRegistration: A item registration that creates, configurate and returns each of the items for the collection view from the data the diffable data source provides.
        - supplementaryRegistrations: An array of collection view’s SupplementaryRegistration that provides supplementary views, such as headers and footers.
     */
    convenience init<I: NSCollectionViewItem>(collectionView: NSCollectionView, itemRegistration: NSCollectionView.ItemRegistration<I, ItemIdentifierType>, supplementaryRegistrations: [NSCollectionViewSupplementaryRegistration]) {
        self.init(collectionView: collectionView, itemRegistration: itemRegistration)
        self.useSupplementaryRegistrations(supplementaryRegistrations)
    }
    
    /// Uses the supplementary registrations to return supplementary views to `supplementaryViewProvider`.
    func useSupplementaryRegistrations(_ registrations: [NSCollectionViewSupplementaryRegistration]) {
        self.supplementaryViewProvider = { tCollectionView, kind, indexPath in
            if let provider = registrations.first(where: {$0.elementKind == kind}) {
                return (provider as! _NSCollectionViewSupplementaryRegistration).makeSupplementaryView(tCollectionView, indexPath)
            }
            return nil
        }
    }
}
