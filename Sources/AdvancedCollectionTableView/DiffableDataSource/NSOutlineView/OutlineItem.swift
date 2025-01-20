//
//  OutlineItem.swift
//  
//
//  Created by Florian Zand on 20.01.25.
//

/*
import AppKit

public protocol OutlineItem {
    var isGroupRow: Bool { get }
    func makeCellView(_ outlineView: NSOutlineView, forColumn tableCoulmn: NSTableColumn, row: Int) -> NSView
}
extension OutlineItem {
    public var isGroupRow: Bool {
        false
    }
}

extension OutlineViewDiffableDataSource {
    public convenience init(outlineView: NSOutlineView) where ItemIdentifierType: OutlineItem {
        self.init(outlineView: outlineView, cellProvider: {
            outlineView, column, item in
            item.makeCellView(outlineView, forColumn: column ?? .outline, row: 0)
        })
    }
}

fileprivate extension NSTableColumn {
    static let outline = NSTableColumn()
}
*/
