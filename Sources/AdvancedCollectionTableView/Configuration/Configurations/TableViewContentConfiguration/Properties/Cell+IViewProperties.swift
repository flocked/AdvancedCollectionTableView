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
    struct ViewProperties: Hashable {
        public enum WidthSizeOption: Hashable {
            case absolute(CGFloat)
            case textWidth
            case relative(CGFloat)
        }
        
        public enum HeightSizeOption: Hashable {
            case absolute(CGFloat)
            case textWidth
            case relative(CGFloat)
        }
        
        public typealias Corners = CACornerMask
        public var cornerRadius: CGFloat = 0.0
        public var roundedCorners: Corners = .all
        
        public var width: WidthSizeOption = .textWidth
        public var height: HeightSizeOption = .absolute(30.0)
        
        public var backgroundColor: NSColor? = nil
        public var backgroundColorTransform: NSConfigurationColorTransformer? = nil
        
        public static func `default`() -> ViewProperties {
            return ViewProperties()
        }

        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        public init(cornerRadius: CGFloat = 0.0, roundedCorners: Corners = .all, width: WidthSizeOption = .textWidth, height: HeightSizeOption = .absolute(30.0), backgroundColor: NSColor? = nil, backgroundColorTransform: NSConfigurationColorTransformer? = nil) {
            self.cornerRadius = cornerRadius
            self.roundedCorners = roundedCorners
            self.width = width
            self.height = height
            self.backgroundColor = backgroundColor
            self.backgroundColorTransform = backgroundColorTransform
        }
    }
}
