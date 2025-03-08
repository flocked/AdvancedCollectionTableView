//
//  TextStackView.swift
//
//
//  Created by Florian Zand on 02.03.25.
//

import AppKit
import FZUIKit

class TextStackView: NSStackView {
    let textField = ListItemTextField.wrapping().truncatesLastVisibleLine(true)
    let secondaryTextField = ListItemTextField.wrapping().truncatesLastVisibleLine(true)
    
    func update(with properties: TextStackProperties, for view: NSView) {
        textField.isEnabled = properties.isEnabled
        textField.properties = properties.textProperties
        textField.updateText(properties.text, properties.attributedText, properties.placeholderText, properties.attributedPlaceholderText)
        textField.updateLayoutGuide(for: view)
        secondaryTextField.isEnabled = properties.isEnabled
        secondaryTextField.properties = properties.secondaryTextProperties
        secondaryTextField.updateText(properties.secondaryText, properties.secondaryAttributedText, properties.secondaryPlaceholderText, properties.secondaryAttributedPlaceholderText)
        secondaryTextField.updateLayoutGuide(for: view)
        spacing = properties.textToSecondaryTextPadding
    }
    
    init() {
        super.init(frame: .zero)
        addArrangedSubview(textField)
        addArrangedSubview(secondaryTextField)
        orientation = .vertical
        alignment = .leading
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSListContentConfiguration: TextStackProperties { }
extension NSItemContentConfiguration: TextStackProperties { }

protocol TextStackProperties {
    var text: String? { get }
    var attributedText: AttributedString? { get }
    var placeholderText: String? { get }
    var attributedPlaceholderText: AttributedString? { get }
    var secondaryText: String? { get }
    var secondaryAttributedText: AttributedString? { get }
    var secondaryPlaceholderText: String? { get }
    var secondaryAttributedPlaceholderText: AttributedString? { get }
    var textToSecondaryTextPadding: CGFloat { get }
    var textProperties: TextProperties { get }
    var secondaryTextProperties: TextProperties { get }
    var isEnabled: Bool { get }
}

extension TextStackProperties {
    var isEnabled: Bool { true }
}
