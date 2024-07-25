//
//  NSListContentView+Accessory.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

extension NSListContentConfiguration {
    
    /// Properties for a list accessory.
    struct Accessory: Hashable {
        
        /// Position of the accessory.
        public enum Position: Int, Hashable {
            /// The accessory is positioned at the top of the list item.
            case top
            /// The accessory is positioned at the bottom of the list item.
            case bottom
        }
        
        /// The leading accessory item.
       var leading: AccessoryProperties = {
           var properties = AccessoryProperties()
           properties.textProperties.alignment = .left
           properties.secondaryTextProperties.alignment = .left
           return properties
       }()
        
        /// The trailing accessory item.
       var trailing: AccessoryProperties = {
           var properties = AccessoryProperties()
           properties.textProperties.alignment = .right
           properties.secondaryTextProperties.alignment = .right
           return properties
       }()
        
        /// The position of the accessory.
        public var position: Position = .top
        
        /// The padding to the next accessory.
        public var padding: CGFloat = 4.0
    }
}

extension NSListContentConfiguration {
    /// Properties for a list accessory item.
    struct AccessoryProperties: Hashable {
        // MARK: Customizing content

        /// The primary text.
        public var text: String?
        
        /// An attributed variant of the primary text.
        public var attributedText: AttributedString?
        
        /// The secondary text.
        public var secondaryText: String?
        
        /// An attributed variant of the secondary text.
        public var secondaryAttributedText: AttributedString?
        
        /// The image.
        public var image: NSImage?

        // MARK: Customizing appearance

        /// Properties for configuring the primary text.
        public var textProperties: TextProperties = .primary
        
        /// Properties for configuring the secondary text.
        public var secondaryTextProperties: TextProperties = .secondary
        
        /// Properties for configuring the image.
        public var imageProperties = ImageProperties()

        // MARK: Customizing layout

        /// The padding to the next accessory item.
        public var padding: CGFloat = 4.0
        
        /// The padding between the image and text.
        public var imageToTextPadding: CGFloat = 8.0
        
        /// The padding between primary and secndary text.
        public var textToSecondaryTextPadding: CGFloat = 2.0

        var hasText: Bool {
            text != nil || attributedText != nil
        }

        var hasSecondaryText: Bool {
            secondaryText != nil || secondaryAttributedText != nil
        }

        var hasContent: Bool {
            image != nil
        }

        var isVisible: Bool {
            image != nil || hasText || hasSecondaryText
        }
    }
}
