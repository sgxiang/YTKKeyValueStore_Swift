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
    fileprivate var object : Any!
    public init(_ id : String!, _ object : Any!){
        self.objectId = id
        self.object = object
    }
    
    internal var jsonString : String?{
        get{
            
            if object is String{
                return (object as! String)
            }else{
                
                var sqlObject : Any?
                
                if let number = self.object as? NSNumber{
                    sqlObject = [number]
                }else if let arrayObject = self.object as? [Any]{
                    sqlObject = arrayObject as AnyObject
                }else if let dictionaryObject = self.object as? Dictionary<String,AnyObject>{
                    sqlObject = dictionaryObject as AnyObject
                }else{
                    return nil
                }
                
                do{
                    let data = try JSONSerialization.data(withJSONObject: sqlObject!, options: JSONSerialization.WritingOptions(rawValue: 0))
                    return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
                }catch{
                    print("faild to get json data")
                    return nil
                }
            }

        }
    }
}


infix operator <- : MultiplicationPrecedence
precedencegroup MultiplicationPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

public func <- (objectId: String!, object: Any!) -> YTKSetter{
    return YTKSetter(objectId , object)
}
