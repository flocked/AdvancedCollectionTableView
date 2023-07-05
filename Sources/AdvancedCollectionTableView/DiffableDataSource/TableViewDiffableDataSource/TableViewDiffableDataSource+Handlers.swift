//
//  File.swift
//  
//
//  Created by Florian Zand on 21.12.22.
//

import AppKit
import FZUIKit


extension TableViewDiffableDataSource {
    public struct SelectionHandlers<Element> {
        public var shouldSelect: (([Element]) -> [Element])? = nil
        public var shouldDeselect: (([Element]) -> [Element])? = nil
        public var didSelect: (([Element]) -> Void)? = nil
        public var didDeselect: (([Element]) -> Void)? = nil
    }
    
    /// Handlers for deletion.
    public struct DeletionHandlers<Element> {
        /// Handler that determines whether Elementlements should get deleted.
        public var shouldDelete: ((_ element: [Element]) -> [Element])? = nil
        /// Handler that gets called whenever Elementlements get deleted.
        public var didDelete: ((_ element: [Element]) -> ())? = nil
    }
    
    public struct DragdropHandlers<Element> {
        public var canDropOutside: ((Element) -> PasteboardWriting)? = nil
        public var didDropOutside: ((Element) -> ())? = nil
        public var canDragInside: (([PasteboardWriting]) -> [PasteboardWriting])? = nil
        public var didDragInside:  (([PasteboardWriting]) -> ())? = nil
        internal var acceptsDropInside: Bool {
            self.canDragInside != nil && self.didDragInside != nil
        }
        
        internal var acceptsDragOutside: Bool {
            self.canDropOutside != nil
        }
    }
    
    public struct ReorderHandlers<Element> {
        public var canReorder: (([Element]) -> Bool)? = nil
        public var willReorder: (([Element]) -> Void)? = nil
        public var didReorder: (([Element]) -> Void)? = nil
    }
    
    public struct PrefetchHandlers<Element> {
        public var willPrefetch: (([Element]) -> Void)? = nil
        public var didCancelPrefetching: (([Element]) -> Void)? = nil
    }
    
    public struct DisplayHandlers<Element> {
        public var isDisplaying: (([Element]) -> Void)?
        public var didEndDisplaying: (([Element]) -> Void)?
    }
    
    public struct MouseHandlers<Element> {
        public var mouseClick: ((CGPoint, Int, Element?) -> Void)? = nil
        public var rightMouseClick: ((CGPoint, Int, Element?) -> Void)? = nil
        public var mouseDragged: ((CGPoint, Element?) -> Void)? = nil
    }
    
    public struct HoverHandlers<Element> {
        public var isHovering: ((Element) -> Void)?
        public var didEndHovering: ((Element) -> Void)?
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
