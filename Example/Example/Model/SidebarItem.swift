//
//  SidebarItem.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

import Foundation

class SidebarItem: NSObject, Identifiable {

    public let title: String
    public let symbolName: String
    public var isFavorite: Bool = false

    public init(title: String, symbolName: String) {
        self.title = title
        self.symbolName = symbolName
    }

    public static var sampleItems1: [SidebarItem] {
        [SidebarItem(title: "Messages", symbolName: "message.fill"),
         SidebarItem(title: "Photos", symbolName: "photo"),
         SidebarItem(title: "Videos", symbolName: "film")]
    }

    public static var sampleItems2: [SidebarItem] {
        [SidebarItem(title: "Archive", symbolName: "tray.full")]
    }
    
    public static var sampleItems3: [SidebarItem] {
        [SidebarItem(title: "News", symbolName: "newspaper")]
    }
}
