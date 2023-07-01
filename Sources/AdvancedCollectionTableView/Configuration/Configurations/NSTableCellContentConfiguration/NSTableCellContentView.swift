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
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSTableCellContentConfiguration
    }
    
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSTableCellContentConfiguration {
                _configuration = newValue
            }
        }
    }
    
    /// Creates a table cell content view with the specified content configuration.
    public init(configuration: NSTableCellContentConfiguration) {
        self._configuration = configuration
        super.init(frame: .zero)
        self.initialSetup()
        self.updateConfiguration()
    }
    
    internal lazy var textField = CellTextField(properties: self._configuration.textProperties)
    internal lazy var secondaryTextField = CellTextField(properties: self._configuration.secondaryTextProperties)
    internal lazy var imageView = CellImageView(properties: self._configuration.imageProperties)

    internal lazy var textStackView: NSStackView = {
        var stackView = NSStackView(views: [textField, secondaryTextField])
        stackView.orientation = .vertical
        stackView.spacing = _configuration.textToSecondaryTextPadding
        stackView.alignment = .leading
    //    textStack.setDistribution(.center)
        return stackView
    }()
    
    internal lazy var stackView: NSStackView = {
        var stackView = NSStackView(views: [imageView, textStackView])
        stackView.orientation = .horizontal
        stackView.spacing = _configuration.imageToTextPadding
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
            self.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -self._configuration.insets.top),
            self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: self._configuration.insets.bottom),
            self.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -self._configuration.insets.left),
            self.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: self._configuration.insets.right)]
        NSLayoutConstraint.activate(self.stackViewConstraints)
    }
    
    internal func updateConfiguration() {
        textField.text(_configuration.text, attributedString: _configuration.attributedText)
        secondaryTextField.text(_configuration.secondaryText, attributedString: _configuration.secondaryAttributedText)
        imageView.image = _configuration.image
                
        imageView.properties = _configuration.imageProperties
        textField.properties = _configuration.textProperties
        secondaryTextField.properties = _configuration.secondaryTextProperties
        
        textStackView.spacing = _configuration.textToSecondaryTextPadding
        stackView.spacing = _configuration.imageToTextPadding
        stackView.orientation = _configuration.imageProperties.position.orientation
        
        switch _configuration.imageProperties.position {
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
        if _configuration.imageProperties.position == .leading && stackView.arrangedSubviews.first != imageView {
            stackView.addArrangedSubview(imageView)
        } else if _configuration.imageProperties.position == .trailing && stackView.arrangedSubviews.first != textStackView {
            stackView.addArrangedSubview(textStackView)
            stackView.addArrangedSubview(imageView)
        }
        
        self.stackViewConstraints[0].constant = -_configuration.insets.top
        self.stackViewConstraints[1].constant = _configuration.insets.bottom
        self.stackViewConstraints[2].constant = -_configuration.insets.left
        self.stackViewConstraints[3].constant = _configuration.insets.right
    }
    
    internal var _configuration: NSTableCellContentConfiguration {
        didSet {
            if oldValue != _configuration {
                updateConfiguration()
            }
        }
    }
 
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

internal extension NSTableCellContentView {
    class CellTextField: NSTextField {
        var properties: NSTableCellContentConfiguration.TextProperties {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        func text(_ text: String?, attributedString: AttributedString?) {
            if let attributedString = attributedString {
                self.isHidden = false
                self.attributedStringValue = NSAttributedString(attributedString)
            } else if let text = text {
                self.stringValue = text
                self.isHidden = false
            } else {
                self.stringValue = ""
                self.isHidden = true
            }
        }
        
        func update() {
            self.maximumNumberOfLines = properties.maxNumberOfLines
            self.textColor = properties._resolvedColor
            self.lineBreakMode = properties.lineBreakMode
            self.font = properties.font
            self.alignment = properties.alignment
            self.isSelectable = properties.isSelectable
            self.isEditable = properties.isEditable
            self.drawsBackground = false
            self.backgroundColor = nil
            self.isBordered = false
        }
        
        init(properties: NSTableCellContentConfiguration.TextProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.drawsBackground = false
            self.backgroundColor = nil
            self.textLayout = .wraps
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    class CellImageView: NSImageView {
        var properties: NSTableCellContentConfiguration.ImageProperties {
            didSet {
                if oldValue != properties {
                    update()
                }
            }
        }
        
        override var image: NSImage? {
            didSet {
                self.isHidden = (self.image == nil)
                if let image = image {
                    let width = image.alignmentRect.size.height*2.0
                    var origin = self.frame.origin
                    origin.x = width - image.alignmentRect.size.width
                    self.frame.origin = origin
                }
            }
        }
    
        
        func update() {
            self.imageScaling = properties.scaling
            self.symbolConfiguration = properties.symbolConfiguration?.nsSymbolConfiguration()
            self.borderColor = properties._resolvedBorderColor
            self.borderWidth = properties.borderWidth
            self.backgroundColor = properties._resolvedBackgroundColor
            self.contentTintColor = properties._resolvedTintColor
            self.cornerRadius = properties.cornerRadius
            
            
            var width: CGFloat? =  image?.size.width
            var height: CGFloat? =  image?.size.height
            if let maxWidth = properties.maxWidth, let _width = width {
                width = max(_width, maxWidth)
            }
            
            if let maxHeight = properties.maxHeight, let _height = height {
                height = max(_height, maxHeight)
            }
            
            /*
            if let pointSize = self.properties.symbolConfiguration?.font?.pointSize {
              //  width = pointSize * 2
            }
             */
            
            if let width = width {
                widthA = self.widthAnchor.constraint(equalToConstant: width)
                widthA?.isActive = true
            } else {
                widthA?.isActive = false
            }

            if let height = height {
                heightA = self.heightAnchor.constraint(equalToConstant: height)
                heightA?.isActive = true
            } else {
                heightA?.isActive = false
            }
            
        }
        
        var widthA: NSLayoutConstraint? = nil
        var heightA: NSLayoutConstraint? = nil

        init(properties: NSTableCellContentConfiguration.ImageProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.imageAlignment = .alignCenter
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
