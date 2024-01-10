//
//  NSListContentConfiguration+AccessoryView.swift
//  
//
//  Created by Florian Zand on 18.08.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

class AccessoryView: NSView {

}

extension AccessoryView {
    struct ContentView: View {
        struct AccessoryItem: View {
            let properties: NSListContentConfiguration.AccessoryProperties
            let alignment: SwiftUI.Alignment

            @ViewBuilder
            var text: some View {
                if let text = properties.attributedText {
                    Text(text)
                        .configurate(using: properties.textProperties)
                } else if let text = properties.text {
                    Text(text)
                        .configurate(using: properties.textProperties)
                }
            }

            @ViewBuilder
            var secondaryText: some View {
                if let text = properties.secondaryAttributedText {
                    Text(text)
                        .configurate(using: properties.secondaryTextProperties)
                } else if let text = properties.secondaryText {
                    Text(text)
                        .configurate(using: properties.secondaryTextProperties)
                }
            }

            @ViewBuilder
            var image: some View {
                if let image = properties.image {
                    Image(image)
                        .configurate(using: properties.imageProperties)
                }
            }

            @ViewBuilder
            var textItems: some View {
                HStack(alignment: .firstTextBaseline, spacing: properties.textToSecondaryTextPadding) {
                    text
                    secondaryText
                }
            }

            @ViewBuilder
            var items: some View {
                if properties.imagePosition == .leading {
                    image
                    textItems
                } else {
                    text
                    textItems
                }
            }

            var body: some View {
                HStack(alignment: .center, spacing: properties.imageToTextPadding) {
                    items
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)

            }
        }

        let accessory: NSListContentConfiguration.Accessory

        @ViewBuilder
        var leading: some View {
            if accessory.leading.isVisible {
                AccessoryItem(properties: accessory.leading, alignment: .leading)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }

        @ViewBuilder
        var center: some View {
            if accessory.center.isVisible {
                AccessoryItem(properties: accessory.center, alignment: .center)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }

        @ViewBuilder
        var trailing: some View {
            if accessory.trailing.isVisible {
                AccessoryItem(properties: accessory.trailing, alignment: .trailing)
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }

        var body: some View {
            HStack(alignment: .firstTextBaseline, spacing: accessory.padding) {
                leading
                center
                trailing
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}

func testAcces() {
    var accessory = NSListContentConfiguration.Accessory()
    accessory.leading.text = "Leading Text"
    accessory.trailing.text = "Trailing Text"
}

struct ContentView_Previews: PreviewProvider {
    static var accessory1: NSListContentConfiguration.Accessory {
        var accessory = NSListContentConfiguration.Accessory()
        accessory.leading.text = "Leading Text"
        accessory.trailing.text = "Trailing Text"
        accessory.center.image = NSImage(named: "astronaut cat")
        accessory.trailing.secondaryText = "Secondary"
        return accessory
    }
    static var previews: some View {
        AccessoryView.ContentView(accessory: accessory1)
            .frame(width: 300)
            .padding()
    }
}

@available(macOS 11.0, iOS 15.0, tvOS 15.0, watchOS 6.0, *)
 extension Text {
    @ViewBuilder
    func configurateAlt(using properties: TextProperties) -> some View {
        self
            .font(Font(properties.font))
            .foregroundColor(Color(properties.resolvedColor()))
            .lineLimit(properties.numberOfLines == 0 ? nil : properties.numberOfLines)
            .multilineTextAlignment(properties.alignment.swiftUIMultiline)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: properties.alignment.swiftUI)
    }
}

extension NSTextAlignment {
    var swiftUI: Alignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        default: return .leading
        }
    }

    var swiftUIMultiline: SwiftUI.TextAlignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        default: return .leading
        }
    }
}
