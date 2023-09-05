//
//  NSItemContentViewSwiftUI.swift
//  
//
//  Created by Florian Zand on 02.06.23.
//

/*
import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

// Unused SwiftUI based version of NSItemContentView
@available(macOS 13.0, *)
internal class NSItemContentViewSwiftUI: NSView, NSContentView {
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSItemContentConfiguration {
                _configuration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSItemContentConfiguration
    }
    
    /// Creates an item content view with the specified content configuration.
    public init(configuration: NSItemContentConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
        
        addSubview(withConstraint: hostingController.view)
        self.updateConfiguration()
        self.maskToBounds = false
    }
    
    internal var _configuration: NSItemContentConfiguration {
        didSet {
            if oldValue != _configuration {
                updateConfiguration()
            }
        }
    }
    
    internal func updateConfiguration() {
        hostingController.rootView =  ContentView(configuration: self._configuration)
    }
    
    internal lazy var hostingController: NSHostingController<ContentView> = {
        let hostingView = ContentView(configuration: self._configuration)
        let hostingController = NSHostingController<ContentView>(rootView: hostingView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.maskToBounds = false
        hostingController.view.isOpaque = false
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        return hostingController
    }()
    
    
    public func sizeThatFits(_ size: CGSize) -> CGSize {
        return hostingController.sizeThatFits(in: size)
    }
    
    override var fittingSize: NSSize {
        return hostingController.fittingSize
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidMoveToSuperview() {
        if superview == nil {
            hostingController.removeFromParent()
        } else {
            if (hostingController.parent == nil) {
                parentController?.addChild(hostingController)
            }
        }
    }
}

@available(macOS 13.0, *)
internal extension NSItemContentViewSwiftUI {
    @available(macOS 13.0, *)
    struct ContentItem: View {
        let view: NSView?
        let image: NSImage?
        let overlayView: NSView?
        let contentPosition: NSItemContentConfiguration.ContentPosition
        let properties: NSItemContentConfiguration.ContentProperties
        
        @ViewBuilder
        var contentStack: some View {
            ZStack() {
                if let backgroundColor = properties._resolvedBackgroundColor {
                    RoundedRectangle(cornerRadius: properties.cornerRadius)
                        .foregroundColor(backgroundColor.swiftUI)
                }
                
                if let view = view {
                    ContainerView(view: view)
                }
                
                if let image = image {
                    ShapedImage(image: image, shape: RoundedRectangle(cornerRadius: properties.cornerRadius), aspectRatio: properties.imageScaling.swiftui)
                }
                
                if let overlayView = overlayView {
                    ContainerView(view: overlayView)
                }
            }
        }
        
        @ViewBuilder
        var contentItem: some View {
            if properties.imageScaling == .fill {
                contentStack
            } else {
                contentStack
                    .sizing(properties.sizing, hasImage: (image != nil), isVertical: contentPosition.isVertical)
            }
        }
        
        var body: some View {
            contentItem
                .clipShape(RoundedRectangle(cornerRadius: properties.cornerRadius))
                .background(
                    RoundedRectangle(cornerRadius: properties.cornerRadius)
                        .shadow(properties.shadow)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: properties.cornerRadius)
                        .stroke(properties._resolvedBorderColor?.swiftUI ?? .clear, lineWidth: properties.borderWidth))
                .scaleEffect(properties.scaleTransform)
            
            
        }
    }
    
    struct TextItem: View {
        let text: String?
        @State private var _text: String = ""
        let attributedText: AttributedString?
        let properties: ConfigurationProperties.Text
        
        init(text: String?, attributedText: AttributedString?, properties: ConfigurationProperties.Text) {
            self.text = text
            self.attributedText = attributedText
            self.properties = properties
            self._text = self.text ?? ""
            
        }
        @ViewBuilder
        var item: some View {
            if (properties.isEditable && properties.isSelectable) {
                EditableText($_text, alignment: properties.alignment.swiftUI, onEditEnd: properties.onEditEnd ?? {_ in })
            } else {
                if let attributedText = attributedText {
                    Text(attributedText)
                } else if let text = text {
                    Text(text)
                }
            }
        }
        
        var body: some View {
            item
                .frame(maxWidth: .infinity, alignment: properties.alignment.swiftUI)
                .multilineTextAlignment(properties.alignment.swiftUIMultiline)
                .font(properties.swiftUIFont ?? properties.font.swiftUI)
                .lineLimit(properties.maxNumberOfLines == 0 ? nil : properties.maxNumberOfLines)
                .foregroundColor(properties._resolvedTextColor.swiftUI)
                .textSelection(properties.isSelectable)
        }
    }
    
    @available(macOS 13.0, *)
    struct ContentView: View {
        let configuration: NSItemContentConfiguration
        
        @ViewBuilder
        var textItems: some View {
            VStack(alignment: .center, spacing: configuration.textToSecondaryTextPadding) {
                NSItemContentViewSwiftUI.TextItem(text: configuration.text, attributedText:  configuration.attributedText, properties: configuration.textProperties)
                
                NSItemContentViewSwiftUI.TextItem(text:  configuration.secondaryText, attributedText:  configuration.secondaryAttributedText, properties: configuration.secondaryTextProperties)
            }
            
        }
        
        @ViewBuilder
        var contentItem: some View {
            NSItemContentViewSwiftUI.ContentItem(view: configuration.view, image: configuration.image, overlayView: configuration.overlayView, contentPosition: configuration.contentPosition, properties: configuration.contentProperties)
        }
        
        @ViewBuilder
        var stackItem: some View {
            if configuration.contentPosition.isVertical {
                VStack(spacing: configuration.contentToTextPadding) {
                    if configuration.contentPosition == .top {
                        contentItem
                        textItems
                    } else {
                        textItems
                        contentItem
                    }
                }
            } else {
                HStack(alignment: .top, spacing: configuration.contentToTextPadding) {
                    if configuration.contentPosition == .leading {
                        contentItem
                        textItems
                        Spacer()
                    } else {
                        Spacer()
                        textItems
                        contentItem
                    }
                }
            }
        }
        
        
        var body: some View {
            stackItem
                .padding(configuration.margins.edgeInsets)
                .scaleEffect(configuration.scaleTransform)
        }
    }
}

internal extension Shape {
    @ViewBuilder
    func stroke(_ properties: NSItemContentConfiguration.ContentProperties) -> some View {
        self
            .stroke(properties._resolvedBorderColor?.swiftUI ?? .clear, lineWidth: properties.borderWidth)
    }
}

internal extension View {
    @ViewBuilder
    func sizing(_ sizing: NSItemContentConfiguration.ContentProperties.SizeOption?, hasImage: Bool, isVertical: Bool) -> some View {
        switch sizing {
        case .size(let size):
            self
                .frame(width: size.width, height: size.height)
        case .max(width: let maxWidth, height: let maxHeight):
            self
                .frame(maxWidth: maxWidth, maxHeight: maxHeight)
        case .min(width: let minWidth, height: let minHeight):
            self
                .frame(minWidth: minWidth, minHeight: minHeight)
        case .textAndSecondaryTextHeight:
            self
            //   .frame(maxWidth: .infinite, maxHeight: .infinite)
        case .none:
            if hasImage {
                self
                    .fixedSize(horizontal: isVertical ? true : false, vertical: isVertical ? false : true)
            } else {
                self
            }
        }
    }
}

@available(macOS 13.0, *)
struct ShapedImage: View {
    let image: NSImage
    let shape: AnyShape
    let aspectRatio: ContentMode
    
    init<S: Shape>(image: NSImage, shape: S, aspectRatio: ContentMode) {
        self.image = image
        self.shape = shape.asAnyShape()
        self.aspectRatio = aspectRatio
    }
    var body: some View {
        if aspectRatio == .fill {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity
                )
                .clipShape(shape)
        } else {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            //   .clipShape(shape)
            //     .fixedSize(horizontal: true, vertical: false)
        }
    }
}
*/
