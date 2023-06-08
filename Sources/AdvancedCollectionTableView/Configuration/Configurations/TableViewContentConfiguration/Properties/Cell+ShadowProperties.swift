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
        public var color: NSColor? = nil
        public var opacity: CGFloat = 0.0
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
            property.opacity = 1.0
            return property
        }
        
        public static func `default`() -> ShadowProperties {
            return ShadowProperties()
        }
        
        public static func none() -> ShadowProperties {
            return ShadowProperties()
        }
        
        public init(radius: CGFloat = 0.0, color: NSColor? = nil, opacity: CGFloat = 0.0, offset: CGPoint = .zero, colorTransform: NSConfigurationColorTransformer? = nil) {
            self.radius = radius
            self.color = color
            self.opacity = opacity
            self.offset = offset
            self.colorTransform = colorTransform
        }
    }
}
