//
//  YTKObject.swift
//  YTKKeyValueStore
//
//  Created by ysq on 15/2/11.
//  Copyright (c) 2015年 sgxiang. All rights reserved.
//

import UIKit

//MARK: - 数据库的对象类型

public struct YTKObject{
    internal var value : AnyObject?
    
    public var objectValue : AnyObject?{
        get{
            return self.value
        }
    }
    
    public var stringValue : String? {
        get{
            return self.value as? String
        }
    }
    
    public var numberValue : NSNumber?{
        
        get{
            if self.value == nil { return nil}
            
            if let num = self.value as? NSNumber{
                return num
            }else{
                
                var error : NSError?
                let result: AnyObject? = NSJSONSerialization.JSONObjectWithData(self.value!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
                if error != nil{
                    return nil
                }else{
                    if let num = result as? [NSNumber]{
                        return num[0]
                    }else{
                        return nil
                    }
                }
            }
        }
        
    }
    
    public var dictionaryValue : Dictionary<String , AnyObject>?{
        get{
            if self.value == nil { return nil}
            
            var error : NSError?
            let result: AnyObject? = NSJSONSerialization.JSONObjectWithData(self.value!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
            if error != nil{
                return nil
            }else{
                if let dic = result as? Dictionary<String , AnyObject>{
                    return dic
                }else{
                    return nil
                }
            }
            
        }
    }
    
    
    public var arrayValue : Array<AnyObject>?{
        get{
            if self.value == nil { return nil}
            
            var error : NSError?
            let result: AnyObject? = NSJSONSerialization.JSONObjectWithData(self.value!.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
            if error != nil{
                return nil
            }else{
                if let dic = result as? Array<AnyObject>{
                    return dic
                }else{
                    return nil
                }
            }
        }
    }
    
    
}
