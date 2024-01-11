//
//  CollectionItem.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import AppKit
import FZQuicklook

public class GalleryItem: NSObject, Identifiable {
    
    public var title: String
    public var detail: String
    public var imageName: String
    public var badge: String?
    public var badgeColor: NSColor = .controlAccentColor

    public init(title: String, detail: String, imageName: String, badge: String? = nil, badgeColor: NSColor = .controlAccentColor) {
        self.title = title
        self.detail = detail
        self.imageName = imageName
        self.badge = badge
        self.badgeColor = badgeColor
    }

    public static var sampleItems: [GalleryItem] {
        [GalleryItem(title: "Astronaut Cat", detail: "Liquid ink", imageName: "astronaut cat"),
         GalleryItem(title: "Cat", detail: "Painted by Vermeer", imageName: "cat vermeer"),
         GalleryItem(title: "Cat", detail: "Vaporwave", imageName: "cat vaporwave", badge: "new"),
         GalleryItem(title: "Sea Creature", detail: "Oil on canvas", imageName: "sea creature oil"),
         GalleryItem(title: "Sea Creature", detail: "Science fiction", imageName: "sea creature science fiction", badge: "favorite", badgeColor: .systemPurple),
         GalleryItem(title: "Techno Club", detail: "Surrealist painting", imageName: "techno club surrealist"),
         GalleryItem(title: "Techno Club", detail: "Oil painting", imageName: "techno club oil"),
         GalleryItem(title: "Fireworker Monkey", detail: "Japanese manga", imageName: "monkey fireworkers manga"),
         GalleryItem(title: "Dystopian City", detail: "Oil painting", imageName: "dystopian city science fiction")]
    }
}

///  By conforming to `QuicklookPreviewable` and providing `previewItemURL` the item can be quicklooked by `QuicklookPanel` (simliar to Finder's Quicklook panel).
extension GalleryItem: QuicklookPreviewable {
    public var previewItemURL: URL? {
        Bundle.main.urlForImageResource(imageName)
    }

    public var previewItemTitle: String? {
        title
    }
}

public extension Array where Element: GalleryItem {
    /// Shuffles the items by replacing the info of each item.
    func shuffledItems() -> Self {
        var sampleItems = GalleryItem.sampleItems
        for galleryItem in self {
            let newRandomItem = sampleItems.randomElement(excluding: [galleryItem])!
            sampleItems.remove(newRandomItem)
            galleryItem.title = newRandomItem.title
            galleryItem.detail = newRandomItem.detail
            galleryItem.imageName = newRandomItem.imageName
            galleryItem.badge = newRandomItem.badge
        }
        return self
    }
}
