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

    /// The line limit of the text, or `nil` if no line limit applies.
    public var maximumNumberOfLines: Int? = nil

    /// The alignment of the text.
    public var alignment: NSTextAlignment = .left

    /// The technique for wrapping and truncating the text.
    public var lineBreakMode: NSLineBreakMode = .byWordWrapping

    /// The number formatter of the text.
    public var numberFormatter: NumberFormatter?

    /// A Boolean value that determines whether the text fields reduces the text’s font size to fit the title string into the text field’s bounding rectangle.
    public var adjustsFontSizeToFitWidth: Bool = false

    /// The minimum scale factor for the text field’s text.
    public var minimumScaleFactor: CGFloat = 0.0

    /// A Boolean value that controls whether single-line text fields tighten intercharacter spacing before truncating the text.
    public var allowsDefaultTighteningForTruncation: Bool = false

    /**
     A Boolean value that determines whether the user can select the content of the text field.

     If `true`, the text field becomes selectable but not editable. Use `isEditable` to make the text field selectable and editable. If `false`, the text is neither editable nor selectable.
     */
    public var isSelectable: Bool = false
    /**
     A Boolean value that controls whether the user can edit the value in the text field.

     If `true`, the user can select and edit text. If `false`, the user can’t edit text, and the ability to select the text field’s content is dependent on the value of `isSelectable`.
     */
    public var isEditable: Bool = false
    
    /**
     The action to perform when the user presses the enter key while editing.
     
     The default value is `endEditing`.
     
     The property is only used, if `isEditable` is `true`.
     */
    public var editingActionOnEnterKeyDown: NSTextField.EnterKeyAction = .endEditing
    
    /**
     The action to perform when the user presses the escape key while editing.
     
     The default value is `endEditingAndReset`.
     
     The property is only used, if `isEditable` is `true.
     */
    public var editingActionOnEscapeKeyDown: NSTextField.EscapeKeyAction = .endEditingAndReset
    
    /**
     The handler that gets called when editing of the text ended.

     It only gets called, if `isEditable` is `true`.
     */
    public var onEditEnd: ((String) -> Void)?

    /**
     The handler that determines whether the edited string is valid.

     It only gets called, if `isEditable` is true.
     */
    public var stringValidation: ((String) -> (Bool))?

    /// The color of the text.
    public var color: NSUIColor = .labelColor

    /// The color transformer for resolving the text color.
    public var colorTansform: ColorTransformer?

    /// Generates the resolved text color, using the text color and color transformer.
    public func resolvedColor() -> NSUIColor {
        colorTansform?(color) ?? color
    }
    
    /// The tooltip of the text. If set to to an empty string, the text of the textfield is used.
    public var toolTip: String? = nil

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
        return properties
    }

    /// A text configuration for a text that contains primary content.
    public static var primary: Self {
        var properties = Self()
        return properties
    }

    /// A text configuration for a text that contains secondary content.
    public static var secondary: Self {
        var properties = Self.primary
        properties.font = .callout
        properties.color = .secondaryLabelColor
        return properties
    }

    /// A text configuration for a text that contains tertiary content.
    public static var tertiary: Self {
        var properties = Self.primary
        properties.color = .tertiaryLabelColor
        return properties
    }

    /// A text configuration with a font for bodies.
    public static var body: Self {
        Self.system(.body)
    }

    /// A text configuration with a font for callouts.
    public static var callout: Self {
        Self.system(.callout)
    }

    /// A text configuration with a font for captions.
    public static var caption1: Self {
        Self.system(.caption1)
    }

    /// A text configuration with a font for alternate captions.
    public static var caption2: Self {
        Self.system(.caption2)
    }

    /// A text configuration with a font for footnotes.
    public static var footnote: Self {
        Self.system(.footnote)
    }

    /// A text configuration with a font for headlines.
    public static var headline: Self {
        Self.system(.headline)
    }

    /// A text configuration with a font for subheadlines.
    public static var subheadline: Self {
        Self.system(.subheadline)
    }

    /// A text configuration with a font for large titles.
    public static var largeTitle: Self {
        Self.system(.largeTitle)
    }

    /// A text configuration with a font for titles.
    public static var title1: Self {
        Self.system(.title1)
    }

    /// A text configuration with a font for alternate titles.
    public static var title2: Self {
        Self.system(.title2)
    }

    /// A text configuration with a font for alternate titles.
    public static var title3: Self {
        Self.system(.title3)
    }
}

extension TextProperties: Hashable {
    public static func == (lhs: TextProperties, rhs: TextProperties) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(font)
        hasher.combine(maximumNumberOfLines)
        hasher.combine(alignment)
        hasher.combine(isEditable)
        hasher.combine(isSelectable)
        hasher.combine(color)
        hasher.combine(colorTansform)
        hasher.combine(numberFormatter)
        hasher.combine(adjustsFontSizeToFitWidth)
        hasher.combine(minimumScaleFactor)
        hasher.combine(allowsDefaultTighteningForTruncation)
        hasher.combine(toolTip)
    }
}

extension Text {
    @ViewBuilder
    func configurate(using properties: TextProperties) -> some View {
        font(Font(properties.font))
            .foregroundColor(Color(properties.resolvedColor()))
            .lineLimit(properties.maximumNumberOfLines == 0 ? nil : properties.maximumNumberOfLines)
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
        textContainer?.maximumNumberOfLines = configuration.maximumNumberOfLines ?? 0
        textContainer?.lineBreakMode = configuration.lineBreakMode
        textColor = configuration.resolvedColor()
        font = configuration.font
        alignment = configuration.alignment
        isEditable = configuration.isEditable
        isSelectable = configuration.isSelectable
        toolTip = configuration.toolTip
    }
}

extension NSTextField {
    /**
     Configurates the text field.

     - Parameters:
        - configuration:The configuration for configurating the text field.
     */
    func configurate(using configuration: TextProperties) {
        maximumNumberOfLines = configuration.maximumNumberOfLines ?? 0
        textColor = configuration.resolvedColor()
        font = configuration.font
        alignment = configuration.alignment
        lineBreakMode = configuration.lineBreakMode
        isEditable = configuration.isEditable
        isSelectable = configuration.isSelectable
        formatter = configuration.numberFormatter
        adjustsFontSizeToFitWidth = configuration.adjustsFontSizeToFitWidth
        minimumScaleFactor = configuration.minimumScaleFactor
        allowsDefaultTighteningForTruncation = configuration.allowsDefaultTighteningForTruncation
        toolTip = configuration.toolTip
    }
}
