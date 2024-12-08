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
        
        lazy var hostingViiew = NSHostingView(rootView: ContentView(badge: properties))
        
        var properties: NSListContentConfiguration.Badge {
            didSet {
                guard oldValue != properties else { return }
                hostingViiew.rootView = ContentView(badge: properties)
            }
        }
        
        init(properties: NSListContentConfiguration.Badge) {
            self.properties = properties
            super.init(frame: .zero)
            addSubview(withConstraint: hostingViiew)
        }
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    struct ContentView: View {
        let badge: NSListContentConfiguration.Badge
        
        init(badge: NSListContentConfiguration.Badge) {
            self.badge = badge
        }
        
        @ViewBuilder
        var text: some View {
            if let attributedText = badge.attributedText {
                Text(attributedText)
            } else if let text = badge.text {
                Text(text)
                    .font(Font(badge.font))
            }
        }
        
        @ViewBuilder
        var textItem: some View {
            text
                .foregroundColor(Color(badge.resolvedColor()))
                .lineLimit(1)
                .truncationMode(.tail)
        }
        
        @ViewBuilder
        var imageItem: some View {
            if let image = badge.image {
                Image(nsImage: image)
                    .imageScaling(badge.imageProperties.scaling.swiftUI)
                    .foregroundStyle(badge.imageProperties.resolvedTintColor()?.swiftUI ?? badge.resolvedColor().swiftUI)
                    .symbolConfiguration(badge.imageProperties.symbolConfiguration)
                    .frame(maxWidth: badge.imageProperties.maxWidth, maxHeight: badge.imageProperties.maxHeight)
            }
        }
        
        @ViewBuilder
        var stackItem: some View {
            HStack(alignment: .center, spacing: badge.imageToTextPadding) {
                if badge.imageProperties.position == .leading {
                    imageItem
                    textItem
                } else {
                    textItem
                    imageItem
                }
            }
        }

        var body: some View {
            stackItem
                .padding(badge.margins.edgeInsets)
                .background(badge.resolvedBackgroundColor()?.swiftUI)
                .badgeShape(badge)
                .shadow(badge.shadow)
                .frame(maxWidth: badge.maxWidth)
                .help(badge.toolTip != nil ? LocalizedStringKey(badge.toolTip!) : nil)
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func badgeShape(_ badge: NSListContentConfiguration.Badge) -> some View {
        switch badge.shape {
        case .roundedRect(let radius):
            self.clipShape(RoundedRectangle(cornerRadius: radius))
                .overlay(RoundedRectangle(cornerRadius: radius)
                    .stroke(badge.border)
                    .background(RoundedRectangle(cornerRadius: radius).foregroundColor(Color.clear)))
        case .circle:
            self.clipShape(Circle())
                .overlay(Circle()
                    .stroke(badge.border)
                    .background(Circle().foregroundColor(Color.clear)))
        case .capsule:
            self.clipShape(Capsule())
                .overlay(Capsule()
                    .stroke(badge.border)
                    .background(Capsule().foregroundColor(Color.clear)))
        }
    }
}

/*
extension NSListContentView {
    class BadgeView: NSView {
        let textField = NSTextField.wrapping()
        let imageView = ImageView()
        lazy var stackView = NSStackView(views: [textField, imageView])
        var stackViewConstraints: [NSLayoutConstraint] = []
        var maxWidthConstraint: NSLayoutConstraint?
        var imageViewMaxWidthConstraint: NSLayoutConstraint?
        var imageViewMaxHeightConstraint: NSLayoutConstraint?
                
        var properties: NSListContentConfiguration.Badge {
            didSet {
                guard oldValue != properties else { return }
                update()
            }
        }
        
        func update() {
            textField.textColor = properties.resolvedColor()
            textField.font = properties.font
            if let attributedText = properties.attributedText {
                textField.attributedStringValue = attributedText.nsAttributedString
                textField.isHidden = false
            } else if let text = properties.text {
                textField.stringValue = text
                textField.isHidden = false
            } else {
                textField.stringValue = ""
                textField.isHidden = true
            }
            
            imageView.tintColor = properties.imageProperties.resolvedTintColor() ?? properties.resolvedColor()
            imageView.image = properties.image
            imageView.imageSymbolConfiguration = properties.imageProperties.symbolConfiguration
            imageView.isHidden = properties.image == nil
            imageView.imageScaling = .init(rawValue: properties.imageProperties.scaling.rawValue) ?? .scaleToFit
            
            stackView.spacing = properties.imageToTextPadding
            if properties.imageProperties.position == .leading, stackView.arrangedViews.first != imageView {
                stackView.arrangedViews = [imageView, textField]
            } else if properties.imageProperties.position == .trailing, stackView.arrangedViews.first != textField {
                stackView.arrangedViews = [textField, imageView]
            }
            
            border = properties.border
            outerShadow = properties.shadow
            backgroundColor = properties.resolvedBackgroundColor()
            
            stackViewConstraints.constant(properties.margins)
            toolTip = properties.toolTip
            
            maxWidthConstraint?.activate(false)
            if let maxWidth = properties.maxWidth {
                maxWidthConstraint = widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).activate()
            }
            
            imageViewMaxWidthConstraint?.activate(false)
            imageViewMaxHeightConstraint?.activate(false)
            if let maxWidth = properties.imageProperties.maxWidth {
                imageViewMaxWidthConstraint = imageView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).activate()
            }
            if let maxHeight = properties.imageProperties.maxHeight {
                imageViewMaxHeightConstraint = imageView.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight).activate()
            }
            
            layoutSubtreeIfNeeded()
            
            switch properties.shape {
            case .roundedRect(let radius):
                cornerRadius = radius
            case .circle:
                cornerRadius = fittingSize.height/2.0
            case .capsule:
                cornerRadius = fittingSize.height/2.0
            }
        }
        
        func sharedInit() {
            stackViewConstraints = addSubview(withConstraint: stackView)
        }
        
        init(properties: NSListContentConfiguration.Badge) {
            self.properties = properties
            super.init(frame: .zero)
            sharedInit()
            update()
        }
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
*/
