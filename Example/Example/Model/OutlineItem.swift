//
//  OutlineItem.swift
//  OutlineTest
//
//  Created by Florian Zand on 19.01.25.
//

import Foundation

struct OutlineItem: Hashable, ExpressibleByStringLiteral, CustomStringConvertible {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    init(stringLiteral value: String) {
        self.title = value
    }
    
    var description: String {
        title
    }
}
