//
//  TextProperties.swift
//
//
//  Created by Florian Zand on 01.01.24.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

/// Properties that affect the text.
public struct TextProperties {
    /// The font of the text.
    public var font: NSUIFont = .body
    var swiftUIFont: Font? = .body

    /// The line limit of the text, or `0` if no line limit applies.
    public var numberOfLines: Int = 0

    /// The alignment of the text.
    public var alignment: NSTextAlignment = .left

    /// The technique for wrapping and truncating the text.
    public var lineBreakMode: NSLineBreakMode = .byWordWrapping

    /// The number formatter of the text.
    public var numberFormatter: NumberFormatter?

    /// A Boolean value that determines whether the label reduces the text’s font size to fit the title string into the label’s bounding rectangle.
    public var adjustsFontSizeToFitWidth: Bool = false

    /// The minimum scale factor for the label’s text.
    public var minimumScaleFactor: CGFloat = 0.0

    /// A Boolean value that determines whether the label tightens text before truncating.
    public var allowsDefaultTighteningForTruncation: Bool = false

    /**
     A Boolean value that determines whether the user can select the content of the text field.

     If true, the text field becomes selectable but not editable. Use `isEditable` to make the text field selectable and editable. If false, the text is neither editable nor selectable.
     */
    public var isSelectable: Bool = false
    /**
     A Boolean value that controls whether the user can edit the value in the text field.

     If true, the user can select and edit text. If false, the user can’t edit text, and the ability to select the text field’s content is dependent on the value of `isSelectable`.
     */
    public var isEditable: Bool = false
    /**
     The handler that gets called when editing of the text ended.

     It only gets called, if `isEditable` is true.
     */
    public var onEditEnd: ((String) -> Void)?

    /**
     The handler that determines whether the edited string is valid.

     It only gets called, if `isEditable` is true.
     */
    public var stringValidation: ((String) -> (Bool))?
    
    /// The tooltip of the text. If set to "", the text is automatically used.
    public var toolTip: String? = nil

    public var color: NSUIColor = .labelColor {
        didSet { updateResolvedTextColor() }
    }

    /// The color transformer of the text color.
    public var colorTansform: ColorTransformer? {
        didSet { updateResolvedTextColor() }
    }

    /// Generates the resolved text color, using the text color and color transformer.
    public func resolvedColor() -> NSUIColor {
        colorTansform?(color) ?? color
    }

    var _resolvedTextColor: NSUIColor = .labelColor

    mutating func updateResolvedTextColor() {
        _resolvedTextColor = resolvedColor()
    }

    /// Initalizes a text configuration.
    init() {}

