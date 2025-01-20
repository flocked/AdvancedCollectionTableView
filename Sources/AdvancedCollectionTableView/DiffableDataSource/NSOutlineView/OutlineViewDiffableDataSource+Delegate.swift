//
//  OutlineViewDiffableDataSource+Delegate.swift
//
//
//  Created by Florian Zand on 14.01.25.
//

import AppKit
import FZUIKit
import FZSwiftUtils

extension OutlineViewDiffableDataSource {
    class Delegate: NSObject, NSOutlineViewDelegate {
        weak var dataSource: OutlineViewDiffableDataSource!
        var previousSelectedItems: [ItemIdentifierType] = []
        
        func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
            previousSelectedItems = outlineView.selectedRowIndexes.compactMap({ outlineView.item(atRow: $0) as? ItemIdentifierType })
            let diff = outlineView.selectedRowIndexes.difference(to: proposedSelectionIndexes)
            
            var selected = diff.added.compactMap({ outlineView.item(atRow: $0) as? ItemIdentifierType })
            selected = selected.filter({ !self.outlineView(outlineView, isGroupItem: $0) })
            if !selected.isEmpty {
                selected = dataSource.selectionHandlers.shouldSelect?(selected) ?? selected
            }

            var deselected = diff.removed.compactMap({ outlineView.item(atRow: $0) as? ItemIdentifierType })
            if !deselected.isEmpty {
                let should = dataSource.selectionHandlers.shouldDeselect?(deselected) ?? deselected
                selected += deselected.filter({ !should.contains($0) })
                deselected = deselected.filter({ should.contains($0) })
            }
            
            return IndexSet(selected.compactMap({dataSource.row(for:$0)}) + diff.unchanged)
        }
        
        func outlineViewSelectionDidChange(_: Notification) {
            guard dataSource.selectionHandlers.didSelect != nil || dataSource.selectionHandlers.didDeselect != nil else { return }
            
            let diff = previousSelectedItems.difference(to: dataSource.selectedItems)
            if !diff.added.isEmpty {
                dataSource.selectionHandlers.didSelect?(diff.added)
            }
            if !diff.removed.isEmpty {
                dataSource.selectionHandlers.didDeselect?(diff.removed)
            }
        }
        
        func outlineView(_ outlineView: NSOutlineView, userCanChangeVisibilityOf column: NSTableColumn) -> Bool {
            dataSource.columnHandlers.userCanChangeVisibility?(column) ?? false
        }
        
        func outlineView(_ outlineView: NSOutlineView, userDidChangeVisibilityOf columns: [NSTableColumn]) {
            dataSource.columnHandlers.userDidChangeVisibility?(columns)
        }
        
