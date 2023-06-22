//
//  Section.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

import Foundation

enum Section: Int, Hashable, Identifiable {
    case main
    var id: Int {
        return self.rawValue
    }
}
