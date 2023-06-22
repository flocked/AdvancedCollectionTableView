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
            public var text: String?
            public var attributedText: AttributedString?
            
            public var image: NSImage?
            public var view: NSView?
            
            public var textProperties = TextProperties()
            public var imageProperties = ImageProperties()
        }
        public var leading: AccessoryContent = AccessoryContent()
        public var center: AccessoryContent = AccessoryContent()
        public var trailing: AccessoryContent = AccessoryContent()
        
        public var spacing: CGFloat = 2.0


    }
}
