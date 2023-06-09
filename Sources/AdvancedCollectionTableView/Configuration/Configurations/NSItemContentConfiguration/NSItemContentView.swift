//
//  File.swift
//  
//
//  Created by Florian Zand on 02.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

internal class NSItemContentView: NSView, NSContentView {
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSItemContentConfiguration {
                _configuration = newValue
            }
        }
    }
    
    internal var forwardMouseDown = false
    override func mouseDown(with event: NSEvent) {
        if  forwardMouseDown {
            if let item = (self.nextResponder as? NSCollectionViewItem) {
                item.select()
            }
            
            self.nextResponder?.mouseDown(with: event)
            self.parentViewController?.mouseDown(with: event)
            self.firstSuperview(for: NSCollectionView.self)?.mouseDown(with: event)
            forwardMouseDown = false
            super.mouseDown(with: event)

        }
        /*
       let location = event.location(in: self.hostingController.view)
        
       let views = self.hostingController.view.subviews(where: {$0.frame.contains(location)}, depth: 10000)
        
        Swift.print(views)
         */
        
    }
    
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSItemContentConfiguration
    }
    
    public init(configuration: NSItemContentConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
        addSubview(withConstraint: hostingView)
     //   addSubview(withConstraint: hostingController.view)
        self.updateConfiguration()
        self.maskToBounds = false
        
        self.hostingController.view.maskToBounds = false
    }
    
    internal var _configuration: NSItemContentConfiguration {
        didSet {
            if oldValue != _configuration {
                updateConfiguration()
            }
        }
    }
    
    internal func updateConfiguration() {
        hostingView.rootView =  ContentView(configuration: self._configuration)
        /*
        hostingController.rootView = ContentView(configuration: self._configuration, mouseHandler: { [weak self] in
            guard let self = self else { return }
            if let event = NSEvent.current, event.type == .leftMouseDown {
                forwardMouseDown = true
                self.mouseDown(with: event)
            }
        })
         */
    }
    
    internal lazy var hostingView: CollectionItemHostingView<ContentView> = {
        let contentView = ContentView(configuration: self._configuration)
        let hostingView = CollectionItemHostingView(rootView: contentView)
        hostingView.backgroundColor = .clear
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.maskToBounds = false
        return hostingView
    }()
    
    internal lazy var hostingController: NSHostingController<ContentView> = {
        let hostingView = ContentView(configuration: self._configuration)
        let hostingController = NSHostingController<ContentView>(rootView: hostingView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        return hostingController
    }()
        
    override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
    }
    
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
                parentViewController?.addChild(hostingController)
            }
        }
    }
}

internal extension NSItemContentView {
    struct ContentItem: View {
        let view: NSView?
        let image: NSImage?
        let contentPosition: NSItemContentConfiguration.ContentPosition
        let properties: NSItemContentConfiguration.ContentProperties
                
