//
//  DiffableDataSourceSnapshot.swift
//
//
//  Created by Florian Zand on 03.02.24.
//

/*
import AppKit

/**
 A representation of the state of the data in a view at a specific point in time.
 
 Diffable data sources use snapshots to provide data for collection views and table views. You use a snapshot to set up the initial state of the data that a view displays, and you use snapshots to reflect changes to the data that the view displays.
 
 The data in a snapshot is made up of the sections and items you want to display, in the order you that you determine. You configure what to display by adding, deleting, or moving the sections and items.
 
 - Important: Each of your sections and items must have unique identifiers that conform to the `Hashable` and `Identifiable` protocol.
 
 To display data in a view using a snapshot:
 
 1. Create a snapshot and populate it with the state of the data you want to display.
 2. Apply the snapshot to reflect the changes in the UI.
 
 You can create and configure a snapshot in one of these ways:
 
 - Create an empty snapshot, then append sections and items to it.
 - Get the current snapshot by calling the diffable data source’s snapshot() method, then modify that snapshot to reflect the new state of the data that you want to display.
 
 For example, the following code creates an empty snapshot and populates it with a single section with three items. Then, the code applies the snapshot, animating the UI updates between the previous state and the new state.
 
 ```swift
 // Create a snapshot.
 var snapshot = DiffableDataSourceSnapshot<Section, Item>()

 // Populate the snapshot.
 snapshot.appendSections([mySection])
 snapshot.appendItems(items)

 // Apply the snapshot.
 dataSource.apply(snapshot, .animated)
 ```
 For more information, see the diffable data source types:
 
 - ``CollectionViewDiffableDataSource``
 - ``TableViewDiffableDataSource``
 */
public struct DiffableDataSourceSnapshot<Section, Item> where Section: Hashable & Identifiable, Item: Hashable & Identifiable {
    
    var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
    /// Creates an empty snapshot.
    public init() {
        
    }
    
    /**
     Adds the sections to the snapshot.
     
     - Parameter sections: An array of the sections to add to the snapshot.
     */
    public mutating func appendSections(_ sections: [Section]) {
        snapshot.appendSections(sections)
    }
    
    /**
     Adds the items to the specified section of the snapshot.
     
     - Parameters:
        - items: An array of the items to add to the snapshot.
        - section: The section to which to add the items. If no value is provided, the items are appended to the last section of the snapshot.
     */
    public mutating func appendItems(_ items: [Item], toSection section: Section? = nil) {
        snapshot.appendItems(items, toSection: section)
    }
    
    /// The number of items in the snapshot.
    public var numberOfItems: Int {
        snapshot.numberOfItems
    }
    
    /// The number of sections in the snapshot.
    public var numberOfSections: Int {
        snapshot.numberOfSections
    }
    
    /**
     Returns the number of items in the specified section of the snapshot.
     
     - Parameter section: The section of the snapshot.
     - Returns: The number of items in the specified section. This method returns `0` if the section is empty.
     */
    public func numberOfItems(inSection section: Section) -> Int {
        snapshot.numberOfItems(inSection: section)
    }
    
    /// The items in the snapshot.
    public var items: [Item] {
        snapshot.itemIdentifiers
    }
    
    /// The sections in the snapshot.
    public var sections: [Section] {
        snapshot.sectionIdentifiers
    }
    
    /**
     Returns the index of the item of the snapshot.
     
     - Parameter item: The item of the snapshot.
     - Returns: The index of the item of the snapshot, or `nil` if the item doesn't exist in the snapshot. This index value is 0-based.
     */
    public func indexOfItem(_ item: Item) -> Int? {
        snapshot.indexOfItem(item)
    }
    
    /**
     Returns the index of the section of the snapshot.
     
     - Parameter section: The section of the snapshot.
     - Returns: The index of the section of the snapshot, or `nil` if the section doesn't exist in the snapshot. This index value is 0-based.
     */
    public func indexOfSection(_ section: Section) -> Int? {
        snapshot.indexOfSection(section)
    }
    
