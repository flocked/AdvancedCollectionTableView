//
//  TypedKVO+propagateChanges.swift
//  BXSwiftUtils
//
//  Created by Stefan Fochler on 25.06.18.
//  Copyright © 2018 Boinx Software Ltd. & Imagine GbR. All rights reserved.
//

import Foundation
import FZSwiftUtils

extension TypedKVO
{
    /**
     Setup a "link" between `origin`'s property at `fromKeyPath` to `target`'s property at `toKeyPath` by simulating an
     update to `toKeyPath` using the willChangeValue/didChangeValue pair whenever the value at `fromKeyPath` fires.
     This can be used to link two properties in situations where KVO dependent keys are not usable (e.g. when the
     dependent key resides on an NSArrayController) or the mechanism is not fine-grained enough.
     
     The target object is not retained.
     
     There is no initial call on creation.
     */
    public static func propagateChanges<Target, TargetValue>(from origin: Root, _ fromKeyPath: KeyPath<Root, Value>, to target: Target, _ toKeyPath: KeyPath<Target, TargetValue>, asyncOn queue: DispatchQueue? = nil) -> TypedKVO where Target: NSObject
    {
        let notify = { [weak target] in
            target?.willChangeValue(for: toKeyPath)
            target?.didChangeValue(for: toKeyPath)
        }
    
        return TypedKVO(origin, fromKeyPath, options: [])
        { [weak queue] (_, _) in
            if let queue = queue
            {
                queue.async(execute: notify)
            }
            else
            {
                notify()
            }
        }
    }
}
