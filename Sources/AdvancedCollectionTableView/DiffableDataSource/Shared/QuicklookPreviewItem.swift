//
//  QuicklookPreviewItem.swift
//
//
//  Created by Florian Zand on 15.09.23.
//

import AppKit
import FZQuicklook
import QuickLookUI

// Used for Quicklook of selected collection items & table cells.
class QuicklookPreviewItem: NSObject, QLPreviewItem, QuicklookPreviewable {
    let preview: QuicklookPreviewable
    weak var view: NSView?

    public var previewItemURL: URL? {
        preview.previewItemURL
    }

    public var previewItemFrame: CGRect? {
        if let view = self.view {
            if let parentController = view.parentController as? NSCollectionViewItem {
                let offset = parentController._collectionView?.enclosingScrollView?.contentOffset ?? .zero
                let frame = view.frame.offsetBy(dx: -offset.x, dy: -offset.y)
                if parentController._collectionView?.enclosingScrollView?.bounds.intersects(frame) == true {
                    return view.frameOnScreen
                }
            } else if let view = view as? NSTableRowView {
                if view.tableView?.bounds.intersects(view.frame) == true {
                    return view.frameOnScreen
                }
            } else {
                return view.frameOnScreen
            }
            return .zero
        }
        return preview.previewItemFrame
    }

    public var previewItemTitle: String? {
        preview.previewItemTitle
    }

    public var previewItemTransitionImage: NSImage? {
        view?.renderedImage ?? preview.previewItemTransitionImage
    }

    init(_ preview: QuicklookPreviewable, view: NSView? = nil) {
        self.preview = preview
        self.view = view
    }
}

extension NSPasteboard.PasteboardType {
    // Used for drag & drop
    static let itemID: NSPasteboard.PasteboardType = .init("DiffableDataSource.ItemID")
}
