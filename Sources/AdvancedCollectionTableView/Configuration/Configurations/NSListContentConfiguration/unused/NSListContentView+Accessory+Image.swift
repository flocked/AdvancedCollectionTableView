//
//  NSListContentView+Accessory+Image.swift
//
//
//  Created by Florian Zand on 13.08.23.
//

import AppKit
import FZUIKit
import SwiftUI

extension NSListContentConfiguration.AccessoryProperties {
    /// Properties that affect the cell content configuration’s image.
    struct ImageProperties: Hashable {
        enum ImageScaling {
            case scaleToFit
            case scaleToFill
            case resize
            case none

            var isResizable: Bool {
                self != .none
            }

            var contentMode: ContentMode? {
                switch self {
                case .scaleToFit: return .fit
                case .scaleToFill: return .fill
                default: return nil
                }
            }
        }

        var scaling: ImageScaling = .scaleToFit
        var tintColor: NSColor?
        var symbolConfiguration: ImageSymbolConfiguration?
        var maxWidth: CGFloat?
        var maxHeight: CGFloat?
    }
}

extension Image {
    @ViewBuilder
    func configurate(using properties: NSListContentConfiguration.AccessoryProperties.ImageProperties) -> some View {
        if properties.scaling.isResizable {
            resizable()
                .foregroundColor(properties.tintColor?.swiftUI)
                .symbolConfiguration(tintColor: properties.tintColor?.swiftUI, configuration: properties.symbolConfiguration)
                .aspectRatio(contentMode: properties.scaling.contentMode ?? .fit)
                .frame(maxWidth: properties.maxWidth, maxHeight: properties.maxHeight)
        } else {
            foregroundColor(properties.tintColor?.swiftUI)
                .frame(maxWidth: properties.maxWidth, maxHeight: properties.maxHeight)
        }
    }
}
