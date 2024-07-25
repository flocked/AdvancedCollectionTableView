//
//  EditingContentView.swift
//
//
//  Created by Florian Zand on 28.12.23.
//

import Foundation
import AppKit

protocol EdiitingContentView: NSView {
    var isEditing: Bool { get set }
    func updateTableRowHeight()
}

extension EdiitingContentView {
    func updateTableRowHeight() { }
}
 
