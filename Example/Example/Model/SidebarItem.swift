//
//  SidebarItem.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

import Foundation

struct SidebarItem: Hashable, Identifiable {
    let id = UUID()
    var title: String
    var symbolName: String
    
    static var sampleItems: [SidebarItem] {
        return [SidebarItem(title: "Person", symbolName: "person"),
                SidebarItem(title: "Photo", symbolName: "photo"),
                SidebarItem(title: "Video", symbolName: "film"),
        ]
    }
    
    static var moreSampleItems: [SidebarItem] {
        return [SidebarItem(title: "Table", symbolName: "table"),
                SidebarItem(title: "Collection", symbolName: "square.grid.3x3"),
        ]
    }
}
