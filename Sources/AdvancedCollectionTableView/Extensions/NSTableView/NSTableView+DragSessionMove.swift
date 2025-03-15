//
//  NSTableView+DragSessionMove.swift
//
//
//  Created by Florian Zand on 02.03.25.
//

import AppKit
import FZSwiftUtils

extension NSTableView {
    var draggingSessionMovedHandler: ((NSDraggingSession, CGPoint)->())? {
        get { getAssociatedValue("draggingSessionMoveHandler") }
        set {
            setAssociatedValue(newValue, key: "draggingSessionMoveHandler")
            let selector = #selector(NSTableView.draggingSession(_:movedTo:))
            if newValue != nil, !isMethodReplaced(selector) {
                do {
                    if responds(to: selector) {
                        try replaceMethod(selector,
                            methodSignature: (@convention(c) (AnyObject, Selector, NSDraggingSession, CGPoint) -> ()).self,
                            hookSignature: (@convention(block) (AnyObject, NSDraggingSession, CGPoint) -> ()).self) { store in { object, session, point in
                                (object as? NSTableView)?.draggingSessionMovedHandler?(session, point)
                                store.original(object, selector, session, point)
                            } }
                    } else {
                        try addMethod(selector,
                            methodSignature: (@convention(block) (AnyObject, NSDraggingSession, CGPoint) -> ()).self) { object, session, point in
                                (object as? NSTableView)?.draggingSessionMovedHandler?(session, point)
                            }
                    }
                } catch {
                   debugPrint(error)
                }
            } else if newValue == nil {
                resetMethod(selector)
            }
        }
    }
}
