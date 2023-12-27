//
//  NSListContentView.swift
//
//
//  Created by Florian Zand on 22.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

/// A content view for displaying list-based content.
public class NSListContentView: NSView, NSContentView {
    
    /// Creates a table cell content view with the specified content configuration.
    public init(configuration: NSListContentConfiguration) {
        _configuration = configuration
        super.init(frame: .zero)
        /*
        superviewObserver = self.observeChanges(for: \.superview) { old, new in
            guard old != new, let rowView = new as? NSTableRowView else { return }
            Swift.print("NSListContentView", rowView.contentConfiguration != nil)
        }
         */
        
        superviewObserver = self.observeChanges(for: \.superview?.superview?.superview) { old, new in
            guard old != new, let tableView = new as? NSTableView, let rowView = self.superview as? NSTableRowView, var configuration = rowView.contentConfiguration as? NSListContentConfiguration, configuration.type == .automaticRow  else { return }
            configuration = configuration.tableViewStyle(tableView.style, isGroupRow: true)
          //  Swift.print("NSListContentView", tableView.row(for: self), tableView.row(for: self.superview!))
           // Swift.print("NSListContentView", new ?? "nil")
        }
         
        
        /*
        superviewObserver = self.observeChanges(for: \.superview) { old, new in
            guard old != new, let rowView = new as? NSTableRowView else { return }
            self.rowViewSuperviewObserver = rowView.observeChanges(for: \.superview, handler: { old, new in
                guard old != new, let rowView = new as? NSTableRowView else { return }
                self.rowViewSuperviewSuperViewObserver = rowView.observeChanges(for: \.superview, handler: { old, new in
                    Swift.print("rowViewSuperviewSuperViewObserver", new ?? "nil", new?.superview ?? "nil")
                })
                Swift.print("rowViewSuperviewObserver", new ?? "nil", new?.superview ?? "nil")
            })
            if let tableView = rowView.tableView {
                Swift.print("NSListContentView", rowView.superview ?? "nil", tableView.row(for: self), tableView.row(for: rowView))
            } else {
                Swift.print("NSListContentView", rowView.superview ?? "nil")
            }
           // Swift.print("NSListContentView", new ?? "nil", (new as? NSTableRowView)?.row ?? "nil")
            
        }
         */

        initialSetup()
        updateConfiguration()
    }
    
    var superviewObserver: NSKeyValueObservation? = nil
    var rowViewSuperviewObserver: NSKeyValueObservation? = nil
    var rowViewSuperviewSuperViewObserver: NSKeyValueObservation? = nil

    
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { _configuration }
        set {
            if let newValue = newValue as? NSListContentConfiguration {
                _configuration = newValue }
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSListContentConfiguration
    }
    
    internal func initialSetup() {
        clipsToBounds = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackViewConstraints = addSubview(withConstraint: stackView)
        addSubview(stackView)
    }
    
    internal var stackViewConstraints: [NSLayoutConstraint] = []
    internal var _configuration: NSListContentConfiguration {
        didSet { if oldValue != _configuration {
            updateConfiguration() } } }
    
    internal lazy var textField = ListTextField(properties: _configuration.textProperties)
    internal lazy var secondaryTextField = ListTextField(properties: _configuration.secondaryTextProperties)
    internal lazy var imageView = ListImageView(properties: _configuration.imageProperties)
    internal var badgeView: BadgeView? = nil
    
