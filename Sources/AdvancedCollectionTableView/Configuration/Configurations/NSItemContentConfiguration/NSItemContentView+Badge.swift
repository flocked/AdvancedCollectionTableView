//
//  NSItemContentView+Badge.swift
//
//
//  Created by Florian Zand on 18.01.24.
//

import AppKit
import SwiftUI
import FZUIKit


extension NSItemContentView {
    class BadgeView: NSView {
        var properties: NSItemContentConfiguration.Badge {
            didSet {
                guard oldValue != properties else { return }
                update()
            }
        }
        
        lazy var hostingView = NSHostingView(rootView: ContentView(badge: properties))
        var verticalConstraint: NSLayoutConstraint?
        var horizontalConstraint: NSLayoutConstraint?
        var widthConstraint: NSLayoutConstraint?
        var heightConstraint: NSLayoutConstraint?
        
        init(properties: NSItemContentConfiguration.Badge) {
            self.properties = properties
            super.init(frame: .zero)
            translatesAutoresizingMaskIntoConstraints = false
            addSubview(withConstraint: hostingView)
        }
        
        func update() {
            hostingView.rootView = ContentView(badge: properties)
            frame.size = hostingView.fittingSize
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        struct ContentView: View {
            let badge: NSItemContentConfiguration.Badge
            
            @ViewBuilder
            var text: some View {
                if let attributedText = badge.attributedText {
                    Text(attributedText)
                } else if let text = badge.text {
                    Text(text)
                }
            }
            
            @ViewBuilder
            var textItem: some View {
                text
                    .font(Font(badge.textProperties.font))
                    .lineLimit(1)
                    .foregroundStyle(Color(badge.textProperties.resolvedTextColor()))
                    .multilineTextAlignment(.center)
            }
            
            @ViewBuilder
            var imageItem: some View {
                if let image = badge.image {
                    Image(image)
                        .imageScaling(badge.imageProperties.scaling.swiftUI)
                        .foregroundStyle(badge.imageProperties.resolvedTintColor()?.swiftUI ?? badge.textProperties.textColor.swiftUI, nil, nil)
                        .symbolConfiguration(badge.imageProperties.symbolConfiguration)
                        .frame(maxWidth: badge.imageProperties.maxWidth, maxHeight: badge.imageProperties.maxHeight)
                }
            }
            
            @ViewBuilder
            var stackItem: some View {
                HStack(alignment: .firstTextBaseline, spacing: badge.imageToTextPadding) {
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
                    .badgeBackground(badge)
                    .badgeShape(badge)
                    .shadow(badge.shadow)
                    .help(badge.toolTip != nil ? LocalizedStringKey(badge.toolTip!) : nil)
            }
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func badgeBackground(_ badge: NSItemContentConfiguration.Badge) -> some View {
        if let effect = badge.visualEffect {
            self.visualEffect(effect)
        } else {
            self.background(badge.resolvedBackgroundColor()?.swiftUI ?? .clear)
        }
    }
    
    @ViewBuilder
    func badgeShape(_ badge: NSItemContentConfiguration.Badge) -> some View {
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
        }
    }
}