    /**
     Returns theitems in the specified section of the snapshot.
     
     - Parameter section: The section of the snapshot.
     - Returns: An array of items contained in the section.
     */
    public func items(inSection section: Section) -> [Item] {
        snapshot.itemIdentifiers(inSection: section)
    }
    
    /**
     Returns the section containing the specified item in the snapshot.
     
     - Parameter item: The item contained in the section of the snapshot.
     - Returns: The section containing the specified item, or `nil` if the specified item doesn't exist in any section of the snapshot.
     
     */
    public func section(containingItem item: Item) -> Section? {
        snapshot.sectionIdentifier(containingItem: item)
    }
    
    /**
     Inserts the provided items immediately after the item in the snapshot.
     
     - Parameters:
        - item: The array of items to add to the snapshot.
        - afterItem: The item after which to insert the new items.
     */
    public mutating func insertItems(_ items: [Item], afterItem: Item) {
        snapshot.insertItems(items, afterItem: afterItem)
    }
    
    /**
     Inserts the provided items immediately before the item in the snapshot.
     
     - Parameters:
        - item: The array of items to add to the snapshot.
        - beforeItem: Theitem before which to insert the new items.
     */
    public mutating func insertItems(_ items: [Item], beforeItem: Item) {
        snapshot.insertItems(items, beforeItem: beforeItem)
    }
    
    /**
     Inserts the provided sections immediately after the section in the snapshot.
     
     - Parameters:
        - item: The array of sections to add to the snapshot.
        - afterSection: The section after which to insert the new sections.
     */
    public mutating func insertSections(_ sections: [Section], afterSection: Section) {
        snapshot.insertSections(sections, afterSection: afterSection)
    }
    
    /**
     Inserts the provided sections immediately before the section in the snapshot.
     
     - Parameters:
        - item: The array of the sections to add to the snapshot.
        - beforeItem: The section before which to insert the new sections.
     */
    public mutating func insertSections(_ sections: [Section], beforeSection: Section) {
        snapshot.insertSections(sections, beforeSection: beforeSection)
    }
    
    /// Deletes all of the items from the snapshot.
    public mutating func deleteAllItems() {
        snapshot.deleteAllItems()
    }
    
    /**
     Deletes the items from the snapshot.
     
     - Parameter sections: The array of the items to delete from the snapshot.
     */
    public mutating func deleteItems(_ items: [Item]) {
        snapshot.deleteItems(items)
    }
    
    /**
     Deletes the sections from the snapshot.
     
     - Parameter sections: The array of the sections to delete from the snapshot.
     */
    public mutating func deleteSections(_ sections: [Section]) {
        snapshot.deleteSections(sections)
    }
    
    /**
     Moves the item from its current position in the snapshot to the position immediately after the specified item.
     
     - Parameters:
        - item: The item to move in the snapshot.
        - beforeItem: The item after which to move the specified item.
     */
    public mutating func moveItem(_ item: Item, afterItem: Item) {
        snapshot.moveItem(item, afterItem: afterItem)
    }
    
    /**
     Moves the item from its current position in the snapshot to the position immediately before the specified item.
     
     - Parameters:
        - item: The item to move in the snapshot.
        - beforeItem: The item before which to move the specified item.
     */
    public mutating func moveItem(_ item: Item, beforeItem: Item) {
        snapshot.moveItem(item, beforeItem: beforeItem)
    }
    
    /**
     Moves the section from its current position in the snapshot to the position immediately after the specified section.
     
     - Parameters:
        - section: The section to move in the snapshot.
        - beforeSection: The section after which to move the specified section.
     */
    public mutating func moveSection(_ section: Section, afterSection: Section) {
        snapshot.moveSection(section, afterSection: afterSection)
    }
    
    /**
     Moves the section from its current position in the snapshot to the position immediately before the specified section.
     
     - Parameters:
        - section: The section to move in the snapshot.
        - beforeSection: The section before which to move the specified section.
     */
    public mutating func moveSection(_ section: Section, beforeSection: Section) {
        snapshot.moveSection(section, beforeSection: beforeSection)
    }
    
