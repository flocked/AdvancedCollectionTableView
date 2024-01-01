//
//  NSListContentConfiguration+Accessory.swift
//
//
//  Created by Florian Zand on 19.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

extension NSListContentConfiguration {
    /// Properties that affect the cell content configuration’s image.
    struct Accessory: Hashable {
        var leading: AccessoryProperties = {
            var properties = AccessoryProperties()
            properties.textProperties.alignment = .left
            properties.secondaryTextProperties.alignment = .left
            return properties
        }()
        
        var center: AccessoryProperties = {
            var properties = AccessoryProperties()
            properties.textProperties.alignment = .center
            properties.secondaryTextProperties.alignment = .center
            return properties
        }()
        
        var trailing: AccessoryProperties = {
            var properties = AccessoryProperties()
            properties.textProperties.alignment = .right
            properties.secondaryTextProperties.alignment = .right
            return properties
        }()
        
        var padding: CGFloat = 4.0
    }
}

extension NSListContentConfiguration {
    /// Properties that affect the cell content configuration’s image.
    struct AccessoryProperties: Hashable {
        // MARK: Customizing content
        
        /// The primary text.
        public var text: String? = nil
        /// An attributed variant of the primary text.
        public var attributedText: AttributedString? = nil
        /// The secondary text.
        public var secondaryText: String? = nil
        /// An attributed variant of the secondary text.
        public var secondaryAttributedText: AttributedString? = nil
        /// The image.
        public var image: NSImage? = nil
        
        // MARK: Customizing appearance
        
        /// Properties for configuring the primary text.
        public var textProperties: TextProperties = .primary
        /// Properties for configuring the secondary text.
        public var secondaryTextProperties: TextProperties = .secondary
        /// Properties for configuring the image.
        public var imageProperties = ImageProperties()
        
        // MARK: Customizing layout
        
        /// The padding to 
        public var padding: CGFloat = 4.0
        /// The padding between the image and text.
        public var imageToTextPadding: CGFloat = 8.0
        /// The padding between primary and secndary text.
        public var textToSecondaryTextPadding: CGFloat = 2.0
        public var imagePosition: ImagePosition = .leading
        
        public enum ImagePosition {
            case leading
            case trailing
        }
        
        var hasText: Bool {
            text != nil || attributedText != nil
        }
        
        var hasSecondaryText: Bool {
            secondaryText != nil || secondaryAttributedText != nil
        }
        
        var hasContent: Bool {
            return image != nil
        }
        
        var isVisible: Bool {
            image != nil || hasText || hasSecondaryText
        }
    }
}
