//
//  File.swift
//  
//
//  Created by Florian Zand on 15.09.23.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import FZQuicklook


extension AdvanceTableViewDiffableDataSource {
    internal class Responder: NSResponder {
        weak var dataSource: AdvanceTableViewDiffableDataSource!
        
        init (_ dataSource: AdvanceTableViewDiffableDataSource) {
            self.dataSource = dataSource
            super.init()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func rightMouseUp(with event: NSEvent) {
            if let menuProvider = self.dataSource.menuProvider {
                self.dataSource.tableView.menu = nil
                let point = event.location(in: self.dataSource.tableView)
                Swift.print("")
                Swift.print("menuProvider", point, self.dataSource.tableView.row(at: point))
                for row in self.dataSource.tableView.visibleRows() {
                    Swift.print(row.frame)
                }
                
                if let item = self.dataSource.item(at: point) {
                    var menuItems: [Item] = [item]
                    let selectedItems = self.dataSource.selectedItems
                    if selectedItems.contains(item) {
                        menuItems = selectedItems
                    }
                    self.dataSource.tableView.menu = menuProvider(menuItems)
                  //  menuProvider(menuItems)?.popUp(positioning: nil, at: point, in: self.dataSource.tableView)
                }
            }
            super.rightMouseUp(with: event)
        }
    }
}