    /**
     Updates the data for the items you specify in the snapshot, preserving the existing cells for the items.
     
     To update the contents of existing (including prefetched) cells without replacing them with new cells, use this method instead of ``reloadItems(_:)``. For optimal performance, choose to reconfigure items instead of reloading items unless you have an explicit need to replace the existing cell with a new cell.
     
     Your cell provider must dequeue the same type of cell for the provided index path, and must return the same existing cell for a given index path. Because this method reconfigures existing cells, the collection view or table view doesn’t call `prepareForReuse` for each cell dequeued. If you need to return a different type of cell for an index path, use ``reloadItems(_:)`` instead.
     
     If your cells are self-sizing, the collection view or table view resizes your cells after reconfiguring them.
     
     Use the `animated` option when applying the snapshot to tell the collection view or table view whether to animate any size or layout changes that are a result of reconfiguration when you apply the snapshot to your data source. To avoid animations when setting specific properties, use `withoutAnimation` or `usingReloadData`  in your cell configuration logic.
     
     If your collection view or table view uses a diffable data source, use this method. If your collection view uses a custom implementation of `NSCollectionViewDataSource`, use ``AppKit/NSCollectionView/reconfigureItems(at:)`` instead. If your table view uses a custom implementation of `NSTableViewDataSource`, use ``AppKit/NSTableView/reconfigureRows(at:)`` instead.
     
     - Parameter items: An array of the items to update data for in the snapshot.
     */
    public mutating func reconfigureItems(_ items: [Item]) {
        reconfiguredItems.append(contentsOf: items)
    }
    
    /**
     The items reconfigured by the changes to the snapshot.
     
     After you make updates to the snapshot, this method returns an array of the items that the view reconfigures when you apply the snapshot to your data source.
     */
    public var reconfiguredItems: [Item] = []
    
    /**
     Reloads the data within the specified items in the snapshot.
     
     - Parameter items: The array of the items to reload in the snapshot.
     
     */
    public mutating func reloadItems(_ items: [Item]) {
        reloadedItems.append(contentsOf: items)
        snapshot.reloadItems(items)
    }
    
    /**
     The items reloaded by the changes to the snapshot.
     
     After you make updates to the snapshot, this method returns an array of the items that the view reloads when you apply the snapshot to your data source.
     */
    public var reloadedItems: [Item] = []
    
    /**
     Reloads the data within the specified sections of the snapshot.
     
     - Parameter sections: The array of the sections to reload in the snapshot.
     
     */
    public mutating func reloadSections(_ sections: [Section]) {
        reloadedSections.append(contentsOf: sections)
        snapshot.reloadSections(sections)
    }
    
    /**
     The sections reloaded by the changes to the snapshot.
     
     After you make updates to the snapshot, this method returns an array of sections that the view reloads when you apply the snapshot to your data source.
     */
    public var reloadedSections: [Section] = []
}


/**
 ### Creating a snapshot

 ``init()``
 ``appendSections(_:)``
 ``appendItems(_:toSection:)``
 
 ### Getting item and section metrics
 
 ``numberOfItems``
 ``numberOfSections``
 ``numberOfItems(inSection:)``

 ### Identifying items and sections
 
 ``items``
 ``sections``
 ``indexOfItem(_:)``
 ``indexOfSection(_:)``
 ``items(inSection:)``
 ``section(containingItem:)``

 ### Inserting items and sections
 
 ``insertItems(_:afterItem:)``
 ``insertItems(_:beforeItem:)``
 ``insertSections(_:afterSection:)``
 ``insertSections(_:beforeSection:)``

 ### Removing items and sections
 
 ``deleteAllItems()``
 ``deleteItems(_:)``
 ``deleteSections(_:)``
 
 ### Reordering items and sections
 
 ``moveItem(_:afterItem:)``
 ``moveItem(_:beforeItem:)``
 ``moveSection(_:afterSection:)``
 ``moveSection(_:beforeSection:)``
 
 ### Reloading data
 
 ``reconfigureItems(_:)``
 ``reconfiguredItems``
 ``reloadItems(_:)``
 ``reloadedItems``
 ``reloadSections(_:)``
 ``reloadedSections``
 */
*/
