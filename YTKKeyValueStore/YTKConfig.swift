//
//  YTKConfig.swift
//  YTKKeyValueStore
//
//  Created by ysq on 15/2/11.
//  Copyright (c) 2015年 sgxiang. All rights reserved.
//

import UIKit
import SQLite

public let YTKDEBUG = true

public let PATH_OF_DOCUMENT : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

public let DEFAULT_DB_NAME = "database_swift.sqlite3"

public let ID = Expression<String>("id")
public let JSON = Expression<String>("json")
public let CREATEDTIME = Expression<Date>("createdTime")
