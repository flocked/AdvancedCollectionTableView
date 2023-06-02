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
    struct ContentProperties: Hashable {
        public enum Shape: Hashable {
            case circle
            case capsule
            case roundedRectangular(_ cornerRadius: CGFloat)
            case rectangular
            
            @ShapeBuilder internal var swiftui: some SwiftUI.Shape {
                switch self {
                case .circle: Circle()
                case .capsule: Capsule()
                case .roundedRectangular(let cornerRadius): RoundedRectangle(cornerRadius: cornerRadius)
                case .rectangular: Rectangle()
                }
            }
            
            /*
            internal var swiftui: some SwiftUI.Shape {
                switch self {
                case .circle: return Circle().asAnyShape()
                case .capsule: return Capsule().asAnyShape()
                case .roundedRectangular(let cornerRadius): return RoundedRectangle(cornerRadius: cornerRadius).asAnyShape()
                case .rectangular: return Rectangle().asAnyShape()
                }
            }
             */
        }
        
        public var shape: Shape = .roundedRectangular(8.0)
        public var shadowProperties: ShadowProperties = .black()
        
        public var backgroundColor: NSColor? = .systemGray
        public var backgroundColorTransform: NSConfigurationColorTransformer? = nil
                
        public var borderWidth: CGFloat = 0.0
        public var borderColor: NSColor? = nil
        public var borderColorTransform: NSConfigurationColorTransformer? = nil
        
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTransform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        public func resolvedBorderdColor() -> NSColor? {
            if let borderColor = self.borderColor {
                return self.borderColorTransform?(borderColor) ?? borderColor
            }
            return nil
        }
    }
}
