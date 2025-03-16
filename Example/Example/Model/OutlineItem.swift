//
//  OutlineItem.swift
//  OutlineTest
//
//  Created by Florian Zand on 19.01.25.
//

import Foundation

public struct OutlineItem: Hashable, ExpressibleByStringLiteral, CustomStringConvertible {
    
    public let title: String
    
    public init(_ title: String) {
        self.title = title
    }
    
    public init(stringLiteral value: String) {
        self.title = value
    }
    
    public var description: String {
        title
    }
}
