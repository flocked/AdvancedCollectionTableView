//
//  File.swift
//  
//
//  Created by Florian Zand on 30.08.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSListContentView {
    class TextStack: NSView {
        var configuration: NSListContentConfiguration {
            didSet {
                if oldValue != configuration {
                    update()
                }
            }
        }
        
        func update() {
            
        }
        
        var previousWidth: CGFloat = -1
        override func layout() {
            super.layout()
            guard self.bounds.size.width != previousWidth else { return }
            previousWidth = self.bounds.size.width
        }
        
        init(configuration: NSListContentConfiguration) {
            self.configuration = configuration
            super.init(frame: .zero)
            self.addSubview(textField)
            self.addSubview(secondaryTextField)
        }
        
        internal lazy var textField = CellTextField(properties: self.configuration.textProperties)
        internal lazy var secondaryTextField = CellTextField(properties: self.configuration.secondaryTextProperties)
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
