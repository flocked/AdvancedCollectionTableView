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
    
 internal let hostingController: NSHostingController<HostingView<Content, Background>?> = {
   let controller = NSHostingController<HostingView<Content, Background>?>(rootView: nil)
   controller.view.backgroundColor = .clear
   controller.view.translatesAutoresizingMaskIntoConstraints = false
   return controller
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
    
    override func mouseDown(with event: NSEvent) {
        Swift.print("Mouse Down", self.nextResponder, self.superview)
        self.superview?.mouseDown(with: event)
        self.nextResponder?.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        Swift.print("Mouse up")
        self.superview?.mouseUp(with: event)
        self.nextResponder?.mouseUp(with: event)
    }
       
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
   
   internal func applyConfiguration(_ configuration: NSContentConfiguration) {
       if let configuration = configuration as? NSHostingConfiguration<Content, Background> {
         hostingController.rootView = HostingView(configuration: configuration)
           directionalLayoutMargins = configuration.margins
       }
   }

    public var configuration: NSContentConfiguration {
   didSet {
       self.applyConfiguration(configuration)
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
   
  internal var hostingViewConstraints: [NSLayoutConstraint] = []

    
    public init(configuration: NSContentConfiguration) {
     self.configuration = configuration
     super.init(frame: .zero)
     hostingViewConstraints = addSubview(withConstraint: hostingController.view)
     self.applyConfiguration(configuration)
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
