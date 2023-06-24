//
//  File.swift
//  
//
//  Created by Florian Zand on 21.12.22.
//

import AppKit
import FZUIKit


extension TableViewDiffableDataSource {
    public struct SelectionHandlers<E> {
        public var shouldSelect: (([E]) -> [E])? = nil
        public var shouldDeselect: (([E]) -> [E])? = nil
        public var didSelect: (([E]) -> Void)? = nil
        public var didDeselect: (([E]) -> Void)? = nil
    }
    
    /// Handlers for deletion.
    public struct DeletionHandlers<E> {
        /// Handler that determines whether elements should get deleted.
        public var shouldDelete: ((_ elements: [E]) -> [E])? = nil
        /// Handler that gets called whenever elements get deleted.
        public var didDelete: ((_ elements: [E]) -> ())? = nil
    }
    
    public struct DragdropHandlers<E> {
        public var canDropOutside: ((E) -> PasteboardWriting)? = nil
        public var didDropOutside: ((E) -> ())? = nil
        public var canDragInside: (([PasteboardWriting]) -> [PasteboardWriting])? = nil
        public var didDragInside:  (([PasteboardWriting]) -> ())? = nil
        internal var acceptsDropInside: Bool {
            self.canDragInside != nil && self.didDragInside != nil
        }
        
        internal var acceptsDragOutside: Bool {
            self.canDropOutside != nil
        }
    }
    
    public struct ReorderHandlers<E> {
        public var canReorder: (([E]) -> Bool)? = nil
        public var willReorder: (([E]) -> Void)? = nil
        public var didReorder: (([E]) -> Void)? = nil
    }
    
    public struct PrefetchHandlers<E> {
        public var willPrefetch: (([E]) -> Void)? = nil
        public var didCancelPrefetching: (([E]) -> Void)? = nil
    }
    
    public struct DisplayHandlers<E> {
        public var isDisplaying: (([E]) -> Void)?
        public var didEndDisplaying: (([E]) -> Void)?
    }
    
    public struct MouseHandlers<E> {
        public var mouseClick: ((CGPoint, Int, E?) -> Void)? = nil
        public var rightMouseClick: ((CGPoint, Int, E?) -> Void)? = nil
        public var mouseDragged: ((CGPoint, E?) -> Void)? = nil
    }
    
    public struct HoverHandlers<E> {
        public var isHovering: ((E) -> Void)?
        public var didEndHovering: ((E) -> Void)?
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