        @ViewBuilder
        var contentStack: some View {
            ZStack() {
                if let backgroundColor = properties._resolvedBackgroundColor {
                    properties.shape.swiftui
                        .foregroundColor(backgroundColor.swiftUI)
                }
                
                if let view = view {
                    ContainerView(view: view)
                }
                
                if let image = image {
                    ShapedImage(image: image, shape: properties.shape.swiftui, aspectRatio: properties.imageScaling.swiftui)
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
                .clipShape(properties.shape.swiftui)
            .background(
                properties.shape.swiftui
                    .shadow(properties.shadowProperties)
            )
            .overlay(
                properties.shape.swiftui
                    .stroke(properties._resolvedBorderColor?.swiftUI ?? .clear, lineWidth: properties.borderWidth))
            .scaleEffect(properties.scaleTransform)

   
        }
    }
    
    struct TextItem: View {
        let text: String?
        @State private var _text: String = ""
        let attributedText: AttributedString?
        let properties: NSItemContentConfiguration.TextProperties
        
        init(text: String?, attributedText: AttributedString?, properties: NSItemContentConfiguration.TextProperties) {
            self.text = text
            self.attributedText = attributedText
            self.properties = properties
            self._text = self.text ?? ""

        }
        @ViewBuilder
        var item: some View {
            if (properties.isEditable && properties.isSelectable) {
                EditableText($_text, onEditEnd: properties.onEditEnd ?? {_ in })
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
                .frame(maxWidth: .infinity, alignment: properties.alignment.swiftui)
                .multilineTextAlignment(properties.alignment.swiftuiMultiline)
                .font(properties.swiftuiFont ?? properties.font.swiftUI)
                .lineLimit(properties.numberOfLines)
                .foregroundColor(properties._resolvedTextColor.swiftUI)
                .textSelection(properties.isSelectable)
        }
    }
    
    struct ContentView: View {
        let configuration: NSItemContentConfiguration

        @ViewBuilder
        var textItems: some View {
            VStack(alignment: .center, spacing: configuration.textToSecondaryTextPadding) {
                NSItemContentView.TextItem(text: configuration.text, attributedText:  configuration.attributedText, properties: configuration.textProperties)
                
                NSItemContentView.TextItem(text:  configuration.secondaryText, attributedText:  configuration.secondaryAttributedText, properties: configuration.secondaryTextProperties)
            }

        }
        
        @ViewBuilder
        var contentItem: some View {
            NSItemContentView.ContentItem(view: configuration.view, image: configuration.image, contentPosition: configuration.contentPosition, properties: configuration.contentProperties)
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
                .padding(configuration.padding.edgeInsets)
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
    func shadow(_ properties: NSItemContentConfiguration.ShadowProperties) -> some View {
        self
            .shadow(color: properties._resolvedColor?.swiftUI, radius: properties.radius, offset: properties.offset)
    }
    
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

struct CollectionItemView_Previews: PreviewProvider {
    static func contentProperties(isSelected: Bool) -> NSItemContentConfiguration.ContentProperties {
        let shadowProperties = NSItemContentConfiguration.ShadowProperties(radius: 6.0, opacity: 0.7, offset: CGPoint(1, 1), color: isSelected ? .controlAccentColor : nil)
        return NSItemContentConfiguration.ContentProperties(shape: .roundedRect(10.0), shadowProperties: shadowProperties, backgroundColor: .lightGray, borderWidth: 1.0, borderColor: isSelected ? .controlAccentColor : nil, imageScaling: .fit)
    }
    
    static var configuration: NSItemContentConfiguration {
        let contentProperties = self.contentProperties(isSelected: true)
        let textProperties: NSItemContentConfiguration.TextProperties = .body
       return NSItemContentConfiguration(text: "Image Item", secondaryText: "A item that displays an image", image: NSImage(contentsOf: URL(fileURLWithPath: "/Users/florianzand/Movies/ Porn/1591785825108627457_1.jpg")), view: nil, textProperties: textProperties, contentProperties: contentProperties)
    }
    
    static var configurationFill: NSItemContentConfiguration {
        var contentProperties = self.contentProperties(isSelected: true)
        contentProperties.imageScaling = .fill
       return NSItemContentConfiguration(text: "Image Item", secondaryText: "A item that displays an image", image: NSImage(contentsOf: URL(fileURLWithPath: "/Users/florianzand/Movies/ Porn/Images/Likes/Likes 06.2020-04.2021/tumblr_bobbycamp_628203143674691584_01.jpg")), view: nil, contentProperties: contentProperties)
    }
    
    
    static var configurationView: NSItemContentConfiguration {
        let view = NSView()
        view.backgroundColor = .lightGray
        view.maskToBounds = true
        let contentProperties = self.contentProperties(isSelected: false)

       return NSItemContentConfiguration(text: "View item", secondaryText: "A item that displays a view", view: view, contentProperties: contentProperties)
    }
    
    static var configurationText: NSItemContentConfiguration {
        var contentProperties = self.contentProperties(isSelected: false)
        contentProperties.backgroundColor = nil
       return NSItemContentConfiguration(text: "View item", secondaryText: "A item that displays a view", contentProperties: contentProperties)
    }
    
    static var configurationVertical: NSItemContentConfiguration {
        var contentProperties = self.contentProperties(isSelected: false)
        contentProperties.sizing = .min(width: 80, height: nil)
        contentProperties.imageScaling = .fill
        var textProperties: NSItemContentConfiguration.TextProperties = .body
        textProperties.alignment = .leading
        textProperties.alignment = .leading
        var secondaryTextProperties: NSItemContentConfiguration.TextProperties = .caption1
        secondaryTextProperties.alignment = .leading
        textProperties.alignment = .leading
        return NSItemContentConfiguration(text: "Vertical Image Item", secondaryText: "A item that displays an image vertically", image: NSImage(contentsOf: URL(fileURLWithPath: "/Users/florianzand/Movies/ Porn/1492943419580239874_1.jpg")), view: nil, textProperties: textProperties, secondaryTextProperties: secondaryTextProperties, contentProperties: contentProperties, contentPosition: .leading)
    }
    
    static var previews: some View {
        VStack(spacing: 10.0) {
            NSItemContentView.ContentView(configuration: configuration)
                .frame(width: 200, height: 140)
                .padding()
            NSItemContentView.ContentView(configuration: configurationVertical)
                .frame(width: 200, height: 140)
                .padding()
            NSItemContentView.ContentView(configuration: configurationView)
                .frame(width: 200, height: 160)
                .padding()
            NSItemContentView.ContentView(configuration: configurationFill)
                .frame(width: 200, height: 160)
                .padding()
            NSItemContentView.ContentView(configuration: configurationText)
                .frame(width: 200, height: 120)
                .padding()
        }
    }
}

struct ShapedImage: View {
    let image: NSImage
    let shape: FZUIKit.AnyShape
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

internal class CollectionItemHostingView<Content: View>: NSHostingView<Content> {
    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let hitTest = super.hitTest(point) else {
            Swift.print("hitTest nil")
            return self.firstSuperview(for: NSCollectionView.self) }
        Swift.print("hitTest")
        return hitTest
    }
}
