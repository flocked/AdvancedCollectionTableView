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
     The Handler that determines whether the edited string is valid.

     It only gets called, if `isEditable` is true.
     */
    public var stringValidation: ((String) -> (Bool))?

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
        if configuration.allowsDefaultTighteningForTruncation {
            setupTextFieldObserver()
        }
    }

    var observer: KeyValueObserver<NSTextField>? {
        get { getAssociatedValue(key: "observer", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "observer", object: self) }
    }

    func setupTextFieldObserver() {
        if (adjustsFontSizeToFitWidth && minimumScaleFactor != 0.0) || allowsDefaultTighteningForTruncation {
            swizzleTextField()
            if observer == nil {
                observer = KeyValueObserver(self)
                observer?.add(\.stringValue, handler: { [weak self] old, new in
                    guard let self = self, self.isAdjustingFontSize == false, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.isBezeled, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.isBordered, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.bezelStyle, handler: { [weak self] old, new in
                    guard let self = self, self.isBezeled, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.preferredMaxLayoutWidth, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.allowsDefaultTighteningForTruncation, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.maximumNumberOfLines, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
            }
        } else {
            observer = nil
        }
        adjustFontSize()
    }

    var _font: NSFont? {
        get { getAssociatedValue(key: "font", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "font", object: self) }
    }

    var didSwizzleTextField: Bool {
        get { getAssociatedValue(key: "didSwizzleTextField", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "didSwizzleTextField", object: self)
        }
    }

    func swizzleTextField() {
        guard didSwizzleTextField == false else { return }
        didSwizzleTextField = true
        _font = font

        do {
            try replaceMethod(
                #selector(setter: font),
                methodSignature: (@convention(c) (AnyObject, Selector, NSFont?) -> Void).self,
                hookSignature: (@convention(block) (AnyObject, NSFont?) -> Void).self
            ) { _ in { object, font in
                let textField = (object as? NSTextField)
                textField?._font = font
                textField?.adjustFontSize()
            }
            }

            try replaceMethod(
                #selector(getter: font),
                methodSignature: (@convention(c) (AnyObject, Selector) -> NSFont?).self,
                hookSignature: (@convention(block) (AnyObject) -> NSFont?).self
            ) { _ in { object in
                (object as! NSTextField)._font
            }
            }

            try replaceMethod(
                #selector(layout),
                methodSignature: (@convention(c) (AnyObject, Selector) -> Void).self,
                hookSignature: (@convention(block) (AnyObject) -> Void).self
            ) { store in { object in
                store.original(object, #selector(NSView.layout))
                if let textField = (object as? NSTextField), textField.bounds.size != textField._bounds.size {
                    textField.adjustFontSize()
                    textField._bounds = textField.bounds
                }
            }
            }

            try replaceMethod(
                #selector(NSTextViewDelegate.textView(_:doCommandBy:)),
                methodSignature: (@convention(c) (AnyObject, Selector, NSTextView, Selector) -> (Bool)).self,
                hookSignature: (@convention(block) (AnyObject, NSTextView, Selector) -> (Bool)).self
            ) { store in { object, textView, selector in
                if let doCommand = (object as? NSTextField)?.editingHandlers.doCommand {
                    return doCommand(selector)
                }
                if let textField = object as? NSTextField {
                    switch selector {
                    case #selector(NSControl.cancelOperation(_:)):
                        switch textField.actionOnEscapeKeyDown {
                        case let .endEditingAndReset(handler: handler):
                            textField.stringValue = textField.editStartString
                            textField.adjustFontSize()
                            handler?()
                            return true
                        case let .endEditing(handler: handler):
                            textField.window?.makeFirstResponder(nil)
                            handler?()
                            return true
                        case .none:
                            break
                        }
                    case #selector(NSControl.insertNewline(_:)):
                        switch textField.actionOnEnterKeyDown {
                        case let .endEditing(handler: handler):
                            handler?()
                            return true
                        case .none: break
                        }
                    default: break
                    }
                }
                return store.original(object, #selector(NSTextViewDelegate.textView(_:doCommandBy:)), textView, selector)
            }
            }

            try replaceMethod(
                #selector(textDidEndEditing),
                methodSignature: (@convention(c) (AnyObject, Selector, Notification) -> Void).self,
                hookSignature: (@convention(block) (AnyObject, Notification) -> Void).self
            ) { store in { object, notification in
                let textField = (object as? NSTextField)
                //  textField?.editingState = .didEnd
                textField?.adjustFontSize()
                textField?.editingHandlers.didEnd?()
                store.original(object, #selector(NSTextField.textDidEndEditing), notification)
            }
            }

            try replaceMethod(
                #selector(textDidBeginEditing),
                methodSignature: (@convention(c) (AnyObject, Selector, Notification) -> Void).self,
                hookSignature: (@convention(block) (AnyObject, Notification) -> Void).self
            ) { store in { object, notification in
                store.original(object, #selector(NSTextField.textDidBeginEditing), notification)
                if let textField = (object as? NSTextField) {
                    textField.editStartString = textField.stringValue
                    textField.previousString = textField.stringValue
                    textField.editingHandlers.didBegin?()
                    if let editingRange = textField.currentEditor()?.selectedRange {
                        textField.editingRange = editingRange
                    }
                }
            }
            }

            try replaceMethod(
                #selector(textDidChange),
                methodSignature: (@convention(c) (AnyObject, Selector, Notification) -> Void).self,
                hookSignature: (@convention(block) (AnyObject, Notification) -> Void).self
            ) { store in { object, notification in
                if let textField = (object as? NSTextField) {
                    textField.updateString()
                    /*
                     let newStr = textField.conformingString()
                     if textField.stringValue != newStr {
                         textField.stringValue = newStr
                         if textField.previousString != newStr {
                             textField.editingHandlers.didEdit?()
                             textField.adjustFontSize()
                             textField.previousString = textField.stringValue
                             if let editingRange = textField.currentEditor()?.selectedRange {
                                 textField.editingRange = editingRange
                             }
                         } else {
                             textField.currentEditor()?.selectedRange = textField.editingRange
                         }
                     }

                     let newString = textField.allowedCharacters.trimString(textField.stringValue)
                     if let shouldEdit = textField.editingHandlers.shouldEdit {
                         if shouldEdit(textField.stringValue) == false {
                             textField.stringValue = textField.previousString
                         } else {
                             textField.editingHandlers.didEdit?()
                         }
                     } else if let maxCharCount = textField.maximumNumberOfCharacters, newString.count > maxCharCount {
                         if textField.previousString.count <= maxCharCount {
                             textField.stringValue = textField.previousString
                             textField.currentEditor()?.selectedRange = textField.editingRange
                         } else {
                             textField.stringValue = String(newString.prefix(maxCharCount))
                         }
                         textField.editingHandlers.didEdit?()
                     } else if let minCharCount = textField.minimumNumberOfCharacters, newString.count < minCharCount  {
                         if textField.previousString.count >= minCharCount {
                             textField.stringValue = textField.previousString
                             textField.currentEditor()?.selectedRange = textField.editingRange
                         }
                     } else {
                         textField.stringValue = newString
                         if textField.previousString == newString {
                             textField.currentEditor()?.selectedRange = textField.editingRange
                         }
                         textField.editingHandlers.didEdit?()
                     }
                     textField.previousString = textField.stringValue
                     if let editingRange = textField.currentEditor()?.selectedRange {
                         textField.editingRange = editingRange
                     }
                     textField.adjustFontSize()
                     */
                }
                store.original(object, #selector(NSTextField.textDidChange), notification)
            }
            }
        } catch {
            Swift.debugPrint(error)
        }
    }

    func updateString() {
        let newString = allowedCharacters.trimString(stringValue)
        if let shouldEdit = editingHandlers.shouldEdit {
            if shouldEdit(stringValue) == false {
                stringValue = previousString
            } else {
                editingHandlers.didEdit?()
            }
        } else if let maxCharCount = maximumNumberOfCharacters, newString.count > maxCharCount {
            if previousString.count <= maxCharCount {
                stringValue = previousString
                currentEditor()?.selectedRange = editingRange
            } else {
                stringValue = String(newString.prefix(maxCharCount))
            }
            editingHandlers.didEdit?()
        } else if let minCharCount = minimumNumberOfCharacters, newString.count < minCharCount {
            if previousString.count >= minCharCount {
                stringValue = previousString
                currentEditor()?.selectedRange = editingRange
            }
        } else {
            stringValue = newString
            if previousString == newString {
                currentEditor()?.selectedRange = editingRange
            }
            editingHandlers.didEdit?()
        }
        previousString = stringValue
        if let editingRange = currentEditor()?.selectedRange {
            self.editingRange = editingRange
        }
        adjustFontSize()
    }

    func adjustFontSize(requiresSmallerScale: Bool = false) {
        guard let _font = _font else { return }
        isAdjustingFontSize = true
        cell?.font = _font
        stringValue = stringValue
        if adjustsFontSizeToFitWidth, minimumScaleFactor != 0.0 {
            var scaleFactor = requiresSmallerScale ? lastFontScaleFactor : 1.0
            var needsUpdate = !isFittingCurrentText
            while needsUpdate, scaleFactor >= minimumScaleFactor {
                scaleFactor = scaleFactor - 0.005
                let adjustedFont = _font.withSize(_font.pointSize * scaleFactor)
                cell?.font = adjustedFont
                needsUpdate = !isFittingCurrentText
            }
            lastFontScaleFactor = scaleFactor
            if needsUpdate, allowsDefaultTighteningForTruncation {
                adjustFontKerning()
            }
        } else if allowsDefaultTighteningForTruncation {
            adjustFontKerning()
        }
        isAdjustingFontSize = false
    }

    var _bounds: CGRect {
        get { getAssociatedValue(key: "bounds", object: self, initialValue: .zero) }
        set { set(associatedValue: newValue, key: "bounds", object: self) }
    }

    var lastFontScaleFactor: CGFloat {
        get { getAssociatedValue(key: "lastFontScaleFactor", object: self, initialValue: 1.0) }
        set { set(associatedValue: newValue, key: "lastFontScaleFactor", object: self) }
    }

    var isAdjustingFontSize: Bool {
        get { getAssociatedValue(key: "isAdjustingFontSize", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "isAdjustingFontSize", object: self)
        }
    }

    var editStartString: String {
        get { getAssociatedValue(key: "editStartString", object: self, initialValue: stringValue) }
        set { set(associatedValue: newValue, key: "editStartString", object: self) }
    }

    var previousString: String {
        get { getAssociatedValue(key: "previousString", object: self, initialValue: stringValue) }
        set { set(associatedValue: newValue, key: "previousString", object: self) }
    }

    var editingRange: NSRange {
        get { getAssociatedValue(key: "editingRange", object: self, initialValue: currentEditor()?.selectedRange ?? NSRange(location: 0, length: 0)) }
        set { set(associatedValue: newValue, key: "editingRange", object: self) }
    }

    func adjustFontKerning() {
        guard let fontSize = _font?.pointSize else { return }
        var needsUpdate = !isFittingCurrentText
        var kerning: Float = 0.0
        let maxKerning: Float
        if fontSize < 8 {
            maxKerning = 0.6
        } else if fontSize < 16 {
            maxKerning = 0.8
        } else {
            maxKerning = 1.0
        }
        while needsUpdate, kerning <= maxKerning {
            attributedStringValue = attributedStringValue.applyingAttributes([.kern: -kerning])
            kerning += 0.005
            needsUpdate = !isFittingCurrentText
        }
    }

    var isFittingCurrentText: Bool {
        let isFitting = !isTruncatingText
        if isFitting == true {
            if let cell = cell, cell.cellSize(forBounds: CGRect(.zero, CGSize(bounds.width, CGFloat.greatestFiniteMagnitude))).height > bounds.height {
                return false
            }
        }
        return isFitting
    }
}

extension NSTextField.AllowedCharacters {
    func trimString<S: StringProtocol>(_ string: S) -> String {
        var string = String(string)
        if contains(.lowercaseLetters) == false { string = string.trimmingCharacters(in: .lowercaseLetters) }
        if contains(.uppercaseLetters) == false { string = string.trimmingCharacters(in: .uppercaseLetters) }
        if contains(.digits) == false { string = string.trimmingCharacters(in: .decimalDigits) }
        if contains(.symbols) == false { string = string.trimmingCharacters(in: .symbols) }
        if contains(.newLines) == false { string = string.trimmingCharacters(in: .newlines) }
        if contains(.emojis) == false { string = string.trimmingEmojis() }
        return string
    }
}
