//
//  NSTableView+DragSessionMove.swift
//
//
//  Created by Florian Zand on 02.03.25.
//

import AppKit
import FZSwiftUtils

/*
extension NSTableView {
    var draggingSessionMovedHandler: ((NSDraggingSession, CGPoint)->())? {
        get { getAssociatedValue("draggingSessionMoveHandler") }
        set {
            setAssociatedValue(newValue, key: "draggingSessionMoveHandler")
            let selector = #selector(NSTableView.draggingSession(_:movedTo:))
            if newValue != nil, !isMethodReplaced(selector), !isMethodHooked(selector) {
                do {
                    if responds(to: selector) {
                        try hook(selector, closure: { original, object, sel, session, point in
                            (object as? NSTableView)?.draggingSessionMovedHandler?(session, point)
                            original(object, sel, session, point)
                        } as @convention(block) (
                            (AnyObject, Selector, NSDraggingSession, CGPoint) -> Void,
                            AnyObject, Selector, NSDraggingSession, CGPoint) -> Void)
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
                revertHooks(for: selector)
            }
        }
    }
}
*/
