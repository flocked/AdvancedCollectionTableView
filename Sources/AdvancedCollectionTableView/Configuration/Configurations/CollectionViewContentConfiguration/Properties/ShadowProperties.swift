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
    /// Properties for configuring the shadow of an item.
    struct ShadowProperties: Hashable {
        /// The blur radius of the shadow.
        public var radius: CGFloat = 0.0
        /// The color of the shadow.
        public var color: NSColor? = nil
        /// The opacity of the shadow.
        public var opacity: CGFloat = 1.0
        /// The shadow’s relative position, which you specify with horizontal and vertical offset values.
        public var offset: CGPoint = .zero
        /// The color transformer for resolving the shadow color.
        public var colorTransform: NSConfigurationColorTransformer? = nil

        /// Generates the resolved shadow color for the specified shadow color, using the color and color transformer.
        public func resolvedColor() -> NSColor? {
            if let color = self.color {
                return self.colorTransform?(color) ?? color
            }
            return nil
        }
        
        /// Shadow properties for black shadow.
        public static func black() -> ShadowProperties {
            var property = ShadowProperties()
            property.radius = 3.0
            property.color = .black
            return property
        }
        
        /// Shadow properties for none shadow.
        public static func none() -> ShadowProperties {
            return ShadowProperties()
        }
    }
}
