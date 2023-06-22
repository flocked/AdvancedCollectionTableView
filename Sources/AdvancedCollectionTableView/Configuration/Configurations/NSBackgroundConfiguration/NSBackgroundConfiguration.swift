//
//  File.swift
//  
//
//  Created by Florian Zand on 08.04.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public struct NSBackgroundConfiguration: NSContentConfiguration, Hashable {
    public func makeContentView() -> NSView & NSContentView {
        NSBackgroundContentView(configuration: self)
    }
    
    public func updated(for state: NSConfigurationState) -> NSBackgroundConfiguration {
        return self
    }
    
    public var customView: NSView? = nil
    public var cornerRadius: CGFloat = 0.0
    public var insets: NSDirectionalEdgeInsets = .zero
    public var color: NSColor? = nil {
        didSet {
            if self.color != oldValue {
                self.updateResolvedColors()
            }
        }
    }
    public var colorTransformer: NSConfigurationColorTransformer? = nil {
        didSet {
            if self.colorTransformer != oldValue {
                self.updateResolvedColors()
            }
        }
    }
    
    public func resolvedColor() -> NSColor? {
        if let color = self.color {
            return colorTransformer?(color) ?? color
        }
        return nil
    }
    public var visualEffect: ContentConfiguration.VisualEffect? = nil
    
    public var border: ContentConfiguration.Border = .none() {
        didSet {
            if self.border != oldValue {
                self.updateResolvedColors()
            }
        }
    }
    
    public var image: NSImage? = nil
    public var imageScaling: CALayerContentsGravity = .center
    
    public init(customView: NSView? = nil,
                cornerRadius: CGFloat = 0.0,
                insets: NSDirectionalEdgeInsets = .init(),
                color: NSColor? = nil,
                colorTransformer: NSConfigurationColorTransformer? = nil, visualEffect: ContentConfiguration.VisualEffect? = nil,
                border: ContentConfiguration.Border = .init(),
                image: NSImage? = nil,
                imageScaling: CALayerContentsGravity = .center) {
        self.customView = customView
        self.cornerRadius = cornerRadius
        self.insets = insets
        self.color = color
        self.colorTransformer = colorTransformer
        self.visualEffect = visualEffect
        self.border = border
        self.image = image
        self.imageScaling = imageScaling
    }
    
    internal var _resolvedColor: NSColor? = nil
    internal var _resolvedBorderColor: NSColor? = nil
    
    internal mutating func updateResolvedColors() {
        self._resolvedColor = self.resolvedColor()
        self._resolvedBorderColor = self.border.resolvedColor()
    }
}
