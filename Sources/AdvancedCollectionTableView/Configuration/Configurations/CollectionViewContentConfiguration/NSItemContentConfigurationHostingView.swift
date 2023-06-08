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

internal class NSItemContentConfigurationHostingView: NSView, NSContentView {
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSItemContentConfiguration {
                _configuration = newValue
            }
        }
    }
    
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSItemContentConfiguration
    }
    
    public init(configuration: NSItemContentConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
        addSubview(withConstraint: hostingController.view)
        self.updateConfiguration()
    }
    
    internal var _configuration: NSItemContentConfiguration {
        didSet {
            if oldValue != _configuration {
                updateConfiguration()
            }
        }
    }
    
    internal func updateConfiguration() {
        hostingController.rootView = ContentView(configuration: self._configuration)
    }
    
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

internal extension NSItemContentConfigurationHostingView {
    struct ContentItem: View {
        let view: NSView?
        let image: NSImage?
        let properties: NSItemContentConfiguration.ContentProperties
        
        var body: some View {
            ZStack() {
                if let backgroundColor = properties._resolvedBackgroundColor {
                    properties.shape.swiftui
                        .foregroundColor(backgroundColor.swiftUI)
                }
                
                if let view = view {
                    ContainerView(view: view)
                }
                
                if let image = image {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: properties.imageScaling.swiftui)
                        .foregroundColor(properties._resolvedImageTintColor?.swiftUI)
                        .symbolConfiguration(properties.imageSymbolConfiguration)
                }
            }
          //  .frame(maxWidth: properties.maxWidth, maxHeight:  properties.maxHeight)
            .sizing(properties.sizing)
            .clipShape(properties.shape.swiftui)
            .background(
                properties.shape.swiftui
                    .shadow(color: properties.shadowProperties._resolvedColor?.swiftUI, radius: properties.shadowProperties.radius, offset: properties.shadowProperties.offset)
            )
            .overlay(
                properties.shape.swiftui
                    .stroke(properties._resolvedBorderColor?.swiftUI, lineWidth: properties.borderWidth))
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
                .multilineTextAlignment(properties.alignment.swiftuiMultiline)
                .frame(alignment: properties.alignment.swiftui)
                .font(properties.swiftuiFont ?? properties.font.swiftUI)
                .lineLimit(properties.numberOfLines)
                .foregroundColor(properties._resolvedTextColor.swiftUI)
                .textSelection((properties.isSelectable == true) ? .enabled : .enabled)
        }
    }
    
    struct ContentView: View {
        let configuration: NSItemContentConfiguration
            
        @ViewBuilder
        var textItems: some View {
            VStack(spacing: configuration.textToSecondaryTextPadding) {
                NSItemContentConfigurationHostingView.TextItem(text:  configuration.text, attributedText:  configuration.attributedText, properties: configuration.textProperties)
                
                NSItemContentConfigurationHostingView.TextItem(text:  configuration.secondaryText, attributedText:  configuration.secondaryAttributedText, properties: configuration.secondaryTextProperties)
            }
        }
        
        @ViewBuilder
        var contentItem: some View {
            NSItemContentConfigurationHostingView.ContentItem(view: configuration.view, image: configuration.image, properties: configuration.contentProperties)
        }
        
        @ViewBuilder
        var stackItem: some View {
            if configuration.contentPosition == .top || configuration.contentPosition == .bottom {
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
                HStack(spacing: configuration.contentToTextPadding) {
                    if configuration.contentPosition == .leading {
                        contentItem
                        textItems
                    } else {
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

internal struct ContainerView<V: NSView>: NSViewRepresentable {
    let view: V
  func makeNSView(context: Context) -> V {
    return view
  }
  
  func updateNSView(_ nsView: V, context: Context) {
    // Nothing to do.
  }
}

internal extension View {
    @ViewBuilder
    func sizing(_ sizing: NSItemContentConfiguration.ContentProperties.SizeOption?) -> some View {
        switch sizing {
        case .size(let size):
            self
                .frame(width: size.width, height: size.height)
        case .max(width: let maxWidth, height: let maxHeight):
            self
                .frame(maxWidth: maxWidth, maxHeight: maxHeight)
        case .textAndSecondaryTextHeight:
            self
             //   .frame(maxWidth: .infinite, maxHeight: .infinite)
        case .none:
            self
        }
    }
}

struct CollectionItemView_Previews: PreviewProvider {
    static var configuration: NSItemContentConfiguration {
        let view = NSView()
        view.backgroundColor = .lightGray
        view.maskToBounds = true
        let shadowProperties = NSItemContentConfiguration.ShadowProperties(radius: 6.0, opacity: 0.7, offset: CGPoint(1, 1), color: .controlAccentColor)
        let contentProperties = NSItemContentConfiguration.ContentProperties(shape: .roundedRectangular(10.0), shadowProperties: shadowProperties, backgroundColor: .lightGray, borderWidth: 1.0, borderColor: .controlAccentColor)

       return NSItemContentConfiguration(text: "A fun title", secondaryText: "A fun title that fits", view: nil, contentProperties: contentProperties)
    }
    
    static var configuration1: NSItemContentConfiguration {
        let view = NSView()
        view.backgroundColor = .lightGray
        view.maskToBounds = true
        let shadowProperties = NSItemContentConfiguration.ShadowProperties(radius: 6.0, opacity: 0.7, offset: CGPoint(1, 1), color: .controlAccentColor)
        
        let contentProperties = NSItemContentConfiguration.ContentProperties(shape: .roundedRectangular(10.0), shadowProperties: shadowProperties, maxWidth: 40, backgroundColor: .lightGray, borderWidth: 1.0, borderColor: .controlAccentColor)

        return NSItemContentConfiguration(text: "A fun title", secondaryText: "A fun title that fits", view: nil, contentProperties: contentProperties, contentPosition: .leading)
    }
    
    static var previews: some View {
        VStack(spacing: 10.0) {
            NSItemContentConfigurationHostingView.ContentView(configuration: configuration)
                .frame(width: 200, height: 140)
                .padding()
            NSItemContentConfigurationHostingView.ContentView(configuration: configuration1)
                .frame(width: 200, height: 140)
                .padding()
        }
    }
}

