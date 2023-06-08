//
//  File.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableCellContentConfiguration {
    struct ShadowProperties: Hashable {
        public var radius: CGFloat = 0.0
        public var opacity: CGFloat = 0.0
        public var offset: CGPoint = .zero
        public var color: NSColor? = nil
        public var colorTransform: NSConfigurationColorTransformer? = nil
        public func resolvedColor() -> NSColor? {
            if let color = self.color {
                return self.colorTransform?(color)
            }
            return nil
        }
        
        public static func black() -> ShadowProperties {
            return ShadowProperties(radius: 3.0, opacity: 1.0, color: .shadowColor)
        }
        
        public static func `default`() -> ShadowProperties {
            return ShadowProperties()
        }
        
        public static func none() -> ShadowProperties {
            return ShadowProperties()
        }
        
        public init(radius: CGFloat = 0.0, opacity: CGFloat = 0.0, offset: CGPoint = .zero, color: NSColor? = nil, colorTransform: NSConfigurationColorTransformer? = nil) {
            self.radius = radius
            self.opacity = opacity
            self.offset = offset
            self.color = color
            self.colorTransform = colorTransform
        }
    }
}
