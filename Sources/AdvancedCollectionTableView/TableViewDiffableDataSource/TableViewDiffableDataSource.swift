//
//  CollectionViewDiffableDataSource.swift
//  Coll
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZExtensions

public class TableViewDiffableDataSource<Section: HashIdentifiable, Element: HashIdentifiable>: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    public typealias CollectionSnapshot = NSDiffableDataSourceSnapshot<Section,  Element>
    public typealias CellProvider = (NSTableView, NSTableColumn, Int, Element) -> NSTableCellView?
    public typealias RowProvider = (NSTableView, Int, Element) -> NSTableRowView?

    var rowProvider: RowProvider = {tableView, row, element in
        return nil
    }
    
    var cellProvider: CellProvider = {tableView, column, row, element in
        return nil
    }
    
    let tableView: NSTableView
  
    public init(tableView: NSTableView, cellProvider: @escaping CellProvider) {
        self.tableView = tableView
        self.cellProvider = cellProvider
        super.init()
        sharedInit()
    }
    
    public init(tableView: NSTableView, cellProvider: @escaping CellProvider, rowProvider:  @escaping RowProvider) {
        self.tableView = tableView
        self.cellProvider = cellProvider
        self.rowProvider = rowProvider
        super.init()
        sharedInit()
    }

    internal func sharedInit() {
    
    }
}
    


