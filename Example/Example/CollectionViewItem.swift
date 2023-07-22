//
//  CollectionViewItem.swift
//  Example
//
//  Created by Florian Zand on 14.07.23.
//

import Cocoa
import FZUIKit
import FZSwiftUtils
import AdvancedCollectionTableView

class CollectionViewItem: NSCollectionViewItem {
    
    internal let _view = NSView()
    
    override func loadView() {
        self.view = NSView()
        self.view.backgroundColor = .lightGray
        self.view.cornerRadius = 6.0
    }
     
    
    
    override var isSelected: Bool {
        didSet {
            self.view.backgroundColor = isSelected ? .controlAccentColor :  .lightGray
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
