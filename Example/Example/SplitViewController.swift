//
//  SplitViewController.swift
//  Example
//
//  Created by Florian Zand on 20.01.25.
//

import Cocoa
import FZUIKit

class SplitViewController: NSSplitViewController {

    let outlineSidebarItem = NSSplitViewItem(sidebarWithViewController: OutlineSidebarViewController.loadFromStoryboard()!)
    var tableSidebarItem: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outlineSidebarItem.isCollapsed = true
        splitViewItems.insert(outlineSidebarItem, at: 1)
    }
    
    func swapSidebar() {
        splitViewItems[0].isCollapsed = true
        splitViewItems.swapAt(0, 1)
        splitViewItems[0].isCollapsed = false
    }
    
}
