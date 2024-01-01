//
//  Section.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

import Foundation

enum Section: String, Hashable, Identifiable {
    case main = "Main"
    case more = "More"
    case empty = "Empty"
    var id: String {
        return rawValue
    }
}
