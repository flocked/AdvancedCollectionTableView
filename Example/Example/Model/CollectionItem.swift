//
//  CollectionItem.swift
//
//
//  Created by Florian Zand on 24.01.23.
//

import Foundation
import FZQuicklook

class CollectionItem: NSObject, Identifiable {
    let id = UUID()
    var title: String
    var detail: String
    var imageName: String
    
    init(title: String, detail: String, imageName: String) {
        self.title = title
        self.detail = detail
        self.imageName = imageName
    }
    
    static var sample: [CollectionItem] {
        return [CollectionItem(title: "Astronaut Cat", detail: "Liquid ink", imageName: "astronaut cat"),
                CollectionItem(title: "Cat", detail: "Painted by Vermeer", imageName: "cat vermeer"),
                CollectionItem(title: "Cat", detail: "Vaporwave", imageName: "cat vaporwave"),
                CollectionItem(title: "Sea Creature", detail: "Oil on canvas", imageName: "sea creature oil"),
                CollectionItem(title: "Sea Creature", detail: "Science fiction", imageName: "sea creature science fiction"),
                CollectionItem(title: "Techno Club", detail: "Surrealist painting", imageName: "techno club surrealist"),
                CollectionItem(title: "Techno Club", detail: "Oil painting", imageName: "techno club oil"),
        ]
    }
}

extension CollectionItem: QuicklookPreviewable {
  
    
    var previewItemURL: URL? {
        return Bundle.main.url(forResource: imageName, withExtension: "png") ?? URL(fileURLWithPath: "/Users/florianzand/Developer/Github/AdvancedCollectionTableView/Example/Example/Assets.xcassets/astronaut cat.imageset/astronaut cat closeup liquid ink.png")
    }
    
    
    var previewItemTitle: String! {
        return self.title
    }
}
