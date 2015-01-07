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
    
    func testSaveString(){
       
        let str1 = "abc"
        let key1 = "key1"
        let str2 = "abc2"
        let key2 = "key2"
        
        _store?.putString(str1, withId: key1, intoTable: _tableName)
        _store?.putString(str2, withId: key2, intoTable: _tableName)
        
        var result : String?
        
        result = _store?.getStringById(key1, fromTable: _tableName)
        XCTAssertNotNil(result)
        XCTAssertEqual(str1, result!)
        
        result = _store?.getStringById(key2, fromTable: _tableName)
        XCTAssertNotNil(result)
        XCTAssertEqual(str2, result!)
        
        result = _store?.getStringById("key3", fromTable: _tableName)
        XCTAssertNil(result)
        
    }
    
    func testSaveCGFloat(){
        
        let num1 : CGFloat = 1
        let key1 = "key1"
        let num2 : CGFloat = 2
        let key2 = "key2"
        
        _store?.putNumber(num1, withId: key1, intoTable: _tableName)
        _store?.putNumber(num2, withId: key2, intoTable: _tableName)
        
        var result : CGFloat?
        
        result = _store?.getNumberById(key1, fromTable: _tableName)
        XCTAssertNotNil(result)
        XCTAssertEqual(num1, result!)
        
        result = _store?.getNumberById(key2, fromTable: _tableName)
        XCTAssertNotNil(result)
        XCTAssertEqual(num2, result!)
        
        result = _store?.getNumberById("key3", fromTable: _tableName)
        XCTAssertNil(result)
    
    }
    
}
