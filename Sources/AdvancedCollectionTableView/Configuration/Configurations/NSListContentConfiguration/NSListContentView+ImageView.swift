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

extension Image {
    func resizable(_ resizable: Bool) -> Image {
        if resizable {
            self.resizable()
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder
    func aspectRatio(_ contentMode: ContentMode?) -> some View {
        if let contentMode = contentMode {
            self.aspectRatio(contentMode: contentMode)
        } else {
            self
        }
    }
}

internal extension NSListContentView {
    class CellImageView: NSView {
        var image: NSImage? = nil {
            didSet {
                guard oldValue != image else { return }
                update()
            }
        }
                
        var properties: NSListContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                    update()
            }
        }
        
        lazy var hostingController = NSHostingController(rootView: ContentView(image: image, properties: properties))
        
        func update() {
            hostingController.rootView = ContentView(image: image, properties: properties)
            updateView()
        }
                
        func updateView() {
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.backgroundColor = properties._resolvedBackgroundColor
            self.cornerRadius = properties.cornerRadius
            self.configurate(using: properties.shadow, type: .outer)
            self.invalidateIntrinsicContentSize()
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
        
        init(properties: NSListContentConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.addSubview(hostingController.view)
            self.updateView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        struct ContentView: View {
            let image: NSImage?
            let properties: NSListContentConfiguration.ImageProperties
            
            @ViewBuilder
            var imageItem: some View {
                if let image = image {
                    Image(image)
                        .resizable(properties.scaling.resizable)
                        .aspectRatio(properties.scaling.contentMode)
                        .foregroundStyle(properties._resolvedTintColor?.swiftUI, nil, nil)
                        .symbolConfiguration(properties.symbolConfiguration)
                }
            }
            var body: some View {
                imageItem
            }
        }
    }
    
    /*
    class CellImageView: NSImageView {
        var properties: NSListContentConfiguration.ImageProperties {
            didSet {
                guard oldValue != properties else { return }
                    update()
            }
        }
                
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
        
        init(properties: NSListContentConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.wantsLayer = true
          //  self.imageAlignment = .alignCenter
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
     */
}
