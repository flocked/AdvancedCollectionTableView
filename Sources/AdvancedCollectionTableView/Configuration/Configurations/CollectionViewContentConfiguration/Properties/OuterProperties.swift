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
    struct OuterProperties: Hashable {
        public var cornerRadius: CGFloat = 0.0

        public var shadowProperties: ShadowProperties = .black()
        
        public var borderWidth: CGFloat = 0.0
        public var borderColor: NSColor? = nil
        public var borderColorTransform: NSConfigurationColorTransformer? = nil
        
        public var backgroundColor: NSColor? = .systemGray
        public var backgroundColorTransform: NSConfigurationColorTransformer? = nil
                
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