        func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
            let rowView: NSTableRowView
            if let view = dataSource.rowViewProvider?(outlineView, dataSource.row(for: item as! ItemIdentifierType)!, item as! ItemIdentifierType) {
                rowView = view
            } else {
                rowView = outlineView.makeView(withIdentifier: "_RowView", owner: self) as? NSTableRowView ?? NSTableRowView()
                rowView.identifier = "_RowView"
            }
            if dataSource.currentSnapshot.groupItemsAreExpandable, self.outlineView(dataSource.outlineView, isGroupItem: item) {
                var isExpanded = false
                if let item = item as? ItemIdentifierType {
                    isExpanded = dataSource.currentSnapshot.isExpanded(item)
                }
                let button = rowView.viewWithTag(OutlineButton.tag) as? OutlineButton ?? OutlineButton(for: rowView, dataSource.outlineView)
                button.state = isExpanded ? .on : .off
            } else {
                rowView.viewWithTag(OutlineButton.tag)?.removeFromSuperview()
            }
            return rowView
        }
        
        func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
            guard !dataSource.isExpandingItems else { return true }
            return dataSource.expanionHandlers.shouldExpand?(item as! ItemIdentifierType) ?? true
        }
        
        func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
            guard !dataSource.isExpandingItems else { return true }
            return dataSource.expanionHandlers.shouldCollapse?(item as! ItemIdentifierType) ?? true
        }
        
        func outlineViewItemDidExpand(_ notification: Notification) {
            guard !dataSource.isExpandingItems, let item = notification.userInfo?["NSObject"] as? ItemIdentifierType else { return }
            Swift.print("outlineViewItemDidExpand")
            dataSource.expanionHandlers.didExpand?(item)
            dataSource.currentSnapshot.expand([item])
        }
        
        func outlineViewItemDidCollapse(_ notification: Notification) {
            guard !dataSource.isExpandingItems, let item = notification.userInfo?["NSObject"] as? ItemIdentifierType else { return }
            dataSource.expanionHandlers.didCollapse?(item)
            dataSource.currentSnapshot.collapse([item])
        }
        
        func outlineViewColumnDidMove(_ notification: Notification) {
            guard let didReorder = dataSource.columnHandlers.didReorder else { return }
            guard let oldPos = notification.userInfo?["NSOldColumn"] as? Int,
                  let newPos = notification.userInfo?["NSNewColumn"] as? Int,
                  let tableColumn = dataSource.outlineView.tableColumns[safe: newPos] else { return }
            didReorder(tableColumn, oldPos, newPos)
        }

        func outlineViewColumnDidResize(_ notification: Notification) {
            guard let didResize = dataSource.columnHandlers.didResize else { return }
            guard let tableColumn = notification.userInfo?["NSTableColumn"] as? NSTableColumn, let oldWidth = notification.userInfo?["NSOldWidth"] as? CGFloat else { return }
            didResize(tableColumn, oldWidth)
        }

        func outlineView(_ outlineView : NSOutlineView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
            guard let tableColumn = outlineView.tableColumns[safe: columnIndex] else { return true }
            return dataSource.columnHandlers.shouldReorder?(tableColumn, newColumnIndex) ?? true
        }
        
        func outlineView(_ outlineView: NSOutlineView, didClick tableColumn: NSTableColumn) {
            dataSource.columnHandlers.didClick?(tableColumn)
        }
        
        func outlineView(_ outlineView: NSOutlineView, mouseDownInHeaderOf tableColumn: NSTableColumn) {
            dataSource.columnHandlers.didClickHeader?(tableColumn)
        }
        
        func outlineView(_ outlineView: NSOutlineView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
            dataSource.columnHandlers.sortDescriptorsChanged?(outlineView.sortDescriptors, oldDescriptors)
        }
    
        func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
            let isGroupItem = self.outlineView(outlineView, isGroupItem: item)
            let cellView: NSView
            if isGroupItem, let groupRowCellProvider = dataSource.groupRowCellProvider {
                cellView = groupRowCellProvider(outlineView, tableColumn, item as! ItemIdentifierType)
            } else {
                cellView = dataSource.cellProvider(outlineView, tableColumn, item as! ItemIdentifierType)
            }
            return cellView
        }
        
        func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
            !self.outlineView(outlineView, isGroupItem: item)
        }
        
        func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
            guard let item = item as? ItemIdentifierType, dataSource.currentSnapshot.usesGroupItems else { return false }
            return dataSource.currentSnapshot.rootItems.contains(item)
        }
        
        func outlineView(_ outlineView: NSOutlineView, tintConfigurationForItem item: Any) -> NSTintConfiguration? {
            guard let item = item as? ItemIdentifierType else { return nil }
            return dataSource.tintConfigurationProvider?(item)
        }
        
        init(_ dataSource: OutlineViewDiffableDataSource!) {
            self.dataSource = dataSource
        }
        
        class OutlineButton: NSButton {
            init(for view: NSView, _ outlineView: NSOutlineView) {
                super.init(frame: .zero)
                title = ""
                bezelStyle = .disclosure
                sizeToFit()
                frame.origin = .init(x: view.bounds.width - 20, y: (view.bounds.height/2.0)-(bounds.height/2.0))
                target = outlineView
                action = NSSelectorFromString("_outlineControlClicked:")
                tag = Self.tag
                view.addSubview(self)
                frameObservation = observeChanges(for: \.superview?.frame) { [weak self] old, new in
                    guard let self = self, old?.size != new?.size, let new = new?.size else { return }
                    self.frame.origin = CGPoint(x: new.width - 20, y: (new.height/2.0)-(self.bounds.height/2.0))
                }
            }
            
            static var tag: Int { 3345665333 }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            var frameObservation: KeyValueObservation?
        }
    }
}


/*
extension OutlineViewDiffableDataSource {
    class SectionRowView: NSTableRowView {
        override var frame: NSRect {
            didSet {
                if frame.size.width != 200 {
                    frame.size.width = 200
                }
            }
        }
        
        override var subviews: [NSView] {
            didSet {
            }
        }
        
        var _button: NSButton?
        var buttonSuperviewObservation: KeyValueObservation?
        
        override func addSubview(_ view: NSView) {
            super.addSubview(view)
            if let button = subviews(type: NSButton.self).first {
                _button = button
                buttonSuperviewObservation = button.observeChanges(for: \.superview) { [weak self] old, new in
                    guard let self = self else { return }
                    if new == nil {
                        self.addSubview(button)
                    }
                    button.frame.origin.x = frame.width - button.frame.width
                }
            }
        }
        
        override func viewDidMoveToSuperview() {
            super.viewDidMoveToSuperview()
            if let button = _button, !subviews.contains(button) {
              //  addSubview(button)
            }
        }
    }
}
*/
