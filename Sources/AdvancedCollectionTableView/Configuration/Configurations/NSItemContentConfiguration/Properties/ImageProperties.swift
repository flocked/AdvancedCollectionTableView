//
//  File.swift
//  
//
//  Created by Florian Zand on 09.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

public extension NSItemContentConfiguration {
    struct ImageProperties: Hashable {
        /// The image scaling of an item image.
        public enum ImageScaling {
            /// An option that resizes the image so it’s all within the available space, both vertically and horizontally.
            case fit
            /// An option that resizes the image so it occupies all available space, both vertically and horizontally.
            case fill
            internal var swiftui: ContentMode {
                switch self {
                case .fit: return .fit
                case .fill: return .fill
                }
            }
        }
        
        /// The symbol configuration for the image.
        public var symbolConfiguration: NSItemContentConfiguration.ContentProperties.SymbolConfiguration? = nil
        /// The image scaling.
        public var scaling: ImageScaling = .fit
        /// The image tint color for an image that is a template or symbol image.
        public var tintColor: NSColor? = nil
        /// The color transformer for resolving the image tint color.
        public var tintColorTransform: NSConfigurationColorTransformer? = nil
        /// Generates the resolved image tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = self.tintColor {
                return self.tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }
        
        init(symbolConfiguration: NSItemContentConfiguration.ContentProperties.SymbolConfiguration? = nil,
             scaling: ImageScaling = .fit,
             tintColor: NSColor? = nil,
             tintColorTransform: NSConfigurationColorTransformer? = nil) {
            self.symbolConfiguration = symbolConfiguration
            self.scaling = scaling
            self.tintColor = tintColor
            self.tintColorTransform = tintColorTransform
        }
    }
}
