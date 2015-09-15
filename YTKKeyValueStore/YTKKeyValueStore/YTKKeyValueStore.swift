//
//  YTKKeyValueStore_Swift.swift
//  YTKKeyValueStore
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 TangQiao. All rights reserved.
//

import UIKit
import SQLite

public class YTKKeyValueStore{
    
    private var db : Connection?
    
    private init(dbPath : String!) {
        db = try! Connection(dbPath)
    }
    
    convenience public init(_ dbName : String! = DEFAULT_DB_NAME , path : String! = PATH_OF_DOCUMENT) throws{

        self.init(dbPath:"\(path)/\(dbName)")
        
        guard db != nil else{
            throw YTKError.DBConnectionError
        }

    }
    
    public subscript (tableName : String!) -> YTKTable{
        return YTKTable(db: self.db, tableName)
    }
    
    public func createTable(tableName:String!) throws{
        
        guard YTKTable.checkTableName(tableName) else{
            throw YTKError.NameFormatError
        }
        
        do{
            try db?.run(Table(tableName).create(ifNotExists: true){ t in
                t.column(ID,primaryKey:true)
                t.column(JSON)
                t.column(CREATEDTIME,defaultValue:NSDate())
            })
        }catch let error{
            print("failed to create table : \(tableName)")
            throw error
        }

    }
    
    public func dropTable(tableName:String!) throws{
        
        guard YTKTable.checkTableName(tableName) else{
            throw YTKError.NameFormatError
        }
        
        do{
            try db?.run(Table(tableName).drop(ifExists: false))
        }catch let error{
            print("failed to drop table : \(tableName)")
            throw error
        }
        
    }
    
    
}






