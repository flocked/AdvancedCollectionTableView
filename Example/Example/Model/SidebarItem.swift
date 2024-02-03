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

    static let sampleItems1 = [SidebarItem(title: "Messages", symbolName: "message.fill"),
                                      SidebarItem(title: "Photos", symbolName: "photo"),
                                      SidebarItem(title: "Videos", symbolName: "film")]
    static let sampleItems2 = [SidebarItem(title: "Archive", symbolName: "tray.full")]
    static let sampleItems3 = [SidebarItem(title: "News", symbolName: "newspaper")]
}
