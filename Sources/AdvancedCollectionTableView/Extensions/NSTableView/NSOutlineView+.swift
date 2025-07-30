//
//  NSOutlineView+.swift
//  
//
//  Created by Florian Zand on 30.07.25.
//

import AppKit
import FZUIKit

extension NSOutlineView {
    /**
     Updates the data for the items you specify, preserving the existing row views and cells for the rows.

     To update the contents of existing (including prefetched) cells without replacing them with new row views nad cells, use this method instead of ``AppKit/NSOutlineView/reloadItems(_:)``. For optimal performance, choose to reconfigure rows instead of reloading rows unless you have an explicit need to replace the existing row view or cells with new.
     
     - Parameter items: The items you want to update.
     */
    public func reconfigurateItems(_ items: [Any]) {
        let rows = items.map({ row(forItem: $0) }).filter({ $0 != -1 })
        guard !rows.isEmpty else { return }
        reconfigureRows(at: IndexSet(rows))
    }
}
