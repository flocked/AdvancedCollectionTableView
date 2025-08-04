//
//  NSItemContentView.swift
//
//
//  Created by Florian Zand on 07.08.23.
//

import AppKit
import FZUIKit
import FZSwiftUtils

/**
 A content view for displaying collection-based item content.
 
 You use a list content view for displaying list-based content in a custom view hierarchy. You can embed a list content view manually in a custom cell or in a container view, like a [NSStackView](https://developer.apple.com/documentation/appkit/nsstackview). You can use Auto Layout or manual layout techniques to size and position the view.
 
 A item content view relies on its item content configuration to supply its styling and content. You create a item content view by passing in a ``NSItemContentConfiguration`` to ``init(configuration:)``. To update the content view, you set a new configuration on it through its ``configuration`` property.
 
 If you’re using a [NSCollectionView](https://developer.apple.com/documentation/appkit/nscollectionview) or [NSTableView](https://developer.apple.com/documentation/appkit/nstableview), you don’t need to manually create a item content view to take advantage of the item configuration. Instead, you assign a ``NSItemContentConfiguration`` to the ``AppKit/NSCollectionViewItem/contentConfiguration`` property of the collection view items or table view cells.
 */
open class NSItemContentView: NSView, NSContentView, EditingContentView {
    
    /// Creates an item content view with the specified content configuration.
    public init(configuration: NSItemContentConfiguration) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
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
    
    /**
     A guide for positioning the primary text in the content view.
     
     If the configuration doesn’t specify primary text, the value of this property is `nil`.
     
     If you apply a new configuration without primary text to the content view, the system removes this layout guide from the view and deactivates any constraints associated with it.
     */
    public var textLayoutGuide: NSLayoutGuide? { textStackView.textField.layoutGuide }
    
    /**
     A guide for positioning the secondary text in the content view.
     
     If the configuration doesn’t specify secondary text, the value of this property is `nil`.
     
     If you apply a new configuration without secondary text to the content view, the system removes this layout guide from the view and deactivates any constraints associated with it.
     */
    public var secondaryTextLayoutGuide: NSLayoutGuide? { textStackView.secondaryTextField.layoutGuide }
    
    /**
     A guide for positioning the image or view in the content view.
     
     If the configuration doesn’t specify an image or view, the value of this property is `nil`.
     
     If you apply a new configuration without image or view to the content view, the system removes this layout guide from the view and deactivates any constraints associated with it.
     */
    public internal(set) var contentLayoutGuide: NSLayoutGuide?
    
    func isHovering(at location: CGPoint) -> Bool {
        return (contentView.frame.contains(location) && contentView.isHidden == false) ||
        CGRect(0, 0, max(textField.bounds.width, secondaryTextField.bounds.width), contentView.frame.y).contains(location)
        /*
        return contentView.frame.contains(location) ||
        (textField.isHidden == false && textField.frame.contains(location)) ||
        (secondaryTextField.isHidden == false && secondaryTextField.frame.contains(location))
         */
    }
    
    open override func hitTest(_ point: NSPoint) -> NSView? {
        let view = super.hitTest(point)
        if let view = view, (view.isDescendant(of: contentView) && !contentView.isHidden) || (view == textField && !textField.isHidden) || (view == secondaryTextField && !secondaryTextField.isHidden) {
            return view
        }
        return nil
    }
    
    public func check(_ rect: CGRect) -> Bool {
        (rect.intersects(contentView.frame) && !contentView.isHidden) || (rect.intersects(textField.frame) && !textField.isHidden)  || (rect.intersects(secondaryTextField.frame) && !secondaryTextField.isHidden)
    }

    var textField: ListItemTextField { textStackView.textField }
    var secondaryTextField: ListItemTextField { textStackView.secondaryTextField }
    lazy var contentView = ItemContentView(configuration: appliedConfiguration)
    var textFieldAlignment: NSTextAlignment?
    var secondaryTextFieldAlignment: NSTextAlignment?
    var textFieldConstraint: NSLayoutConstraint?
    var secondaryTextFieldConstraint: NSLayoutConstraint?

    lazy var textStackView = TextStackView()

    lazy var stackView = NSStackView(views: [contentView, textStackView])
        .orientation(appliedConfiguration.contentPosition.orientation)
        .alignment(appliedConfiguration.contentAlignment)
        .spacing(appliedConfiguration.contentToTextPadding)

    var stackviewConstraints: [NSLayoutConstraint] = []

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
        let isAnimating = NSAnimationContext.hasActiveGrouping && NSAnimationContext.current.duration > 0.0
        contentView.centerYConstraint?.activate(false)
        
        textStackView.update(with: appliedConfiguration, for: self)

        _scaleTransform = appliedConfiguration.scaleTransform
        _rotation = appliedConfiguration.rotation

        animator(isAnimating).alphaValue = appliedConfiguration.alpha
        
        contentView.configuration = appliedConfiguration
        stackView.animator(isAnimating).spacing = appliedConfiguration.contentToTextPadding
        stackView.animator(isAnimating).orientation = appliedConfiguration.contentPosition.orientation
        stackView.animator(isAnimating).alignment = appliedConfiguration.contentAlignment
        stackView.animator(isAnimating).arrangedViews = appliedConfiguration.contentPosition.contentIsLeading ? [contentView, textStackView] : [textStackView, contentView]
        stackviewConstraints.constant(appliedConfiguration.margins, animated: isAnimating)
        if appliedConfiguration.contentPosition.isFirstBaseline, appliedConfiguration.image?.isSymbolImage == false {
            if appliedConfiguration.hasText {
                contentView.centerYConstraint = contentView.centerYAnchor.constraint(equalTo: textField.firstBaselineAnchor).activate()
            } else if appliedConfiguration.hasSecondaryText {
                contentView.centerYConstraint = contentView.centerYAnchor.constraint(equalTo: secondaryTextField.firstBaselineAnchor).activate()
            }
        }
        toolTip = appliedConfiguration.toolTip
        contentView.invalidateIntrinsicContentSize()
                        
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
        updateLayoutGuides()
    }
    
    func updateLayoutGuides() {
       if !appliedConfiguration.hasContent, let guide = contentLayoutGuide {
           removeLayoutGuide(guide)
           contentLayoutGuide = nil
       } else if appliedConfiguration.hasContent, contentLayoutGuide == nil {
           contentLayoutGuide = NSLayoutGuide()
           addLayoutGuide(contentLayoutGuide!)
           contentLayoutGuide?.constraint(to: contentView)
       }
    }
}
