//
//  newww.swift
//  NSCollectionViewDiffableSectionDataSource
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit

extension CollectionViewDiffableDataSource {
    public struct SelectionHandlers<E> {
        public var shouldSelect: (([E]) -> [E])? = nil
        public var shouldDeselect: (([E]) -> [E])? = nil
        public var didSelect: (([E]) -> Void)? = nil
        public var didDeselect: (([E]) -> Void)? = nil
    }
    
    public struct DragdropHandlers<E> {
        public var canDropOutside: (([E]) -> [E])? = nil
        public var dropOutside: (([E]) -> [AnyObject])? = nil
        public var canDrag: (([AnyObject]) -> Bool)? = nil
        public var dragOutside: (([E]) -> [AnyObject])? = nil
        public var draggingImage: (([E], NSEvent, NSPointPointer) -> NSImage?)? = nil
    }
    
    public struct HighlightHandlers<E> {
        public var shouldChangeItems: (([E], NSCollectionViewItem.HighlightState) -> [E])? = nil
        public var didChangeItems: (([E], NSCollectionViewItem.HighlightState) -> ())? = nil
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
    
    public struct QuicklookHandlers<E> {
        public var preview: (([E]) -> [(element: Element, url: URL)]?)?
        public var endPreviewing: (([E]) ->  [(element: Element, url: URL)]?)?
    }
    
    public struct MouseHandlers<E> {
        public var mouseClick: ((_ point: CGPoint, _ count: Int, _ element: E?) -> Void)? = nil
        public var rightMouseClick: ((_ point: CGPoint, _ count: Int, _ element: E?) -> Void)? = nil
        public var mouseDragged: ((_ point: CGPoint, _ element: E?) -> Void)? = nil
    //   var mouseEntered: ((CGPoint) -> Void)? = nil
        public var mouseMoved: ((CGPoint) -> Void)? = nil
     //   var mouseExited: ((CGPoint) -> Void)? = nil
    }
    
    public struct HoverHandlers<E> {
        public var isHovering: ((E) -> Void)?
        public var didEndHovering: ((E) -> Void)?
    }
    
    public struct SectionHandlers<Section> {
        public var shouldCollapse: ((Section) -> Bool)?
        public var willCollapse: ((Section) -> Void)?
        public var shouldExpand: ((Section) -> Bool)?
        public var willExpand: ((Section) -> Void)?
        public var canReorder: ((Section) -> Bool)?
        public var didReorder: ((Section) -> Void)?
    }
}
