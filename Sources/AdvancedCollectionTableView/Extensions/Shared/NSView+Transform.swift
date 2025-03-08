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
        get { getAssociatedValue("_scaleTransform") ?? .none }
        set {
            guard newValue != _scaleTransform else { return }
            setAssociatedValue(newValue, key: "_scaleTransform")
            anchorPoint = .center
            scale = newValue
        }
    }
    
    var _rotation: Rotation {
        get { getAssociatedValue("_rotation") ?? .zero }
        set {
            guard newValue != _rotation else { return }
            setAssociatedValue(newValue, key: "_rotation")
            anchorPoint = .center
            rotation = newValue
        }
    }
}
