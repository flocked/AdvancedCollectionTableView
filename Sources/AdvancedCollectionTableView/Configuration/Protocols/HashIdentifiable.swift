//
//  HashIdentifiable.swift
//  NSHostingViewSizeInTableView
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit

public protocol HashIdentifiable: Identifiable, Hashable {
    
}
/*

extension CollectionIdentifiable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

*/
