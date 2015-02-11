//
//  YTKTable.swift
//  YTKKeyValueStore
//
//  Created by ysq on 15/2/11.
//  Copyright (c) 2015年 sgxiang. All rights reserved.
//

import UIKit
import SQLite


public struct YTKTable{
    
    public var isExists : Bool {
        get{
            return self.query != nil
        }
    }
    
    internal var query : Query?
    
    internal init(db : Database?, _ tableName : String!){
        if YTKTable.checkTableName(tableName){
            self.query = db?[tableName]
        }
    }
    
    internal static func checkTableName(tableName : String!)->Bool{
        if find(tableName, " ") != nil{
            printYTKLog("表名出错")
            return false
        }
        
        return true
    }
    
    public func delete( like : Bool = false , _ objectIds : String... ) -> Int?{
        
        if objectIds.count == 0{
            return self.query?.delete()
        }else if objectIds.count == 1{
            if like{
                return self.query?.filter( SQLite.like("\(objectIds[0])%", ID) ).delete()
            }else{
                return self.query?.filter( ID == objectIds[0] ).delete()
            }
        }else{
            if like{
                var change : Int?
                for id in objectIds{
                    if let c = self.query?.filter( SQLite.like("\(id)",ID) ).delete(){
                        change = change == nil ? c : change! + c
                    }
                }
                return change
            }else{
                return self.query?.filter( contains(objectIds, ID) ).delete()
            }
        }
        
    }
    
    //MARK: 对象
    private enum YTKKeyValueType{
        case String,Number,Object
    }
    private static func valueWithType(object : AnyObject!)->YTKKeyValueType{
        if object is String{
            return .String
        }else if (object as? NSNumber) != nil{
            return .Number
        }else{
            return .Object
        }
    }
    
    public func put( set :  YTKSetter )->Int?{
        
        let type = YTKTable.valueWithType(set.object)
        var jsonString : String?
        
        if type == .Number || type == .Object{
            let sqlObject: AnyObject! = type == .Number ? [set.object] : set.object
            var error : NSError?
            let data = NSJSONSerialization.dataWithJSONObject(sqlObject, options: NSJSONWritingOptions(0), error: &error)
            if error != nil {
                printYTKLog("插入数据出错: json解析出错")
                return nil
            }
            jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
        }else{
            jsonString = set.object as? String
        }
        
        if let filter =  self.query?.filter(ID == set.objectId).limit(1){
            if filter.isEmpty{
                return self.query!.insert(ID <- set.objectId , JSON <- jsonString! , CREATEDTIME <- NSDate())
            }else{
                return self.query!.update(JSON <- jsonString! , CREATEDTIME <- NSDate() )
            }
        }
        return nil
    }
    
    public func get( objectId : String! ) -> YTKObject?{
        if let item = self.getItem(objectId){
            return item.itemObject
        }
        return nil
    }
    
    public func getItem(objectId :String!)->YTKItem?{
        
        if let filter =  self.query?.filter(ID == objectId).limit(1){
            if filter.isEmpty{
                return nil
            }else{
                var item = YTKItem()
                item.itemId = objectId
                item.itemObject = YTKObject(value: filter.first![JSON] )
                item.createdTime = filter.first!.get(CREATEDTIME)
                return item
            }
        }
        return nil
    }
    
    public func getAllItems()->[YTKItem]?{
        
        var result : [YTKItem] = []
        
        if let table = self.query{
            for row in table{
                var item = YTKItem()
                item.itemId = row[ID]
                item.itemObject = YTKObject(value:row[JSON])
                item.createdTime = row.get(CREATEDTIME)
                result.append(item)
            }
        }
        return result.count == 0 ? nil : result
        
    }
    
    
}