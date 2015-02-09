//
//  YTKKeyValueStore_Swift.swift
//  YTKKeyValueStore
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 TangQiao. All rights reserved.
//

import UIKit
import SQLite

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
    
    private var db : Database?
    
    private let DEFAULT_DB_NAME = "database_swift.sqlite"
    
    private let id = Expression<String>("id")
    private let json = Expression<String>("json")
    private let createTime = Expression<NSDate>("createTime")

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
        if db != nil{
            db = nil
        }
        db = Database(dbPath)
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
        db?.create(table: db![tableName] , ifNotExists : true){t in
            t.column(self.id)
            t.column(self.json)
            t.column(self.createTime, defaultValue: NSDate())
            t.primaryKey(self.id)
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
        db?[tableName].delete()?
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
        
        if let table = db?[tableName]{
            let filter =  table.filter(self.id == objectId).limit(1)
            if filter.isEmpty{
                table.insert(self.id <- objectId , self.json <- jsonString! , self.createTime <- NSDate())?
            }else{
                filter.update(self.json <- jsonString! , self.createTime <- NSDate() )?
            }
        }
       
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
        if let table = db?[tableName]{
            let filter =  table.filter(self.id == objectId).limit(1)
            if filter.isEmpty{
                return nil
            }else{
                var item = YTKKeyValueItem_Swift()
                item.itemId = objectId
                item.itemObject = YTKObject(value: filter.first![self.json] )
                item.createdTime = filter.first!.get(self.createTime)
                return item
            }
            
        }
        return nil
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
        var result : [YTKKeyValueItem_Swift] = []
        
        if let table = db?[tableName]{
            for row in table{
                var item = YTKKeyValueItem_Swift()
                item.itemId = row[self.id]
                item.itemObject = YTKObject(value:row[self.json])
                item.createdTime = row.get(self.createTime)
                result.append(item)
            }
        }
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
        
        if let table = db?[tableName]{
            table.filter(self.id == objectId).delete()?
        }
    }
    
    /**
    根据索引数组删除数据
    
    :param: objectIdArray 索引数组
    :param: tableName     表单名
    */
    public func deleteObjectsByIdArray(objectIdArray:[String]! , fromTable tableName : String!){
        if !YTKKeyValueStore_Swift.checkTableName(tableName){
            return
        }
        db?[tableName].filter(contains(objectIdArray, id)).delete()?
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
        db?[tableName].filter( like("\(objectIdPrefix)%", self.id)).delete()?
    }
    
    /**
    关闭数据库
    */
    public func close(){
        self.db = nil
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

