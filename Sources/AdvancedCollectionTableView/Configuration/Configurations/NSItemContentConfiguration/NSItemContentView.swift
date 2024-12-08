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
 
 You use a list content view for displaying list-based content in a custom view hierarchy. You can embed a list content view manually in a custom cell or in a container view, like a `NSStackView`. You can use Auto Layout or manual layout techniques to size and position the view, and its height adjusts dynamically according to its width and the space it needs to display its content.
 
 A list content view relies on its list content configuration to supply its styling and content. You create a list content view by passing in a ``NSItemContentConfiguration`` to ``init(configuration:)``. To update the content view, you set a new configuration on it through its ``configuration`` property.
 
 If you’re using a `NSCollectionView` or `NSTableView`, you don’t need to manually create a list content view to take advantage of the list configuration. Instead, you assign a ``NSItemContentConfiguration`` to the ``AppKit/NSCollectionViewItem/contentConfiguration`` property of the collection view items or table view cells.
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

    ///
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
    }
}

extension NSItemContentView {
    func calculateContentViewFrame(remaining: CGRect) -> CGRect {
        var frame = remaining
        if let imageSize = appliedConfiguration.image?.size {
            switch appliedConfiguration.imageProperties.scaling {
            case .fit:
                frame.size = imageSize.scaled(toHeight: remaining.height)
            case .fill, .resize:
                if appliedConfiguration.contentPosition.orientation == .vertical {
                    frame = remaining
                } else {
                    frame.size = CGSize(remaining.height, remaining.height)
                }
            case .none:
                frame.size = imageSize
            }
        }
        var maxWidth = appliedConfiguration.contentProperties.maximumSize.width
        var maxHeight = appliedConfiguration.contentProperties.maximumSize.height
        if appliedConfiguration.contentProperties.maximumSize.mode == .relative {
            if let _maxWidth = maxWidth {
                maxWidth = _maxWidth * frame.width
            }
            if let _maxHeight = maxHeight {
                maxHeight = _maxHeight * frame.height
            }
        }

        if let maxWidth = maxWidth, let maxHeight = maxHeight, frame.width > maxWidth, frame.height > maxHeight {
            frame = frame.scaled(toFit: CGSize(maxWidth, maxHeight))
        } else if let maxWidth = maxWidth, frame.width > maxWidth {
            frame = frame.scaled(toWidth: maxWidth)
        } else if let maxHeight = maxHeight, frame.height > maxHeight {
            frame = frame.scaled(toHeight: maxHeight)
        }

        return frame
    }

    func horizontalTest() {
        let contentRegion = bounds.inset(by: appliedConfiguration.margins)
        var remainingRegion = contentRegion
        if appliedConfiguration.hasContent {
            if let imageSize = appliedConfiguration.image?.size, appliedConfiguration.imageProperties.scaling == .fit {
                let resized = imageSize.scaled(toHeight: remainingRegion.height)
                let contentRectArea = remainingRegion.divided(atDistance: resized.width, from: .minXEdge)
                remainingRegion = contentRectArea.remainder
                if appliedConfiguration.hasText || appliedConfiguration.hasSecondaryText {
                    remainingRegion = remainingRegion.offsetBy(dx: appliedConfiguration.contentToTextPadding, dy: 0)
                }
            } else {
                // let contentRect = remainingRegion
            }
        }
    }

    func test() {
        let contentRegion = bounds.inset(by: appliedConfiguration.margins)
        var remainingRegion = contentRegion
        if appliedConfiguration.hasSecondaryText, let height = secondaryTextField.cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: contentRegion.width, height: 10000)).height {
            let secondaryTextFieldArea = contentRegion.divided(atDistance: height, from: .maxYEdge)
            remainingRegion = secondaryTextFieldArea.remainder
            if appliedConfiguration.hasText {
                remainingRegion = remainingRegion.offsetBy(dx: 0, dy: appliedConfiguration.textToSecondaryTextPadding)
            } else if appliedConfiguration.hasContent {
                remainingRegion = remainingRegion.offsetBy(dx: 0, dy: appliedConfiguration.contentToTextPadding)
            }
        }
        if appliedConfiguration.hasText, let height = textField.cell?.cellSize(forBounds: NSRect(x: 0, y: 0, width: contentRegion.width, height: 10000)).height {
            let textFieldArea = contentRegion.divided(atDistance: height, from: .maxYEdge)
            remainingRegion = textFieldArea.remainder
            if appliedConfiguration.hasContent {
                remainingRegion = remainingRegion.offsetBy(dx: 0, dy: appliedConfiguration.contentToTextPadding)
            }
        }
        if appliedConfiguration.hasContent {
            if let imageSize = appliedConfiguration.image?.size, appliedConfiguration.imageProperties.scaling == .fit {
                var contentRect: CGRect = .zero
                contentRect.size = imageSize.scaled(toHeight: remainingRegion.height)
                contentRect.center = remainingRegion.center
            } else {
                // let contentRect = remainingRegion
            }
        }
    }
}
