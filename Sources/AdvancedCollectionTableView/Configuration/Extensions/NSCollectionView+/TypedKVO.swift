//
//  nKVO.swift
//  BXSwiftUtils
//
//  Created by Stefan Fochler on 26.03.18.
//  Copyright © 2018 Boinx Software Ltd. & Imagine GbR. All rights reserved.
//

import Foundation
import FZSwiftUtils

public typealias observeSafe = TypedKVO

public class TypedKVO<Root, Value> : KVO where Root : NSObject
{
    public struct Change<Value>
    {
        public let oldValue: Value?
        public let newValue: Value?
    }
    
    /**
     Creates a TypedKVO token belonging to the key-value-observation of `keyPath`.
     
     - Parameters:
        - observedObject: The object at the root of the key path.
        - keyPath: The Swift 4 `KeyPath` which must only contain properties and classes that are exposed to Objective-C
                   and marked as `@objc dynamic`.
        - options: The `NSKeyValueObservingOptions` options set, defaulting to `.initial` & `.new`.
        - closure: The closure that will take the following parameters when the observed value changes or one of the
                   `keyPath`'s intermediate objects get deallocated:
        - target: The weakly retained `observedObject` to avoiding the need of capturing it.
        - change: A `Change` struct containing `oldValue` and `newValue`, if availabile.
     
     - throws: `invalidArgumentException` if the keyPath contains properties that are not exposed to Objective-C.
     */
    public init(_ observedObject: Root, _ keyPath: KeyPath<Root, Value>, options: NSKeyValueObservingOptions = [.initial, .new], _ closure: @escaping (_ target: Root, _ change: Change<Value>) -> Void)
    {
        guard let keyPathString = keyPath._kvcKeyPathString else
        {
            let message = "Not all objects in key path \(String(describing: keyPath)) starting from \(String(describing: observedObject)) are exposed to the Objective C runtime and thus unfit for KVO.";
            
            // NSException can be caught in unit tests without taking down the build process. Incontrast to Swift errors,
            // they are "unchecked" and don't need to be declared on the method, which would be really inconvenient to use.
            NSException.raise(.invalidArgumentException, format: message, arguments: getVaList([]))
            
            // This fatalError is needed so that the compiler understands that this guard really does stop the execution
            // flow if the _kvcKeyPathString could not be read
            fatalError(message)
        }
    
        super.init(object: observedObject, keyPath: keyPathString, options: options)
        { [weak observedObject] (old, new) in
            guard let observedObject = observedObject else { return }
            
            let change = Change<Value>(oldValue: old as? Value, newValue: new as? Value)
            closure(observedObject, change)
        }
    }
}
