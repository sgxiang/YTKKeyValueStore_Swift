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
                
                do{
                    let result: AnyObject? = try NSJSONSerialization.JSONObjectWithData(self.value!.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
                    if let num = result as? [NSNumber]{
                        return num[0]
                    }else{
                        return nil
                    }
                }catch{
                    print("faild to get json data")
                    return nil
                }
                
            }
        }
        
    }
    
    public var dictionaryValue : Dictionary<String , AnyObject>?{
        get{
            if self.value == nil { return nil}
            
            do{
                let result: AnyObject? = try NSJSONSerialization.JSONObjectWithData(self.value!.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
                if let dic = result as? Dictionary<String , AnyObject>{
                    return dic
                }else{
                    return nil
                }
            }catch{
                print("faild to get json data")
                return nil
            }
            
        }
    }
    
    
    public var arrayValue : Array<AnyObject>?{
        get{
            if self.value == nil { return nil}
            
            do{
                let result: AnyObject? = try NSJSONSerialization.JSONObjectWithData(self.value!.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments)
                if let dic = result as? Array<AnyObject>{
                    return dic
                }else{
                    return nil
                }
            }catch{
                print("faild to get json data")
                return nil
            }
        }
    }
    
    
}
