//
//  File.swift
//  
//
//  Created by Florian Zand on 08.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

public extension NSTableCellContentConfiguration {
    enum Accessory: Hashable {
        case left(AccessoryConfiguration)
        case center(AccessoryConfiguration)
        case right(AccessoryConfiguration)
        case stack(left: AccessoryConfiguration, right: AccessoryConfiguration)
    }
    
    
    struct AccessoryConfiguration: Hashable {
        public enum ContentPosition: Hashable {
            case leading
            case trailing
        }
        
        /// The primary text.
        public var text: String? = nil
        /// An attributed variant of the primary text.
        public var attributedText: AttributedString? = nil
        /// The image to display.
        public var image: NSImage? = nil
        /// The view to display.
        public var view: NSView? = nil
        
        /**
         The padding between the content view and text.
         
         This value only applies when there’s both a content view and text.
         */
        public var contentToTextPadding: CGFloat = 0.0
        /// The position of the content.
        public var contentPosition: ContentPosition = .leading
        /// The margins between the content and the edges of the content view.
        public var padding: NSDirectionalEdgeInsets = .init(4.0)

        
        /// Properties for configuring the view.
        public var viewProperties: ViewProperties = .default()
        /// Properties for configuring the image.
        public var imageProperties: ImageProperties = ImageProperties()
        /// Properties for configuring the text.
        public var textProperties: TextProperties = .body
        /// Properties for configuring the text.
        public var contentProperties: ContentProperties = ContentProperties()
        
        public static func text(_ text: String, font: NSFont = .body) -> Self {
            var configuration = Self()
            configuration.text = text
            configuration.textProperties.font = font
            return configuration
        }
        
        public static func image(_ image: NSImage) -> Self {
            var configuration = Self()
            configuration.image = image
            return configuration
        }
        
        public static func view(_ view: NSView) -> Self {
            var configuration = Self()
            configuration.view = view
            return configuration
        }
    }
}

internal extension NSTableCellContentConfiguration.AccessoryConfiguration {
    struct TextItem: View {
        let text: String?
        @State private var _text: String = ""
        let attributedText: AttributedString?
        let properties: NSTableCellContentConfiguration.TextProperties
        
        init(text: String?, attributedText: AttributedString?, properties: NSTableCellContentConfiguration.TextProperties) {
            self.text = text
            self.attributedText = attributedText
            self.properties = properties
            self._text = self.text ?? ""

        }
        @ViewBuilder
        var item: some View {
            if let attributedText = attributedText {
                Text(attributedText)
            } else if let text = text {
                Text(text)
            }
        }
        
        var body: some View {
            item
                .font(properties.swiftuiFont ?? properties.font.swiftUI)
                .lineLimit(properties.numberOfLines)
                .foregroundColor(properties.textColor.swiftUI)
                .textSelection((properties.isSelectable == true) ? .enabled : .enabled)
        }
    }
    
    struct StackAccessoryView: View {
        let left: NSTableCellContentConfiguration.AccessoryConfiguration?
        let right: NSTableCellContentConfiguration.AccessoryConfiguration?
        
        var body: some View {
            HStack(alignment: .center) {
                if let left = self.left {
                    AccessoryView(configuration: left)
                }
                if let right = self.right {
                    AccessoryView(configuration: right)
                }
            }
        }
    }
    
    struct AccessoryView: View {
        let configuration: NSTableCellContentConfiguration.AccessoryConfiguration
        
        @ViewBuilder
        var contentItem: some View {
                ZStack() {
                    if let backgroundColor = configuration.contentProperties.backgroundColor {
                        configuration.contentProperties.shape.swiftui
                            .foregroundColor(backgroundColor.swiftUI)
                    }
                    
                    if let view = configuration.view {
                        ContainerView(view: view)
                    }
                    
                    if let image = configuration.image {
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: configuration.contentProperties.imageScaling.swiftui)
                            .foregroundColor(configuration.contentProperties.imageTintColor?.swiftUI)
                        //    .symbolConfiguration(configuration.contentProperties.imageSymbolConfiguration)
                    }
                }
           //     .backgroundOptional(configuration.contentProperties.backgroundColor?.swiftUI)
             //   .clipShape(configuration.contentProperties.shape.swiftui)
                .frame(maxWidth: configuration.contentProperties.maxSize?.width, maxHeight:  configuration.contentProperties.maxSize?.height)
                .clipShape(configuration.contentProperties.shape.swiftui)
                .shadow(color: configuration.contentProperties.shadowProperties.color?.swiftUI, radius: configuration.contentProperties.shadowProperties.radius, offset: configuration.contentProperties.shadowProperties.offset)
            
        }

        
        var body: some View {
            HStack(spacing: configuration.contentToTextPadding) {
                if (configuration.contentPosition == .leading) {
                    contentItem
                    TextItem(text:  configuration.text, attributedText:  configuration.attributedText, properties: configuration.textProperties)
                } else {
                    contentItem
                    TextItem(text:  configuration.text, attributedText:  configuration.attributedText, properties: configuration.textProperties)
                }
            }.padding(configuration.padding.edgeInsets)
        }
    }
}
