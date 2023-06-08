//
//  TableCellContentVierw.swift
//  NSTableViewRegister
//
//  Created by Florian Zand on 14.12.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

extension NSTableCellContentConfiguration {
    internal class ContentView: NSView, NSContentView {
        lazy var textField: TableCellTextField = TableCellTextField(properties: appliedConfiguration.textProperties)
        lazy var secondaryTextField: TableCellTextField = TableCellTextField(properties: appliedConfiguration.secondaryTextProperties)

        let imageView: ImageView = ImageView()
        
        let contentView: NSView = NSView(frame: .zero)
        var _constraints: [NSLayoutConstraint] = []
        var imageViewConstraints: [NSLayoutConstraint] = []
        var accessoryViews: [NSView] = []
        
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
                
        internal func updateConfiguration(with configuration: NSTableCellContentConfiguration) {
            if configuration.imageProperties.position == .leading {
                if (stackView.arrangedSubviews.last != self.textStackView) {
                    stackView.removeArrangedSubview(textStackView)
                    stackView.addArrangedSubview(textStackView)
                }
            } else {
                if (stackView.arrangedSubviews.last != self.imageView) {
                    stackView.removeArrangedSubview(imageView)
                    stackView.addArrangedSubview(imageView)
                }
            }
            
            textField.properties = configuration.textProperties
            textField.isHidden = configuration.hasText
            if let attributedText = configuration.attributedText {
                textField.attributedStringValue = NSAttributedString(attributedText)
                //                 textField.attributedStringValue = attributedText.transform(using: configuration.textProperties.transform)

            } else {
                textField.stringValue = configuration.text ?? ""
             //   textField.stringValue = configuration.text?.transform(using: configuration.textProperties.textTransform) ?? ""
            }
            
            secondaryTextField.properties = configuration.secondaryTextProperties
            secondaryTextField.isHidden = configuration.hasSecondaryText
            if let attributedText = configuration.secondaryAttributedText {
                secondaryTextField.attributedStringValue = NSAttributedString(attributedText)
                //                 textField.attributedStringValue = attributedText.transform(using: configuration.textProperties.transform)

            } else {
                secondaryTextField.stringValue = configuration.secondaryText ?? ""
             //   textField.stringValue = configuration.text?.transform(using: configuration.textProperties.textTransform) ?? ""
            }
                    
            /*
            var topAccessorVyiews: [NSView] = []
            var bottomAccessorVyiews: [NSView] = []
            for accessory in configuration.accessories {
                if (accessory.position.isTopPosition) {
                    
                }
            }
             */
                          
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
        //    imageView.symbolConfiguration = configuration.imageProperties.symbolConfiguration.nsImageSymbolConfiguration
            
            stackView.spacing = configuration.imageToTextPadding
            textStackView.spacing = configuration.textToSecondaryTextPadding
            textStackView.alignment = .leading
            
            _constraints[0].constant = -configuration.padding.bottom
            _constraints[1].constant = configuration.padding.top
            _constraints[2].constant = configuration.padding.leading
            _constraints[3].constant = configuration.padding.trailing
            
            NSLayoutConstraint.deactivate(imageViewConstraints)
            switch configuration.imageProperties.size {
            case .cellHeight:
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
        
        var configuration: NSContentConfiguration {
            get { self.appliedConfiguration }
            set {
                if let newValue = newValue as? NSTableCellContentConfiguration {
                    self.appliedConfiguration = newValue
                }
            }
        }
        
        internal var appliedConfiguration: NSTableCellContentConfiguration {
            didSet {
                if oldValue != self.appliedConfiguration {
                    self.updateConfiguration(with: self.appliedConfiguration)
                }
            }
        }
        
        func supports(_ configuration: NSContentConfiguration) -> Bool {
            return configuration is NSTableCellContentConfiguration
        }
        
        init(configuration: NSTableCellContentConfiguration) {
            self.appliedConfiguration = configuration
            super.init(frame: .zero)
            self.addSubview(withConstraint: contentView)
            self._constraints = contentView.addSubview(withConstraint: stackView)
            self.updateConfiguration(with: configuration)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}

internal extension NSTableCellContentConfiguration.ContentView {
    class TableCellTextField: NSTextField {
        var properties: NSTableCellContentConfiguration.TextProperties {
            didSet {
                if oldValue != self.properties {
                self.update() }
            }
        }
        
        internal func update() {
            self.maximumNumberOfLines = properties.numberOfLines ?? 0
            self.alignment = properties.alignment
            self.font = properties.font
            self.textColor = properties.resolvedTextColor()
            self.lineBreakMode = properties.lineBreakMode
            self.isSelectable = properties.isSelectable
            self.isEditable = properties.isEditable
            self.actionBlock = { [weak self] textField in
                guard let self = self else { return }
                properties.onEditEnd?(self.stringValue)
            }
            self.drawsBackground = (self.backgroundColor != nil)
         //   textField.bezelStyle = configuration.textProperties.bezelStyle ?? .roundedBezel
        //    textField.isBezeled = (configuration.textProperties.bezelStyle != nil)
            self.isBezeled = false
        }
        
        init(properties: NSTableCellContentConfiguration.TextProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.lineBreakMode = .byWordWrapping
            self.usesSingleLineMode = false
            self.cell?.wraps = true
            self.truncatesLastVisibleLine = true
            self.cell?.isScrollable = false
            self.setContentCompressionResistancePriority( .fittingSizeCompression , for: .horizontal)
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

/*
extension NSStackView {
    internal var arrangedView: [NSView] {
        get { getAssociatedValue(key: "_arrangedView", object: self) }
        set {
            set(associatedValue: newValue, key: "_arrangedView", object: self)
            self.setNeedsUpdateConfiguration()
        }
    }
}
*/


