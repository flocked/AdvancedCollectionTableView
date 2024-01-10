//
//  CollectionItem.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import Foundation
import FZQuicklook

public class GalleryItem: NSObject, Identifiable {
    public let id = UUID()
    public var title: String
    public var detail: String
    public var imageName: String
    public var badge: String?

    public init(title: String, detail: String, imageName: String, badge: String? = nil) {
        self.title = title
        self.detail = detail
        self.imageName = imageName
        self.badge = badge
    }

    public static var sampleItems: [GalleryItem] {
        [GalleryItem(title: "Astronaut Cat", detail: "Liquid ink", imageName: "astronaut cat"),
         GalleryItem(title: "Cat", detail: "Painted by Vermeer", imageName: "cat vermeer"),
         GalleryItem(title: "Cat", detail: "Vaporwave", imageName: "cat vaporwave", badge: "new"),
         GalleryItem(title: "Sea Creature", detail: "Oil on canvas", imageName: "sea creature oil"),
         GalleryItem(title: "Sea Creature", detail: "Science fiction", imageName: "sea creature science fiction"),
         GalleryItem(title: "Techno Club", detail: "Surrealist painting", imageName: "techno club surrealist"),
         GalleryItem(title: "Techno Club", detail: "Oil painting", imageName: "techno club oil"),
         GalleryItem(title: "Fireworker Monkey", detail: "Japanese manga", imageName: "monkey fireworkers manga"),
         GalleryItem(title: "Dystopian City", detail: "Oil painting", imageName: "dystopian city science fiction")]
    }
}

/**
 By conforming to `QuicklookPreviewable`the item can be quicklooked by providing it to `QuicklookPanel.shared`(simliar to Finders Quicklook Panel) or `QuicklookView`

 A NSCollectionView or NSTableView with a diffable data source can also quicklook the item by enabling their `isQuicklookPreviewable` property.
 */
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
