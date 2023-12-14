//
//  NSView+Color.swift
//
//
//  Created by Florian Zand on 02.11.23.
//

import AppKit

public extension NSView {
    convenience init(color: NSUIColor) {
        self.init(frame: .zero)
        self.backgroundColor = color
    }
}
