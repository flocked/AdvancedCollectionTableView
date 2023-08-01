//
//  AdvanceTableViewDiffableDataSource.swift
//  Coll
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import FZQuicklook

/**
 This object is an advanced version or NSTableViewDiffableDataSource. It provides:
 
 - Reordering of rows by enabling `allowsReording`and optionally providing blocks to `reorderingHandlers`.
 - Deleting of rows by enabling `allowsDeleting`and optionally providing blocks to `DeletionHandlers`.
 - Quicklooking of rows via spacebar by providing elements conforming to `QuicklookPreviewable`.
 - Handlers for selection of rows `selectionHandlers`.
 - Handlers for rows that get hovered by mouse `hoverHandlers`.
 - Providing a right click menu for selected rows via `menuProvider` block.
 */
public class AdvanceTableViewDiffableDataSource<Section: Identifiable & Hashable, Element: Identifiable & Hashable>: NSObject, NSTableViewDataSource {
    public typealias CollectionSnapshot = NSDiffableDataSourceSnapshot<Section,  Element>
    public typealias CellProvider = (NSTableView, NSTableColumn, Int, Element) -> NSTableCellView
    public typealias RowProvider = (NSTableView, Int, Element) -> NSTableRowView
    
    internal typealias InternalSnapshot = NSDiffableDataSourceSnapshot<Section.ID,  Element.ID>
    internal typealias DataSoure = NSTableViewDiffableDataSource<Section.ID,  Element.ID>

    public var rowProvider: RowProvider? = nil {
        didSet { self.setupRowProvider() }
    }
    
    public var cellProvider: CellProvider
    
    public let tableView: NSTableView
    internal var dataSource: DataSoure!
    internal var draggingRows = Set<Int>()
    internal var delegateBridge: DelegateBridge<Section, Element>!
    internal var responder: Responder<Section, Element>!
    internal var scrollView: NSScrollView? { return tableView.enclosingScrollView }
    internal var currentSnapshot: CollectionSnapshot = CollectionSnapshot()
    internal var sections: [Section] { currentSnapshot.sectionIdentifiers }
    internal var draggingIndexPaths = Set<IndexPath>()
    internal let pasteboardType = NSPasteboard.PasteboardType("DiffableCollection.Pasteboard")
    internal var hoverElement: Element? = nil {
        didSet {
            guard oldValue != self.hoverElement else { return }
            if let hoverElement = hoverElement, hoverElement.id != oldValue?.id {
                hoverHandlers.isHovering?(hoverElement)
            }
            if let oldValue = oldValue, oldValue.id != hoverElement?.id {
                hoverHandlers.didEndHovering?(oldValue)
            }
        }
    }
    
    /// Handlers that get called whenever the table view receives mouse click events of rows.
    public var mouseHandlers = MouseHandlers<Element>()
    
    /// Handlers that get called whenever the mouse is hovering a row.
    public var hoverHandlers = HoverHandlers<Element>() {
        didSet { self.setupHoverObserving()} }
    
    /// Handlers for selection of rows.
    public var selectionHandlers = SelectionHandlers<Element>()
    
    /// Handlers for deletion of rows.
    public var deletionHandlers = DeletionHandlers<Element>()
    
    /// Handlers for reordering of rows.
    public var reorderHandlers = ReorderHandlers<Element>()
    
    ///Handlers for displaying of rows. The handlers get called whenever the table view is displaying new rows (e.g. when the enclosing scrollview gets scrolled to new rows).
    public var displayHandlers = DisplayHandlers<Element>() {
        didSet {  self.ensureTrackingDisplayingRows() } }
    
    /// Handlers for prefetching elements.
    public var prefetchHandlers = PrefetchHandlers<Element>()
    
    /// Handlers for drag and drop of files from and to the table view.
    public var dragDropHandlers = DragdropHandlers<Element>() {
        didSet { self.setupDragging() } }
    
    /// Handlers for table columns.
    public var columnHandlers = ColumnHandlers<Element>()
    
    /**
    Right click menu provider for selected rows.
     
    When returning a menu to the `menuProvider`, the table view will display a menu on right click of selected rows.
     */
    public var menuProvider: ((_ elements: [Element]) -> NSMenu?)? = nil
    
    /**
    Provides an array of row actions to be attached to the specified edge of a table row and displayed when the user swipes horizontally across the row.     
     */
    public var rowActionProvider: ((_ element: Element, _ edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction])? = nil
    
    /// A handler that gets called whenever table view receives a keydown event.
    public var keydownHandler: ((_ keyCode: Int, _ modifierFlags: NSEvent.ModifierFlags) -> Bool)? = nil
    
