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

public extension NSTableCellContentConfiguration {
    /**
     Properties for configuring the content of an item.
     
     The item content view is displayed if there is a item view, item image and/or background color.
     */
    struct ContentProperties: Hashable {
        /// The shape of an item content.
        public enum Shape: Hashable {
            /// A circular shape.
            case circle
            /// A capsular shape.
            case capsule
            /// A shape with rounded corners.
            case roundedRectangular(_ cornerRadius: CGFloat)
            /// A rectangular shape.
            case rectangular
            
            @ShapeBuilder internal var swiftui: some SwiftUI.Shape {
                switch self {
                case .circle: Circle()
                case .capsule: Capsule()
                case .roundedRectangular(let cornerRadius): RoundedRectangle(cornerRadius: cornerRadius)
                case .rectangular: Rectangle()
                }
            }
        }
        
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
        
        /// The shape of the content.
        public var shape: Shape = .roundedRectangular(8.0)
        /// The outer shadow properties.
        public var shadowProperties: ShadowProperties = .black()
        
        /// The maximum size of the content.
        public var maxSize: CGSize? = nil
        
        /// The background color.
        public var backgroundColor: NSColor? = .systemGray
        /// The color transformer for resolving the background color.
        public var backgroundColorTransform: NSConfigurationColorTransformer? = nil
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
                
        /// The border width.
        public var borderWidth: CGFloat = 0.0
        /// The border color.
        public var borderColor: NSColor? = nil
        /// The color transformer for resolving the border color.
        public var borderColorTransform: NSConfigurationColorTransformer? = nil
        /// Generates the resolved background color for the specified background color, using the background color and color transformer.
        ///         /// Generates the resolved border color for the specified border color, using the border color and border color transformer.
        public func resolvedBorderColor() -> NSColor? {
            if let borderColor = self.borderColor {
                return self.borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }
        
        /// The image tint color.
        public var imageTintColor: NSColor? = nil
        /// The color transformer for resolving the image tint color.
        public var imageTintColorTransform: NSConfigurationColorTransformer? = nil
        /// Generates the resolved image tint color for the specified tint color, using the tint color and tint color transformer.
        public func resolvedImageTintColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }

        /// The symbol configuration for the image.
        public var imageSymbolConfiguration: SymbolConfiguration? = nil
        /// The image scaling.
        public var imageScaling: ImageScaling = .fit
    }
}

/*
 public enum ImageSize: Hashable {
     case fullSize
     case textHeight
     case secondaryTextHeight
     case textAndSecondaryTextHeight
     case size(CGSize)
     case maxSize(CGSize)
 }
 */
