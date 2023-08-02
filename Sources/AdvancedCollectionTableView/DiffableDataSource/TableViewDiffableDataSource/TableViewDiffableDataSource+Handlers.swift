//
//  File.swift
//  
//
//  Created by Florian Zand on 02.08.23.
//

import AppKit
import FZUIKit

extension AdvanceTableViewDiffableDataSource {
    public struct SelectionHandlers<Item> {
        public var shouldSelect: (([Item]) -> [Item])? = nil
        public var shouldDeselect: (([Item]) -> [Item])? = nil
        public var didSelect: (([Item]) -> Void)? = nil
        public var didDeselect: (([Item]) -> Void)? = nil
    }
    
    /// Handlers for deletion.
    public struct DeletionHandlers<Item> {
        /// Handler that determines whether Itemlements should get deleted.
        public var shouldDelete: ((_ item: [Item]) -> [Item])? = nil
        /// Handler that gets called whenever Itemlements get deleted.
        public var didDelete: ((_ item: [Item]) -> ())? = nil
    }
    
    public struct DragdropHandlers<Item> {
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
    
    public struct ReorderHandlers<Item> {
        public var canReorder: (([Item]) -> Bool)? = nil
        public var willReorder: (([Item]) -> Void)? = nil
        public var didReorder: (([Item]) -> Void)? = nil
    }
        
    public struct DisplayHandlers<Item> {
        public var isDisplaying: (([Item]) -> Void)?
        public var didEndDisplaying: (([Item]) -> Void)?
    }
    
    public struct MouseHandlers<Item> {
        public var mouseClick: ((CGPoint, Int, Item?) -> Void)? = nil
        public var rightMouseClick: ((CGPoint, Int, Item?) -> Void)? = nil
        public var mouseDragged: ((CGPoint, Item?) -> Void)? = nil
    }
    
    public struct HoverHandlers<Item> {
        public var isHovering: ((Item) -> Void)?
        public var didEndHovering: ((Item) -> Void)?
    }
    
    public struct ColumnHandlers<Section> {
        public var allowsRenaming: ((NSTableColumn) -> Bool)?
        public var didRename: (([NSTableColumn]) -> ())?
        public var alowsReordering: (([NSTableColumn]) -> Bool)?
        public var didReorder: (([NSTableColumn]) -> ())?
        public var didSelect: ((NSTableColumn) -> ())?
        public var shouldSelect:((NSTableColumn?) -> Bool)?
    }
}
