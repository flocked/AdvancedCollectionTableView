//
//  ShadowProperties.swift
//  
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

/// The content properties of an item configuraton.
public extension NSTableCellContentConfiguration {
    struct ShadowProperties: Hashable {
        public var color: NSColor? = nil {
            didSet { updateResolvedColor() } }
        
        public var offset: CGPoint = CGPoint(1, 1)
        public var opacity: CGFloat = 0.7
        public var radius: CGFloat = 0.3
        
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
        
        public static func black() -> Self {
            ShadowProperties(color: .black)
        }
        
        public init(color: NSColor? = nil,
                    offset: CGPoint = CGPoint(x: 1, y: 1),
                    opacity: CGFloat = 0.7,
                    radius: CGFloat = 0.3) {
            self.color = color
            self.offset = offset
            self.opacity = opacity
            self.radius = radius
        }
    }
}

public extension View {
    @ViewBuilder
    func shadow(properties: NSTableCellContentConfiguration.ShadowProperties) -> some View {
        if let color = properties._resolvedColor {
            self.shadow(color: Color(color), radius: properties.radius, offset: properties.offset)
        } else {
            self
        }
    }
}
