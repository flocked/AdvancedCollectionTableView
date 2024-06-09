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
        
        lazy var hostingView = NSHostingView(rootView: BadgeContentView(badge: properties))
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
            hostingView.rootView = BadgeContentView(badge: properties)
            frame.size = hostingView.fittingSize
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    struct BadgeContentView: View {
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
                .foregroundStyle(Color(badge.textProperties._resolvedTextColor))
                .multilineTextAlignment(.center)
        }
        
        @ViewBuilder
        var imageItem: some View {
            if let image = badge.image {
                Image(image)
                    .imageScaling(badge.imageProperties.scaling.swiftUI)
                    .foregroundStyle(badge.imageProperties._resolvedTintColor?.swiftUI ?? badge.textProperties.textColor.swiftUI, nil, nil)
                    .symbolConfiguration(badge.imageProperties.symbolConfiguration)
                    .frame(maxWidth: badge.imageProperties.maxWidth, maxHeight: badge.imageProperties.maxHeight)
            }
        }
        
        @ViewBuilder
        var stackItem: some View {
            if badge.imageProperties.position == .leading {
                HStack(alignment: .firstTextBaseline, spacing: badge.imageToTextPadding) {
                    imageItem
                    textItem
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: badge.imageToTextPadding) {
                    textItem
                    imageItem
                }
            }
        }
        
        @ViewBuilder
        var backgroundView: some View {
            if let visualEffect = badge.visualEffect {
                VisualEffectBackground(visualEffect)
            } else {
                Color(badge._resolvedBackgroundColor ?? .clear)
            }
        }
        
        @ViewBuilder
        var appliedStackItem: some View {
            stackItem
                .padding(badge.margins.edgeInsets)
                .background(backgroundView)
                .shape(badge.shape, borderColor: badge.borderColor, borderWidth: badge.borderWidth)
                .shadow(badge.shadow)
        }
        
        var body: some View {
            stackItem
                .padding(badge.margins.edgeInsets)
                .background(backgroundView)
                .shape(badge.shape, borderColor: badge.borderColor, borderWidth: badge.borderWidth)
                .shadow(badge.shadow)
                .help(badge.toolTip != nil ? "\(badge.toolTip!)" : nil)
        }
    }
}
    
    extension View {
        @ViewBuilder
        func shape(_ shape: NSItemContentConfiguration.Badge.Shape, borderColor: NSColor?, borderWidth: CGFloat) -> some View {
            switch shape {
            case .roundedRect(let radius):
                self.clipShape(RoundedRectangle(cornerRadius: radius))
                    .overlay(RoundedRectangle(cornerRadius: radius)
                            .strokeBorder(Color(borderColor ?? .clear),lineWidth: borderWidth)
                            .background(RoundedRectangle(cornerRadius: radius).foregroundColor(Color.clear)))
            case .circle:
                self.clipShape(Circle())
                    .overlay(Circle()
                            .strokeBorder(Color(borderColor ?? .clear),lineWidth: borderWidth)
                            .background(Circle().foregroundColor(Color.clear)))
            }
        }
    }

fileprivate struct VisualEffectBackground: NSViewRepresentable {
    private let material: NSVisualEffectView.Material
    private let blendingMode: NSVisualEffectView.BlendingMode
    private let isEmphasized: Bool
    private let appearance: NSAppearance?
    private let state: NSVisualEffectView.State
    
    init(_ configuration: VisualEffectConfiguration) {
        self.material = configuration.material
        self.blendingMode = configuration.blendingMode
        self.isEmphasized = configuration.isEmphasized
        self.appearance = configuration.appearance
        self.state = configuration.state
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.autoresizingMask = [.width, .height]
        view.material = material
        view.appearance = appearance
        view.blendingMode = blendingMode
        view.state = state
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        
    }
}
