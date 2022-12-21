//
//  File.swift
//  
//
//  Created by Florian Zand on 21.12.22.
//

import AppKit



extension TableViewDiffableDataSource {
    public struct SelectionHandlers<E> {
        var shouldSelect: (([E]) -> [E])? = nil
        var shouldDeselect: (([E]) -> [E])? = nil
        var didSelect: (([E]) -> Void)? = nil
        var didDeselect: (([E]) -> Void)? = nil
    }
    
    public struct DragdropHandlers<E> {
        var canDropOutside: (([E]) -> [E])? = nil
        var dropOutside: (([E]) -> [AnyObject])? = nil
        var canDrag: (([AnyObject]) -> Bool)? = nil
        var dragOutside: (([E]) -> [AnyObject])? = nil
        var draggingImage: (([E], NSEvent, NSPointPointer) -> NSImage?)? = nil
    }
    
    public struct ReorderHandlers<E> {
        var canReorder: (([E]) -> Bool)? = nil
        var willReorder: (([E]) -> Void)? = nil
        var didReorder: (([E]) -> Void)? = nil
    }
    
    public struct PrefetchHandlers<E> {
        var willPrefetch: (([E]) -> Void)? = nil
        var didCancelPrefetching: (([E]) -> Void)? = nil
    }
    
    public struct DisplayHandlers<E> {
        var isDisplaying: (([E]) -> Void)?
        var didEndDisplaying: (([E]) -> Void)?
    }
    
    public struct QuicklookHandlers<E> {
        var preview: (([E]) -> [(element: Element, url: URL)]?)?
        var endPreviewing: (([E]) ->  [(element: Element, url: URL)]?)?
    }
    
    public struct MouseHandlers<E> {
        var mouseClick: ((CGPoint, Int, E?) -> Void)? = nil
        var rightMouseClick: ((CGPoint, Int, E?) -> Void)? = nil
        var mouseDragged: ((CGPoint, E?) -> Void)? = nil
    }
    
    public struct HoverHandlers<E> {
        var isHovering: ((E) -> Void)?
        var didEndHovering: ((E) -> Void)?
    }
    
    public struct ColumnHandlers<Section> {
        var allowsRenaming: ((NSTableColumn) -> Bool)?
        var didRename: (([NSTableColumn]) -> ())?
        var alowsReordering: (([NSTableColumn]) -> Bool)?
        var didReorder: (([NSTableColumn]) -> ())?
    }
}
