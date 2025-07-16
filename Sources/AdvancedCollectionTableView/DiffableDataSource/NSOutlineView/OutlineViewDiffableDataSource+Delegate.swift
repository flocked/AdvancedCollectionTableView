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
        var previousSelectedItems: [Item] = []
        
        func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
            previousSelectedItems = outlineView.selectedRowIndexes.compactMap({ outlineView.item(atRow: $0) as? Item })
            let diff = outlineView.selectedRowIndexes.difference(to: proposedSelectionIndexes)
            
            var selected = diff.added.compactMap({ outlineView.item(atRow: $0) as? Item })
            selected = selected.filter({ !self.outlineView(outlineView, isGroupItem: $0) })
            if !selected.isEmpty {
                selected = dataSource.selectionHandlers.shouldSelect?(selected) ?? selected
            }

            var deselected = diff.removed.compactMap({ outlineView.item(atRow: $0) as? Item })
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
            if self.outlineView(dataSource.outlineView, isGroupItem: item) {
                let rowView = outlineView.makeView(withIdentifier: "_GroupRowView", owner: self) as? NSTableRowView ?? NSTableRowView()
                rowView.identifier = "_GroupRowView"
                return rowView
            } else if let view = dataSource.rowViewProvider?(outlineView, dataSource.row(for: item as! Item)!, item as! Item) {
                return view
            } else {
                let rowView = outlineView.makeView(withIdentifier: "_RowView", owner: self) as? NSTableRowView ?? NSTableRowView()
                rowView.identifier = "_RowView"
                return rowView
            }
        }
        
        func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
            guard !dataSource.isApplyingSnapshot else { return true }
            return dataSource.expanionHandlers.shouldExpand?(item as! Item) ?? true
        }
        
        func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
            guard !dataSource.isApplyingSnapshot else { return true }
            return dataSource.expanionHandlers.shouldCollapse?(item as! Item) ?? true
        }
        
        func outlineViewItemDidExpand(_ notification: Notification) {
            guard !dataSource.isApplyingSnapshot, let item = notification.userInfo?["NSObject"] as? Item else { return }
            dataSource.expanionHandlers.didExpand?(item)
            dataSource.currentSnapshot.expand([item])
        }
        
        func outlineViewItemDidCollapse(_ notification: Notification) {
            guard !dataSource.isApplyingSnapshot, let item = notification.userInfo?["NSObject"] as? Item else { return }
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
            if self.outlineView(outlineView, isGroupItem: item), let groupItemCellProvider = dataSource.groupItemCellProvider {
                let rowView = outlineView.makeView(withIdentifier: "_GroupCellRowView", owner: self) as? GroupItemCellRowView ?? GroupItemCellRowView()
                rowView.identifier = "_GroupCellRowView"
                NSAnimationContext.performWithoutAnimation {
                    rowView.view = groupItemCellProvider(outlineView, item as! Item)
                }
                return rowView
            } else {
                return dataSource.cellProvider(outlineView, tableColumn!, item as! Item)
            }
        }
        
        func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
            if !dataSource.groupItemsAreCollapsable, self.outlineView(outlineView, isGroupItem: item) {
                return false
            }
            return true
        }
        
        func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
            guard let item = item as? Item, dataSource.groupItemCellProvider != nil else { return false }
            return dataSource.currentSnapshot.rootItems.contains(item)
        }
        
        func outlineView(_ outlineView: NSOutlineView, tintConfigurationForItem item: Any) -> NSTintConfiguration? {
            guard let item = item as? Item else { return nil }
            return dataSource.tintConfigurationProvider?(item)
        }
        
        init(_ dataSource: OutlineViewDiffableDataSource!) {
            self.dataSource = dataSource
        }
    }
}

fileprivate class GroupItemCellRowView: NSTableRowView {
    var view: NSView? {
        didSet {
            guard oldValue !== view else { return }
            oldValue?.removeFromSuperview()
            guard let view = view else { return }
            addSubview(withConstraint: view)
        }
    }
}

/*
 fileprivate class GroupItemRowView: NSTableRowView {
     
     var mouseEntered = false
     var trackingArea: TrackingArea?
     var disclosureButton: NSButton?
     
     override func mouseEntered(with event: NSEvent) {
         mouseEntered = true
     }
     
     override func mouseExited(with event: NSEvent) {
         disclosureButton?.isHidden = false
         mouseEntered = false
     }
     
     override func updateTrackingAreas() {
         super.updateTrackingAreas()
         trackingArea?.update()
     }
     
     func setupDisclosureButton(for outlineView: NSOutlineView, displaysAlways: Bool) {
         guard disclosureButton == nil || disclosureButton?.target !== outlineView else {
             if displaysAlways {
                 disclosureButton?.state = .on
             }
             return
         }
         disclosureButton?.removeFromSuperview()
         disclosureButton = outlineView.makeView(withIdentifier: NSOutlineView.showHideButtonIdentifier, owner: nil) as? NSButton
         disclosureButton?.state = displaysAlways ? .on : .off
         addSubview(disclosureButton!)
         updateDisclosureButton()
         trackingArea = TrackingArea(for: self, options: [.activeAlways,.mouseEnteredAndExited])
         updateTrackingAreas()
     }
     
     override func addSubview(_ view: NSView) {
         super.addSubview(view)
         if view != disclosureButton && view.identifier == NSOutlineView.showHideButtonIdentifier, mouseEntered {
             disclosureButton?.isHidden = true
         }
     }
     
     override func layout() {
         super.layout()
         updateDisclosureButton()
     }
     
     func updateDisclosureButton() {
         guard let button = disclosureButton else { return }
         button.frame.origin = CGPoint(x: bounds.width - 22.5, y: (bounds.height/2.0)-(button.bounds.height/2.0))
     }
     
     func removeDisclosureButton() {
         disclosureButton?.removeFromSuperview()
         disclosureButton = nil
         trackingArea = nil
     }
 }
 */
