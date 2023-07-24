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
    internal lazy var textField: ItemTextField = ItemTextField(properties: appliedConfiguration.textProperties)
    internal lazy var secondaryTextField: ItemTextField = ItemTextField(properties: appliedConfiguration.secondaryTextProperties)
    internal lazy var contentView: ItemContentView = ItemContentView(properties: appliedConfiguration)
    
    internal var previousSize: CGSize? = nil
    public override func layout() {
        super.layout()
        Swift.print("layout", self.appliedConfiguration.text ?? "", self.frame)
        guard previousSize != self.frame.size else { return }
        previousSize = self.frame.size
        
        let width = self.frame.size.width - appliedConfiguration.padding.width
        var height = self.frame.size.height - appliedConfiguration.padding.height
        
        if (appliedConfiguration.hasText || appliedConfiguration.hasSecondaryText) {
            height -= appliedConfiguration.contentToTextPadding
        }
        
        if (appliedConfiguration.hasText && appliedConfiguration.hasSecondaryText) {
            height -= appliedConfiguration.textToSecondaryTextPadding
        }
        var y = appliedConfiguration.padding.bottom
        if (appliedConfiguration.hasText) {
            textField.frame.size = textField.sizeThatFits(CGSize(width, CGFloat.infinity))
            textField.frame.origin = CGPoint((width - textField.frame.size.width) * 0.5, y)
            
            height -= textField.frame.size.height
            y += textField.frame.size.height
            if appliedConfiguration.hasSecondaryText {
                y += appliedConfiguration.textToSecondaryTextPadding
            }
        }
        
        if (appliedConfiguration.hasSecondaryText) {
            secondaryTextField.frame.size = secondaryTextField.sizeThatFits(CGSize(width, CGFloat.infinity))
            secondaryTextField.frame.origin = CGPoint((width - secondaryTextField.frame.size.width) * 0.5, y)
            
            height -= secondaryTextField.frame.size.height
            y += secondaryTextField.frame.size.height
            if appliedConfiguration.hasContent {
                y += appliedConfiguration.contentToTextPadding
            }
        }
        
        let remainingSize = CGSize(width: width, height: height)
        
        if appliedConfiguration.hasContent {
            if let imageSize = contentView.imageSize {
                let resizedImageSize: CGSize
                if appliedConfiguration.contentProperties.imageScaling == .fit {
                    resizedImageSize = imageSize.scaled(toFit: CGSize(width: width, height: height))
                    contentView.frame.size = resizedImageSize
                    contentView.imageView.frame.size = resizedImageSize
                    contentView.imageView.frame.origin = .zero
                } else {
                    resizedImageSize = imageSize.scaled(toFill: CGSize(width: width, height: height))
                    contentView.frame.size = remainingSize
                    contentView.imageView.frame.size = resizedImageSize
                    contentView.imageView.center = contentView.center
                }
                contentView.frame.origin = CGPoint((width - contentView.frame.size.width) * 0.5, y)
            } else {
                contentView.frame.size = remainingSize
                contentView.frame.origin = CGPoint((width - contentView.frame.size.width) * 0.5, y)
            }
        }
    }
    
    internal func updateConfiguration() {
        
        textField.properties = appliedConfiguration.textProperties
        textField.text(appliedConfiguration.text, attributedText: appliedConfiguration.attributedText)
        
        secondaryTextField.properties = appliedConfiguration.secondaryTextProperties
        secondaryTextField.text(appliedConfiguration.secondaryText, attributedText: appliedConfiguration.secondaryAttributedText)
        
        contentView.properties = appliedConfiguration
        
        self.anchorPoint = CGPoint(0.5, 0.5)
        layer?.scale = CGPoint(x: appliedConfiguration.scaleTransform, y: appliedConfiguration.scaleTransform)
    }
        
    internal var appliedConfiguration: NSItemContentConfiguration {
        didSet {
            guard oldValue != self.appliedConfiguration else { return }
            self.updateConfiguration()
            if self.appliedConfiguration.needsUpdate(comparedTo: oldValue) {
                self.setNeedsLayout()
            }
        }
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
    
    public init(configuration: NSItemContentConfiguration) {
        self.appliedConfiguration = configuration
        super.init(frame: .zero)
        
        self.wantsLayer = true
        self.addSubview(textField)
        self.addSubview(secondaryTextField)
        self.addSubview(contentView)
        
        self.isOpaque = false
        
        self.updateConfiguration()
    }
    
    public override func hitTest(_ point: NSPoint) -> NSView? {
        let view = super.hitTest(point)
        Swift.print("hitTest", view ?? "nil")
        return view
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
