//
//  YTKSetter.swift
//  YTKKeyValueStore
//
//  Created by ysq on 15/2/11.
//  Copyright (c) 2015年 sgxiang. All rights reserved.
//

import UIKit

public struct YTKSetter {
    internal var objectId : String!
    internal var object : AnyObject!
    public init(_ id : String!, _ object : AnyObject!){
        self.objectId = id
        self.object = object
    }
}

infix operator <- { associativity left precedence 140 }
public func <- (objectId: String!, object: AnyObject!) -> YTKSetter{
    return YTKSetter(objectId , object)
}