    internal lazy var textStackView: NSStackView = {
        var stackView = NSStackView(views: [textField, secondaryTextField])
        stackView.orientation = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    internal lazy var stackView: NSStackView = {
        var stackView = NSStackView(views: [imageView, textStackView])
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        return stackView
    }()
    
    internal func updateConfiguration() {
        imageView.verticalConstraint?.activate(false)
        badgeView?.verticalConstraint?.activate(false)
        
        textField.isEnabled = _configuration.state?.isEnabled != false
        secondaryTextField.isEnabled = _configuration.state?.isEnabled != false
        textField.updateText(_configuration.text, _configuration.attributedText, _configuration.placeholderText, _configuration.attributedPlaceholderText)
        secondaryTextField.updateText(_configuration.secondaryText, _configuration.secondaryAttributedText, _configuration.secondaryPlaceholderText, _configuration.secondaryAttributedPlaceholderText)
        imageView.image = _configuration.image
        
        imageView.properties = _configuration.imageProperties
        textField.properties = _configuration.textProperties
        secondaryTextField.properties = _configuration.secondaryTextProperties
        
        textStackView.spacing = _configuration.textToSecondaryTextPadding
        stackView.spacing = _configuration.imageToTextPadding
        stackView.orientation = _configuration.imageProperties.position.orientation
        stackView.alignment = _configuration.imageProperties.position.alignment
        
        if _configuration.imageProperties.position.imageIsLeading,  stackView.arrangedSubviews.first != imageView {
            stackView.removeArrangedSubview(textStackView)
            stackView.addArrangedSubview(textStackView)
        } else if _configuration.imageProperties.position.imageIsLeading == false,  stackView.arrangedSubviews.last != imageView {
            stackView.removeArrangedSubview(imageView)
            stackView.addArrangedSubview(imageView)
        }
        
        stackViewConstraints.constant(_configuration.margins)
        
        if _configuration.hasBadge, _configuration.imageProperties.position.orientation == .horizontal, let badge = _configuration.badge {
            if badgeView == nil {
                badgeView = BadgeView(properties: badge)
            }
            guard let badgeView = badgeView else { return }
            badgeView.properties = badge
            if badge.position == .leading, stackView.arrangedSubviews.first != badgeView {
                badgeView.removeFromSuperview()
                stackView.insertArrangedSubview(badgeView, at: 0)
                stackView.setCustomSpacing(_configuration.textToBadgePadding, after: badgeView)
                stackView.setCustomSpacing(NSStackView.useDefaultSpacing, after: textStackView)
            } else if badge.position == .trailing, stackView.arrangedSubviews.last != badgeView {
                badgeView.removeFromSuperview()
                stackView.addArrangedSubview(badgeView)
                stackView.setCustomSpacing(_configuration.textToBadgePadding, after: textStackView)
                stackView.setCustomSpacing(NSStackView.useDefaultSpacing, after: badgeView)
            }
        } else {
            badgeView?.removeFromSuperview()
            badgeView = nil
            stackView.setCustomSpacing(NSStackView.useDefaultSpacing, after: textStackView)
        }
        
        imageView.calculatedSize = calculateImageViewSize()
        imageView.invalidateIntrinsicContentSize()
        
        switch _configuration.imageProperties.position {
        case .leading(let value), .trailing(let value):
            switch value {
            case .bottom:
                imageView.verticalConstraint = imageView.bottomAnchor.constraint(equalTo: textStackView.bottomAnchor).activate()
            case .center:
                imageView.verticalConstraint = imageView.centerYAnchor.constraint(equalTo: textStackView.centerYAnchor).activate()
            case .top:
                imageView.verticalConstraint = imageView.topAnchor.constraint(equalTo: textStackView.topAnchor).activate()
            case .firstBaseline:
                if _configuration.image?.isSymbolImage == true {
                    if _configuration.hasText {
                        imageView.verticalConstraint = imageView.firstBaselineAnchor.constraint(equalTo: textField.firstBaselineAnchor)
                    } else if _configuration.hasSecondaryText {
                        imageView.verticalConstraint = imageView.firstBaselineAnchor.constraint(equalTo: secondaryTextField.firstBaselineAnchor)
                    }
                } else {
                    if _configuration.hasText {
                        //  var offset = textField.font!.capHeight / 2.0
                        let offset = (textField.font!.ascender + textField.font!.descender) / 2.0
                        imageView.verticalConstraint = imageView.centerYAnchor.constraint(equalTo: textField.firstBaselineAnchor, constant: -offset).activate()
                    } else if _configuration.hasSecondaryText {
                        // var offset = secondaryTextField.font!.capHeight / 2.0
                        let offset = (secondaryTextField.font!.ascender + secondaryTextField.font!.descender) / 2.0
                        imageView.verticalConstraint = imageView.centerYAnchor.constraint(equalTo: secondaryTextField.firstBaselineAnchor, constant: -offset).activate()
                    }
                }
            }
        default: break
        }
    }
    
    internal func calculateTextFieldsSize(imageSize: CGSize?) -> CGSize {
        var textFieldsSize: CGSize = .zero
        textFieldsSize.width = frame.size.width-_configuration.margins.width
        if _configuration.imageProperties.position.orientation == .horizontal, let imageSize = imageSize {
            textFieldsSize.width = textFieldsSize.width - imageSize.width - _configuration.imageToTextPadding
        }
        textField.frame.size.width = textFieldsSize.width
        secondaryTextField.frame.size.width = textFieldsSize.width
        if _configuration.hasSecondaryText {
            textFieldsSize.height = secondaryTextField.intrinsicContentSize.height
            if _configuration.hasText {
                textFieldsSize.height += _configuration.textToSecondaryTextPadding
            }
        }
        if _configuration.hasText {
            textFieldsSize.height += textField.intrinsicContentSize.height
        }
        return textFieldsSize
    }
    
    internal func calculateImageViewSize() -> CGSize? {
        if let image = _configuration.image {
            var imageSize = image.size
            switch _configuration.imageProperties.sizing {
            case .firstTextHeight:
                if _configuration.hasText {
                    return scaleImageSize(imageSize, to: textField.intrinsicContentSize)
                } else if _configuration.hasSecondaryText {
                    return scaleImageSize(imageSize, to: secondaryTextField.intrinsicContentSize)
                } else {
                    let width = frame.size.width - _configuration.margins.width
                    if imageSize.width > width {
                        imageSize = imageSize.scaled(toWidth: width)
                    }
                    return imageSize
                }
            case .totalTextHeight:
                if _configuration.hasText && _configuration.hasSecondaryText {
                    var size = textField.intrinsicContentSize
                    size.height += secondaryTextField.intrinsicContentSize.height
                    size.height += _configuration.textToSecondaryTextPadding
                    return scaleImageSize(imageSize, to: size)
                } else if _configuration.hasText {
                    return scaleImageSize(imageSize, to: textField.intrinsicContentSize)
                } else if _configuration.hasSecondaryText {
                    return scaleImageSize(imageSize, to: secondaryTextField.intrinsicContentSize)
                } else {
                    let width = frame.size.width - _configuration.margins.width
                    if imageSize.width > width {
                        imageSize = imageSize.scaled(toWidth: width)
                    }
                    return imageSize
                }
            case .size(let size):
                var size = size
                let width = frame.size.width - _configuration.margins.width
                if size.width > width {
                    size.width = width
                }
                return size
            case .maxiumSize(width: let maxWidth, height: let maxHeight):
                if let maxWidth = maxWidth, imageSize.width > maxWidth, let maxHeight = maxHeight, imageSize.height > maxHeight {
                    imageSize = imageSize.scaled(toFit: CGSize(maxWidth, maxHeight))
                } else if let maxWidth = maxWidth, imageSize.width > maxWidth {
                    imageSize = imageSize.scaled(toWidth: maxWidth)
                } else if let maxHeight = maxHeight, imageSize.height > maxHeight {
                    imageSize = imageSize.scaled(toHeight: maxHeight)
                }
                let width = frame.size.width - _configuration.margins.width
                if imageSize.width > width {
                    imageSize = imageSize.scaled(toWidth: width)
                }
                return imageSize
            default:
                let width = frame.size.width - _configuration.margins.width
                if imageSize.width > width {
                    imageSize = imageSize.scaled(toWidth: width)
                }
                return imageSize
            }
        }
        return nil
    }
    
    internal func scaleImageSize(_ imageSize: CGSize, to size: CGSize) -> CGSize {
        switch _configuration.imageProperties.scaling {
       // case .fill, .fit: return imageSize.scaled(toHeight: size.height)
        case .fit: return imageSize.scaled(toHeight: size.height)
        default: return CGSize(size.height, size.height)
        }
    }
    
    internal var rowView: NSTableRowView? {
        superview?.superview as? NSTableRowView
    }
    
    public override func layout() {
        super.layout()
        updateRowHeight()
    }
    
    internal func updateRowHeight() {
        if let rowView = rowView, frame.size.height > fittingSize.height {
            rowView.frame.size.height = fittingSize.height
        }
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
