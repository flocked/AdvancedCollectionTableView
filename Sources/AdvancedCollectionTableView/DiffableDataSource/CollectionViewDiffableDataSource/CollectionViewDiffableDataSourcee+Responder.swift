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
        
        internal func shouldKeyDown(for event: NSEvent) -> Bool {
            self.dataSource.keydownHandler?(event) ?? true
        }
        
        override func keyDown(with event: NSEvent) {
            Swift.print("responder keyDown", event.keyCode, self.dataSource.quicklookItems(for: self.dataSource.selectedElements).count)
            if (self.shouldKeyDown(for: event)) {
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
                default:
                    self.dataSource.collectionView.keyDown(with: event)
                }
            } else {
                self.dataSource.collectionView.keyDown(with: event)
            }
        }
    }
}

internal protocol CollectionViewResponder: NSResponder {
    func shouldKeyDown(for event: NSEvent) -> Bool
}

extension CollectionViewDiffableDataSource.Responder: CollectionViewResponder { }
extension CollectionViewDiffableDataSource: DeletableDataSource {
    public func deleteItems(for indexPaths: Set<IndexPath>) {
        let elements = indexPaths.compactMap({ self.element(for: $0) })
        self.removeElements(elements)
    }
}
/*
internal extension NSCollectionView {
    var quicklookItemsEnabled: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_quicklookItemsEnabled", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSCollectionItem_quicklookItemsEnabled", object: self) }
    }
    
    func quicklookItems(for items: [NSCollectionView]) -> [QLPreviewable] {
        self.dataSource as?
    }
    
    static var didSwizzleResponderEvents: Bool {
        get { getAssociatedValue(key: "NSCollectionItem_didSwizzleResponderEvents", object: self, initialValue: false) }
        set {  set(associatedValue: newValue, key: "NSCollectionItem_didSwizzleResponderEvents", object: self) }
    }
    
    @objc func swizzledKeyDown(with event: NSEvent) {
        if let responder = self.nextResponder as? CollectionViewResponder {
            if responder.shouldKeyDown(for: event) {
                switch event.keyCode {
                case 49, 51:
                    responder.keyDown(with: event)
                default:
                    Swift.print("swizzledKeyDown", event.keyCode )
                    self.swizzledKeyDown(with: event)
                }
            }
        } else {
            self.swizzledKeyDown(with: event)
        }
    }
    
    @objc static func swizzleCollectionViewResponderEvents() {
        Swift.print("swizzleCollectionViewResponderEvents")
        if (didSwizzleResponderEvents == false) {
            self.didSwizzleResponderEvents = true
            do {
                _ = try Swizzle(NSCollectionView.self) {
                    #selector(keyDown(with: )) <-> #selector(swizzledKeyDown(with:))
                }
            } catch {
                Swift.print(error)
            }
        }
    }
}
*/
