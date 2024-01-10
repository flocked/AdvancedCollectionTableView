//
//  SidebarItem.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

import Foundation
import FZSwiftUtils

class SidebarItem: NSObject, Identifiable {
    public let id = UUID()
    public let title: String
    public let symbolName: String
    public var isFavorite: Bool = false

    public init(title: String, symbolName: String) {
        self.title = title
        self.symbolName = symbolName
    }

    public static var sampleItems1: [SidebarItem] {
        [SidebarItem(title: "Person", symbolName: "person"),
         SidebarItem(title: "Photo", symbolName: "photo"),
         SidebarItem(title: "Video", symbolName: "film")]
    }

    public static var sampleItems2: [SidebarItem] {
        [SidebarItem(title: "Table", symbolName: "table"),
         SidebarItem(title: "Collection", symbolName: "square.grid.3x3")]
    }
}
