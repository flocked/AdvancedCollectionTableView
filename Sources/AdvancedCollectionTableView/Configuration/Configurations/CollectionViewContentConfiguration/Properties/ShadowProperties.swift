//
//  File.swift
//  
//
//  Created by Florian Zand on 02.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

public extension NSItemContentConfiguration {
    struct ShadowProperties: Hashable {
        public var radius: CGFloat = 0.0
        public var color: NSColor? = nil
        public var opacity: CGFloat = 1.0
        public var offset: CGPoint = .zero
        public var colorTransform: NSConfigurationColorTransformer? = nil

        public func resolvedColor() -> NSColor? {
            if let color = self.color {
                return self.colorTransform?(color) ?? color
            }
            return nil
        }
        
        public static func black() -> ShadowProperties {
            var property = ShadowProperties()
            property.radius = 3.0
            property.color = .black
            return property
        }
        
        public static func none() -> ShadowProperties {
            return ShadowProperties()
        }
    }
}
