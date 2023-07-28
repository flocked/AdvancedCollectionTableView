//
//  NSTableCellContentView+AccessoriesView.swift
//  
//
//  Created by Florian Zand on 22.06.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit

internal extension NSTableCellContentView {
    class AccessoriesView: NSView {
        var accessoryViews: [AccessoriesView] = []
        
        lazy var stackView: NSStackView = {
            var stackView = NSStackView(views: [])
            stackView.orientation = .horizontal
            stackView.spacing = accessory.accessoriesSpacing
            return stackView
        }()
        
        var accessory: NSTableCellContentConfiguration.Accessory {
            didSet {
                if oldValue != accessory {
                    self.update()
                }
            }
        }
        
        init(accessory: NSTableCellContentConfiguration.Accessory) {
            self.accessory = accessory
            super.init(frame: .zero)
            self.initalSetup()
            self.update()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func update() {
        }
        
        func initalSetup() {
            
        }
    }
}
