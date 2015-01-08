//
//  YTKKeyValueStore_Swift.swift
//  YTKKeyValueStore
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 TangQiao. All rights reserved.
//

import UIKit


public class YTKKeyValueItem_Swift:NSObject{
    public var itemId : String?
    public var itemObject : YTKObject?
    public var createdTime : NSDate?
    
    public func description() -> String{
        return "id=\(itemId), value=\(itemObject), timeStamp=\(createdTime)"
    }
    
}

public class YTKKeyValueStore_Swift: NSObject {
    
    //文件夹路径
    private let PATH_OF_DOCUMENT : String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    
    private var dbQueue : FMDatabaseQueue?
    
    private let DEFAULT_DB_NAME = "database_swift.sqlite"
    private let CREATE_TABLE_SQL = "CREATE TABLE IF NOT EXISTS %@ ( id TEXT NOT NULL, json TEXT NOT NULL, createdTime TEXT NOT NULL, PRIMARY KEY(id)) "
    private let UPDATE_ITEM_SQL = "REPLACE INTO %@ (id, json, createdTime) values (?, ?, ?)"
    private let QUERY_ITEM_SQL = "SELECT json, createdTime from %@ where id = ? Limit 1"
    private let SELECT_ALL_SQL = "SELECT * from %@"
    private let CLEAR_ALL_SQL = "DELETE from %@"
    private let DELETE_ITEM_SQL = "DELETE from %@ where id = ?"
    private let DELETE_ITEMS_SQL = "DELETE from %@ where id in ( %@ )"
    private let DELETE_ITEMS_WITH_PREFIX_SQL = "DELETE from %@ where id like ? "
    
    
    /**
    检查名字是否合法
    
    :param: tableName 表名
    
    :returns: 合法性
    */
    private class func checkTableName(tableName : String!)->Bool{
        if find(tableName, " ") != nil{
            println("error, table name: \(tableName) format error")
            return false
        }
        return true
    }
    
    //MARK: - 初始化
    
    public override init(){
        super.init()
        self.setupDB(DEFAULT_DB_NAME)
    }
    
    public init(dbName : String!){
        super.init()
        self.setupDB(dbName)
    }
    
    private func setupDB(dbName : String!){
        let dbPath = PATH_OF_DOCUMENT.stringByAppendingPathComponent(dbName)
        if dbQueue != nil{
            self.close()
        }
        dbQueue = FMDatabaseQueue(path: dbPath)
    }
    
    
    //MARK: - 数据库操作
    
