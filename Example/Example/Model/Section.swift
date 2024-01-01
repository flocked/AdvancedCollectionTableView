//
//  Section.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

import Foundation

public enum Section: String, Hashable, Identifiable {
    case main = "Main"
    case more = "More"
    case empty = "Empty"
    
    public var id: String {
        return rawValue
    }
}