    /**
     A Boolean value that indicates whether users can delete items either via keyboard shortcut or right click menu.

     If the value of this property is true (the default is false), users can delete items.
     */
    public var allowsDeleting: Bool = false {
        didSet { self.setupKeyDownMonitor() }
    }
    /**
     A Boolean value that indicates whether users can reorder items in the table view when dragging them via mouse.

     If the value of this property is true (the default is false), users can reorder items in the table view.
     */
    public var allowsReordering: Bool = false
    /**
     A Boolean value that indicates whether users can select items while an section is collapsed in the table view.

     If the value of this property is true (the default), users can select items while an section is collapsed.
     */
    public var allowsSectionCollapsing: Bool = true
    /**
     A Boolean value that indicates whether users can select items in the table view.

     If the value of this property is true (the default), users can select items.
     */
    public var allowsSelectable: Bool {
        get { self.tableView.isEnabled }
        set { self.tableView.isEnabled = newValue } }
    /**
     A Boolean value that determines whether users can select more than one item in the table view.

     This property controls whether multiple items can be selected simultaneously. The default value of this property is false.
     When the value of this property is true, tapping a cell adds it to the current selection (assuming the delegate permits the cell to be selected). Tapping the item again removes it from the selection.
     */
    public var allowsMultipleSelection: Bool {
        get { self.tableView.allowsMultipleSelection }
        set { self.tableView.allowsMultipleSelection = newValue } }
    /**
     A Boolean value indicating whether the table view may have no selected items.

     The default value of this property is true, which allows the table view to have no selected items. Setting this property to false causes the table view to always leave at least one item selected.
     */
    public var allowsEmptySelection: Bool {
        get { self.tableView.allowsEmptySelection }
        set { self.tableView.allowsEmptySelection = newValue } }
    
    internal func setupDragging() {
        if dragDropHandlers.acceptsDropInside {
            self.tableView.registerForDraggedTypes([.fileURL, .png, .tiff, .string])
        } else {
            self.tableView.unregisterDraggedTypes()
        }
        
        if (dragDropHandlers.acceptsDragOutside) {
            self.tableView.setDraggingSourceOperationMask(.copy, forLocal: false)
        } else {
            self.tableView.setDraggingSourceOperationMask([], forLocal: false)
        }
    }
    
    internal func isHovering(_ row: NSTableRowView) {
        let rowIndex = self.tableView.row(for: row)
        guard rowIndex >= 0, let element = self.element(for: rowIndex) else { return }
        self.hoverHandlers.isHovering?(element)
    }
    
    internal func didEndHovering(_ row: NSTableRowView) {
        let rowIndex = self.tableView.row(for: row)
        guard rowIndex >= 0, let element = self.element(for: rowIndex) else { return }
        self.hoverHandlers.didEndHovering?(element)
    }
    
    internal func setupHoverObserving() {
        if self.hoverHandlers.isHovering != nil || self.hoverHandlers.didEndHovering != nil {
            self.tableView.setupObservingView()
        }
    }
    
    internal func ensureTrackingDisplayingRows() {
        if (self.displayHandlers.isDisplaying != nil || self.displayHandlers.didEndDisplaying != nil) {
            scrollView?.contentView.postsBoundsChangedNotifications = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(scrollViewContentBoundsDidChange(_:)),
                                                   name: NSView.boundsDidChangeNotification,
                                                   object: scrollView?.contentView)
        } else {
            scrollView?.contentView.postsBoundsChangedNotifications = false
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    internal var previousDisplayingElements = [Element]()
    @objc internal func scrollViewContentBoundsDidChange(_ notification: Notification) {
        guard (notification.object as? NSClipView) != nil else { return }
        let displayingElements = self.visibleElements
        var added = [Element]()
        var removed = [Element]()
        for displayingElement in displayingElements {
            if (previousDisplayingElements.contains(displayingElement) == false) {
                added.append(displayingElement)
            }
        }
        for previousDisplayingElement in previousDisplayingElements {
            if (displayingElements.contains(previousDisplayingElement) == false) {
                removed.append(previousDisplayingElement)
            }
        }
        if (added.isEmpty == false) {
            self.displayHandlers.isDisplaying?(added)
        }
        if (removed.isEmpty == false) {
            self.displayHandlers.didEndDisplaying?(removed)
        }
        previousDisplayingElements = displayingElements
    }
    
    /**
     Returns a representation of the current state of the data in the table view.

     A snapshot containing section and item identifiers in the order that they appear in the UI.
     */
    public func snapshot() -> CollectionSnapshot {
        var snapshot = CollectionSnapshot()
        snapshot.appendSections(currentSnapshot.sectionIdentifiers)
        for section in currentSnapshot.sectionIdentifiers {
            snapshot.appendItems(currentSnapshot.itemIdentifiers(inSection: section), toSection: section)
        }
        return snapshot
    }
    
    /**
     Updates the UI to reflect the state of the data in the snapshot, optionally animating the UI changes.

     The system interrupts any ongoing item animations and immediately reloads the table view’s content.
     
     - Parameters:
        - snapshot: The snapshot that reflects the new state of the data in the table view.
        - option: Option how to apply the snapshot to the collection view.
        - completion: A optional completion handlers which gets called after applying the snapshot.
     */
    public func apply(_ snapshot: CollectionSnapshot, _ option: NSDiffableDataSourceSnapshotApplyOption = .animated, completion: (() -> Void)? = nil) {
        let internalSnapshot = convertSnapshot(snapshot)
        self.currentSnapshot = snapshot
        self.dataSource.apply(internalSnapshot, option, completion: completion)
    }
    
    internal func convertSnapshot(_ snapshot: CollectionSnapshot) -> InternalSnapshot {
        var internalSnapshot = InternalSnapshot()
        let sections = snapshot.sectionIdentifiers
        internalSnapshot.appendSections(sections.ids)
        for section in sections {
           let elements = snapshot.itemIdentifiers(inSection: section)
            internalSnapshot.appendItems(elements.ids, toSection: section.id)
        }
        return internalSnapshot
    }
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.numberOfRows(in: tableView)
    }
    
