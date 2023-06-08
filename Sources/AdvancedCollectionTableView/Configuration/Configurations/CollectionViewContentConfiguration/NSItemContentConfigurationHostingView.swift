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
            if (properties.isEditable) {
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
                .font(properties.swiftuiFont ?? properties.font.swiftUI)
                .lineLimit(properties.numberOfLines)
                .foregroundColor(properties.textColor.swiftUI)
                .textSelection((properties.isSelectable == true) ? .enabled : .enabled)
        }
    }
    
    struct ContentView: View {
        let configuration: NSItemContentConfiguration
    
        @ViewBuilder
        var textItems: some View {
            VStack(spacing: configuration.textToSecondaryTextPadding) {
                TextItem(text:  configuration.text, attributedText:  configuration.attributedText, properties: configuration.textProperties)
                
                TextItem(text:  configuration.secondaryText, attributedText:  configuration.secondaryAttributedText, properties: configuration.secondaryTextProperties)
            }
        }
        
        @ViewBuilder
        var contentItem: some View {
                ZStack() {
                    if let backgroundColor = configuration.contentProperties.backgroundColor {
                        configuration.contentProperties.shape.swiftui
                            .foregroundColor(backgroundColor.swiftUI)
                    }
                    
                    if let view = configuration.view {
                        ContainerView(view: view)
                    }
                    
                    if let image = configuration.image {
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: configuration.contentProperties.imageScaling.swiftui)
                            .foregroundColor(configuration.contentProperties.imageTintColor?.swiftUI)
                            .symbolConfiguration(configuration.contentProperties.imageSymbolConfiguration)
                    }
                }
           //     .backgroundOptional(configuration.contentProperties.backgroundColor?.swiftUI)
             //   .clipShape(configuration.contentProperties.shape.swiftui)
                .frame(maxWidth: configuration.contentProperties.maxSize?.width, maxHeight:  configuration.contentProperties.maxSize?.height)
                .clipShape(configuration.contentProperties.shape.swiftui)
                .shadow(color: configuration.contentProperties.shadowProperties.color?.swiftUI, radius: configuration.contentProperties.shadowProperties.radius, offset: configuration.contentProperties.shadowProperties.offset)
            
        }

        
        var body: some View {
            if configuration.orientation == .vertical {
                VStack(spacing: configuration.contentToTextPadding) {
                    contentItem
                    textItems
                }.padding(configuration.padding.edgeInsets)
            } else {
                HStack(spacing: configuration.contentToTextPadding) {
                    contentItem
                    textItems
                }.padding(configuration.padding.edgeInsets)
            }
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

struct CollectionItemView_Previews: PreviewProvider {
    static var configuration: NSItemContentConfiguration {
        let view = NSView()
        view.backgroundColor = .lightGray
        view.maskToBounds = true
        let contentProperties = NSItemContentConfiguration.ContentProperties(shape: .roundedRectangular(10.0), backgroundColor: .lightGray, borderWidth: 1.0, borderColor: .controlAccentColor)

       return NSItemContentConfiguration(text: "A fun title", secondaryText: "A fun title that fits", view: nil, contentProperties: contentProperties)
    }
    static var previews: some View {
        VStack(spacing: 10.0) {
            NSItemContentConfigurationHostingView.ContentView(configuration: configuration)
                .frame(width: 140, height: 160)
                .padding()

        }
    }
}

