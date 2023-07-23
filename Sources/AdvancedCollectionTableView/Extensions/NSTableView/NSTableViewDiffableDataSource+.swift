//
//  NSTableViewDiffableDataSource+.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

import AppKit

public extension NSTableViewDiffableDataSource {
    /**
     Returns the item identifiers for the specified row indexes.
     
     - Parameters rows: The row indexes.
     - Returns: An array of item identifiers for row indexes.
     */
    func itemIdentifiers(for rows: [Int]) -> [ItemIdentifierType] {
        return rows.compactMap({self.itemIdentifier(forRow:$0)})
    }
    
    /**
     Returns the row indexes for the specified item identifiers.
     
     - Parameters identifiers: The item identifiers.
     - Returns: An array of row index for the item identifiers.
     */
    func rows(for identifiers: [ItemIdentifierType]) -> [Int] {
        return identifiers.compactMap({self.row(forItemIdentifier: $0)})
    }
}
