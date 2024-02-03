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
    public let imageName: String
    public let badgeText: String?
    public let badgeColor: NSColor
    public var isFavorite: Bool = false

    public init(title: String, detail: String, imageName: String, badgeText: String? = nil, badgeColor: NSColor = .controlAccentColor) {
        self.title = title
        self.detail = detail
        self.imageName = imageName
        self.badgeText = badgeText
        self.badgeColor = badgeColor
    }

    static let sampleItems = [GalleryItem(title: "Astronaut Cat", detail: "Liquid ink", imageName: "astronaut cat"),
                              GalleryItem(title: "Cat", detail: "Painted by Vermeer", imageName: "cat vermeer"),
                              GalleryItem(title: "Cat", detail: "Vaporwave", imageName: "cat vaporwave", badgeText: "new"),
                              GalleryItem(title: "Sea Creature", detail: "Oil on canvas", imageName: "sea creature oil"),
                              GalleryItem(title: "Sea Creature", detail: "Science fiction", imageName: "sea creature science fiction", badgeText: "favorite", badgeColor: .systemPurple),
                              GalleryItem(title: "Techno Club", detail: "Surrealist painting", imageName: "techno club surrealist"),
                              GalleryItem(title: "Techno Club", detail: "Oil painting", imageName: "techno club oil"),
                              GalleryItem(title: "Fireworker Monkey", detail: "Japanese manga", imageName: "monkey fireworkers manga"),
                              GalleryItem(title: "Dystopian City", detail: "Oil painting", imageName: "dystopian city science fiction")]
}

///  By conforming to `QuicklookPreviewable` and providing `previewItemURL` the items can be previewed by pressing spacebar which opens a Quicklook panel (simliar to Finder).
extension GalleryItem: QuicklookPreviewable {
    public var previewItemURL: URL? {
        Bundle.main.urlForImageResource(imageName)
    }

    public var previewItemTitle: String? {
        title
    }
}