    /**
     A text configuration with a system font for the specified point size, weight and design.

     - Parameters:
        - size: The size of the font.
        - weight: The weight of the font.
        - design: The design of the font.
     */
    public static func system(size: CGFloat, weight: NSUIFont.Weight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> Self {
        var properties = Self()
        properties.font = .systemFont(ofSize: size, weight: weight, design: design)
        properties.swiftUIFont = .system(size: size, design: design.swiftUI).weight(weight.swiftUI)
        return properties
    }

    /**
     A text configuration with a system font for the specified text style, weight and design.

     - Parameters:
        - style: The style of the font.
        - weight: The weight of the font.
        - design: The design of the font.
     */
    public static func system(_ style: NSUIFont.TextStyle = .body, weight: NSUIFont.Weight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> Self {
        var properties = Self()
        properties.font = .systemFont(style, design: design).weight(weight)
        properties.swiftUIFont = .system(style.swiftUI, design: design.swiftUI).weight(weight.swiftUI)
        return properties
    }

    /// A text configuration for a primary text.
    public static var primary: Self {
        var text = Self()
        text.numberOfLines = 1
        return text
    }

    /// A text configuration for a secondary text.
    public static var secondary: Self {
        var text = Self()
        text.font = .callout
        text.color = .secondaryLabelColor
        text.swiftUIFont = .callout
        return text
    }

    /// A text configuration for a tertiary text.
    public static var tertiary: Self {
        var text = Self()
        text.font = .callout
        text.color = .secondaryLabelColor
        text.swiftUIFont = .callout
        return text
    }

    /// A text configuration with a font for bodies.
    public static var body: Self {
        var text = Self.system(.body)
        text.swiftUIFont = .body
        return text
    }

    /// A text configuration with a font for callouts.
    public static var callout: Self {
        var text = Self.system(.callout)
        text.swiftUIFont = .callout
        return text
    }

    /// A text configuration with a font for captions.
    public static var caption1: Self {
        var text = Self.system(.caption1)
        text.swiftUIFont = .caption
        return text
    }

    /// A text configuration with a font for alternate captions.
    public static var caption2: Self {
        var text = Self.system(.caption2)
        text.swiftUIFont = .caption2
        return text
    }

    /// A text configuration with a font for footnotes.
    public static var footnote: Self {
        var text = Self.system(.footnote)
        text.swiftUIFont = .footnote
        return text
    }

    /// A text configuration with a font for headlines.
    public static var headline: Self {
        var text = Self.system(.headline)
        text.swiftUIFont = .headline
        return text
    }

    /// A text configuration with a font for subheadlines.
    public static var subheadline: Self {
        var text = Self.system(.subheadline)
        text.swiftUIFont = .subheadline
        return text
    }

    /// A text configuration with a font for large titles.
    public static var largeTitle: Self {
        var text = Self.system(.largeTitle)
        text.swiftUIFont = .largeTitle
        return text
    }

    /// A text configuration with a font for titles.
    public static var title1: Self {
        var text = Self.system(.title1)
        text.swiftUIFont = .title
        return text
    }

    /// A text configuration with a font for alternate titles.
    public static var title2: Self {
        var text = Self.system(.title2)
        text.swiftUIFont = .title2
        return text
    }

    /// A text configuration with a font for alternate titles.
    public static var title3: Self {
        var text = Self.system(.title3)
        text.swiftUIFont = .title3
        return text
    }
}

extension TextProperties: Hashable {
    public static func == (lhs: TextProperties, rhs: TextProperties) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(font)
        hasher.combine(numberOfLines)
        hasher.combine(alignment)
        hasher.combine(isEditable)
        hasher.combine(isSelectable)
        hasher.combine(color)
        hasher.combine(colorTansform)
    }
}

extension Text {
    @ViewBuilder
    func configurate(using properties: TextProperties) -> some View {
        font(Font(properties.font))
            .foregroundColor(Color(properties._resolvedTextColor))
            .lineLimit(properties.numberOfLines == 0 ? nil : properties.numberOfLines)
            .multilineTextAlignment(properties.alignment.swiftUIMultiline)
            .frame(alignment: properties.alignment.swiftUI)
    }
}

extension NSTextView {
    /**
     Configurates the text view.

     - Parameters:
        - configuration:The configuration for configurating the text view.
     */
    func configurate(using configuration: TextProperties) {
        textContainer?.maximumNumberOfLines = configuration.numberOfLines
        textContainer?.lineBreakMode = configuration.lineBreakMode
        textColor = configuration._resolvedTextColor
        font = configuration.font
        alignment = configuration.alignment
        isEditable = configuration.isEditable
        isSelectable = configuration.isSelectable
    }
}

extension NSTextField {
    /**
     Configurates the text field.

     - Parameters:
        - configuration:The configuration for configurating the text field.
     */
    func configurate(using configuration: TextProperties) {
        maximumNumberOfLines = configuration.numberOfLines
        textColor = configuration._resolvedTextColor
        font = configuration.font
        alignment = configuration.alignment
        lineBreakMode = configuration.lineBreakMode
        isEditable = configuration.isEditable
        isSelectable = configuration.isSelectable
        formatter = configuration.numberFormatter
        adjustsFontSizeToFitWidth = configuration.adjustsFontSizeToFitWidth
        minimumScaleFactor = configuration.minimumScaleFactor
        allowsDefaultTighteningForTruncation = configuration.allowsDefaultTighteningForTruncation
    }
}
