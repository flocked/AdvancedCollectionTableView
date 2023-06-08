//
//  ImageProperties.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableCellContentConfiguration {
    struct ImageProperties: Hashable {
        public enum Position: Hashable {
            case leading
            case trailing
        }
        
        public var symbolConfiguration: SymbolConfiguration = SymbolConfiguration()
        public var tintColor: NSColor? = nil
        public var cornerRadius: CGFloat = 0.0
        public var backgroundColor: NSColor? = nil
        public var shadowProperties: ShadowProperties = .black()
        public var position: Position = .leading
        
        public var backgroundColorTransform: NSConfigurationColorTransformer? = nil
        public var tintColorTransform: NSConfigurationColorTransformer? = nil
        public var size: ImageSize = .cellHeight
        public var scaling: CALayerContentsGravity = .resizeAspect
        
        public enum ImageSize: Hashable {
            case cellHeight
            case textHeight
            case secondaryTextHeight
            case size(CGSize)
            case maxSize(CGSize)
        }
        
        public static func `default`() -> ImageProperties {
            return ImageProperties()
        }
        
        func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        public func resolvedTintColor() -> NSColor? {
            if let tintColor = self.tintColor {
                return self.tintColorTransform?(tintColor) ?? tintColor
            }
            return nil
        }
        
        /*
        
        public init(symbolConfiguration: SymbolConfiguration = SymbolConfiguration(), tintColor: NSColor? = nil, cornerRadius: CGFloat = 0.0, backgroundColor: NSColor? = nil, shadowProperties: ShadowProperties = ShadowProperties(), position: Position = .leading, backgroundColorTransform: NSConfigurationColorTransformer? = nil, tintColorTransform: NSConfigurationColorTransformer? = nil, size: ImageSize = .cellHeight, scaling: CALayerContentsGravity = .resizeAspect) {
            self.symbolConfiguration = symbolConfiguration
            self.tintColor = tintColor
            self.cornerRadius = cornerRadius
            self.backgroundColor = backgroundColor
            self.shadowProperties = shadowProperties
            self.position = position
            self.backgroundColorTransform = backgroundColorTransform
            self.tintColorTransform = tintColorTransform
            self.size = size
            self.scaling = scaling
        }
         */
    }
}
