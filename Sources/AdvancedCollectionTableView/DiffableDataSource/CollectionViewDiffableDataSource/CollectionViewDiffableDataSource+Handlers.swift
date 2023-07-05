//
//  newww.swift
//  NSCollectionViewDiffableSectionDataSource
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZUIKit

extension CollectionViewDiffableDataSource {
    /// Handlers for selection.
    public struct SelectionHandlers<E> {
        /// Handler that determines whether elements should get selected.
        public var shouldSelect: ((_ elements: [E]) -> [E])? = nil
        /// Handler that determines whether elements should get deselected.
        public var shouldDeselect: ((_ elements: [E]) -> [E])? = nil
        /// Handler that gets called whenever elements get selected.
        public var didSelect: ((_ elements: [E]) -> ())? = nil
        /// Handler that gets called whenever elements get deselected.
        public var didDeselect: ((_ elements: [E]) -> ())? = nil
    }
    
    /// Handlers for deletion.
    public struct DeletionHandlers<E> {
        /// Handler that determines whether elements should get deleted.
        public var shouldDelete: ((_ elements: [E]) -> [E])? = nil
        /// Handler that gets called whenever elements get deleted.
        public var didDelete: ((_ elements: [E]) -> ())? = nil
    }
    
    /// Handlers for drag and drop of files.
    public struct DragdropHandlers<E> {
        public var canDropOutside: ((_ elements: [E]) -> [E])? = nil
        public var dropOutside: ((_ element: E) -> PasteboardWriting)? = nil
        public var canDrag: (([AnyObject]) -> Bool)? = nil
        public var dragOutside: ((_ elements: [E]) -> [AnyObject])? = nil
        public var draggingImage: ((_ elements: [E], NSEvent, NSPointPointer) -> NSImage?)? = nil
    }
    
    /// Handlers for highlight.
    public struct HighlightHandlers<E> {
        public var shouldChangeItems: ((_ elements: [E], NSCollectionViewItem.HighlightState) -> [E])? = nil
        public var didChangeItems: ((_ elements: [E], NSCollectionViewItem.HighlightState) -> ())? = nil
    }
    
    /// Handlers for reordering items.
    public struct ReorderingHandlers<E> {
        /// Handler that determines whether you can reorder a particular item.
        public var canReorder: ((_ elements: [E]) -> Bool)? = nil
        /// Handler that prepares the diffable data source for reordering its items.
        public var willReorder: ((_ elements: [E]) -> ())? = nil
        /// Handler that processes a reordering transaction.
        public var didReorder: ((_ elements: [E]) -> ())? = nil
    }
    
    /// Handlers for prefetching items.
    public struct PrefetchHandlers<E> {
        /// Handler that tells you to begin preparing data for the elements.
        public var willPrefetch: ((_ elements: [E]) -> ())? = nil
        /// Cancels a previously triggered data prefetch request.
        public var didCancelPrefetching: ((_ elements: [E]) -> ())? = nil
    }
    
    /// Handlers for the displaying items.
    public struct DisplayHandlers<E> {
        /// Handler that gets called whenever elements start getting displayed.
        public var isDisplaying: ((_ elements: [E]) -> ())?
        /// Handler that gets called whenever elements end getting displayed.
        public var didEndDisplaying: ((_ elements: [E]) -> ())?
    }
    
    
    /// Handlers mouse click of elements.
    public struct MouseHandlers<E> {
        /// Handler that gets called whenever the mouse is clicking an element.
        public var mouseClick: ((_ point: CGPoint, _ clickCount: Int, _ element: E) -> ())? = nil
        /// Handler that gets called whenever the mouse is right-clicking an element.
        public var rightMouseClick: ((_ point: CGPoint, _ clickCount: Int, _ element: E) -> ())? = nil
   //     public var mouseDragged: ((_ point: CGPoint, _ element: E?) -> ())? = nil
    //   var mouseEntered: ((CGPoint) -> ())? = nil
//        public var mouseMoved: ((CGPoint) -> ())? = nil
     //   var mouseExited: ((CGPoint) -> ())? = nil
    }
    
    /// Handlers that get called whenever the mouse is hovering an item.
    public struct HoverHandlers<E> {
        /// The handler that gets called whenever the mouse is hovering an item.
        public var isHovering: ((_ element: E) -> ())?
        /// The handler that gets called whenever the mouse did end hovering an item.
        public var didEndHovering: ((_ element: E) -> ())?
    }
    
    /*
    /// Handlers for expanding and collapsing items.
    public struct SectionHandlers<Section> {
        /// The handler that determines whether a particular section is collapsable.
        public var shouldCollapse: ((_ section: Section) -> Bool)?
        /// The handler that determines whether a particular section is expandable.
        public var shouldExpand: ((_ section: Section) -> Bool)?
        /// The handler that prepares the diffable data source for collapsing an section.
        public var willCollapse: ((_ section: Section) -> ())?
        /// The handler that prepares the diffable data source for expanding an section.
        public var willExpand: ((_ section: Section) -> ())?
        /// The handler that determines whether a particular section can be reordered.
        public var canReorder: ((_ section: Section) -> Bool)?
        public var didReorder: ((_ section: Section) -> ())?
    }
     */
}
