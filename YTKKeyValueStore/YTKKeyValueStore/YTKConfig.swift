//
//  YTKConfig.swift
//  YTKKeyValueStore
//
//  Created by ysq on 15/2/11.
//  Copyright (c) 2015年 sgxiang. All rights reserved.
//

import UIKit
import SQLite

internal let YTKDEBUG = true

internal func printYTKLog<T>(message: T,
    file: String = __FILE__,
    method: String = __FUNCTION__, line: Int = __LINE__)
{
    if YTKDEBUG{
        println("\(file.lastPathComponent)[\(line)], \(method): \(message)")
    }
}

//文件夹路径
internal let PATH_OF_DOCUMENT : String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String

internal let DEFAULT_DB_NAME = "database_swift.sqlite"

internal let ID = Expression<String>("id")
internal let JSON = Expression<String>("json")
internal let CREATEDTIME = Expression<NSDate>("createdTime")