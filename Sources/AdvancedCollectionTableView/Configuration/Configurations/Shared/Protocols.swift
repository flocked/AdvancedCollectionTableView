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
protocol EditingContentView: NSView { }

/// A type that can be dragged to a destination suporting the provided drag conten.
protocol Draggable {
    /// The drag content. Provide an empty array to prevent dragging.
    var dragContent: [PasteboardWriting] { get }
    /// The image representing the type while dragging.
    var dragImage: NSImage? { get }
    /// The method that get's called before the type drags to the specified screen location.
    func willDrag(to screenLocation: CGPoint)
    /// The method that get's called after the dragged to the specified screen location.
    func didDrag(to screenLocation: CGPoint)
}

extension Draggable {
    var dragImage: NSImage? {
        nil
    }
    
    func willDrag(to screenLocation: CGPoint) {
        
    }
    
    func didDrag(to screenLocation: CGPoint) {
        
    }
}
