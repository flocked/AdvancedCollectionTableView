//
//  res.swift
//  Coll
//
//  Created by Florian Zand on 02.11.22.
//

import AppKit
import FZSwiftUtils
import FZUIKit

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
                mouseClick(point, event.clickCount, self.dataSource.element(at: point))
            }
            super.mouseUp(with: event)
        }
        
        override func rightMouseUp(with event: NSEvent) {
            if let rightMouseClick = self.dataSource.mouseHandlers.rightMouseClick {
                let point = event.location(in: self.dataSource.collectionView)
                rightMouseClick(point, event.clickCount, self.dataSource.element(at: point))
            }
            
            if let menuProvider = self.dataSource.menuProvider {
                var elements = self.dataSource.selectedElements
                let point = event.location(in: self.dataSource.collectionView)
                if let element = self.dataSource.element(at: point), self.dataSource.isItemSelected(element) == false {
                    elements.append(element)
                }
                menuProvider(elements)?.popUp(positioning: nil, at: point, in: self.dataSource.collectionView)
            }
            super.rightMouseUp(with: event)
        }
        
        override func mouseDragged(with event: NSEvent) {
            if let mouseDragged = self.dataSource.mouseHandlers.mouseDragged {
                let point = event.location(in: self.dataSource.collectionView)
                mouseDragged(point, self.dataSource.element(at: point))
            }
            super.mouseDragged(with: event)
        }
        
        override func keyDown(with event: NSEvent) {
            var shouldKeyDown = true
            if let keydownHandler = self.dataSource.keydownHandler?(event) {
                shouldKeyDown = keydownHandler
            }
            if (shouldKeyDown) {
                let commandPressed = event.modifierFlags.contains(.command)
                /*
                if (event.keyCode == 49) { // SpaceBar
                    if (self.dataSource.quicklookPanel.isVisible == false) {
                        if let _elements = self.dataSource.quicklookHandlers.preview?(self.dataSource.selectedElements) {
                            var previewItems: [QuicklookItem] = []
                            for _element in _elements {
                                if let _elementRect = self.dataSource.frame(for: _element.element) {
                                    previewItems.append(QuicklookItem(url: _element.url, frame: _elementRect))
                                }
                            }
                            if (previewItems.isEmpty == false) {
                                self.dataSource.quicklookPanel.keyDownResponder = self.dataSource.collectionView
                                self.dataSource.quicklookPanel.present(previewItems)
                            }
                        }
                    } else {
                        var previewItems: [QuicklookItem] = []
                        if let _elements = self.dataSource.quicklookHandlers.endPreviewing?(self.dataSource.selectedElements) {
                            for _element in _elements {
                                if let _elementRect = self.dataSource.frame(for: _element.element) {
                                    previewItems.append(QuicklookItem(url: _element.url, frame: _elementRect))
                                }
                            }
                            if (previewItems.isEmpty == false) {
                                self.dataSource.quicklookPanel.keyDownResponder = self.dataSource.collectionView
                                self.dataSource.quicklookPanel.present(previewItems)
                            }
                        }
                        if (previewItems.isEmpty == false) {
                            self.dataSource.quicklookPanel.close(previewItems)
                        } else {
                            self.dataSource.quicklookPanel.close()
                        }
                    }
                } else */
                if (event.keyCode == 51 && self.dataSource.allowsDeleting) {
                    let selectedElements = self.dataSource.selectedElements
                    if (selectedElements.isEmpty == false) {
                        if (self.dataSource.allowsDeleting) {
                            self.dataSource.removeElements(selectedElements)
                        }
                    }
                } else if (event.keyCode == 0 && commandPressed) {
                    self.dataSource.selectAll()
                } else if (event.keyCode == 30 && commandPressed) {  // Handle Zoom In
                    
                } else if (event.keyCode == 44 && commandPressed) {  // Handle Zoom Out
                    
                } else  {
                    self.dataSource.collectionView.keyDown(with: event)
                }
            } else {
                self.dataSource.collectionView.keyDown(with: event)
            }
        }
    }
}

