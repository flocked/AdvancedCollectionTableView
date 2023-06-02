//**********************************************************************************************************************
//
//  KVO.swift
//    Lightweight wrapper class that provides closure based API around KVO
//  Copyright ©2016-2018 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import FZSwiftUtils

// Importing AppKit is needed for the NSIsControllerMarker() function. For iOS, provide our own implementation of this function.

#if os(macOS)

import AppKit

#elseif os(iOS)

public let NSNoSelectionMarker = "NSNoSelectionMarker" as AnyObject
public let NSMultipleValuesMarker = "NSMultipleValuesMarker" as AnyObject
public let NSNotApplicableMarker = "NSNotApplicableMarker" as AnyObject

public func NSIsControllerMarker(_ value:Any?) -> Bool
{
    let object = value as AnyObject

    return    object === NSNoSelectionMarker ||
            object === NSMultipleValuesMarker ||
            object === NSNotApplicableMarker
}

public func NSIsMultipleValuesMarker(_ value:Any?) -> Bool
{
    let object = value as AnyObject
    return    object === NSMultipleValuesMarker
}

public func NSIsNoSelectionMarker(_ value:Any?) -> Bool
{
    let object = value as AnyObject
    return    object === NSNoSelectionMarker
}

public func NSIsNotApplicableMarker(_ value:Any?) -> Bool
{
    let object = value as AnyObject
    return    object === NSNotApplicableMarker
}

#endif


//----------------------------------------------------------------------------------------------------------------------


/// Lightweight wrapper class that provides closure based API around KVO. Instances of this class can be attached
/// to other classes. When the instances are deallocated, the KVO is automatically unregistered.

public class KVO : NSObject
{
    public/*(get)*/ private(set) weak var observedObject: NSObject?
    public let keyPath: String
    private let closure: (Any?,Any?)->()
    private var isActive = false


//----------------------------------------------------------------------------------------------------------------------


    // MARK: -
    
    /// Create a new KVO helper, observing the property `keypath` of `object`. When it changes, the closure is called.
    /// - parameter object: The root object that is being observed.
    /// - parameter keyPath: The String based keypath to the property that is observed.
    /// - parameter options: Valid options are .initial, .old, and .new.
    /// - parameter closure: This closure (with old and new value) will be called when the observed property changes.
    /// - parameter oldValue: The old value, if `options` contains `.old`.
    /// - parameter newValue: The old value, if `options` contains `.new`.
    /// - returns: KVO wrapper object, which should be retained as long as you wish the observing to be active.

    public init(object: NSObject, keyPath: String, options: NSKeyValueObservingOptions = [], _ closure:@escaping (_ oldValue: Any?, _ newValue: Any?)->())
    {
        self.observedObject = object
        self.keyPath = keyPath
        self.closure = closure
        super.init()
        
        // Gather all objects in the keypath, starting with inObject
        
        let keys = keyPath.components(separatedBy:".").dropLast()
        var objectsInKeypath: [NSObject] = [object]
        var nextObject: NSObject? = object
        
        for key in keys
        {
            nextObject = nextObject?.value(forKey:key) as? NSObject
            
            if nextObject == nil || NSIsControllerMarker(nextObject)
            {
                break
            }
   
            objectsInKeypath += nextObject
        }
        
        // If any object in the keypath dies, then automatically remove the observer again
        
        for object in objectsInKeypath
        {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(KVO.handleInvalidate(notification:)),
                name: KVO.invalidateNotification,
                object: object)
        }
  
        // Add the observer
        
        object.addObserver(
            self,
            forKeyPath: keyPath,
            options: options,
            context: nil)
        
        self.isActive = true
    }


    /// The KVO is automatically removed when getting rid of the helper.
    
    deinit
    {
        self.invalidate(for:observedObject)
        NotificationCenter.default.removeObserver(self)
    }


//----------------------------------------------------------------------------------------------------------------------


    /// When the property at `keypath` has changed, the closure is executed.

    override open func observeValue(
        forKeyPath keyPath:String?,
        of object:Any?,
        change:[NSKeyValueChangeKey:Any]?,
        context:UnsafeMutableRawPointer?)
    {
        var oldValue:Any? = nil
        var newValue:Any? = nil
        
        if let change = change
        {
            oldValue = change[NSKeyValueChangeKey.oldKey]
            newValue = change[NSKeyValueChangeKey.newKey]
        }
        
        self.closure(oldValue,newValue)
    }


//----------------------------------------------------------------------------------------------------------------------


    // MARK: -
    
    /// Notification name that must be sent when objects are dying.
    
    private static let invalidateNotification = NSNotification.Name("invalidate")
    
    /// Send out a notification letting KVO observers know that this object is about to disappear. Receivers
    /// of this notification should remove their KVO observer, or they risk crashing due to an exception.
    
    @objc public class func invalidate(for object: NSObject)
    {
        NotificationCenter.default.post(
            name:KVO.invalidateNotification,
            object:object)
    }
    
    /// Called in response to KVO.invalidateNotification. Take the object reference from the notification itself.
    /// This is much more reliable that trying to get the object reference from self.observedObject - as it is
    /// already nilled out at the time the deinit of this object is called.
    
    @objc private func handleInvalidate(notification: NSNotification)
    {
        let object = self.observedObject ?? (notification.object as? NSObject)
        self.invalidate(for: object)
    }


    /// Removes the KVO observer again.
    
    private func invalidate(for inObject: NSObject?)
    {
        FZSwiftUtils.synchronized(self)
        {
            if self.isActive
            {
                if let object = inObject
                {
                    object.removeObserver(self, forKeyPath:keyPath)
                    self.isActive = false
                }
            }
        }
    }
}


//----------------------------------------------------------------------------------------------------------------------

// Objective C API that allows nicer setup for observations with or without options.
extension KVO
{
    @objc public static func observe(_ object: NSObject, onKeyPath keyPath: String, usingBlock block: @escaping () -> Void) -> KVO
    {
        return KVO(object: object, keyPath: keyPath,
        { _, _ in
            block()
        })
    }
    
    @objc public static func observe(_ object: NSObject, onKeyPath keyPath: String, options: NSKeyValueObservingOptions, usingBlock block: @escaping (_ oldValue: Any?, _ newValue: Any?) -> Void) -> KVO
    {
        return KVO(object: object, keyPath: keyPath, options: options, block)
    }
}
