//
//  newww.swift
//  NSCollectionViewDiffableSectionDataSource
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit

extension CollectionViewDiffableDataSource {
    /// Handlers for selection.
    public struct SelectionHandlers<E> {
        public var shouldSelect: ((_ elements: [E]) -> [E])? = nil
        public var shouldDeselect: ((_ elements: [E]) -> [E])? = nil
        public var didSelect: ((_ elements: [E]) -> ())? = nil
        public var didDeselect: ((_ elements: [E]) -> ())? = nil
    }
    
    public struct DragdropHandlers<E> {
        public var canDropOutside: ((_ elements: [E]) -> [E])? = nil
        public var dropOutside: ((_ elements: [E]) -> [AnyObject])? = nil
        public var canDrag: (([AnyObject]) -> Bool)? = nil
        public var dragOutside: ((_ elements: [E]) -> [AnyObject])? = nil
        public var draggingImage: ((_ elements: [E], NSEvent, NSPointPointer) -> NSImage?)? = nil
    }
    
    public struct HighlightHandlers<E> {
        public var shouldChangeItems: ((_ elements: [E], NSCollectionViewItem.HighlightState) -> [E])? = nil
        public var didChangeItems: ((_ elements: [E], NSCollectionViewItem.HighlightState) -> ())? = nil
    }
    
    /// Handlers for reordering items.
    public struct ReorderingHandlers<E> {
        /// The handler that determines whether you can reorder a particular item.
        public var canReorder: ((_ elements: [E]) -> Bool)? = nil
        /// The handler that prepares the diffable data source for reordering its items.
        public var willReorder: ((_ elements: [E]) -> ())? = nil
        /// The handler that processes a reordering transaction.
        public var didReorder: ((_ elements: [E]) -> ())? = nil
    }
    
    /// Handlers for prefetching items.
    public struct PrefetchHandlers<E> {
        /// Handler that tells you to begin preparing data for the elements.
        public var willPrefetch: ((_ elements: [E]) -> ())? = nil
        /// Cancels a previously triggered data prefetch request.
        public var didCancelPrefetching: ((_ elements: [E]) -> ())? = nil
    }
    
    /// Handlers for displayig items.
    public struct DisplayHandlers<E> {
        public var isDisplaying: ((_ elements: [E]) -> ())?
        public var didEndDisplaying: ((_ elements: [E]) -> ())?
    }
    
    public struct QuicklookHandlers<E> {
        public var preview: (([E]) -> [(element: Element, url: URL)]?)?
        public var endPreviewing: ((_ elements: [E]) ->  [(element: Element, url: URL)]?)?
    }
    
    public struct MouseHandlers<E> {
        public var mouseClick: ((_ point: CGPoint, _ count: Int, _ element: E?) -> ())? = nil
        public var rightMouseClick: ((_ point: CGPoint, _ count: Int, _ element: E?) -> ())? = nil
        public var mouseDragged: ((_ point: CGPoint, _ element: E?) -> ())? = nil
    //   var mouseEntered: ((CGPoint) -> ())? = nil
        public var mouseMoved: ((CGPoint) -> ())? = nil
     //   var mouseExited: ((CGPoint) -> ())? = nil
    }
    
    public struct HoverHandlers<E> {
        public var isHovering: ((_ element: E) -> ())?
        public var didEndHovering: ((_ element: E) -> ())?
    }
    
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
        ///         /// The handler that determines whether a particular section can be reordered.
        public var canReorder: ((_ section: Section) -> Bool)?
        public var didReorder: ((_ section: Section) -> ())?
    }
}
