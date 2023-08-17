//
//  NSTableCellContentView.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

public class NSTableCellContentView: NSView, NSContentView {
    /// Creates a table cell content view with the specified content configuration.
    public init(configuration: NSTableCellContentConfiguration) {
        self.appliedConfiguration = configuration
        super.init(frame: .zero)
        self.initialSetup()
        self.updateConfiguration()
    }
    
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { appliedConfiguration }
        set {
            if let newValue = newValue as? NSTableCellContentConfiguration {
                appliedConfiguration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSTableCellContentConfiguration
    }
    
    internal lazy var textField = CellTextField(properties: self.appliedConfiguration.textProperties)
    internal lazy var secondaryTextField = CellTextField(properties: self.appliedConfiguration.secondaryTextProperties)
    internal lazy var imageView = CellImageView(properties: self.appliedConfiguration.imageProperties)
    
    internal lazy var textStackView: NSStackView = {
        var stackView = NSStackView(views: [textField, secondaryTextField])
        stackView.orientation = .vertical
        stackView.spacing = appliedConfiguration.textToSecondaryTextPadding
        stackView.alignment = .leading
        return stackView
    }()
    
    internal lazy var stackView: NSStackView = {
        var stackView = NSStackView(views: [imageView, textStackView])
        stackView.orientation = .horizontal
        stackView.spacing = appliedConfiguration.imageToTextPadding
        stackView.alignment = appliedConfiguration.contentAlignment
        stackView.distribution = .fill
        return stackView
    }()
    
    internal var stackViewConstraints: [NSLayoutConstraint] = []
    
    internal func initialSetup() {
        self.maskToBounds = false
        self.stackViewConstraints = self.addSubview(withConstraint: stackView)
        self.stackViewConstraints.constant(appliedConfiguration.margins)
    }
    
    internal func updateConfiguration() {
        textField.text(appliedConfiguration.text, attributedString: appliedConfiguration.attributedText)
        secondaryTextField.text(appliedConfiguration.secondaryText, attributedString: appliedConfiguration.secondaryAttributedText)
        imageView.image = appliedConfiguration.image
        
        imageView.properties = appliedConfiguration.imageProperties
        textField.properties = appliedConfiguration.textProperties
        secondaryTextField.properties = appliedConfiguration.secondaryTextProperties
        
        textStackView.spacing = appliedConfiguration.textToSecondaryTextPadding
        stackView.spacing = appliedConfiguration.imageToTextPadding
        stackView.orientation = appliedConfiguration.imageProperties.position.orientation
        stackView.alignment = appliedConfiguration.contentAlignment
        
        if appliedConfiguration.imageProperties.position.imageIsLeading,  stackView.arrangedSubviews.first != imageView {
            stackView.removeArrangedSubview(textStackView)
            stackView.addArrangedSubview(textStackView)
        } else if appliedConfiguration.imageProperties.position.imageIsLeading == false,  stackView.arrangedSubviews.last != imageView {
            stackView.removeArrangedSubview(imageView)
            stackView.addArrangedSubview(imageView)
        }
        stackViewConstraints.constant(appliedConfiguration.margins)
    }
        
    internal func updateLayout() {
        let width = self.frame.size.width - appliedConfiguration.margins.width
        var height =  appliedConfiguration.margins.height
                
        if (appliedConfiguration.hasText && appliedConfiguration.hasSecondaryText) {
            height += appliedConfiguration.textToSecondaryTextPadding
            if (appliedConfiguration.hasContent && (appliedConfiguration.contentPosition == .top || appliedConfiguration.contentPosition == .bottom) ) {
                height += appliedConfiguration.imageToTextPadding
            }
        }
        var y = appliedConfiguration.margins.bottom
        if (appliedConfiguration.hasText) {
            textField.frame.size = textField.sizeThatFits(CGSize(width, CGFloat.infinity))
            textField.frame.size.width = width
            textField.frame.origin = CGPoint((width - textField.frame.size.width) * 0.5, y)
            
            height += textField.frame.size.height
            y += textField.frame.size.height
            if appliedConfiguration.hasSecondaryText {
                y += appliedConfiguration.textToSecondaryTextPadding
            }
        }
        
        if (appliedConfiguration.hasSecondaryText) {
            secondaryTextField.frame.size = secondaryTextField.sizeThatFits(CGSize(width, CGFloat.infinity))
            secondaryTextField.frame.size.width = width
            secondaryTextField.frame.origin = CGPoint((width - secondaryTextField.frame.size.width) * 0.5, y)
            
            height -= secondaryTextField.frame.size.height
            y += secondaryTextField.frame.size.height
        }
        
       // let remainingSize = CGSize(width: width, height: height)
    }
    
    internal var appliedConfiguration: NSTableCellContentConfiguration {
        didSet {
            if oldValue != appliedConfiguration {
                updateConfiguration()
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
