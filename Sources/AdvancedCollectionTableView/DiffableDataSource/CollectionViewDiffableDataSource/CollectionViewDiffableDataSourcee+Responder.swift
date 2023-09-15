//
//  res.swift
//  Coll
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit
import FZQuicklook


extension AdvanceCollectionViewDiffableDataSource {
    internal class Responder: NSResponder {
        weak var dataSource: AdvanceCollectionViewDiffableDataSource!
        
        init (_ dataSource: AdvanceCollectionViewDiffableDataSource) {
            self.dataSource = dataSource
            super.init()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func mouseEntered(with event: NSEvent) {
            super.mouseEntered(with: event)
            let point = event.location(in: self.dataSource.collectionView)
            self.dataSource.hoveredIndexPath = self.dataSource.collectionView.indexPathForItem(at: point)
        }
        
        override func mouseMoved(with event: NSEvent) {
            super.mouseMoved(with: event)
            let point = event.location(in: self.dataSource.collectionView)
            self.dataSource.hoveredIndexPath = self.dataSource.collectionView.indexPathForItem(at: point)
        }
        
        override func mouseExited(with event: NSEvent) {
            super.mouseExited(with: event)
            self.dataSource.hoveredIndexPath = nil
        }
    }
}
