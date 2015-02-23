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
    
    public let name : String?
    
    public var isExists : Bool {
        get{
            return self.query != nil
        }
    }
    
    internal let query : Query?
    
    internal init(db : Database?, _ tableName : String!){
        if YTKTable.checkTableName(tableName){
            self.name = tableName
            self.query = db?[tableName]
        }else{
            self.name = nil
            self.query = nil
        }
    }
    
    internal static func checkTableName(tableName : String!)->Bool{
        if find(tableName, " ") != nil{
            printYTKLog("table name : \(tableName) format error")
            return false
        }
        
        return true
    }
    
    public func clear()->Int?{
        let changes = self.query?.delete()
        printYTKLog("table : \(self.name)  number of deleted rows : \(changes)")
        return changes
    }
    
    public func delete(objectIds : String... ) -> Int?{
        let changes = self.query?.filter( contains(objectIds, ID) ).delete()
        printYTKLog("table : \(self.name)  number of deleted rows : \(changes)")
        return changes
    }
    
    public func deletePreLike(objectId : String!) -> Int?{
        let changes = self.query?.filter( SQLite.like("\(objectId)%", ID) ).delete()
        printYTKLog("table : \(self.name)  number of deleted rows : \(changes)")
        return changes
    }
    
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
        
        var jsonString : String? = set.jsonString
        
        if jsonString == nil{
            printYTKLog("no support db value")
            return nil
        }
        
        printYTKLog("[put] id : \(set.objectId)  jsonString : \(set.jsonString!)")
        
        var changes : Int?
        if let filter =  self.query?.filter(ID == set.objectId).limit(1){
            if filter.isEmpty{
                changes = self.query?.insert(ID <- set.objectId , JSON <- jsonString! , CREATEDTIME <- NSDate())
            }else{
                changes = filter.update(JSON <- jsonString! , CREATEDTIME <- NSDate() )
            }
        }
        
        if changes == nil{
            printYTKLog("failed to insert/replace into table : \(self.name)")
        }
        return changes
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