    /**
    创建表单
    
    :param: tableName 表单名
    */
    public func createTable(#tableName:String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName) {
            return
        }
        let sql = NSString(format: CREATE_TABLE_SQL, tableName)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:nil)
        })
        if !result! {
            println("error, failed to create table: \(tableName)")
        }
    }
    
    /**
    清除表单
    
    :param: tableName 表单名
    */
    public func clearTable(#tableName:String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        let sql = NSString(format: CLEAR_ALL_SQL, tableName)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:nil)
        })
        if !result!{
            println("error, failed to clear table: \(tableName)")
        }
    }
    
    //MARK: 对象
    
    private enum YTKKeyValueType{
        case String,Number,Object
    }
    
    private class func valueWithType(object : AnyObject!)->YTKKeyValueType{
        if object is String{
            return .String
        }else if object as? NSNumber != nil{
            return .Number
        }else{
            return .Object
        }
    }
    
    /**
    加入数据
    
    :param: object    数据
    :param: objectId  数据索引
    :param: tableName 表单名
    */
    
    public func putObject(object : AnyObject! , withId objectId: String! , intoTable tableName: String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        
        let type = YTKKeyValueStore_Swift.valueWithType(object)
        var jsonString : String?
        
        if type == .Number || type == .Object{
            let sqlObject: AnyObject! = type == .Number ? [object] : object
            var error : NSError?
            let data = NSJSONSerialization.dataWithJSONObject(sqlObject, options: NSJSONWritingOptions(0), error: &error)
            if error != nil {
                println("error, faild to get json data")
                return
            }
            jsonString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        }else{
            jsonString = object as? String
        }
        
        let createTime = NSDate()
        let sql = NSString(format: UPDATE_ITEM_SQL, tableName)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:[objectId,jsonString!,createTime])
        })
       
    }
    
    
    /**
    根据ID查找对象
    
    :param: objectId  对象索引
    :param: tableName 表单名
    
    :returns: 对象数据
    */
    public func getObjectById(objectId : String! , fromTable tableName : String! )->YTKObject?{
        let item = self.getYTKKeyValueItemById(objectId, fromTable: tableName)
        if item != nil {
            return item!.itemObject
        }
        return nil
    }
    
    /**
    获取数据封装类型
    
    :param: objectId  对象索引
    :param: tableName 表单名
    
    :returns: 对象数据
    */
    public func getYTKKeyValueItemById(objectId :String! , fromTable tableName : String! )->YTKKeyValueItem_Swift?{
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return nil
        }
        let sql = NSString(format: QUERY_ITEM_SQL, tableName)
        var json : String? = nil
        var createdTime : NSDate? = nil
        dbQueue?.inDatabase({ (db) -> Void in
            var rs : FMResultSet = db.executeQuery(sql, withArgumentsInArray: [objectId])
            if rs.next() {
                json = rs.stringForColumn("json")
                createdTime = rs.dateForColumn("createdTime")
            }
            rs.close()
        })
        if json != nil{
            var item = YTKKeyValueItem_Swift()
            item.itemId = objectId
            item.itemObject = YTKObject(value:  json! )
            item.createdTime = createdTime
            return item
        }else{
            return nil
        }
    }
    
    
    //MARK: 其他
    
    /**
    获取表单的所有的数据
    
    :param: tableName 表单名
    
    :returns: 所有数据
    */
    public func getAllItemsFromTable(tableName : String!)->[YTKKeyValueItem_Swift]?{
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return nil
        }
        let sql = NSString(format: SELECT_ALL_SQL, tableName)
        var result : [YTKKeyValueItem_Swift] = []
        dbQueue?.inDatabase({ (db) -> Void in
            var rs : FMResultSet = db.executeQuery(sql, withArgumentsInArray: nil)
            while(rs.next()){
                var item = YTKKeyValueItem_Swift()
                item.itemId = rs.stringForColumn("id")
                item.itemObject = YTKObject(value:rs.stringForColumn("json"))
                item.createdTime = rs.dateForColumn("createdTime")
                result.append(item)
            }
            rs.close()
        })

        return result == [] ? nil : result
    }
    
    /**
    根据索引删除数据
    
    :param: objectId  索引
    :param: tableName 表单名
    */
    public func deleteObjectById(objectId : String! , fromTable tableName:String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        let sql = NSString(format: DELETE_ITEM_SQL, tableName)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:[objectId])
        })
        if !result! {
            println("error, failed to delete time from table: \(tableName)")
        }
    }
    
    /**
    根据索引数组删除数据
    
    :param: objectIdArray 索引数组
    :param: tableName     表单名
    */
    public func deleteObjectsByIdArray(objectIdArray:[AnyObject]! , fromTable tableName : String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        var stringBuilder = ""
        for objectId in objectIdArray{
            var item = " '\(objectId)' "
            if stringBuilder.isEmpty {
                stringBuilder += "item"
            }else{
                stringBuilder += ",\(item)"
            }
        }
        let sql = NSString(format: DELETE_ITEMS_SQL, tableName,stringBuilder)
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:nil)
        })
        if !result!{
            println("error, failed to delete items by ids from table: \(tableName)")
        }
    }
    
    /**
    根据索引前缀删除数据
    
    :param: objectIdPrefix 索引前缀
    :param: tableName      表单名
    */
    public func deleteObjectsByIdPrefix(objectIdPrefix :String , fromTable tableName:String){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        let sql = NSString(format: DELETE_ITEMS_WITH_PREFIX_SQL, tableName)
        let prefixArgument = "\(objectIdPrefix)%"
        var result : Bool?
        dbQueue?.inDatabase({ (db) -> Void in
            result = db.executeUpdate(sql, withArgumentsInArray:[prefixArgument])
        })
        if !result!{
            println("error, failed to delete items by id prefix from table: \(tableName)")
        }
    }
    
    /**
    关闭数据库
    */
    public func close(){
        dbQueue?.close()
        dbQueue = nil
    }
    
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

