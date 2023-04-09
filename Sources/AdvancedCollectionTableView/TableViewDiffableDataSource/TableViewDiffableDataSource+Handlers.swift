//
//  File.swift
//  
//
//  Created by Florian Zand on 21.12.22.
//

import AppKit



extension TableViewDiffableDataSource {
    public struct SelectionHandlers<E> {
        var shouldSelect: ((_ elements: [E]) -> [E])? = nil
        var shouldDeselect: ((_ elements: [E]) -> [E])? = nil
        var didSelect: ((_ elements: [E]) -> Void)? = nil
        var didDeselect: ((_ elements: [E]) -> Void)? = nil
    }
    
    public struct DragdropHandlers<E> {
        var canDropOutside: ((_ elements: [E]) -> [E])? = nil
        var dropOutside: ((_ elements: [E]) -> [AnyObject])? = nil
        var canDrag: ((_ objects: [AnyObject]) -> Bool)? = nil
        var dragOutside: ((_ elements: [E]) -> [AnyObject])? = nil
        var draggingImage: ((_ elements: [E], NSEvent, NSPointPointer) -> NSImage?)? = nil
    }
    
    public struct ReorderHandlers<E> {
        var canReorder: ((_ elements: [E]) -> Bool)? = nil
        var willReorder: ((_ elements: [E]) -> Void)? = nil
        var didReorder: ((_ elements: [E]) -> Void)? = nil
    }
    
    public struct PrefetchHandlers<E> {
        var willPrefetch: ((_ elements: [E]) -> Void)? = nil
        var didCancelPrefetching: ((_ elements: [E]) -> Void)? = nil
    }
    
    public struct DisplayHandlers<E> {
        var isDisplaying: ((_ elements: [E]) -> Void)?
        var didEndDisplaying: ((_ elements: [E]) -> Void)?
    }
    
    public struct QuicklookHandlers<E> {
        var preview: ((_ elements: [E]) -> [(element: Element, url: URL)]?)?
        var endPreviewing: ((_ elements: [E]) ->  [(element: Element, url: URL)]?)?
    }
    
    public struct MouseHandlers<E> {
        var mouseClick: ((_ point: CGPoint, _ clickCount: Int, _ element: E?) -> Void)? = nil
        var rightMouseClick: ((_ point: CGPoint, _ clickCount: Int, _ element: E?) -> Void)? = nil
        var mouseDragged: ((_ point: CGPoint, _ element: E?) -> Void)? = nil
    }
    
    public struct HoverHandlers<E> {
        var isHovering: ((_ element: E) -> Void)?
        var didEndHovering: ((_ element: E) -> Void)?
    }
    
    public struct ColumnHandlers<Section> {
        var allowsRenaming: ((_ column: NSTableColumn) -> Bool)?
        var didRename: ((_ columns: [NSTableColumn]) -> ())?
        var alowsReordering: ((_ columns: [NSTableColumn]) -> Bool)?
        var didReorder: ((_ columns: [NSTableColumn]) -> ())?
        var didSelect: ((_ column: NSTableColumn) -> ())?
        var shouldSelect:((_ column: NSTableColumn?) -> Bool)?
    }
}
