//
//  CellOutlineVItem.swift
//  
//
//  Created by Florian Zand on 20.01.25.
//

import AppKit

/*
public protocol OutlineItemObject: AnyObject, Hashable {
    /// The parent of the item.
    var parent: Self? { get set }
    
    /// The children of the item.
    var children: [Self] { get set }
    
    /**
     A Boolean value indicating whether the item is expanded.
     
     The default value is `true`.
     */
    var isExpanded: Bool { get set }

    /**
     A Boolean value indicating whether the item can be expanded / collapsed by the user.
     
     The default value is `true`.
     */
    var isExpandable: Bool { get }
    
    /**
     A Boolean value indicating whether the item can be selected.
     
     The default value is `true`.
     */
    var isSelectable: Bool { get }
    
    /**
     A Boolean value indicating whether the item can be deleted by the user pressing `Backspace`.
     
     The default value is `false`.
     */
    var isDeletable: Bool { get }
    
    /**
     A Boolean value indicating whether the item can be reorded.
     
     The default value is `false`.
     */
    var isReordable: Bool { get }
}
 

extension OutlineItemObject {
    public var isExpandable: Bool { !children.isEmpty }
    public var isSelectable: Bool { true }
    public var isDeletable: Bool { false }
    public var isReordable: Bool { false }
    
    /// Checks if the specified item is a children of the items or the items children.
    public func contains(_ item: Self) -> Bool {
        children.contains(item) || children.contains(where: { $0.contains($0) })
    }
}
 */

/*
import AppKit

/// A outline view item that creates it's cell view.
public protocol CellOutlineItem: Hashable {
    /// Returns the cell view for the item.
    func cellView(_ outlineView: NSOutlineView, column: NSTableColumn, row: Int) -> NSView
    
    /**
     A Boolean value indicating whether the item can be expanded / collapsed by the user.
     
     The default value is `true`.
     */
    var isExpandable: Bool { get }
    
    /**
     A Boolean value indicating whether the item can be selected.
     
     The default value is `true`.
     */
    var isSelectable: Bool { get }
    
    /**
     A Boolean value indicating whether the item can be deleted by the user pressing `Backspace`.
     
     The default value is `false`.
     */
    var isDeletable: Bool { get }
    
    /**
     A Boolean value indicating whether the item can be reorded.
     
     The default value is `false`.
     */
    var isReordable: Bool { get }
    
    /**
     A Boolean value indicating whether the user can insert items as children.
     
     The default value is `true`.
     */
    var canInsertChildren: Bool { get }
    
    /**
     A Boolean value indicating whether the item is a group item.
     
     The default value is `false`.
     */
    var isGroupItem: Bool { get }
}

extension CellOutlineItem {
    public var isExpandable: Bool { true }
    public var isSelectable: Bool { true }
    public var isDeletable: Bool { false }
    public var isReordable: Bool { false }
    public var canInsertChildren: Bool { true }
    public var isGroupItem: Bool { false }
}

/// A outline view item that creates it's cell view.
public protocol RegisteredCellOutlineItem: CellOutlineItem {
    associatedtype Cell: NSTableCellView
    /// The cell registration that creates the cell view for the item.
    static var cellRegistration:  NSTableView.CellRegistration<Cell, Self> { get }
}

extension RegisteredCellOutlineItem {
    public func cellView(_ outlineView: NSOutlineView, column: NSTableColumn, row: Int) -> NSView {
        outlineView.makeCellView(using: Self.cellRegistration, forColumn: column, row: row, item: self) ?? NSTableCellView()
    }
}
*/
