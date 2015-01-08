//
//  YTKKeyValueStore_SwiftTests.swift
//  YTKKeyValueStore_SwiftTests
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 ysq. All rights reserved.
//

import UIKit
import XCTest
import YTKKeyValueStore_Swift

class YTKKeyValueStore_SwiftTests: XCTestCase {
    
    private var _store : YTKKeyValueStore_Swift?
    private var _tableName : String?
    
    override func setUp() {
        super.setUp()
        _tableName = "test_table"
        _store = YTKKeyValueStore_Swift()
        _store?.createTable(tableName: _tableName!)
        _store?.clearTable(tableName: _tableName!)
    }
    
    override func tearDown() {
        _store?.clearTable(tableName: _tableName)
        _store?.close()
        _store = nil
        super.tearDown()
    }
    
    func testSave(){
        
        let str = "abc"
        let num1 = 1
        let num2 = 1.3
        let user : Dictionary<String,AnyObject> = ["id":1 , "name" : "tangqiao" , "age" : 30]
        
        _store?.putObject(str, withId: "str", intoTable: _tableName)
        _store?.putObject(num1, withId: "num1", intoTable: _tableName)
        _store?.putObject(num2, withId: "num2", intoTable: _tableName)
        _store?.putObject(user, withId: "user", intoTable: _tableName)
        
        
        if let result =  _store?.getObjectById("str", fromTable: _tableName)?.stringValue{
            XCTAssertEqual(str, result)
        }else{
            XCTAssertFalse(true)
        }
        
        if let result = _store?.getObjectById("num1", fromTable: _tableName)?.numberValue{
            XCTAssertEqual(num1, result)
        }else{
            XCTAssertFalse(true)
        }
        
        if let result = _store?.getObjectById("num2", fromTable: _tableName)?.numberValue{
            XCTAssertEqual(num2, result)
        }else{
            XCTAssertFalse(true)
        }
        
        if let result = _store?.getObjectById("user", fromTable: _tableName)?.dictionaryValue{
            XCTAssertEqual(user["id"] as Int, result["id"] as Int)
            XCTAssertEqual(user["name"] as String, result["name"] as String)
            XCTAssertEqual(user["age"] as Int, result["age"] as Int)
        }else{
            XCTAssertFalse(true)
        }
        
        if let result = _store?.getObjectById("user1", fromTable: _tableName)?.dictionaryValue{
            XCTAssertFalse(true)
        }else{
            XCTAssertTrue(true)
        }
        
    }
   
}
