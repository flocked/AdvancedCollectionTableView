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
        didSet { updateConfiguration() }
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
    struct ContentView: View {
        let configuration: NSItemContentConfiguration
        
        @ViewBuilder
        var textItem: some View {
            if let attributedText = configuration.attributedText {
                Text(attributedText)
            } else if let text = configuration.text {
                Text(text)
            }
        }
        
        @ViewBuilder
        var secondaryTextItem: some View {
            if let attributedText = configuration.secondaryattributedText {
                Text(attributedText)
            } else if let text = configuration.secondaryText {
                Text(text)
            }
        }
        
        @ViewBuilder
        var textItems: some View {
            VStack(spacing: configuration.textToSecondaryTextPadding) {
                textItem
                    .font(configuration.textProperties.font.swiftUI)
                    .lineLimit(configuration.textProperties.numberOfLines)
                    .foregroundColor(configuration.textProperties.textColor.swiftUI)
                    .textSelection((configuration.textProperties.isSelectable == true) ? .enabled : .enabled)

                secondaryTextItem
                    .font(configuration.secondaryTextProperties.font.swiftUI)
                    .lineLimit(configuration.secondaryTextProperties.numberOfLines)
                    .foregroundColor(configuration.secondaryTextProperties.textColor.swiftUI)
                    .textSelection(configuration.secondaryTextProperties.isSelectable == true ? .enabled : .enabled)
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
                            .aspectRatio(contentMode: .fit)
                    }
                }
           //     .backgroundOptional(configuration.contentProperties.backgroundColor?.swiftUI)
             //   .clipShape(configuration.contentProperties.shape.swiftui)
                .clipShape(configuration.contentProperties.shape.swiftui)
                .shadowOptional(color: configuration.contentProperties.shadowProperties.color?.swiftUI, radius: configuration.contentProperties.shadowProperties.radius, offset: configuration.contentProperties.shadowProperties.offset)
            
        }

        
        var body: some View {
            VStack(spacing: configuration.imageToTextPadding) {
                contentItem
                textItems
            }.padding(configuration.padding.edgeInsets)
        }
    }
}

internal extension View {
    @ViewBuilder
    func backgroundOptional<S: ShapeStyle>(_ style: S?) -> some View {
        if let style = style {
            background(style)
        } else {
            self
        }
    }
    
    
    @ViewBuilder
    func shadowOptional(color: Color?, radius: CGFloat, offset: CGPoint) -> some View {
        if let color = color {
            shadow(color: color, radius: radius, x: offset.x, y: offset.y)
        } else {
            self
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

