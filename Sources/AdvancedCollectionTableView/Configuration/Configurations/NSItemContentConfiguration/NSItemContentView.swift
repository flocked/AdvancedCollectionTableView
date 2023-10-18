//
//  ItemContentView.swift
//  ItemConfiguration
//
//  Created by Florian Zand on 07.08.23.
//

import AppKit
import FZUIKit

/// A content view for displaying collection item-based content.
public class NSItemContentView: NSView, NSContentView {
    /// Creates an item content view with the specified content configuration.
    public init(configuration: NSItemContentConfiguration) {
        self.appliedConfiguration = configuration
        super.init(frame: .zero)
        self.isOpaque = false
        self.maskToBounds = false
        self.stackviewConstraints = self.addSubview(withConstraint: stackView)
        self.updateConfiguration()
    }
    
    /// The current configuration of the view.
    public var configuration: NSContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newValue = newValue as? NSItemContentConfiguration else { return }
            self.appliedConfiguration = newValue
        }
    }
    
    /// Determines whether the view is compatible with the provided configuration.
    public func supports(_ configuration: NSContentConfiguration) -> Bool {
        configuration is NSItemContentConfiguration
    }
    
    func calculateContentViewFrame(remaining: CGRect) -> CGRect {
        var frame = remaining
        if let imageSize = appliedConfiguration.image?.size {
            switch appliedConfiguration.contentProperties.imageScaling {
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
        let maxWidth = appliedConfiguration.contentProperties.maximumWidth
        let maxHeight = appliedConfiguration.contentProperties.maximumHeight
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
        let contentRegion = self.bounds.inset(by: appliedConfiguration.margins)
        var remainingRegion = contentRegion
        if appliedConfiguration.hasContent {
            if let imageSize = appliedConfiguration.image?.size, appliedConfiguration.contentProperties.imageScaling == .fit {
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
        let contentRegion = self.bounds.inset(by: appliedConfiguration.margins)
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
            if let imageSize = appliedConfiguration.image?.size, appliedConfiguration.contentProperties.imageScaling == .fit {
                var contentRect: CGRect = .zero
                contentRect.size = imageSize.scaled(toHeight: remainingRegion.height)
                contentRect.center = remainingRegion.center
            } else {
                let contentRect = remainingRegion
            }
        }
    }
    
    internal lazy var textField = ItemTextField(properties: appliedConfiguration.textProperties)
    internal lazy var secondaryTextField = ItemTextField(properties: appliedConfiguration.secondaryTextProperties)
    internal lazy var contentView = ItemContentView(configuration: appliedConfiguration)
    
    internal lazy var textStackView: NSStackView = {
        let stackView = NSStackView(views: [textField, secondaryTextField])
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = appliedConfiguration.textToSecondaryTextPadding
        return stackView
    }()
    
    internal lazy var stackView: NSStackView = {
        let stackView = NSStackView(views: [contentView, textStackView])
        stackView.orientation = appliedConfiguration.contentPosition.orientation
        stackView.alignment = appliedConfiguration.contentAlignment
        stackView.spacing = appliedConfiguration.contentToTextPadding
        return stackView
    }()
    
    internal var stackviewConstraints: [NSLayoutConstraint] = []
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var appliedConfiguration: NSItemContentConfiguration {
        didSet {
            guard oldValue != self.appliedConfiguration else { return }
            self.updateConfiguration()
        }
    }
    
    internal func updateConfiguration() {
        contentView.centerYConstraint?.activate(false)
        
      //  contentView.backgroundColor = .red
      //  Swift.print("item has", appliedConfiguration.hasContent)
        
        textField.properties = appliedConfiguration.textProperties
        textField.updateText(appliedConfiguration.text, appliedConfiguration.attributedText)
        secondaryTextField.properties = appliedConfiguration.secondaryTextProperties
        secondaryTextField.updateText(appliedConfiguration.secondaryText, appliedConfiguration.secondaryAttributedText)
        
        contentView.configuration = appliedConfiguration
        textStackView.spacing = appliedConfiguration.textToSecondaryTextPadding
        stackView.spacing = appliedConfiguration.contentToTextPadding
        stackView.orientation = appliedConfiguration.contentPosition.orientation
        stackView.alignment = appliedConfiguration.contentAlignment
        if appliedConfiguration.contentPosition.contentIsLeading, stackView.arrangedSubviews.first != contentView {
            stackView.removeArrangedSubview(textStackView)
            stackView.addArrangedSubview(textStackView)
        } else if appliedConfiguration.contentPosition.contentIsLeading == false, stackView.arrangedSubviews.last != contentView {
            stackView.removeArrangedSubview(contentView)
            stackView.addArrangedSubview(contentView)
        }
        stackviewConstraints.constant(appliedConfiguration.margins)
        if appliedConfiguration.contentPosition.isFirstBaseline, appliedConfiguration.image?.isSymbolImage == false {
            if appliedConfiguration.hasText {
                contentView.centerYConstraint = contentView.centerYAnchor.constraint(equalTo: textField.firstBaselineAnchor).activate()
            } else if appliedConfiguration.hasSecondaryText {
                contentView.centerYConstraint = contentView.centerYAnchor.constraint(equalTo: secondaryTextField.firstBaselineAnchor).activate()
            }
        }
        contentView.invalidateIntrinsicContentSize()
    }
}
