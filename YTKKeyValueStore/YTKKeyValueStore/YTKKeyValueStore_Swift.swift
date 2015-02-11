//
//  YTKKeyValueStore_Swift.swift
//  YTKKeyValueStore
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 TangQiao. All rights reserved.
//

import UIKit
import SQLite

//文件夹路径
private let PATH_OF_DOCUMENT : String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String

private let DEFAULT_DB_NAME = "database_swift.sqlite"

private let ID = Expression<String>("id")
private let JSON = Expression<String>("json")
private let CREATEDTIME = Expression<NSDate>("createdTime")

public struct YTKKeyValueItem{
    public var itemId : String?
    public var itemObject : YTKObject?
    public var createdTime : NSDate?
}

public class YTKKeyValueStore : NSObject{
    
    private var db : Database?
    
    public init(_ dbName : String! = DEFAULT_DB_NAME){
        let dbPath = PATH_OF_DOCUMENT.stringByAppendingPathComponent(dbName)
        db = Database(dbPath)
    }
    
    public subscript (tableName : String!) -> YTKTable{
        return YTKTable(db: self.db, tableName)
    }
    
    public func createTable(tableName:String!)->(Bool){
        if !YTKTable.checkTableName(tableName) {
            return false
        }
        if let statement = (db?.create(table: db![tableName] , ifNotExists : true){t in
            t.column(ID)
            t.column(JSON)
            t.column(CREATEDTIME, defaultValue: NSDate())
            t.primaryKey(ID)
        }) where !statement.failed{
            return true
        }else{
            return false
        }
    }
    
    public func dropTable(tableName:String!)->(Bool){
        if !YTKTable.checkTableName(tableName) {
            return false
        }
        
        if let statement = (db?.drop(table: db![tableName], ifExists: false)) where !statement.failed{
                return true
        }else{
            return false
        }
        
    }
    
    
}

//MAEK:- 实现Value协议 用于存储NSDate数据

extension NSDate: Value {
    public class var declaredDatatype: String {
        return Int.declaredDatatype
    }
    public class func fromDatatypeValue(intValue: Int) -> Self {
        return self(timeIntervalSince1970: NSTimeInterval(intValue))
    }
    public var datatypeValue: Int {
        return Int(timeIntervalSince1970)
    }
}


public struct YTKTable{
    
    public var isExists : Bool {
        get{
            return self.query != nil
        }
    }
    
    private var query : Query?
    
    private init(db : Database?, _ tableName : String!){
        if YTKTable.checkTableName(tableName){
            self.query = db?[tableName]
        }
        
        self.delete()
        self.delete(like: true)
        self.delete(like: true, "a","d","d")
        self.delete(like: false)
        self.delete(like: false, "a")
        
    }
    
    private static func checkTableName(tableName : String!)->Bool{
        if find(tableName, " ") != nil{
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
    
    public func getItem(objectId :String!)->YTKKeyValueItem?{
        
        if let filter =  self.query?.filter(ID == objectId).limit(1){
            if filter.isEmpty{
                return nil
            }else{
                var item = YTKKeyValueItem()
                item.itemId = objectId
                item.itemObject = YTKObject(value: filter.first![JSON] )
                item.createdTime = filter.first!.get(CREATEDTIME)
                return item
            }
        }
        return nil
    }
    
    public func getAllItems()->[YTKKeyValueItem]?{
      
        var result : [YTKKeyValueItem] = []
        
        if let table = self.query{
            for row in table{
                var item = YTKKeyValueItem()
                item.itemId = row[ID]
                item.itemObject = YTKObject(value:row[JSON])
                item.createdTime = row.get(CREATEDTIME)
                result.append(item)
            }
        }
        return result.count == 0 ? nil : result
        
    }
    
    
}


public struct YTKSetter {
    private var objectId : String!
    private var object : AnyObject!
    internal init(_ id : String!, _ object : AnyObject!){
        self.objectId = id
        self.object = object
    }
}


infix operator <- { associativity left precedence 140 }
public func <- (objectId: String!, object: AnyObject!) -> YTKSetter{
    return YTKSetter(objectId , object)
}


//MARK: - 数据库的对象类型

public struct YTKObject{
    private var value : AnyObject?
    
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

