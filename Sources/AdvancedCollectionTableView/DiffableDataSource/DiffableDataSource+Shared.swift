//
//  File.swift
//
//
//  Created by Florian Zand on 15.09.23.
//

import AppKit
import FZQuicklook
import QuickLookUI

internal extension NSPasteboard.PasteboardType {
    // Used for drag & drop
    static let itemID: NSPasteboard.PasteboardType = .init("DiffableDataSource.ItemID")
}

// Used for Quicklook of selected collection items & table cells.
internal class QuicklookPreviewItem: NSObject, QLPreviewItem, QuicklookPreviewable {
    let preview: QuicklookPreviewable
    var view: NSView?
    
    public var previewItemURL: URL? {
        preview.previewItemURL
    }
    public var previewItemFrame: CGRect? {
        view?.frameOnScreen ?? preview.previewItemFrame
    }
    public var previewItemTitle: String? {
        preview.previewItemTitle
    }
    public var previewItemTransitionImage: NSImage? {
        view?.renderedImage ?? preview.previewItemTransitionImage
    }
    
    internal init(_ preview: QuicklookPreviewable, view: NSView? = nil) {
        self.preview = preview
        self.view = view
    }
}
