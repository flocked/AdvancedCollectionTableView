//
//  File.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

import Foundation

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableCellContentConfiguration {
    struct AccessoryProperties: Hashable {
        public enum Position: Hashable {
            case top
            case topLeft
            case topRight
            case bottom
            case bottomLeft
            case bottomRight
            internal var isTopPosition: Bool {
                return self == .top || self == .topLeft || self == .topRight
            }
        }
        
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
        
        /// The position of the accessory.
        public var position: Position = .topLeft
        /// The primary text.
        public var text: String? = nil
        /// An attributed variant of the primary text.
        public var attributedText: NSAttributedString? = nil
        
        /// The image to display.
        public var image: NSImage? = nil
        
        /// The view to display.
        public var view: NSView? = nil
        
        /// Properties for configuring the view.
        public var viewProperties: ViewProperties = .default()
        /// Properties for configuring the image.
        public var imageProperties: ImageProperties = ImageProperties()
        /// Properties for configuring the text.
        public var textProperties: TextProperties = .textStyle(.body, weight: .bold)
        
        /// The background color.
        public var backgroundColor: NSColor? = nil
        /// The color transformer for resolving the background color.
        public var backgroundColorTansform: NSConfigurationColorTransformer? = nil
        
        /// Generates the resolved background color for the specified background color, using the background color and color transformer.
        public func resolvedBackgroundColor() -> NSColor? {
            if let backgroundColor = self.backgroundColor {
                return self.backgroundColorTansform?(backgroundColor) ?? backgroundColor
            }
            return nil
        }
        
        /*
        public init(position: Position = .topLeft, text: String? = nil, attributedText: NSAttributedString? = nil, image: NSImage? = nil, view: NSView? = nil, viewProperties: ViewProperties = ViewProperties(), imageProperties: ImageProperties = ImageProperties(), textProperties: TextProperties = TextProperties(), backgroundColor: NSColor? = nil, backgroundColorTansform: NSConfigurationColorTransformer? = nil) {
            self.position = position
            self.text = text
            self.attributedText = attributedText
            self.image = image
            self.view = view
            self.viewProperties = viewProperties
            self.imageProperties = imageProperties
            self.textProperties = textProperties
            self.backgroundColor = backgroundColor
            self.backgroundColorTansform = backgroundColorTansform
        }
        */
    }
}
