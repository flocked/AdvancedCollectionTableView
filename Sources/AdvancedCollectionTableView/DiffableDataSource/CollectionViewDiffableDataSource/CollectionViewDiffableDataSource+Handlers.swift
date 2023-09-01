//
//  newww.swift
//  NSCollectionViewDiffableSectionDataSource
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZUIKit

extension AdvanceColllectionViewDiffableDataSource {
    /// Handlers for prefetching items.
    public struct PrefetchHandlers {
        /// Handler that tells you to begin preparing data for the elements.
        public var willPrefetch: ((_ elements: [Element]) -> ())? = nil
        /// Cancels a previously triggered data prefetch request.
        public var didCancelPrefetching: ((_ elements: [Element]) -> ())? = nil
    }
    
    /// Handlers for selection of items.
    public struct SelectionHandlers {
        /// Handler that determines whether elements should get selected.
        public var shouldSelect: ((_ elements: [Element]) -> [Element])? = nil
        /// Handler that determines whether elements should get deselected.
        public var shouldDeselect: ((_ elements: [Element]) -> [Element])? = nil
        /// Handler that gets called whenever elements get selected.
        public var didSelect: ((_ elements: [Element]) -> ())? = nil
        /// Handler that gets called whenever elements get deselected.
        public var didDeselect: ((_ elements: [Element]) -> ())? = nil
    }
    
    /// Handlers for deletion of items.
    public struct DeletionHandlers {
        /// Handler that determines whether elements should get deleted.
        public var shouldDelete: ((_ elements: [Element]) -> [Element])? = nil
        /// Handler that gets called whenever elements get deleted.
        public var didDelete: ((_ elements: [Element]) -> ())? = nil
    }
    
    /// Handlers for reordering items.
    public struct ReorderingHandlers {
        /// Handler that determines whether you can reorder a particular item.
        public var canReorder: ((_ elements: [Element]) -> Bool)? = nil
        /// Handler that prepares the diffable data source for reordering its items.
        public var willReorder: ((DiffableDataSourceTransaction) -> ())? = nil
        /// Handler that processes a reordering transaction.
        public var didReorder: ((DiffableDataSourceTransaction) -> ())? = nil
    }
    
    /// Handlers for highlight.
    public struct HighlightHandlers {
        /// Handler that determines which elements should change to a highlight state.
        public var shouldChange: ((_ elements: [Element], NSCollectionViewItem.HighlightState) -> [Element])? = nil
        /// Handler that gets called whenever elements changed their highlight state.
        public var didChange: ((_ elements: [Element], NSCollectionViewItem.HighlightState) -> ())? = nil
    }
    
    /**
     Handlers for the displayed items.
     
     The handlers get called whenever the collection view is displaying new items (e.g. when the enclosing scrollview scrolls to new items).
     */
    public struct DisplayHandlers {
        /// Handler that gets called whenever elements start getting displayed.
        public var isDisplaying: ((_ elements: [Element]) -> ())?
        /// Handler that gets called whenever elements end getting displayed.
        public var didEndDisplaying: ((_ elements: [Element]) -> ())?
    }
    
    /// Handlers that get called whenever the mouse is hovering an item.
    public struct HoverHandlers {
        /// The handler that gets called whenever the mouse is hovering an item.
        public var isHovering: ((_ element: Element) -> ())?
        /// The handler that gets called whenever the mouse did end hovering an item.
        public var didEndHovering: ((_ element: Element) -> ())?
    }
    
    /// Handlers for drag and drop of files from and to the collection view.
    public struct DragdropHandlers {
        public var canDropOutside: ((_ elements: [Element]) -> [Element])? = nil
        public var dropOutside: ((_ element: Element) -> PasteboardWriting)? = nil
        public var canDrag: (([AnyObject]) -> Bool)? = nil
        public var dragOutside: ((_ elements: [Element]) -> [AnyObject])? = nil
        public var draggingImage: ((_ elements: [Element], NSEvent, NSPointPointer) -> NSImage?)? = nil
    }
}
