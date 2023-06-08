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
        
        let containerView: NSView = NSView(frame: .zero)
        lazy var contentView = TableCellContentView(properties: self.appliedConfiguration.contentProperties)
        var _constraints: [NSLayoutConstraint] = []
        var contentViewConstraints: [NSLayoutConstraint] = []
        var accessoryViews: [NSView] = []
        
        lazy var textStackView: NSStackView = {
            let textStackView = NSStackView(views: [textField, secondaryTextField])
            textStackView.orientation = .vertical
            return textStackView
        }()
        
        lazy var stackView: NSStackView = {
            let stackView = NSStackView(views: [contentView, textStackView])
            stackView.orientation = .horizontal
            stackView.alignment = .firstBaseline
            return stackView
        }()
        
        internal func updateConfiguration(with configuration: NSTableCellContentConfiguration) {
            if configuration.contentPosition == .leading {
                if (stackView.arrangedSubviews.last != self.textStackView) {
                    stackView.removeArrangedSubview(textStackView)
                    stackView.addArrangedSubview(textStackView)
                }
            } else {
                if (stackView.arrangedSubviews.last != self.contentView) {
                    stackView.removeArrangedSubview(contentView)
                    stackView.addArrangedSubview(contentView)
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
                          
            contentView.isHidden = configuration.contentIsHidden
            contentView.properties = configuration.contentProperties
            contentView.view = configuration.view
            contentView.image = configuration.image

            stackView.spacing = configuration.imageToTextPadding
            textStackView.spacing = configuration.textToSecondaryTextPadding
            textStackView.alignment = .leading
            
            self.updateConstraints()
        }
                
        override func updateConstraints() {
            super.updateConstraints()
            _constraints[0].constant = -appliedConfiguration.padding.bottom
            _constraints[1].constant = appliedConfiguration.padding.top
            _constraints[2].constant = appliedConfiguration.padding.leading
            _constraints[3].constant = appliedConfiguration.padding.trailing
            
            NSLayoutConstraint.deactivate(contentViewConstraints)
            if appliedConfiguration.contentIsHidden == false {
                switch appliedConfiguration.contentProperties.size {
                case .textAndSecondaryTextHeight:
                    switch (appliedConfiguration.hasText, appliedConfiguration.hasSecondaryText) {
                    case (true, false):
                        self.applyContentConstraint(.textHeight)
                    case (false, true):
                        self.applyContentConstraint(.secondaryTextHeight)
                    case (true, true):
                        self.applyContentConstraint(.textAndSecondaryTextHeight)
                    case (false, false):
                        break
                    }
                default:
                    self.applyContentConstraint(self.appliedConfiguration.contentProperties.size)
                }
            }
        }
        
        internal func applyContentConstraint(_ contentSize: NSTableCellContentConfiguration.ContentProperties.ContentSize) {
            switch contentSize {
            case .textHeight:
                contentViewConstraints = [
                    contentView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 0.0),
                    contentView.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0.0),
                    contentView.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: 0.0),
                    contentView.widthAnchor.constraint(equalTo: contentView.heightAnchor, constant: 0.0),
                ]
            case .secondaryTextHeight:
                contentViewConstraints = [
                    contentView.topAnchor.constraint(equalTo: secondaryTextField.topAnchor, constant: 0.0),
                    contentView.centerYAnchor.constraint(equalTo: secondaryTextField.centerYAnchor, constant: 0.0),
                    contentView.bottomAnchor.constraint(equalTo: secondaryTextField.bottomAnchor, constant: 0.0),
                    contentView.widthAnchor.constraint(equalTo: contentView.heightAnchor, constant: 0.0),
                ]
            case .size(let size):
                contentViewConstraints = [
                    contentView.heightAnchor.constraint(equalToConstant: size.height),
                    contentView.centerYAnchor.constraint(equalTo: textField.centerYAnchor, constant: 0.0),
                    contentView.widthAnchor.constraint(equalToConstant: size.width),]
            case .contentHeight(let maxSize):
                Swift.print("Missing", maxSize ?? "")
                var size: CGSize? = nil
                if let imageSize = contentView.image?.size, imageSize != .zero {
                    size = imageSize
                }
                
                if let viewSize = contentView.view?.intrinsicContentSize, viewSize != .zero {
                    if let _size = size {
                        size = CGSize(max(_size.width, viewSize.width), max(_size.height, viewSize.height))
                    } else {
                        size = viewSize
                    }
                }
                
                if let maxSize = maxSize, let _size = size {
                    size = CGSize(max(_size.width, maxSize.width), max(_size.height, maxSize.height))
                }
                
                if let size = size {
                    contentViewConstraints = [
                        contentView.heightAnchor.constraint(equalToConstant:  size.height),
                        contentView.widthAnchor.constraint(equalToConstant: size.width),
                        contentView.centerYAnchor.constraint(equalTo: textStackView.centerYAnchor, constant: 0.0),
                    ]
                }
            case .textAndSecondaryTextHeight:
                contentViewConstraints = [
                    contentView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 0.0),
                    contentView.bottomAnchor.constraint(equalTo: secondaryTextField.bottomAnchor, constant: 0.0),
                    contentView.widthAnchor.constraint(equalTo: contentView.heightAnchor, constant: 0.0),
                ]
            }
            NSLayoutConstraint.activate(contentViewConstraints)
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
            self.addSubview(withConstraint: containerView)
            self._constraints = containerView.addSubview(withConstraint: stackView)
            self.updateConfiguration(with: configuration)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
}

internal extension NSTableCellContentConfiguration.ContentView {
    class TableCellContentView: NSView {
        var imageView: NSImageView?
        
        var view: NSView? {
            didSet {
                if oldValue != self.view {
                    oldValue?.removeFromSuperview()
                    if let newView = self.view {
                        self.addSubview(withConstraint: newView)
                    }
                }
                
            }
        }
        var image: NSImage? {
            didSet {
                if let image = self.image {
                    if self.imageView == nil {
                        self.imageView = NSImageView(image: image)
                        self.update()
                    }
                } else {
                    self.imageView?.image = nil
                }
            }
        }
        
        var properties: NSTableCellContentConfiguration.ContentProperties {
            didSet {
                if oldValue != self.properties {
                self.update() }
            }
        }
        
        override func layout() {
            super.layout()
            self.updateShape()
        }
        
        internal func updateShape() {
            switch properties.shape {
            case .circle:
                self.cornerRadius = self.frame.size.height/2.0
            case .roundedRectangular(let cornerRadius):
                self.cornerRadius = cornerRadius
            case .rectangular:
                self.cornerRadius = 0.0
            }
        }
        
        internal func update() {
            self.backgroundColor = properties.resolvedBackgroundColor()
            self.updateShape()
            self.borderColor = properties.resolvedBorderColor()
            self.borderWidth = properties.borderWidth
            self.imageView?.imageScaling = properties.imageScaling.nsImageScaling
            self.imageView?.contentTintColor = properties.resolvedImageTintColor()
            self.layer?.shadowOffset = CGSize(properties.shadowProperties.offset.x, properties.shadowProperties.offset.y)
            self.layer?.shadowColor = properties.shadowProperties.color?.withAlphaComponent(self.properties.shadowProperties.opacity).cgColor
            self.layer?.shadowRadius = properties.shadowProperties.radius
        }
        
        init(properties: NSTableCellContentConfiguration.ContentProperties) {
            self.properties = properties
            super.init(frame: .zero)
            self.maskToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
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


