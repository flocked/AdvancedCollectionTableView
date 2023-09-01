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
        public var shouldSelect: (([Item]) -> [Item])? = nil
        public var shouldDeselect: (([Item]) -> [Item])? = nil
        public var didSelect: (([Item]) -> Void)? = nil
        public var didDeselect: (([Item]) -> Void)? = nil
    }
    
    public struct ReorderHandlers {
        public var canReorder: (([Item]) -> Bool)? = nil
        public var willReorder: (([Item]) -> Void)? = nil
        public var didReorder: (([Item]) -> Void)? = nil
    }
    
    /// Handlers for deletion.
    public struct DeletionHandlers {
        /// Handler that determines whether Itemlements should get deleted.
        public var shouldDelete: ((_ item: [Item]) -> [Item])? = nil
        /// Handler that gets called whenever Itemlements get deleted.
        public var didDelete: ((_ item: [Item]) -> ())? = nil
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
        
    public struct DisplayHandlers {
        public var isDisplaying: (([Item]) -> Void)?
        public var didEndDisplaying: (([Item]) -> Void)?
    }
    
    public struct HoverHandlers {
        public var isHovering: ((Item) -> Void)?
        public var didEndHovering: ((Item) -> Void)?
    }
    
    public struct ColumnHandlers {
        public var didResize: ((_ column: NSTableColumn, _ oldWidth: CGFloat) -> ())?
        public var didReorder: ((_ column: NSTableColumn, _ oldIndex: Int, _ newIndex: Int) -> ())?
        public var shouldReorder: ((_ column: NSTableColumn, _ newIndex: Int) -> Bool)?
    }
}
