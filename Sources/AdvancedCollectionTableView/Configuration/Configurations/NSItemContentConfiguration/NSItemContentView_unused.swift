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
    
    var previousSize: CGSize? = nil
    var previousImageSize: CGSize? = nil
    public override func layout() {
        super.layout()
        guard previousSize != self.frame.size || previousImageSize != contentView.imageSize else { return }
        previousSize = self.frame.size
        previousImageSize = contentView.imageSize
        
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
                    Swift.print("fit", contentView.frame.size, contentView.imageView.frame)
                } else {
                    resizedImageSize = imageSize.scaled(toFill: CGSize(width: width, height: height))
                    contentView.frame.size = remainingSize
                    contentView.imageView.frame.size = resizedImageSize
                    contentView.imageView.center = contentView.center
                    Swift.print("fill", contentView.frame.size, contentView.imageView.frame)
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
        
        layer?.scale = CGPoint(x: _configuration.scaleTransform, y: _configuration.scaleTransform)
        
        /*
        stackView.spacing = _configuration.contentToTextPadding
        textStackView.spacing = _configuration.textToSecondaryTextPadding
        
        _constraints[0].constant = _configuration.padding.leading
        _constraints[1].constant = _configuration.padding.bottom
        _constraints[2].constant = -_configuration.padding.trailing
        _constraints[3].constant = -_configuration.padding.top
         */
        
        self.setNeedsLayout()

    }
    
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSItemContentConfiguration {
                self._configuration = newValue
            }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSItemContentConfiguration
    }
    
    internal var _configuration: NSItemContentConfiguration {
        didSet {
            if oldValue != self._configuration {
                update()
            }
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



/*
extension NSItemContentConfiguration {
    internal class ContentView: NSView, NSContentView {
        let textField: NSTextField = NSTextField(wrappingLabelWithString: "")
        let secondaryTextField: NSTextField = NSTextField(wrappingLabelWithString: "")
        let imageView: ImageView = ImageView()
        
        let contentView: NSView = NSView(frame: .zero)
        var _constraints: [NSLayoutConstraint] = []
        var imageViewConstraints: [NSLayoutConstraint] = []
        
        lazy var textStackView: NSStackView = {
            let textStackView = NSStackView(views: [textField, secondaryTextField])
            textStackView.orientation = .vertical
            return textStackView
        }()
        
        lazy var stackView: NSStackView = {
            let stackView = NSStackView(views: [imageView, textStackView])
            stackView.orientation = .horizontal
            stackView.alignment = .firstBaseline
            return stackView
        }()
        
        var configuration: NSContentConfiguration {
            get { self.appliedConfiguration }
            set {
                if let newValue = newValue as? NSItemContentConfiguration {
                    self.appliedConfiguration = newValue
                }
            }
        }
        
        internal var appliedConfiguration: NSItemContentConfiguration {
            didSet {
                self.updateConfiguration(with: self.appliedConfiguration)
            }
        }
        
        internal func updateConfiguration(with configuration: NSItemContentConfiguration) {
            textField.maximumNumberOfLines = configuration.textProperties.numberOfLines ?? 0
            textField.isHidden = (configuration.hasText == false)
            textField.alignment = configuration.textProperties.alignment
            textField.font = configuration.textProperties.font
            textField.textColor = configuration.textProperties.resolvedTextColor()
            textField.lineBreakMode = configuration.textProperties.lineBreakMode
            textField.isSelectable = configuration.textProperties.isSelectable
            textField.isEditable = configuration.textProperties.isEditable
            textField.backgroundColor = configuration.textProperties.resolvedBackgroundColor()
            textField.drawsBackground = (textField.backgroundColor != nil)
            textField.bezelStyle = configuration.textProperties.bezelStyle ?? .roundedBezel
            textField.isBezeled = (configuration.textProperties.bezelStyle != nil)
            if let attributedText = configuration.attributedText {
                textField.attributedStringValue = NSAttributedString(attributedText)
                
                //                 textField.attributedStringValue = attributedText.transform(using: configuration.textProperties.transform)

            } else {
                textField.stringValue = configuration.text?.transform(using: configuration.textProperties.textTransform) ?? ""
            }
            
            secondaryTextField.isHidden = (configuration.hasSecondaryText == false)
            secondaryTextField.maximumNumberOfLines = configuration.secondaryTextProperties.numberOfLines ?? 0
            secondaryTextField.alignment = configuration.secondaryTextProperties.alignment
            secondaryTextField.font = configuration.secondaryTextProperties.font
            secondaryTextField.textColor = configuration.secondaryTextProperties.resolvedTextColor()
            secondaryTextField.lineBreakMode = configuration.secondaryTextProperties.lineBreakMode
            secondaryTextField.isSelectable = configuration.secondaryTextProperties.isSelectable
            secondaryTextField.isEditable = configuration.secondaryTextProperties.isEditable
            secondaryTextField.backgroundColor = configuration.secondaryTextProperties.resolvedBackgroundColor()
            secondaryTextField.drawsBackground = (secondaryTextField.backgroundColor != nil)
            secondaryTextField.bezelStyle = configuration.secondaryTextProperties.bezelStyle ?? .roundedBezel
            secondaryTextField.isBezeled = (configuration.secondaryTextProperties.bezelStyle != nil)

            if let secondaryattributedText = configuration.secondaryattributedText {
                secondaryTextField.attributedStringValue = NSAttributedString(secondaryattributedText)
            } else {
                secondaryTextField.stringValue = configuration.secondaryText?.transform(using: configuration.secondaryTextProperties.textTransform) ?? ""
            }
              
            imageView.isHidden = (configuration.hasImage == false)
            if let image = configuration.image {
                imageView.images = [image]
            }
            imageView.layer?.shadowColor = configuration.contentProperties.shadowProperties.resolvedColor()?.cgColor
            imageView.layer?.shadowOffset = CGSize(width:  configuration.contentProperties.shadowProperties.offset.x, height: configuration.contentProperties.shadowProperties.offset.y)
            imageView.layer?.shadowRadius = configuration.contentProperties.shadowProperties.radius
            imageView.layer?.shadowOpacity = Float( configuration.contentProperties.shadowProperties.opacity)
            
         //   imageView.cornerRadius = configuration.contentProperties.cor
            imageView.backgroundColor = configuration.contentProperties.resolvedBackgroundColor()
           // imageView.contentTintColor = configuration.imageProperties.resolvedTintColor()
            imageView.imageScaling = .center
            if #available(macOS 11.0, *) {
                imageView.symbolConfiguration = configuration.imageProperties.symbolConfiguration.symbolConfiguration
            }
            
            stackView.spacing = configuration.imageToTextPadding
            stackView.orientation = configuration.orientation
            textStackView.spacing = configuration.textToSecondaryTextPadding
            textStackView.alignment = .leading
            
            _constraints[0].constant = -configuration.padding.bottom
            _constraints[1].constant = configuration.padding.top
            _constraints[2].constant = configuration.padding.leading
            _constraints[3].constant = configuration.padding.trailing
            
            NSLayoutConstraint.deactivate(imageViewConstraints)
            switch configuration.imageProperties.size {
             case .fullSize:
                imageViewConstraints = [
                    imageView.topAnchor.constraint(equalTo: textStackView.topAnchor, constant: 0.0),
                    imageView.centerYAnchor.constraint(equalTo: textStackView.centerYAnchor, constant: 0.0),
                    imageView.bottomAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 0.0),
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, constant: 0.0),
                ]
                 
            case .textHeight:
                imageViewConstraints = [
                    imageView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 0.0),
                    //     _imageView.centerYAnchor.constraint(equalTo: textTextField.centerYAnchor, constant: 0.0),
                    imageView.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0.0),
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, constant: 0.0),
                ]
            case .secondaryTextHeight:
                imageViewConstraints = [
                    imageView.topAnchor.constraint(equalTo: secondaryTextField.topAnchor, constant: 0.0),
                    imageView.centerYAnchor.constraint(equalTo: secondaryTextField.centerYAnchor, constant: 0.0),
                    imageView.bottomAnchor.constraint(equalTo: secondaryTextField.bottomAnchor, constant: 0.0),
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, constant: 0.0),
                ]
            case .size(let size):
                imageViewConstraints = [
                    imageView.heightAnchor.constraint(equalToConstant: size.height),
                    imageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0.0),
                    imageView.widthAnchor.constraint(equalToConstant: size.width),]
            case .maxSize(let size):
                if let image = configuration.image {
                    if (image.size.width > size.width || image.size.height > size.height) {
                        imageViewConstraints = [
                            imageView.heightAnchor.constraint(equalToConstant:  size.height),
                            imageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0.0),
                            imageView.widthAnchor.constraint(equalToConstant: size.width),]
                    } else {
                        imageViewConstraints = [
                            imageView.heightAnchor.constraint(equalToConstant:  image.size.height),
                            imageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0.0),
                            imageView.widthAnchor.constraint(equalToConstant: size.width),]
                    }
                } else {
                    imageViewConstraints = [
                        imageView.heightAnchor.constraint(equalToConstant:  size.height),
                        imageView.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0.0),
                        imageView.widthAnchor.constraint(equalToConstant: size.width),]
                }
            case .textAndSecondaryTextHeight:
                // Missing
                break
            }
            NSLayoutConstraint.activate(imageViewConstraints)
            
        }
        
        
        public override func layout() {
            super.layout()
            // missing
        }
        
        func supports(_ configuration: NSContentConfiguration) -> Bool {
            return (configuration as? NSItemContentConfiguration) != nil
        }
        
        init(configuration: NSItemContentConfiguration) {
            self.appliedConfiguration = configuration
            super.init(frame: .zero)
            self.addSubview(withConstraint: contentView)
            _constraints = contentView.addSubview(withConstraint: stackView)
            self.updateConfiguration(with: configuration)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}
*/
