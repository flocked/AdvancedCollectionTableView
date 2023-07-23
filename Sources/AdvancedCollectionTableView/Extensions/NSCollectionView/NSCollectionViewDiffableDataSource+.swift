//
//  NSCollectionViewDiffableDataSource+.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit

public extension NSCollectionViewDiffableDataSource {
    /**
     Returns the item identifiers for the specified index paths.
     
     - Parameters indexPaths: The index paths.
     - Returns: An array of item identifiers for the index paths.
     */
    func itemIdentifiers(for indexPaths: [IndexPath]) -> [ItemIdentifierType] {
        return indexPaths.compactMap({self.itemIdentifier(for:$0)})
    }
    
    /**
     Returns the index paths for the specified item identifiers.
     
     - Parameters identifiers: The item identifiers.
     - Returns: An array of index paths for the item identifiers.
     */
    func indexPaths(for identifiers: [ItemIdentifierType]) -> [IndexPath] {
        return identifiers.compactMap({self.indexPath(for: $0)})
    }
}
