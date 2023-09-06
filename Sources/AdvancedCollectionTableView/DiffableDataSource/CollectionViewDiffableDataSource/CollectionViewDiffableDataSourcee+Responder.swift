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


extension AdvanceColllectionViewDiffableDataSource {
    internal class Responder<S: Identifiable & Hashable,  E: Identifiable & Hashable>: NSResponder {
        weak var dataSource: AdvanceColllectionViewDiffableDataSource<S,E>!
        
        init (_ dataSource: AdvanceColllectionViewDiffableDataSource<S,E>) {
            self.dataSource = dataSource
            super.init()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func mouseEntered(with event: NSEvent) {
            super.mouseEntered(with: event)
            let point = event.location(in: self.dataSource.collectionView)
            self.dataSource.hoverElement = self.dataSource.element(at: point)
        }
        
        override func mouseMoved(with event: NSEvent) {
            super.mouseMoved(with: event)
            let point = event.location(in: self.dataSource.collectionView)
            self.dataSource.hoverElement = self.dataSource.element(at: point)
        }
        
        override func mouseExited(with event: NSEvent) {
            super.mouseExited(with: event)
            self.dataSource.hoverElement = nil
        }
        
        override func rightMouseUp(with event: NSEvent) {
            if let menuProvider = self.dataSource.menuProvider {
                let point = event.location(in: self.dataSource.collectionView)
                if let element = self.dataSource.element(at: point) {
                    var elements = self.dataSource.selectedElements
                    if elements.contains(element) == false {
                        elements.append(element)
                    }
                    menuProvider(elements)?.popUp(positioning: nil, at: point, in: self.dataSource.collectionView)
                }
            }
            super.rightMouseUp(with: event)
        }
    }
}

/*
override func mouseUp(with event: NSEvent) {
    if let mouseClick = self.dataSource.mouseHandlers.mouseClick {
        let point = event.location(in: self.dataSource.collectionView)
        guard let element = self.dataSource.element(at: point) else { return }
        mouseClick(point, event.clickCount, element)
    }
    super.mouseUp(with: event)
}
 */
