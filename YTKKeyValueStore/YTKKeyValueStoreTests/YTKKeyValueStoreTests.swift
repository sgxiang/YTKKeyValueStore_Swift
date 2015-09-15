//
//  YTKKeyValueStore_SwiftTests.swift
//  YTKKeyValueStore_SwiftTests
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 ysq. All rights reserved.
//

import UIKit
import XCTest
import YTKKeyValueStore

class YTKKeyValueStoreTests : XCTestCase {
    
    private var _store : YTKKeyValueStore!
    private var _table : YTKTable!
    
    override func setUp() {
        super.setUp()
        
        do{
            _store = try YTKKeyValueStore("db_test.db")
        }catch let error as NSError{
            print(error.localizedDescription)
            return
        }
        
        do{
            try _store.createTable("test_table")
            _table = _store["test_table"]
        }catch let error as NSError{
            print(error.localizedDescription)
            return
        }
        
    }
    
    override func tearDown() {
        try! _table.clear()
        try! _store.dropTable("test_table")
        super.tearDown()
    }

    func testSave(){
        
        let str = "abc"
        let num1 = 1
        let num2 = 1.3
        let user : Dictionary<String,AnyObject> = ["id":1 , "name" : "tangqiao" , "age" : 30]
        
        try! _table.put("str" <- str )
        try! _table.put("num1" <- num1)
        try! _table.put("num2" <- num2)
        try! _table.put("user" <- user)
        
        
        if let result =  _table.get("str")?.stringValue{
            XCTAssertEqual(str, result)
        }else{
            XCTAssertFalse(true)
        }
        
        if let result =  _table.get("num1")?.numberValue{
            XCTAssertEqual(num1, result)
        }else{
            XCTAssertFalse(true)
        }
        
        if let result =  _table.get("num2")?.numberValue{
            XCTAssertEqual(num2, result)
        }else{
            XCTAssertFalse(true)
        }
        
        if let result =  _table.get("user")?.dictionaryValue{
            XCTAssertEqual(user["id"] as? Int, result["id"] as? Int)
            XCTAssertEqual(user["name"] as? String, result["name"] as? String)
            XCTAssertEqual(user["age"] as? Int, result["age"] as? Int)
        }else{
            XCTAssertFalse(true)
        }
        
        if let _ =  _table.get("user!")?.dictionaryValue{
            XCTAssertFalse(true)
        }else{
            XCTAssertTrue(true)
        }
        
    }
    
}
