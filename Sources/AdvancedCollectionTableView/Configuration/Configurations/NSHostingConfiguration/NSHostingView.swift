//
//  NSHostingView.swift
//  
//
//  Created by Florian Zand on 01.06.23.
//

import AppKit
import SwiftUI
import FZSwiftUtils
import FZUIKit

internal class NSHostingContentView<Content, Background>: NSView, NSContentView where Content: View, Background: View {
    
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSHostingConfiguration<Content, Background> {
                _configuration = newValue
            }
        }
    }
    
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSHostingConfiguration<Content, Background>
    }
    
    public init(configuration: NSHostingConfiguration<Content, Background>) {
        self._configuration = configuration
        super.init(frame: .zero)
        hostingViewConstraints = addSubview(withConstraint: hostingController.view)
        self.updateConfiguration()
    }
    
    internal var _configuration: NSHostingConfiguration<Content, Background> {
        didSet { updateConfiguration() }
    }
    
    internal func updateConfiguration() {
        hostingController.rootView = HostingView(configuration: _configuration)
        directionalLayoutMargins = _configuration.margins
    }
    
    internal lazy var hostingController: NSHostingController<HostingView<Content, Background>> = {
        let hostingView = HostingView(configuration: _configuration)
        let hostingController = NSHostingController<HostingView<Content, Background>>(rootView: hostingView)
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
    
    internal var hostingViewConstraints: [NSLayoutConstraint] = []

    internal var directionalLayoutMargins: NSDirectionalEdgeInsets {
        get { return NSDirectionalEdgeInsets(top: -hostingViewConstraints[0].constant, leading: -hostingViewConstraints[1].constant , bottom: hostingViewConstraints[2].constant , trailing: hostingViewConstraints[3].constant)
        }
        set {
            hostingViewConstraints[0].constant = -newValue.bottom
            hostingViewConstraints[1].constant = newValue.top
            hostingViewConstraints[2].constant = newValue.leading
            hostingViewConstraints[3].constant = -newValue.trailing
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        if let configuration = configuration as? NSHostingConfiguration<Content, Background> {
            if let width = configuration.minWidth {
                intrinsicContentSize.width = max(intrinsicContentSize.width, width)
            }
            if let height = configuration.minHeight {
                intrinsicContentSize.height = max(intrinsicContentSize.height, height)
            }
        }
        return intrinsicContentSize
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

extension NSHostingContentView {
    internal struct HostingView<V: View, B: View>: View {
        let configuration: NSHostingConfiguration<V, B>
        
        init(configuration: NSHostingConfiguration<V, B>) {
            self.configuration = configuration
        }
        
        public var body: some View {
            ZStack {
                self.configuration.background
                self.configuration.content
            }
        }
    }
}


public struct _NSHostingConfigurationBackgroundView<S>: View where S: ShapeStyle {
    let style: S
    
    public var body: some View {
        Rectangle().fill(style)
    }
}

