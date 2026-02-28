//
//  SimpleListContentView.swift
//  
//
//  Created by Florian Zand on 21.02.26.
//

import AppKit
import FZUIKit

///  A content view for displaying simple list-based item content.
open class SimpleListContentView: NSView, NSContentView {
    var appliedConfiguration: SimpleListContentConfiguration
    let textField = NSTextField(labelWithString: "")
    let imageView = NSImageView()
    var shouldUpdateTableCellView = false
    
    open override func layout() {
        super.layout()
        
        Swift.print(textField.stringValue, textField.frame)
    }
    
    /// The current configuration of the view.
    open var configuration: any NSContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let configuration = newValue as? SimpleListContentConfiguration else { return }
            guard configuration != appliedConfiguration else { return }
            appliedConfiguration = configuration
            updateConfiguration()
        }
    }
    
    func updateConfiguration() {
        if let symbolConfiguration = appliedConfiguration.imageTintColor?.configuration {
            imageView.image = appliedConfiguration.image?.applyingSymbolConfiguration(symbolConfiguration)
        } else {
            imageView.image = appliedConfiguration.image
        }
        imageView.image = appliedConfiguration.image
        imageView.contentTintColor = appliedConfiguration.imageTintColor?.color
        textField.textColor = appliedConfiguration.resolvedTextColor()
        if let attributedText = appliedConfiguration.attributedText {
            textField.attributedStringValue = attributedText.nsAttributedString
        } else {
            textField.stringValue = appliedConfiguration.text ?? ""
        }
        tableCellView?.imageView = appliedConfiguration.image != nil ? imageView : nil
    }
    
    /// Creates a list content view with the specified content configuration.
    public init(configuration: SimpleListContentConfiguration) {
        self.appliedConfiguration = configuration
        super.init(frame: .zero)
        frame.size = CGSize(width: 100, height: 17)
        autoresizingMask = .all
        imageView.frame = CGRect(x: 3, y: 0, width: 17, height: 17)
        imageView.autoresizingMask = [.minXMargin, .maxYMargin]
        imageView.imageScaling = .scaleProportionallyDown
        textField.frame = CGRect(x: 25, y: 0, width: 75, height: 17)
        textField.autoresizingMask = [.minXMargin, .maxXMargin, .width, .maxYMargin]
        textField.font = .systemFont(ofSize: 13)
        textField.textColor = .controlTextColor
        textField.lineBreakMode = .byTruncatingTail
        textField.maximumNumberOfLines = 1
        addSubview(imageView)
        addSubview(textField)
        updateConfiguration()
    }
    
    var tableCellView: NSTableCellView? {
        shouldUpdateTableCellView ? superview as? NSTableCellView : nil
    }
        
    public override func viewWillMove(toSuperview newSuperview: NSView?) {
        if let tableCellView = tableCellView {
            if tableCellView.textField == textField {
                tableCellView.textField = nil
            }
            if tableCellView.imageView == imageView {
                tableCellView.imageView = nil
            }
        }
        shouldUpdateTableCellView = false
        guard let tableCellView = newSuperview as? NSTableCellView, tableCellView.contentView == self else { return }
        shouldUpdateTableCellView = true
        tableCellView.textField = textField
        tableCellView.imageView = appliedConfiguration.image != nil ? imageView : nil
    }
    
    public override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        guard let tableCell = superview as? NSTableCellView else { return }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
