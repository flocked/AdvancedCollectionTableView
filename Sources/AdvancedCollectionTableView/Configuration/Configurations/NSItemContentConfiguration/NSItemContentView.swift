//
//  NSItemContentView.swift
//
//
//  Created by Florian Zand on 07.08.23.
//

import AppKit
import FZUIKit

/**
 A content view for displaying collection-based item content.
 
 You use a list content view for displaying list-based content in a custom view hierarchy. You can embed a list content view manually in a custom cell or in a container view, like a [NSStackView](https://developer.apple.com/documentation/appkit/nsstackview). You can use Auto Layout or manual layout techniques to size and position the view.
 
 A item content view relies on its item content configuration to supply its styling and content. You create a item content view by passing in a ``NSItemContentConfiguration`` to ``init(configuration:)``. To update the content view, you set a new configuration on it through its ``configuration`` property.
 
 If you’re using a ``AppKit/NSCollectionView`` or ``AppKit/NSTableView``, you don’t need to manually create a item content view to take advantage of the item configuration. Instead, you assign a ``NSItemContentConfiguration`` to the ``AppKit/NSCollectionViewItem/contentConfiguration`` property of the collection view items or table view cells.
 */
open class NSItemContentView: NSView, NSContentView, EditingContentView {
    
    /// Creates an item content view with the specified content configuration.
    public init(configuration: NSItemContentConfiguration) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
        isOpaque = false
        wantsLayer = true
        clipsToBounds = false
        stackviewConstraints = addSubview(withConstraint: stackView)
        updateConfiguration()
    }

    /// The current configuration of the view.
    open var configuration: NSContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newValue = newValue as? NSItemContentConfiguration else { return }
            appliedConfiguration = newValue
        }
    }

    /**
     Determines whether the view is compatible with the provided configuration.

     Returns `true` if the configuration is ``NSItemContentConfiguration``, or `false` if not.
     */
    open func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSItemContentConfiguration
    }
    
    func isHovering(at location: CGPoint) -> Bool {
        return (contentView.frame.contains(location) && contentView.isHidden == false) ||
        CGRect(0, 0, max(textField.bounds.width, secondaryTextField.bounds.width), contentView.frame.y).contains(location)
        /*
        return contentView.frame.contains(location) ||
        (textField.isHidden == false && textField.frame.contains(location)) ||
        (secondaryTextField.isHidden == false && secondaryTextField.frame.contains(location))
         */
    }
    
    /// Returns the farthest descendant of the view in the view hierarchy (including itself) that contains a specified point, or `nil if that point lies completely outside the view.
    open override func hitTest(_ point: NSPoint) -> NSView? {
        let view = super.hitTest(point)
        if ((view == contentView || view?.isDescendant(of: contentView) == true) && contentView.isHidden == false) || (view == textField && textField.isHidden == false) || (view == secondaryTextField && secondaryTextField.isHidden == false) {
            return view
        }
        return nil
    }

    let textField = ListItemTextField.wrapping().truncatesLastVisibleLine(true)
    let secondaryTextField = ListItemTextField.wrapping().truncatesLastVisibleLine(true)
    lazy var contentView = ItemContentView(configuration: appliedConfiguration)
    var textFieldAlignment: NSTextAlignment?
    var secondaryTextFieldAlignment: NSTextAlignment?
    var textFieldConstraint: NSLayoutConstraint?
    var secondaryTextFieldConstraint: NSLayoutConstraint?

    lazy var textStackView = NSStackView(views: [textField, secondaryTextField]).orientation(.vertical).alignment(.leading).spacing(appliedConfiguration.textToSecondaryTextPadding)

    lazy var stackView = NSStackView(views: [contentView, textStackView])
        .orientation(appliedConfiguration.contentPosition.orientation)
        .alignment(appliedConfiguration.contentAlignment)
        .spacing(appliedConfiguration.contentToTextPadding)

    var stackviewConstraints: [NSLayoutConstraint] = []
    var _scaleTransform: Scale = .none
    var _rotation: Rotation = .zero

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var appliedConfiguration: NSItemContentConfiguration {
        didSet{
            guard oldValue != appliedConfiguration else { return }
            updateConfiguration()
        }
    }

    var tableCellView: NSTableCellView? {
        firstSuperview(for: NSTableCellView.self)
    }

    var tableRowView: NSTableRowView? {
        firstSuperview(for: NSTableRowView.self)
    }

    var collectionViewItem: NSCollectionViewItem? {
        firstSuperview(where: { $0.parentController is NSCollectionViewItem })?.parentController as? NSCollectionViewItem
    }

    func updateConfiguration() {
        contentView.centerYConstraint?.activate(false)

        textField.properties = appliedConfiguration.textProperties
        textField.updateText(appliedConfiguration.text, appliedConfiguration.attributedText, appliedConfiguration.placeholderText, appliedConfiguration.attributedPlaceholderText)
        secondaryTextField.properties = appliedConfiguration.secondaryTextProperties
        secondaryTextField.updateText(appliedConfiguration.secondaryText, appliedConfiguration.secondaryAttributedText, appliedConfiguration.secondaryPlaceholderText, appliedConfiguration.secondaryAttributedPlaceholderText)
        textField.isEnabled = firstSuperview(for: NSCollectionView.self)?.isEnabled ?? true
        secondaryTextField.isEnabled = textField.isEnabled

        if appliedConfiguration.scaleTransform != _scaleTransform {
            _scaleTransform = appliedConfiguration.scaleTransform
            scale = _scaleTransform
        }
        if appliedConfiguration.rotation != _rotation {
            _rotation = appliedConfiguration.rotation
            rotation = _rotation
        }
        
        contentView.configuration = appliedConfiguration
        textStackView.spacing = appliedConfiguration.textToSecondaryTextPadding
        stackView.spacing = appliedConfiguration.contentToTextPadding
        stackView.orientation = appliedConfiguration.contentPosition.orientation
        stackView.alignment = appliedConfiguration.contentAlignment
        stackView.arrangedViews = appliedConfiguration.contentPosition.contentIsLeading ? [contentView, textStackView] : [textStackView, contentView]
        stackView.addArrangedSubview(appliedConfiguration.contentPosition.contentIsLeading ? textStackView : contentView)
        stackviewConstraints.constant(appliedConfiguration.margins)
        if appliedConfiguration.contentPosition.isFirstBaseline, appliedConfiguration.image?.isSymbolImage == false {
            if appliedConfiguration.hasText {
                contentView.centerYConstraint = contentView.centerYAnchor.constraint(equalTo: textField.firstBaselineAnchor).activate()
            } else if appliedConfiguration.hasSecondaryText {
                contentView.centerYConstraint = contentView.centerYAnchor.constraint(equalTo: secondaryTextField.firstBaselineAnchor).activate()
            }
        }
        toolTip = appliedConfiguration.toolTip
        contentView.invalidateIntrinsicContentSize()
        textField.drawsBackground = true
        
        if textFieldAlignment != appliedConfiguration.textProperties.alignment {
            textFieldAlignment = appliedConfiguration.textProperties.alignment
            textFieldConstraint?.activate(false)
            switch appliedConfiguration.textProperties.alignment {
            case .center:
                textFieldConstraint = textField.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).activate()
            case .right:
                textFieldConstraint = textField.rightAnchor.constraint(equalTo: stackView.rightAnchor).activate()
            default:
                textFieldConstraint = textField.leftAnchor.constraint(equalTo: stackView.leftAnchor).activate()
            }
        }
        
        if secondaryTextFieldAlignment != appliedConfiguration.secondaryTextProperties.alignment {
            secondaryTextFieldAlignment = appliedConfiguration.secondaryTextProperties.alignment
            secondaryTextFieldConstraint?.activate(false)
            switch appliedConfiguration.secondaryTextProperties.alignment {
            case .center:
                secondaryTextFieldConstraint = secondaryTextField.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).activate()
            case .right:
                secondaryTextFieldConstraint = secondaryTextField.rightAnchor.constraint(equalTo: stackView.rightAnchor).activate()
            default:
                secondaryTextFieldConstraint = secondaryTextField.leftAnchor.constraint(equalTo: stackView.leftAnchor).activate()
            }
        }
    }
}
