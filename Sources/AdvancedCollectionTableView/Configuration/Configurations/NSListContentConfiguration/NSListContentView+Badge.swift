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
                .font(Font(badge.font))
                .lineLimit(1)
                .foregroundStyle(Color(badge.resolvedColor()))
                .multilineTextAlignment(.center)
        }
        
        @ViewBuilder
        var imageItem: some View {
            if let image = badge.image {
                Image(image)
                    .imageScaling(badge.imageProperties.scaling.swiftUI)
                    .foregroundStyle(badge.imageProperties.resolvedTintColor()?.swiftUI ?? badge.resolvedColor().swiftUI, nil, nil)
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
                .frame(maxWidth: badge.maxWidth)
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
        }
    }
}
