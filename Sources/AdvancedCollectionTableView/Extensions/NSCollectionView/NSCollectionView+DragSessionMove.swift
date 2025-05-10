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
                guard !isMethodHooked(selector) else { return }
                do {
                    try hook(selector, closure: { original, object, sel, session, point in
                        (object as? NSCollectionView)?.draggingSessionMoveHandler?(session, point)
                        original(object, sel, session, point)
                    } as @convention(block) (
                        (AnyObject, Selector, NSDraggingSession, CGPoint) -> Void,
                        AnyObject, Selector, NSDraggingSession, CGPoint) -> Void)
                } catch {
                   debugPrint(error)
                }
            } else {
                revertHooks(for: selector)
            }
        }
    }
}
