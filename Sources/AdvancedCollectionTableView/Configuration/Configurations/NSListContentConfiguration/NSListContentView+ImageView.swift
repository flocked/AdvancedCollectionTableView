//
//  NSListContentView+ImageView.swift
//
//
//  Created by Florian Zand on 28.07.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

internal extension NSListContentView {
    class TestView: NSView {
        @objc dynamic func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
            Swift.print("TestView setBackgroundStyle", backgroundStyle.rawValue)
        }
    }
    
    class SomeOther1View: NSView {
        @objc dynamic func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
            Swift.print("SomeOther1 setBackgroundStyle", backgroundStyle.rawValue)
        }
    }
    
    class SomeOther2View: NSView {
        @objc dynamic func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
            Swift.print("SomeOther2 setBackgroundStyle", backgroundStyle.rawValue)
        }
    }
    
    class CellImageView: NSImageView {
        var properties: NSListContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                    update()
            }
        }
        
        /*
        override func setBackgroundStyle(_ backgroundStyle: NSView.BackgroundStyle) {
            Swift.print("setBackgroundStyle", self.cell?.backgroundStyle.rawValue ?? "nil")
        }
        */
                
        override var image: NSImage? {
            didSet {
                self.isHidden = (self.image == nil)
            }
        }
        
        override var intrinsicContentSize: NSSize {
            var intrinsicContentSize = super.intrinsicContentSize
            
            if image?.isSymbolImage == true, properties.position.orientation == .horizontal {
                intrinsicContentSize.width = (intrinsicContentSize.height*2.5).rounded(.towardZero)
                return intrinsicContentSize
            }
            
            if let calculatedSize = calculatedSize {
                return calculatedSize
            }
            
            return intrinsicContentSize
        }
                
        var calculatedSize: CGSize?
        var verticalConstraint: NSLayoutConstraint? = nil
        
        func update() {
            self.imageScaling = image?.isSymbolImage == true  ? .scaleNone : properties.scaling.imageScaling
            self.symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.backgroundColor = properties._resolvedBackgroundColor
            self.contentTintColor = properties._resolvedTintColor
            self.cornerRadius = properties.cornerRadius
            self.configurate(using: properties.shadow, type: .outer)
            self.invalidateIntrinsicContentSize()
        }
        
        let testView = ImageView()
        let teetView1 = TestView()
        let someOtherView1 = SomeOther1View()
        let someOtherView2 = SomeOther2View()

        init(properties: NSListContentConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.wantsLayer = true
            self.addSubview(someOtherView1)
            someOtherView1.addSubview(someOtherView2)
        //    self.addSubview(testView)
          //  testView.addSubview(teetView1)
          //  self.imageAlignment = .alignCenter
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
