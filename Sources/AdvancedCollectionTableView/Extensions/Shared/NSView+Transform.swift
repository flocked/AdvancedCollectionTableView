//
//  NSView+Transform.swift
//
//
//  Created by Florian Zand on 03.03.25.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSView {
    var _scaleTransform: Scale {
        get { associatedValue(for: "_scaleTransform") ?? .none }
        set {
            guard newValue != _scaleTransform else { return }
            setAssociatedValue(newValue, for: "_scaleTransform")
            anchorPoint = .center
            animatorIfNeeded().scale = newValue
        }
    }
    
    var _rotation: Rotation {
        get { associatedValue(for: "_rotation") ?? .zero }
        set {
            guard newValue != _rotation else { return }
            setAssociatedValue(newValue, for: "_rotation")
            anchorPoint = .center
            animatorIfNeeded().rotation = newValue
        }
    }
}
