//
//  AppDelegate.swift
//  YTKKeyValueStore_Swift
//
//  Created by ysq on 14/12/15.
//  Copyright (c) 2014年 ysq. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let store = YTKKeyValueStore("test.db")
        store.createTable("user")
        
        let key = "1"
        let user = ["id":1 , "name" : "tangqiao" , "age" : 30]
        
        let userTable = store["user"]
        
        println("user table isExists :  \(userTable.isExists)")
        
        userTable.delete()
        
        userTable.put( key <- (user as NSDictionary)  )
        
        if let queryUser = userTable.get(key)?.dictionaryValue{
            println("query data result : \(queryUser)")
        }
        
        return true
    }


}

