//
//  NSTableCellContentView+AccessoryView.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSTableCellContentView.AccessoriesView {
    class AccessoryView: NSView {
        var accessory: NSTableCellContentConfiguration.Accessory.AccessoryContent {
            didSet {
                if oldValue != accessory {
                    self.update()
                }
            }
        }
        lazy var textField = NSTableCellContentView.CellTextField(properties: accessory.textProperties)
        lazy var contentView = ContentView(properties: accessory.contentProperties, view: accessory.view, image: accessory.image)

        lazy var stackView: NSStackView = {
            var stackView = NSStackView(views: [textField, contentView])
            stackView.orientation = .horizontal
            stackView.spacing = accessory.contentToTextSpacing
            return stackView
        }()

        
        init(accessory: NSTableCellContentConfiguration.Accessory.AccessoryContent) {
            self.accessory = accessory
            super.init(frame: .zero)
            self.initalSetup()
            self.update()
        }
        
        func update() {
            textField.text(accessory.text, attributedString: accessory.attributedText)
            contentView.contentView = accessory.view
            contentView.image = accessory.image
            contentView.properties = accessory.contentProperties
            textField.properties = accessory.textProperties
            
            if accessory.contentPosition == .leading, stackView.arrangedSubviews.first != contentView {
                stackView.addArrangedSubview(textField)
            } else if accessory.contentPosition == .trailing, stackView.arrangedSubviews.first != textField {
                stackView.addArrangedSubview(contentView)
            }
        }
        
        func initalSetup() {
            self.addSubview(withConstraint: stackView)
        }
        
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
