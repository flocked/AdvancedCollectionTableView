//
//  TableCellConfiguration+Accessory+Image.swift
//  ItemConfiguration
//
//  Created by Florian Zand on 13.08.23.
//

import AppKit
import FZUIKit
import SwiftUI

public extension NSListContentConfiguration.AccessoryProperties {
    /// Properties that affect the cell content configuration’s image.
    struct ImageProperties: Hashable {
        enum ImageScaling {
            case scaleToFit
            case scaleToFill
            case resize
            case none
            
            internal var isResizable: Bool {
                self != .none
            }
            
            internal var contentMode: ContentMode? {
                switch self {
                case .scaleToFit: return .fit
                case .scaleToFill: return .fill
                default: return nil
                }
            }
        }
        var scaling: ImageScaling = .scaleToFit
        var tintColor: NSColor? = nil
        var symbolConfiguration: ContentConfiguration.SymbolConfiguration? = nil
        var maxWidth: CGFloat? = nil
        var maxHeight: CGFloat? = nil
    }
}

internal extension Image {
    @ViewBuilder
    func configurate(using properties: NSListContentConfiguration.AccessoryProperties.ImageProperties) -> some View {
        if properties.scaling.isResizable {
            self.resizable()
                .foregroundColor(properties.tintColor?.swiftUI)
                .symbolConfiguration(tintColor: properties.tintColor?.swiftUI, configuration: properties.symbolConfiguration)
                .aspectRatio(contentMode: properties.scaling.contentMode ?? .fit)
                .frame(maxWidth: properties.maxWidth, maxHeight: properties.maxHeight)
        } else {
            self
                .foregroundColor(properties.tintColor?.swiftUI)
                .frame(maxWidth: properties.maxWidth, maxHeight: properties.maxHeight)
        }
    }
}
