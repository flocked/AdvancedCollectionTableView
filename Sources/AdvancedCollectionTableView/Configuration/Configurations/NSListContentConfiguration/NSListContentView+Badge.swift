//
//  NSListContentView+Badge.swift
//
//
//  Created by Florian Zand on 18.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

extension NSListContentView {
    class BadgeView: NSView {
        var properties: NSListContentConfiguration.Badge {
            didSet {
                guard oldValue != properties else { return }
                updateBadge()
            }
        }

        var verticalConstraint: NSLayoutConstraint?
        var widthConstraint: NSLayoutConstraint?

        func updateBadge() {
            border = properties.border
            cornerRadius = properties.cornerRadius
            backgroundColor = properties.resolvedBackgroundColor()
            outerShadow = properties.shadow
            textField.font = properties.font
            textField.textColor = properties.resolvedColor()
            imageView.image = properties.image
            imageView.properties = properties.imageProperties
            imageView.contentTintColor = properties.resolvedImageTintColor
            if let attributedText = properties.attributedText {
                textField.attributedStringValue = NSAttributedString(attributedText)
            } else {
                textField.stringValue = properties.text ?? ""
            }
            textField.isHidden = (properties.text == nil && properties.attributedText == nil)

            stackViewConstraints.constant(properties.margins)
            stackView.spacing = properties.imageToTextPadding
            if properties.imageProperties.position == .leading, stackView.arrangedSubviews.first != imageView {
                stackView.removeArrangedSubview(textField)
                stackView.addArrangedSubview(textField)
            } else if properties.imageProperties.position == .trailing, stackView.arrangedSubviews.last != imageView {
                stackView.removeArrangedSubview(imageView)
                stackView.addArrangedSubview(imageView)
            }

            textField.invalidateIntrinsicContentSize()

            if let maxWidth = properties.maxWidth {
                if widthConstraint == nil {
                    widthConstraint = widthAnchor.constraint(equalToConstant: maxWidth)
                }
                widthConstraint?.constant = maxWidth
                widthConstraint?.activate()
            } else {
                widthConstraint?.activate(false)
                widthConstraint = nil
            }
            
            toolTip = properties.toolTip
        }

        init(properties: NSListContentConfiguration.Badge) {
            self.properties = properties
            super.init(frame: .zero)
            initalSetup()
            updateBadge()
        }

        let textField = NSTextField(wrappingLabelWithString: "")
        lazy var imageView = BadgeImageView(properties: properties.imageProperties)
        lazy var stackView = NSStackView(views: [imageView, textField]).orientation(.horizontal).alignment(.firstBaseline)

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var stackViewConstraints: [NSLayoutConstraint] = []
        func initalSetup() {
            translatesAutoresizingMaskIntoConstraints = false
            textField.textLayout = .wraps
            textField.maximumNumberOfLines = 1
            textField.isSelectable = false
            stackViewConstraints = addSubview(withConstraint: stackView)
        }
    }

