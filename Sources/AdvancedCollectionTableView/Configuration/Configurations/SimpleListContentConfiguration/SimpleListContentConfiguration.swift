//
//  SimpleListContentConfiguration.swift
//
//
//  Created by Florian Zand on 21.02.26.
//

import AppKit
import FZUIKit

/// A content configuration for a simple list-based content view that displays a single text line and image.
public struct SimpleListContentConfiguration: Hashable, NSContentConfiguration {
    /**
     The primary text.

     This value supersedes the ``attributedText`` property.
     */
    public var text: String? {
        didSet {
            guard text != nil else { return }
            attributedText = nil
        }
    }

    /**
     An attributed variant of the primary text.

     This value supersedes the ``text`` property.
     */
    public var attributedText: AttributedString? {
        didSet {
            guard attributedText != nil else { return }
            text = nil
        }
    }
    
    /// The image.
    public var image: NSImage?
    
    /// The text color.
    public var textColor: NSColor = .controlTextColor

    /// The color transformer for resolving the text color.
    public var textColorTransformer: ColorTransformer?

    /// Generates the resolved text color.
    public func resolvedTextColor() -> NSColor {
        textColorTransformer?(textColor) ?? textColor
    }
    
    /// The tint color for an image that is a template or symbol image.
    public var imageTintColor: ImageTintColor?
    
    /// The tint color for an image that is a template or symbol image.
    public enum ImageTintColor: Hashable {
        /// Monochrome.
        case monochrome(NSColor)
        /// Hierarchical
        case hierarchical(NSColor)
        /// Palette.
        case palette([NSColor])
        // case multicolor(primary: NSColor)

        var configuration: NSImage.SymbolConfiguration? {
            switch self {
            case .hierarchical(let color): return .init(hierarchicalColor: color)
            case .palette(let colors): return .init(paletteColors: colors)
            default: return nil
            }
        }
        
        var color: NSColor? {
            switch self {
            case .monochrome(let color): return color
            default: return nil
            }
        }
    }
    
    /// Creates a
    public init() { }
    
    public func makeContentView() -> any NSView & NSContentView {
        SimpleListContentView(configuration: self)
    }
}
