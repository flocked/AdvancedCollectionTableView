//
//  GalleryItem.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import Foundation
import FZQuicklook

class GalleryItem: NSObject, Identifiable {
    let id = UUID()
    
    var title: String
    var detail: String
    var imageName: String
    var badge: String?
    
    init(title: String, detail: String, imageName: String, badge: String? = nil) {
        self.title = title
        self.detail = detail
        self.imageName = imageName
        self.badge = badge
    }
    
    func replaceInfo(with item: GalleryItem) {
        self.title = item.title
        self.detail = item.detail
        self.imageName = item.imageName
        self.badge = item.badge
    }
    
    static var sampleItems: [GalleryItem] {
        return [GalleryItem(title: "Astronaut Cat", detail: "Liquid ink", imageName: "astronaut cat"),
                GalleryItem(title: "Cat", detail: "Painted by Vermeer", imageName: "cat vermeer"),
                GalleryItem(title: "Cat", detail: "Vaporwave", imageName: "cat vaporwave", badge: "new"),
                GalleryItem(title: "Sea Creature", detail: "Oil on canvas", imageName: "sea creature oil"),
                GalleryItem(title: "Sea Creature", detail: "Science fiction", imageName: "sea creature science fiction"),
                GalleryItem(title: "Techno Club", detail: "Surrealist painting", imageName: "techno club surrealist"),
                GalleryItem(title: "Techno Club", detail: "Oil painting", imageName: "techno club oil"),
                GalleryItem(title: "Fireworker Monkey", detail: "Japanese manga", imageName: "monkey fireworkers manga"),
                GalleryItem(title: "Dystopian City", detail: "Oil painting", imageName: "dystopian city science fiction"),
        ]
    }
}

/**
 By conforming to `QuicklookPreviewable`the item can be quicklooked by providing it to `QuicklookPanel.shared`(simliar to Finders Quicklook Panel) or `QuicklookView`
 
 A NSCollectionView or NSTableView with a diffable data source can also quicklook the item by enabling their `isQuicklookPreviewable` property.
 */
extension GalleryItem: QuicklookPreviewable {
    var previewItemURL: URL? {
        return Bundle.main.urlForImageResource(imageName)
    }
    
    var previewItemTitle: String? {
        return self.title
    }
}

extension Array where Element: GalleryItem {
    // Shuffles the items by replacing the info of each item.
    func shuffleItems() {
        var sampleItems = GalleryItem.sampleItems
        for galleryItem in self {
            let newRandomItem = sampleItems.randomElement(excluding: [galleryItem])!
            sampleItems.remove(newRandomItem)
            galleryItem.replaceInfo(with: newRandomItem)
        }
    }
}
