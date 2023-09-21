//
//  File.swift
//  
//
//  Created by Florian Zand on 02.08.23.
//

import AppKit
import FZUIKit

extension AdvanceTableViewDiffableDataSource {
    public struct SelectionHandlers {
        /// Handler that determines whether items should get selected.
        public var shouldSelect: (([Item]) -> [Item])? = nil
        /// Handler that determines whether items should get deselected.
        public var shouldDeselect: (([Item]) -> [Item])? = nil
        /// Handler that gets called whenever items get selected.
        public var didSelect: (([Item]) -> Void)? = nil
        /// Handler that gets called whenever items get deselected.
        public var didDeselect: (([Item]) -> Void)? = nil
    }
    
    /// Handlers for reordering items.
    public struct ReorderingHandlers {
        /// The handler that determines whether you can reorder a particular item.
        public var canReorder: (([Item]) -> Bool)? = nil
        /// Handler that prepares the diffable data source for reordering its items.
        public var willReorder: ((DiffableDataSourceTransaction<Section, Item>) -> ())? = nil
        /// Handler that processes a reordering transaction.
        public var didReorder: ((DiffableDataSourceTransaction<Section, Item>) -> ())? = nil
    }
    
    /// Handlers for deletion.
    public struct DeletionHandlers {
        /// Handler that determines whether Itemlements should get deleted.
        public var shouldDelete: ((_ items: [Item]) -> [Item])? = nil
        /// Handler that gets called whenever Itemlements get deleted.
        public var didDelete: ((_ items: [Item]) -> ())? = nil
    }
    
    public struct DragdropHandlers {
        public var canDropOutside: ((Item) -> PasteboardWriting)? = nil
        public var didDropOutside: ((Item) -> ())? = nil
        public var canDragInside: (([PasteboardWriting]) -> [PasteboardWriting])? = nil
        public var didDragInside:  (([PasteboardWriting]) -> ())? = nil
        internal var acceptsDropInside: Bool {
            self.canDragInside != nil && self.didDragInside != nil
        }
        
        internal var acceptsDragOutside: Bool {
            self.canDropOutside != nil
        }
    }
    
    /// Handlers that get called whenever the mouse is hovering an item.
    public struct HoverHandlers {
        /// The handler that gets called whenever the mouse is hovering an item.
        public var isHovering: ((Item) -> Void)?
        /// The handler that gets called whenever the mouse did end hovering an item.
        public var didEndHovering: ((Item) -> Void)?
    }
    
    public struct ColumnHandlers {
        public var didResize: ((_ column: NSTableColumn, _ oldWidth: CGFloat) -> ())?
        public var didReorder: ((_ column: NSTableColumn, _ oldIndex: Int, _ newIndex: Int) -> ())?
        public var shouldReorder: ((_ column: NSTableColumn, _ newIndex: Int) -> Bool)?
    }
}
