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
    /// Properties for configuring the shadow of an item content.
    struct ShadowProperties: Hashable {
        /// The blur radius of the shadow.
        public var radius: CGFloat = 0.0
        
        /// The color of the shadow.
        public var color: NSColor? = nil {
            didSet { updateResolvedColor() } }
        
        /// The opacity of the shadow.
        public var opacity: CGFloat = 1.0
        
        /// The shadow’s relative position, which you specify with horizontal and vertical offset values.
        public var offset: CGPoint = .zero
        
        /// The color transformer for resolving the shadow color.
        public var colorTransform: NSConfigurationColorTransformer? = nil {
            didSet { updateResolvedColor() } }
        
        /// Generates the resolved shadow color for the specified shadow color, using the color and color transformer.
        public func resolvedColor() -> NSColor? {
            if let color = self.color?.withAlphaComponent(self.opacity) {
                return self.colorTransform?(color) ?? color
            }
            return nil
        }
        
        internal var _resolvedColor: NSColor? = nil
        internal mutating func updateResolvedColor() {
            _resolvedColor = resolvedColor()
        }
        
        public init(radius: CGFloat = 0.0, opacity: CGFloat = 1.0, offset: CGPoint = .zero, color: NSColor? = nil, colorTransform: NSConfigurationColorTransformer? = nil) {
            self.radius = radius
            self.opacity = opacity
            self.offset = offset
            self.color = color
            self.colorTransform = colorTransform
            self.updateResolvedColor()
        }
        
        /// Shadow properties for a black shadow.
        public static func black() -> ShadowProperties {
            return ShadowProperties(radius: 3.0, opacity: 1.0, offset: CGPoint(1, 1), color: .shadowColor)
        }
        
        /// Shadow properties for a black shadow.
        public static func colored(_ color: NSColor) -> ShadowProperties {
            return ShadowProperties(radius: 3.0, opacity: 1.0, offset: CGPoint(1, 1), color: color)
        }
        
        /// Shadow properties for a none shadow.
        public static func none() -> ShadowProperties {
            return ShadowProperties()
        }
    }
}
