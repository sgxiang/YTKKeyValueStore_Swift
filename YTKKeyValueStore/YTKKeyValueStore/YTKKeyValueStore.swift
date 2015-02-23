//
//  YTKKeyValueStore_Swift.swift
//  YTKKeyValueStore
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 TangQiao. All rights reserved.
//

import UIKit
import SQLite

public class YTKKeyValueStore : NSObject{
    
    private var db : Database?
    
    public init(_ dbName : String! = DEFAULT_DB_NAME , path : String! = PATH_OF_DOCUMENT){
        let dbPath = path.stringByAppendingPathComponent(dbName)
        printYTKLog("dbPath = \(path)")
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
            printYTKLog("failed to create table : \(tableName)")
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
            printYTKLog("failed to drop table : \(tableName)")
            return false
        }
        
    }
    
    
}


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






