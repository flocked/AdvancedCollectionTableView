//
//  TableCellContentVierw.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZExtensions

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
            textField.maximumNumberOfLines = configuration.textProperties.numberOfLines
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
                textField.attributedStringValue = attributedText
                //                 textField.attributedStringValue = attributedText.transform(using: configuration.textProperties.transform)

            } else {
                textField.stringValue = configuration.text?.transform(using: configuration.textProperties.textTransform) ?? ""
            }
            
            secondaryTextField.isHidden = (configuration.hasSecondaryText == false)
            secondaryTextField.maximumNumberOfLines = configuration.secondaryTextProperties.numberOfLines
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
                secondaryTextField.attributedStringValue = secondaryattributedText
            } else {
                secondaryTextField.stringValue = configuration.secondaryText?.transform(using: configuration.secondaryTextProperties.textTransform) ?? ""
            }
              
            imageView.isHidden = (configuration.hasImage == false)
            if let image = configuration.image {
                imageView.images = [image]
            }
            imageView.layer?.shadowColor = configuration.imageProperties.shadowProperties.resolvedColor()?.cgColor
            imageView.layer?.shadowOffset = CGSize(width:  configuration.imageProperties.shadowProperties.offset.x, height: configuration.imageProperties.shadowProperties.offset.y)
            imageView.layer?.shadowRadius = configuration.imageProperties.shadowProperties.radius
            imageView.layer?.shadowOpacity = Float( configuration.imageProperties.shadowProperties.opacity)
            
            imageView.cornerRadius = configuration.imageProperties.cornerRadius
            imageView.backgroundColor = configuration.imageProperties.resolvedBackgroundColor()
            imageView.contentTintColor = configuration.imageProperties.resolvedTintColor()
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
            case .fullHeight:
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
