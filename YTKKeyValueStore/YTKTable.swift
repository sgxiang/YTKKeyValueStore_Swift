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
            guard tableHandle != nil else{
                return false
            }
            do{
                return try db?.scalar("SELECT EXISTS (SELECT * FROM sqlite_master WHERE type = 'table' AND name = ?)",name) as! Int64 > 0
            }catch _{
                return false
            }
        }
    }
    
    internal let db : Connection?
    internal let tableHandle : Table?
    
    internal init(db : Connection?, _ tableName : String!){
        if YTKTable.checkTableName(tableName){
            self.db = db
            self.name = tableName
            self.tableHandle = Table(tableName)
        }else{
            self.db = nil
            self.name = nil
            self.tableHandle = nil
        }
    }
    
    internal static func checkTableName(_ tableName : String!)->Bool{
        if tableName.contains(" "){
            print("table name : \(tableName) format error")
            return false
        }
        return true
    }
    
    public func clear() throws ->Int{
        
        do{
            let changes = try db?.run(tableHandle!.delete()) ?? 0
            print("table : \(name ?? "")  number of deleted rows : \(changes)")
            return changes
        }catch let error{
            throw error
        }
        
    }
    
    public func delete(_ objectIds : String... ) throws -> Int{
        
        do{
            let changes = try db?.run(tableHandle!.filter(objectIds.contains(ID)).delete()) ?? 0
            print("table : \(name ?? "")  number of deleted rows : \(changes)")
            return changes
        }catch let error{
            throw error
        }

    }
    
    public func deletePreLike(_ objectId : String!) throws -> Int{
        
        do{
            let changes = try db?.run(tableHandle!.filter(ID.like("\(objectId)%")).delete()) ?? 0
            print("table : \(name ?? "")  number of deleted rows : \(changes)")
            return changes
        }catch let error{
            throw error
        }
    }
    
    fileprivate enum YTKKeyValueType{
        case string,number,object
    }
    
    fileprivate static func valueWithType(_ object : AnyObject!)->YTKKeyValueType{
        if object is String{
            return .string
        }else if (object as? NSNumber) != nil{
            return .number
        }else{
            return .object
        }
    }
    
    public func put( _ set :  YTKSetter ) throws{
        
        guard let jsonString : String = set.jsonString else{
            throw YTKError.valueNoSupport
        }
        
        let query = tableHandle!.filter(ID == set.objectId).limit(1)
        do{
            if let filter = try db?.prepare(query){
                if filter.makeIterator().next() == nil{
                    do{
                        try db?.run( tableHandle!.insert(ID <- set.objectId,JSON <- jsonString,CREATEDTIME <- Date()) )
                        print("[insert] id : \(set.objectId)  jsonString : \(set.jsonString!)")
                    }catch let error{
                        throw error
                    }
                }else{
                    do{
                        try db?.run(query.update(JSON <- jsonString,CREATEDTIME <- Date()))
                        print("[update] id : \(set.objectId)  jsonString : \(set.jsonString!)")
                    }catch let error{
                        throw error
                    }
                }
            }
        }catch let error{
            throw error
        }
        
    }
    
    public func get( _ objectId : String! ) throws -> YTKObject?{
        do{
            if let item = try self.getItem(objectId){
                return item.itemObject
            }
        }catch let error{
            throw error
        }
        return nil
    }
    
    public func getItem(_ objectId :String!) throws ->YTKItem?{
        do{
            if let filter = try db?.prepare( tableHandle!.filter(ID == objectId).limit(1) ){
                for v in filter{
                    var item = YTKItem()
                    item.itemId = objectId
                    item.itemObject = YTKObject(value: v[JSON] as AnyObject )
                    item.createdTime = v.get(CREATEDTIME)
                    return item
                }
            }
        }catch let error{
            throw error
        }
        return nil
    }
    
    public func getAllItems() throws ->[YTKItem]{
        
        var result : [YTKItem] = []
        do{
            if let filter = try db?.prepare(tableHandle!){
                for vs in filter{
                    var item = YTKItem()
                    item.itemId = vs[ID]
                    item.itemObject = YTKObject(value:vs[JSON] as AnyObject)
                    item.createdTime = vs.get(CREATEDTIME)
                    result.append(item)
                }
            }
        }catch let error{
            throw error
        }
        return result
    }
    
    
}
