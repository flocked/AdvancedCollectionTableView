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
        //    textStack.setDistribution(.center)
        return stackView
    }()
    
    internal lazy var stackView: NSStackView = {
        var stackView = NSStackView(views: [imageView, textStackView])
        stackView.orientation = .horizontal
        stackView.spacing = appliedConfiguration.imageToTextPadding
        stackView.alignment = .firstBaseline
        stackView.distribution = .fill
        //   stackView.setDistribution(.firstBaseline)
        return stackView
    }()
    
    internal var stackViewConstraints: [NSLayoutConstraint] = []
    internal func initialSetup() {
        self.maskToBounds = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        self.stackViewConstraints = [
            self.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -self.appliedConfiguration.insets.top),
            self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: self.appliedConfiguration.insets.bottom),
            self.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -self.appliedConfiguration.insets.left),
            self.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: self.appliedConfiguration.insets.right)]
        NSLayoutConstraint.activate(self.stackViewConstraints)
    }
    
    internal var layoutUpdateConstraints = false
    public override func layout() {
        super.layout()
        layoutUpdateConstraints = true
        self.updateConstraints()
        layoutUpdateConstraints = false
        self.invalidateIntrinsicContentSize()
        Swift.print("layout", self.appliedConfiguration.text ?? "")
        Swift.print("\n self: ", self.frame.size)
        Swift.print("\n stack: ", self.stackView.frame.size)
        Swift.print("\n textstack: ", self.textStackView.frame.size)
        Swift.print("\n text: ", self.textField.frame.size)
        Swift.print("\n secondary: ", self.secondaryTextField.frame.size)
        Swift.print("\n image: ", self.imageView.frame.size)
        Swift.print("\n intrinsic: ", self.intrinsicContentSize)
        Swift.print("------------")
    }
    
    public override func updateConstraints() {
        if layoutUpdateConstraints == false {
            Swift.print("updateConstraints")
        }
        super.updateConstraints()
    }
    
    public override var intrinsicContentSize: NSSize {
        let intrinsicContentSize = super.intrinsicContentSize
        Swift.print("intrinsicContentSize")
        return intrinsicContentSize
    }
    
    public override func updateConstraintsForSubtreeIfNeeded() {
        Swift.print("updateConstraintsForSubtreeIfNeeded")
        super.updateConstraintsForSubtreeIfNeeded()
    }
    
    public override func display() {
        Swift.print("display")
        super.display()
    }
    
    public override func addConstraint(_ constraint: NSLayoutConstraint) {
        Swift.print("addConstraint", constraint)
        super.addConstraint(constraint)
    }
    public override func addConstraints(_ constraints: [NSLayoutConstraint]) {
        Swift.print("addConstraints", constraints)
        super.addConstraints(constraints)
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
        
        switch appliedConfiguration.imageProperties.position {
        case .leading, .top:
            if stackView.arrangedSubviews.first != imageView {
                stackView.addArrangedSubview(imageView)
                stackView.addArrangedSubview(textStackView)
            }
        case .trailing, .bottom:
            if stackView.arrangedSubviews.last != imageView {
                stackView.addArrangedSubview(textStackView)
                stackView.addArrangedSubview(imageView)
            }
        }
        if appliedConfiguration.imageProperties.position == .leading && stackView.arrangedSubviews.first != imageView {
            stackView.addArrangedSubview(imageView)
        } else if appliedConfiguration.imageProperties.position == .trailing && stackView.arrangedSubviews.first != textStackView {
            stackView.addArrangedSubview(textStackView)
            stackView.addArrangedSubview(imageView)
        }
        
        self.stackViewConstraints[0].constant = -appliedConfiguration.insets.top
        self.stackViewConstraints[1].constant = appliedConfiguration.insets.bottom
        self.stackViewConstraints[2].constant = -appliedConfiguration.insets.left
        self.stackViewConstraints[3].constant = appliedConfiguration.insets.right
    }
    
    internal func updateLayout() {
        let width = self.frame.size.width - appliedConfiguration.insets.width
        var height =  appliedConfiguration.insets.height
                
        if (appliedConfiguration.hasText && appliedConfiguration.hasSecondaryText) {
            height += appliedConfiguration.textToSecondaryTextPadding
            if (appliedConfiguration.hasContent && (appliedConfiguration.contentPosition == .top || appliedConfiguration.contentPosition == .bottom) ) {
                height += appliedConfiguration.imageToTextPadding
            }
        }
        var y = appliedConfiguration.insets.bottom
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