    class BadgeImageView: NSImageView {
        var properties: NSListContentConfiguration.Badge.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                updateProperties()
            }
        }

        init(properties: NSListContentConfiguration.Badge.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            updateProperties()
        }

        override var image: NSImage? {
            didSet {
                isHidden = image == nil
            }
        }

        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            if image?.isSymbolImage == true {
                return intrinsicContentSize
            }

            if let maxWidth = properties.maxWidth, intrinsicContentSize.width > maxWidth {
                intrinsicContentSize.width = maxWidth
            }
            if let maxHeight = properties.maxHeight, intrinsicContentSize.height > maxHeight {
                intrinsicContentSize.height = maxHeight
            }
            return intrinsicContentSize
        }

        func updateProperties() {
            contentTintColor = properties.resolvedTintColor()
            symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            imageScaling = properties.scaling
            invalidateIntrinsicContentSize()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

/*
extension NSListContentView {
    struct BadgeContentView: View {
        let text: String?
        let attributedText: AttributedString?
        let image: NSImage?
        let font: NSFont
        let color: NSColor
        let margins: NSDirectionalEdgeInsets
        let border: BorderConfiguration
        let shadow: ShadowConfiguration
        let toolTip: String?
        let imageMaxWidth: CGFloat?
        let imageMaxHeight: CGFloat?
        let symbolConfiguration: ImageSymbolConfiguration?
        let textIsLeading: Bool
        let cornerRadius: CGFloat
        let isCircle: Bool
        let tintColor: NSColor?
        let imageToTextPadding: CGFloat
        let backgroundColor: NSColor?
        let visualEffect: VisualEffectConfiguration?
        
        init(_ badge: NSListContentConfiguration.Badge) {
            self.text = badge.text
            self.attributedText = badge.attributedText
            self.image = badge.image
            self.font = badge.font
            self.color = badge.resolvedColor()
            self.backgroundColor = badge.resolvedBackgroundColor()
            self.margins = badge.margins
            self.border = badge.border
            self.shadow = badge.shadow
            self.toolTip = badge.toolTip
            self.imageMaxWidth = badge.imageProperties.maxWidth
            self.imageMaxHeight = badge.imageProperties.maxHeight
            self.textIsLeading = badge.imageProperties.position == .trailing
            self.cornerRadius = badge.cornerRadius
            self.symbolConfiguration = badge.imageProperties.symbolConfiguration
            self.tintColor = badge.imageProperties.resolvedTintColor()
            self.imageToTextPadding = badge.imageToTextPadding
            self.isCircle = false
            self.visualEffect = nil
        }
        
        init(_ badge: NSItemContentConfiguration.Badge) {
            self.text = badge.text
            self.attributedText = badge.attributedText
            self.image = badge.image
            self.font = badge.textProperties.font
            self.color = badge.textProperties.resolvedTextColor()
            self.backgroundColor = badge.resolvedBackgroundColor()
            self.margins = badge.margins
            self.border = badge.border
            self.shadow = badge.shadow
            self.toolTip = badge.toolTip
            self.imageMaxWidth = badge.imageProperties.maxWidth
            self.imageMaxHeight = badge.imageProperties.maxHeight
            self.textIsLeading = badge.imageProperties.position == .trailing
            self.symbolConfiguration = badge.imageProperties.symbolConfiguration
            self.tintColor = badge.imageProperties.resolvedTintColor()
            self.imageToTextPadding = badge.imageToTextPadding
            self.visualEffect = badge.visualEffect
            switch badge.shape {
            case .roundedRect(let radius):
                self.cornerRadius = radius
                self.isCircle = false
            case .circle:
                self.cornerRadius = 0
                self.isCircle = true
            }
        }

        @ViewBuilder
        var textContent: some View {
            if let attributedText = attributedText {
                Text(attributedText)
            } else if let text = text {
                Text(text)
            }
        }
        
        @ViewBuilder
        var textItem: some View {
            textContent
                .font(Font(font))
                .lineLimit(1)
                .foregroundStyle(Color(color))
                .multilineTextAlignment(.center)
        }
        
        @ViewBuilder
        var imageItem: some View {
            if let image = image {
                Image(image)
                 //   .imageScaling(badge.imageProperties.scaling.swiftUI)
                    .foregroundStyle(Color(tintColor ?? color))
                    .symbolConfiguration(symbolConfiguration)
                    .frame(maxWidth: imageMaxWidth, maxHeight: imageMaxHeight)
            }
        }
        
        @ViewBuilder
        var stackItem: some View {
            HStack(alignment: .firstTextBaseline, spacing: imageToTextPadding) {
                if textIsLeading {
                    textItem
                    imageItem
                } else {
                    imageItem
                    textItem
                }
            }
        }
        
        var body: some View {
            stackItem
                .padding(margins.edgeInsets)
                .badgeBackground(color: backgroundColor, visualEffect: visualEffect)
                .badgeShape(isCircle: isCircle, cornerRadius: cornerRadius, border: border)
                .shadow(shadow)
                .help(toolTip != nil ? LocalizedStringKey(toolTip!) : nil)
        }
    }
}

extension View {
    @ViewBuilder
    func badgeBackground(color: NSColor?, visualEffect: VisualEffectConfiguration?) -> some View {
        if let effect = visualEffect {
            self.visualEffect(effect)
        } else {
            self.background(color?.swiftUI ?? .clear)
        }
    }
    
    @ViewBuilder
    func badgeShape(isCircle: Bool, cornerRadius: CGFloat, border: BorderConfiguration) -> some View {
        if isCircle {
            self.clipShape(Circle())
                .overlay(Circle()
                    .stroke(border)
                    .background(Circle().foregroundColor(Color.clear)))
        } else {
            self.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(border)
                    .background(RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(Color.clear)))
        }
    }
}
*/
