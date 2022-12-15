//
//  newww.swift
//  NSCollectionViewDiffableSectionDataSource
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit

extension CollectionViewDiffableDataSource {
    public struct SelectionHandlers<E> {
        var shouldSelect: (([E]) -> [E])? = nil
        var shouldDeselect: (([E]) -> [E])? = nil
        var didSelect: (([E]) -> Void)? = nil
        var didDeselect: (([E]) -> Void)? = nil
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
    
    public struct MouseHandlers<E> {
        var mouseClick: ((CGPoint, Int, E?) -> Void)? = nil
        var rightMouseClick: ((CGPoint, Int, E?) -> Void)? = nil
        var mouseDragged: ((CGPoint, E?) -> Void)? = nil
    //   var mouseEntered: ((CGPoint) -> Void)? = nil
     //   var mouseMoved: ((CGPoint) -> Void)? = nil
     //   var mouseExited: ((CGPoint) -> Void)? = nil
    }
    
    public struct HoverHandlers<E> {
        var isHovering: ((E) -> Void)?
        var didEndHovering: ((E) -> Void)?
    }
    
    public struct SectionHandlers<Section> {
        var shouldCollapse: ((Section) -> Bool)?
        var willCollapse: ((Section) -> Void)?
        var shouldExpand: ((Section) -> Bool)?
        var willExpand: ((Section) -> Void)?
        var canReorder: ((Section) -> Bool)?
        var didReorder: ((Section) -> Void)?
    }
}
