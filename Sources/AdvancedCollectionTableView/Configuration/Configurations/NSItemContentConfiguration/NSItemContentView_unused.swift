//
//  TableCellContentVierw.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import SwiftUI

public class NSItemContentViewNS: NSView, NSContentView {
    public lazy var textField: ItemTextField = ItemTextField(properties: _configuration.textProperties)
    public lazy var secondaryTextField: ItemTextField = ItemTextField(properties: _configuration.secondaryTextProperties)
    public lazy var contentView: ItemContentView = ItemContentView(properties: _configuration, view: _configuration.view, image: _configuration.image, overlayView: _configuration.overlayView)
    
    /*
    public var _constraints: [NSLayoutConstraint] = []
    public  var imageViewConstraints: [NSLayoutConstraint] = []
    
    public lazy var textStackView: NSStackView = {
        let textStackView = NSStackView(views: [textField, secondaryTextField])
        textStackView.orientation = .vertical
        textStackView.spacing = _configuration.textToSecondaryTextPadding
        textStackView.distribution = .fill
        return textStackView
    }()
    
    public lazy var stackView: NSStackView = {
        let stackView = NSStackView(views: [contentView, textStackView])
        stackView.orientation = .vertical
       // stackView.alignment = .firstBaseline
        stackView.spacing = _configuration.contentToTextPadding
        return stackView
    }()
     */
    
    
    public override func updateConstraints() {
        super.updateConstraints()
        Swift.print("updateConstraints", self._configuration.text ?? "", self.frame)
        guard previousSize != self.frame.size else { return }
        previousSize = self.frame.size
        self.updateLayout()
    }
    
    public override func display() {
        super.display()
        Swift.print("display", self._configuration.text ?? "", self.frame)
        guard previousSize != self.frame.size else { return }
        previousSize = self.frame.size
        self.updateLayout()
    }
    
    var previousSize: CGSize? = nil
    public override func layout() {
        super.layout()
        Swift.print("layout", self._configuration.text ?? "", self.frame)
        guard previousSize != self.frame.size else { return }
        previousSize = self.frame.size
        self.updateLayout()
    }
    
    internal func updateLayout() {
        
let width = self.frame.size.width - _configuration.padding.width
var height = self.frame.size.height - _configuration.padding.height

if (_configuration.hasText || _configuration.hasSecondaryText) {
    height -= _configuration.contentToTextPadding
}

if (_configuration.hasText && _configuration.hasSecondaryText) {
    height -= _configuration.textToSecondaryTextPadding
}
var y = _configuration.padding.bottom
if (_configuration.hasText) {
    textField.frame.size = textField.sizeThatFits(CGSize(width, CGFloat.infinity))
    textField.frame.origin = CGPoint((width - textField.frame.size.width) * 0.5, y)
    
    height -= textField.frame.size.height
    y += textField.frame.size.height
    if _configuration.hasSecondaryText {
        y += _configuration.textToSecondaryTextPadding
    }
}

if (_configuration.hasSecondaryText) {
    secondaryTextField.frame.size = secondaryTextField.sizeThatFits(CGSize(width, CGFloat.infinity))
    secondaryTextField.frame.origin = CGPoint((width - secondaryTextField.frame.size.width) * 0.5, y)

    height -= secondaryTextField.frame.size.height
    y += secondaryTextField.frame.size.height
    if _configuration.hasContent {
        y += _configuration.contentToTextPadding
    }
}

let remainingSize = CGSize(width: width, height: height)

if _configuration.hasContent {
    if let imageSize = contentView.imageSize {
        let resizedImageSize: CGSize
        if _configuration.contentProperties.imageScaling == .fit {
            resizedImageSize = imageSize.scaled(toFit: CGSize(width: width, height: height))
            contentView.frame.size = resizedImageSize
            contentView.imageView.frame.size = resizedImageSize
            contentView.imageView.frame.origin = .zero
        } else {
            resizedImageSize = imageSize.scaled(toFill: CGSize(width: width, height: height))
            contentView.frame.size = remainingSize
            contentView.imageView.frame.size = resizedImageSize
            contentView.imageView.center = contentView.center
        }
        contentView.frame.origin = CGPoint((width - contentView.frame.size.width) * 0.5, y)
    } else {
        contentView.frame.size = remainingSize
        contentView.frame.origin = CGPoint((width - contentView.frame.size.width) * 0.5, y)
    }
}
    }
    
    public func update() {
        
        textField.properties = _configuration.textProperties
        textField.text(_configuration.text, attributedText: _configuration.attributedText)
        
        secondaryTextField.properties = _configuration.secondaryTextProperties
        secondaryTextField.text(_configuration.secondaryText, attributedText: _configuration.secondaryAttributedText)
        
        contentView.properties = _configuration
        
        self.anchorPoint = CGPoint(0.5, 0.5)
        layer?.scale = CGPoint(x: _configuration.scaleTransform, y: _configuration.scaleTransform)
        
        if needsLayoutUpdate {
            needsLayoutUpdate = false
            self.setNeedsLayout()
        }
    }
    
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            guard let newValue = newValue as? NSItemContentConfiguration else { return }
            self._configuration = newValue
        }
    }
    
    var needsLayoutUpdate = true
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSItemContentConfiguration
    }
    
    internal var _configuration: NSItemContentConfiguration {
        didSet {
            guard oldValue != self._configuration else { return }
            needsLayoutUpdate = self._configuration.needsUpdate(comparedTo: oldValue)
            update()
        }
    }
    
    /// Creates a item content view with the specified content configuration.
    public init(configuration: NSItemContentConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
                
        self.addSubview(textField)
        self.addSubview(secondaryTextField)
        self.addSubview(contentView)

      //  self._constraints = self.addSubview(withConstraint: stackView)
        self.wantsLayer = true
        self.update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
