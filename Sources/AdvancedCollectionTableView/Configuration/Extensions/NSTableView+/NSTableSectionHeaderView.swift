//
//  NSTableSectionHeaderView.swift
//
//
//  Created by Florian Zand on 17.04.24.
//

import AppKit
import FZSwiftUtils
import FZUIKit

class NSTableSectionHeaderView: NSView {    
    var tableView: NSTableView? {
        firstSuperview(for: NSTableView.self)
    }
    
    var cellView: NSTableCellView? {
        subviews.first as? NSTableCellView
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    init(cellView: NSTableCellView) {
        super.init(frame: .zero)
        addSubview(withConstraint: cellView)
    }
    
    override func viewWillMove(toSuperview newSuperview: NSView?) {
        super.viewWillMove(toSuperview: newSuperview)
        if let tableRowView = newSuperview as? NSTableRowView {
            tableRowView.observeTableRowView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
