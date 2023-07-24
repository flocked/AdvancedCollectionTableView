//
//  Accessory.swift
//  NSTableCellContentConfiguration
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public extension NSTableCellContentConfiguration {
    struct Accessory: Hashable {
        public struct AccessoryContent: Hashable {
            public enum ContentPosition {
                case leading
                case trailing
            }
            
            public var text: String?
            public var attributedText: AttributedString?
            
            public var image: NSImage?
            public var view: NSView?
            
            public var textProperties: ConfigurationProperties.Text = .body
            public var contentProperties = ContentProperties()
            
            public var contentPosition: ContentPosition = .trailing
            public var contentToTextSpacing: CGFloat = 2.0
            
            public static func text(_ text: String, image: NSImage? = nil, imagePosition: ContentPosition = .trailing) -> AccessoryContent {
                AccessoryContent(text: text, image: image, contentPosition: imagePosition)
            }
            
            public static func image(_ image: NSImage) -> AccessoryContent {
                AccessoryContent(image: image)
            }
            
            public static func view(_ view: NSView) -> AccessoryContent {
                AccessoryContent(view: view)
            }
        }
        
        public var accessories: [AccessoryContent] = []
        
        public var accessoriesSpacing: CGFloat = 2.0
        public var insets = NSEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    }
}
