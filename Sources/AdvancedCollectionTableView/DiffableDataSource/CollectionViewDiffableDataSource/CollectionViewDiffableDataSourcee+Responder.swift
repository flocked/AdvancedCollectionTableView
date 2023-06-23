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

extension CollectionViewDiffableDataSource {
    internal class Responder<S: Identifiable & Hashable,  E: Identifiable & Hashable>: NSResponder {
        weak var dataSource: CollectionViewDiffableDataSource<S,E>!
        
        init (_ dataSource: CollectionViewDiffableDataSource<S,E>) {
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
           //       self.dataSource.mouseHandlers.mouseEntered?(point)
        }
        
        override func mouseMoved(with event: NSEvent) {
            super.mouseMoved(with: event)
            let point = event.location(in: self.dataSource.collectionView)
            self.dataSource.hoverElement = self.dataSource.element(at: point)
        }
        
        override func mouseExited(with event: NSEvent) {
            super.mouseExited(with: event)
            //     let point = event.location(in: self.dataSource.collectionView)
            self.dataSource.hoverElement = nil
            //       self.dataSource.mouseHandlers.mouseExited?(point)
        }
        
        override func mouseUp(with event: NSEvent) {
            Swift.print("mouseup")
            if let mouseClick = self.dataSource.mouseHandlers.mouseClick {
                let point = event.location(in: self.dataSource.collectionView)
                guard let element = self.dataSource.element(at: point) else { return }
                mouseClick(point, event.clickCount, element)
            }
            super.mouseUp(with: event)
        }
        
        override func rightMouseUp(with event: NSEvent) {
            if let rightMouseClick = self.dataSource.mouseHandlers.rightMouseClick {
                let point = event.location(in: self.dataSource.collectionView)
                guard let element = self.dataSource.element(at: point) else { return }
                rightMouseClick(point, event.clickCount, element)
            }
            
            if let menuProvider = self.dataSource.menuProvider {
                var elements = self.dataSource.selectedElements
                let point = event.location(in: self.dataSource.collectionView)
                if let element = self.dataSource.element(at: point), self.dataSource.isSelected(for: element) == false {
                    elements.append(element)
                }
                menuProvider(elements)?.popUp(positioning: nil, at: point, in: self.dataSource.collectionView)
            }
            super.rightMouseUp(with: event)
        }
        
        override func mouseDragged(with event: NSEvent) {
            /*
            if let mouseDragged = self.dataSource.mouseHandlers.mouseDragged {
                let point = event.location(in: self.dataSource.collectionView)
                mouseDragged(point, self.dataSource.element(at: point))
            }
             */
            super.mouseDragged(with: event)
        }
        
        override func keyDown(with event: NSEvent) {
            let shouldKeyDown = self.dataSource.keydownHandler?(event) ?? true
            if (shouldKeyDown) {
                switch event.keyCode {
                case 49:
                    let previewItems = self.dataSource.quicklookItems(for: self.dataSource.selectedElements)
                    if (self.dataSource.quicklookPanel.isVisible == false) {
                            if (previewItems.isEmpty == false) {
                                self.dataSource.quicklookPanel.keyDownResponder = self.dataSource.collectionView
                                self.dataSource.quicklookPanel.present(previewItems)
                            }
                    } else {
                        self.dataSource.quicklookPanel.close()
                    }
                case 51:
                    if self.dataSource.allowsDeleting {
                        let selectedElements = self.dataSource.selectedElements
                        if (selectedElements.isEmpty == false) {
                            if (self.dataSource.allowsDeleting) {
                                self.dataSource.removeElements(selectedElements)
                            }
                        }
                    }
                case 0:
                    if (event.modifierFlags.contains(.command)) {
                        self.dataSource.selectAll()
                    }
                case 30:
                    if (event.modifierFlags.contains(.command)) {
                       // self.dataSource.selectAll()
                    }
                case 44:
                    if (event.modifierFlags.contains(.command)) {
                     //   self.dataSource.selectAll()
                    }
                default:
                    self.dataSource.collectionView.keyDown(with: event)
                }
            } else {
                self.dataSource.collectionView.keyDown(with: event)
            }
        }
    }
}

