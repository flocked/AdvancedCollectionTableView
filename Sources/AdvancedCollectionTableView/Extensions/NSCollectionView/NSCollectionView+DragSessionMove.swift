//
//  NSCollectionView+DragSessionMove.swift
//
//
//  Created by Florian Zand on 02.03.25.
//

import AppKit
import FZSwiftUtils

extension NSCollectionView {
    var draggingSessionMoveHandler: ((NSDraggingSession, CGPoint)->())? {
        get { getAssociatedValue("draggingSessionMoveHandler") }
        set {
            setAssociatedValue(newValue, key: "draggingSessionMoveHandler")
            let selector = #selector(NSCollectionView.draggingSession(_:movedTo:))
            if newValue != nil {
                guard !isMethodReplaced(selector) else { return }
                do {
                    try replaceMethod(
                        selector,
                        methodSignature: (@convention(c)  (AnyObject, Selector, NSDraggingSession, CGPoint) -> ()).self,
                        hookSignature: (@convention(block)  (AnyObject, NSDraggingSession, CGPoint) -> ()).self) { store in {
                            object, session, point in
                            (object as? NSCollectionView)?.draggingSessionMoveHandler?(session, point)
                            store.original(object, selector, session, point)
                        }
                        }
                } catch {
                   debugPrint(error)
                }
            } else {
                resetMethod(selector)
            }
        }
    }
}
