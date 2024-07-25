//
//  NSListContentView+AccessoryView.swift
//
//
//  Created by Florian Zand on 18.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

extension NSListContentView {
    class AccessoryView: NSView {
        var accessory: NSListContentConfiguration.Accessory {
            didSet {
                update()
            }
        }
        
        func update() {
            leadingAccessoryItemView.accessory = accessory.leading
            trailingAccessoryItemView.accessory = accessory.trailing
            isHidden = !accessory.leading.isVisible && !accessory.trailing.isVisible
        }
        
        lazy var leadingAccessoryItemView = ItemView(accessory: accessory.leading)
        lazy var trailingAccessoryItemView = ItemView(accessory: accessory.trailing)
        lazy var stackView = NSStackView(views: [leadingAccessoryItemView, trailingAccessoryItemView]).orientation(.horizontal).spacing(2.0).distribution(.gravityAreas)
        
        init(accessory: NSListContentConfiguration.Accessory) {
            self.accessory = accessory
            super.init(frame: .zero)
            addSubview(withConstraint: stackView)
            update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension NSListContentView.AccessoryView {
    class ItemView: NSView {
        let textField = ListItemTextField.wrapping().truncatesLastVisibleLine(true)
        let secondaryTextField = ListItemTextField.wrapping().truncatesLastVisibleLine(true)
        lazy var imageView = AccessoryImageView(properties: accessory.imageProperties)
        lazy var textStackView = NSStackView(views: [textField, secondaryTextField]).orientation(.vertical)
        lazy var stackView = NSStackView(views: [textStackView, imageView]).orientation(.vertical)
        var stackViewConstraints: [NSLayoutConstraint] = []
        
        var accessory: NSListContentConfiguration.AccessoryProperties {
            didSet {
                guard oldValue != accessory else { return }
                update()
            }
        }
        
        func update() {
            textField.updateText(accessory.text, accessory.attributedText)
            secondaryTextField.updateText(accessory.secondaryText, accessory.secondaryAttributedText)
            textField.properties = accessory.textProperties
            secondaryTextField.properties = accessory.secondaryTextProperties
            textStackView.spacing = accessory.textToSecondaryTextPadding
            stackView.spacing = accessory.imageToTextPadding
            stackView.orientation = accessory.imageProperties.position.orientation
            stackView.alignment = accessory.imageProperties.position.alignment
            stackView.addArrangedSubview(accessory.imageProperties.position.imageIsLeading ? textStackView : imageView)

            imageView.image = accessory.image
            imageView.properties = accessory.imageProperties
            isHidden = !accessory.isVisible
        }
        
        init(accessory: NSListContentConfiguration.AccessoryProperties) {
            self.accessory = accessory
            super.init(frame: .zero)
            stackViewConstraints = addSubview(withConstraint: stackView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension NSListContentView.AccessoryView.ItemView {
    class AccessoryImageView: NSImageView {
        var properties: NSListContentConfiguration.AccessoryProperties.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                update()
            }
        }

        override var image: NSImage? {
            didSet {
                isHidden = (image == nil)
            }
        }

        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize

            if image?.isSymbolImage == true, properties.position.orientation == .horizontal {
                intrinsicContentSize.width = (intrinsicContentSize.height * 2.5).rounded(.towardZero)
                return intrinsicContentSize
            }

            if let calculatedSize = calculatedSize {
                return calculatedSize
            }

            return intrinsicContentSize
        }
         

        var calculatedSize: CGSize? {
            didSet {
                invalidateIntrinsicContentSize()
            }
        }

        func update() {
            symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            imageScaling = image?.isSymbolImage == true ? .scaleNone : properties.scaling.imageScaling
            border = properties.resolvedBorder()
            backgroundColor = properties.resolvedBackgroundColor()
            contentTintColor = properties.resolvedTintColor()
            cornerRadius = properties.cornerRadius
            outerShadow = properties.resolvedShadow()
            toolTip = properties.toolTip
            invalidateIntrinsicContentSize()
        }

        init(properties: NSListContentConfiguration.AccessoryProperties.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            wantsLayer = true
            imageAlignment = .alignCenter
            update()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

/*
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
        font(Font(properties.font))
            .foregroundColor(Color(properties.resolvedColor()))
            .lineLimit(properties.maximumNumberOfLines == 0 ? nil : properties.maximumNumberOfLines)
            .multilineTextAlignment(properties.alignment.swiftUIMultiline)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: properties.alignment.swiftUI)
    }
}



*/
