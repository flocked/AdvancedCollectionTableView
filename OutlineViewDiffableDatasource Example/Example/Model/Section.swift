//
//  Section.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

import Foundation

public enum Section: String, Hashable, Identifiable {
    case main = "Main"
    case section2 = "Section 2"
    case section3 = "Section 3"
    
    public var title: String {
        rawValue
    }

    public var id: String {
        rawValue
    }
}
