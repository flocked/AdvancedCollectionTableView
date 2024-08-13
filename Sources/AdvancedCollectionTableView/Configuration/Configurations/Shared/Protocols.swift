//
//  AutomaticHeightSizable.swift
//
//
//  Created by Florian Zand on 20.07.24.
//

import AppKit
import FZUIKit

/// Content configurations with views that can autolayout their height.
protocol AutomaticHeightSizable: NSContentConfiguration { }

extension NSListContentConfiguration: AutomaticHeightSizable { }
extension NSHostingConfiguration: AutomaticHeightSizable { }

/// Content configuration views with editable text fields.
protocol EdiitingContentView: NSView {
    var isEditing: Bool { get set }
    func updateTableRowHeight(reset: Bool)
}

extension EdiitingContentView {
    func updateTableRowHeight(reset: Bool = false) { }
}
