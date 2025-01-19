//
//  OutlineItem.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

import Foundation

struct OutlineItem: Hashable, ExpressibleByStringLiteral, CustomStringConvertible {
    let title: String
    
    var description: String {
        title
    }
    
    init(_ title: String) {
        self.title = title
    }
    
    init(stringLiteral value: String) {
        self.title = value
    }
}
