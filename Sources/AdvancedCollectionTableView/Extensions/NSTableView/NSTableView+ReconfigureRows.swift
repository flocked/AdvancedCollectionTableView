//
//  NSTableView+ReconfigurateRows.swift
//
//
//  Created by Florian Zand on 18.05.22.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSTableView {
    /**
     Updates the data for the rows at the indexes you specify, preserving the existing row views and cells for the rows.

     To update the contents of existing (including prefetched) cells without replacing them with new row views nad cells, use this method instead of [reloadData(forRowIndexes:columnIndexes:)](https://developer.apple.com/documentation/appkit/nstableview/reloaddata(forrowindexes:columnindexes:)). For optimal performance, choose to reconfigure rows instead of reloading rows unless you have an explicit need to replace the existing row view or cells with new.
     
     - Parameter indexes: The indexes you want to update.
     */
    public func reconfigureRows(at indexes: IndexSet) {
        let indexes = indexes.filter({$0 >= 0 && $0 < numberOfRows})
        let columns = (0..<numberOfColumns).map({$0})
        guard !indexes.isEmpty, !columns.isEmpty else { return }
        reconfigureRows(at: IndexSet(indexes), columns: IndexSet(columns))
    }
    
    /**
     Updates the data for the rows at the indexes you specify, preserving the existing row views and cells for the rows.

     To update the contents of existing (including prefetched) cells without replacing them with new row views nad cells, use this method instead of [reloadData(forRowIndexes:columnIndexes:)](https://developer.apple.com/documentation/appkit/nstableview/reloaddata(forrowindexes:columnindexes:)). For optimal performance, choose to reconfigure rows instead of reloading rows unless you have an explicit need to replace the existing row view or cells with new.
     
     - Parameters:
        - indexes: The indexes you want to update.
        - columns: The table columns of the table view to update.
     */
    public func reconfigureRows(at indexes: IndexSet, columns: [NSTableColumn]) {
        let columns = columns.compactMap({ tableColumns.firstIndex(of: $0) })
        guard !columns.isEmpty else { return }
        reconfigureRows(at: indexes, columns: IndexSet(columns))
    }
    
    /**
     Updates the data for the rows at the indexes you specify, preserving the existing row views and cells for the rows.

     To update the contents of existing (including prefetched) cells without replacing them with new row views nad cells, use this method instead of [reloadData(forRowIndexes:columnIndexes:)](https://developer.apple.com/documentation/appkit/nstableview/reloaddata(forrowindexes:columnindexes:)). For optimal performance, choose to reconfigure rows instead of reloading rows unless you have an explicit need to replace the existing row view or cells with new.
     
     - Parameters:
        - indexes: The indexes you want to update.
        - columns: The table column identifiers of the table columns to update.
     */
    public func reconfigureRows(at indexes: IndexSet, columns: [NSUserInterfaceItemIdentifier]) {
        let columns = columns.compactMap({ column(withIdentifier: $0) }).filter({$0 != -1})
        guard !columns.isEmpty else { return }
        reconfigureRows(at: indexes, columns: IndexSet(columns))
    }
    
    fileprivate func reconfigureRows(at rows: IndexSet, columns: IndexSet) {
        Self.swizzleViewRegistration()
        guard let delegate = delegate else { return }
        let tableColumns = tableColumns
        let columns = columns.filter({ $0 >= 0 && $0 < tableColumns.count })
        guard columns.isEmpty else { return }
        for row in rows.filter({ $0 >= 0 && $0 < numberOfRows}) {
            if delegate.tableView?(self, isGroupRow: row) ?? false {
                if rowView(atRow: row, makeIfNecessary: false) != nil {
                    reconfigureIndexPath = IndexPath(item: row, section: 0)
                    _ = delegate.tableView?(self, viewFor: nil, row: row)
                }
            } else {
                for column in columns {
                    if view(atColumn: column, row: row, makeIfNecessary: false) != nil {
                        reconfigureIndexPath = IndexPath(item: row, section: column)
                        _ = delegate.tableView?(self, viewFor: tableColumns[column], row: row)
                    }
                    if rowView(atRow: row, makeIfNecessary: false) != nil {
                        reconfigureIndexPath = IndexPath(item: row, section: -1)
                        _ = delegate.tableView?(self, rowViewForRow: row)
                    }
                }
            }
        }
        reconfigureIndexPath = nil
    }

    var reconfigureIndexPath: IndexPath? {
        get { getAssociatedValue("reconfigureIndexPath") }
        set { setAssociatedValue(newValue, key: "reconfigureIndexPath")
        }
    }
}
#endif
