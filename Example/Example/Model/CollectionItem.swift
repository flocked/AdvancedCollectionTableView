//
//  CollectionItem.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import AppKit
import FZQuicklook

public class GalleryItem: NSObject, Identifiable {
    
    public let title: String
    public let detail: String
    public let badgeText: String?
    public let badgeColor: NSColor
    public var isFavorite: Bool = false

    public init(_ title: String, detail: String, badgeText: String? = nil, badgeColor: NSColor = .controlAccentColor) {
        self.title = title
        self.detail = detail
        self.badgeText = badgeText
        self.badgeColor = badgeColor
    }

    static let sampleItems = [GalleryItem("Neil Catstrong", detail: "Liquid ink"),
                              GalleryItem("Majestic Mouser", detail: "Painted by Vermeer"),
                              GalleryItem("Vapor Cat", detail: "Vaporwave", badgeText: "new"),
                              GalleryItem("Cosmojelly", detail: "Oil on canvas"),
                              GalleryItem("Plasmawhale", detail: "Science fiction", badgeText: "favorite", badgeColor: .systemPurple),
                              GalleryItem("Berghain", detail: "Surrealist painting"),
                              GalleryItem("About Blank", detail: "Oil painting"),
                              GalleryItem("Fireworker Monkey", detail: "Japanese manga"),
                              GalleryItem("Dystopian City", detail: "Oil painting")]
}

///  By conforming to `QuicklookPreviewable` and providing `previewItemURL` the items can be previewed by pressing spacebar which opens a Quicklook panel (simliar to Finder).
extension GalleryItem: QuicklookPreviewable {
    public var previewItemURL: URL? {
        Bundle.main.urlForImageResource(title)
    }

    public var previewItemTitle: String? {
        title
    }
}
