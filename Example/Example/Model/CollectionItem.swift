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
    public var isFavorite: Bool

    public init(_ title: String, detail: String, badgeText: String? = nil, badgeColor: NSColor = .controlAccentColor, isFavorite: Bool = false) {
        self.title = title
        self.detail = detail
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.isFavorite = isFavorite
    }

    static let sampleItems = [GalleryItem("Neil Catstrong", detail: "Liquid Ink"),
                              GalleryItem("Majestic Mouser", detail: "Painted by Vermeer"),
                              GalleryItem("Vapor Cat", detail: "Vaporwave", badgeText: "new"),
                              GalleryItem("Cosmojelly", detail: "Oil on Canvas"),
                              GalleryItem("Plasmawhale", detail: "Science Fiction", badgeText: "favorite", badgeColor: .systemPurple),
                              GalleryItem("Berghain", detail: "Surrealist Painting"),
                              GalleryItem("About Blank", detail: "Oil Painting"),
                              GalleryItem("Fireworker Monkey", detail: "Japanese Manga"),
                              GalleryItem("Dystopian City", detail: "Oil Painting", isFavorite: true),
                              GalleryItem("Underground", detail: "Oil on Canvas"),
                              GalleryItem("Tresor", detail: "Painting", isFavorite: true),
                              GalleryItem("Oxi", detail: "Oil on Canvas")]
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
