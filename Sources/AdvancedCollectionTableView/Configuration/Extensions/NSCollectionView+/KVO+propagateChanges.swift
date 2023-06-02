//**********************************************************************************************************************
//
//  KVO+propagateChanges.swift
//    Convenience methods to define dependencies between properties
//  Copyright ©2018 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import FZSwiftUtils

//----------------------------------------------------------------------------------------------------------------------


extension KVO
{

    /// Adds a dependent property with the specified key to the destination object. When any of the source properties
    /// changes, then the value of the dependent property will be recalculated with the supplied closure.
    /// - parameter srcProperties: An array of properties (tuples of object and keypath)
    /// - parameter dstObject: The object that has the dependent property
    /// - parameter dstKeyPath: The name of the dependent property
    /// - parameter queue: If non-nil any changes will be calculated and set on this queue
    /// - parameter calculateValue: A closure that calculates the value of the dependent property whenever one of the source properties changes

    public static func propagateChanges(from srcProperties:[(NSObject,String)], to dstObject:NSObject,_ dstKeyPath:String, asyncOn queue:DispatchQueue? = nil, calculateValue:(([(NSObject,String)])->Any)? = nil) -> [KVO]
    {
        var observers:[KVO] = []

        let notify =
        {
            [weak dstObject] in

            if let calculateValue = calculateValue
            {
                let value = calculateValue(srcProperties)
                dstObject?.setValue(value,forKey:dstKeyPath)
            }
            else
            {
                dstObject?.willChangeValue(forKey:dstKeyPath)
                dstObject?.didChangeValue(forKey:dstKeyPath)
            }
        }

        for (srcObject,srcKeyPath) in srcProperties
        {
            observers += KVO(object:srcObject,keyPath:srcKeyPath,options:[.initial,.new])
            {
                _,_ in

                if let queue = queue
                {
                    queue.async
                    {
                        notify()
                    }
                }
                else
                {
                    notify()
                }
            }
        }
        
        return observers
    }
}


//----------------------------------------------------------------------------------------------------------------------
