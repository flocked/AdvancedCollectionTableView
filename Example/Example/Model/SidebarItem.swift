//
//  SidebarItem.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

import Foundation

public class SidebarItem: NSObject, Identifiable {

    public let title: String
    public let symbolName: String
    public var isFavorite: Bool = false

    public init(_ title: String, symbolName: String) {
        self.title = title
        self.symbolName = symbolName
    }
    
    static let sampleItems1 = [SidebarItem("Messages", symbolName: "message.fill"),
                                      SidebarItem("Photos", symbolName: "photo"),
                                      SidebarItem("Videos", symbolName: "film")]
    static let sampleItems2 = [SidebarItem("Archive", symbolName: "tray.full")]
    static let sampleItems3 = [SidebarItem("News", symbolName: "newspaper")]
}