    public func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        if (self.draggingRows.isEmpty == false) {
            self.moveElements(at: Array(self.draggingRows), to: row)
        }
        return true
    }
    
    public func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    public func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        self.draggingRows = Set(rowIndexes.compactMap({$0}))
    }
    
    public func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        if let elementID = self.element(for: row)?.id {
            let item = NSPasteboardItem()
            item.setString(String(elementID.hashValue), forType: self.pasteboardType)
            return item
        } else {
            return nil
        }
    }
    
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
    
    public init<C: NSTableCellView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<C, Element>) {
        self.tableView = tableView
        self.cellProvider = { tableView, column, row, elementID in
            tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: elementID)!
        }
        super.init()
        sharedInit()
    }
    
    public init<C: NSTableCellView, R: NSTableRowView>(tableView: NSTableView, cellRegistration: NSTableView.CellRegistration<C, Element>, rowRegistration: NSTableView.RowViewRegistration<R, Element>) {
        self.tableView = tableView
        self.cellProvider = { tableView, column, row, elementID in
            tableView.makeCell(using: cellRegistration, forColumn: column, row: row, element: elementID)!
        }
        self.rowProvider = { tableView, row, elementID in
            tableView.makeRowView(using: rowRegistration, forRow: row, element: elementID)
        }
        super.init()
        sharedInit()
    }
    
    internal func sharedInit() {
        self.configurateDataSource()
        
        self.tableView.postsFrameChangedNotifications = false
        self.tableView.postsBoundsChangedNotifications = false
        
        self.tableView.setupTableViewFirstResponderObserver()

        
        if Element.self is QuicklookPreviewable.Type {
            self.tableView.isQuicklookPreviewable = true
        }
        
        self.tableView.registerForDraggedTypes([pasteboardType])
        self.tableView.setDraggingSourceOperationMask(.move, forLocal: true)
        
        self.responder = Responder(self)
        let tableViewNextResponder = self.tableView.nextResponder
        self.tableView.nextResponder = self.responder
        self.responder.nextResponder = tableViewNextResponder
        
   //     self.tableView.dataSource = self
        self.delegateBridge = DelegateBridge(self)
    }
    
    
    internal func configurateDataSource() {
        self.dataSource = DataSoure(tableView: self.tableView, cellProvider: {
            tableView, column, row, elementID in
            let element = self.allElements[id: elementID]!
                return self.cellProvider(tableView, column, row, element)
        })
        self.setupRowProvider()
    }
    
    internal func setupRowProvider() {
        if let rowProvider = self.rowProvider {
            self.dataSource.rowViewProvider = { tableView, row, identifier in
                return rowProvider(tableView, row, identifier as! Element)
            }
        } else {
            self.dataSource.rowViewProvider = nil
        }
    }
}
    
extension AdvanceTableViewDiffableDataSource: NSTableViewQuicklookProvider {
    public func tableView(_ tableView: NSTableView, quicklookPreviewForRow row: Int) -> QuicklookPreviewable? {
        if let previewable = element(for: row) as? QuicklookPreviewable {
            let rowView = tableView.rowView(atRow: row, makeIfNecessary: false)
            return QuicklookPreviewItem(previewable, view: rowView)
        } else if let rowView = tableView.rowView(atRow: row, makeIfNecessary: false), let preview = rowView.cellViews.first(where: {$0.quicklookPreview != nil})?.quicklookPreview {
            return QuicklookPreviewItem(preview, view: rowView)
        }
        return nil
    }
}
