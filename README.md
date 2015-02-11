YTKKeyValueStore_Swfit
==========

`YTKKeyValueStore`的swift版本

源oc版地址：https://github.com/yuantiku/YTKKeyValueStore

![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)


## 要求

- iOS 7.0+ 
- Xcode 6.3

## 使用说明


### YTKKeyValueStore

```swift
// 打开名为test.db的数据库，如果该文件不存在，则创新一个新的。
var store = YTKKeyValueStore("test.db")

// 创建table
store.createTable("User")

// 获取一个table对象 -> YTKTable
let table = store["User"]

// 丢弃一个table 
store.deopTable("User")
```

### YTKTable

```swift
// 判断table是否存在
let isExists = table.isExists

// 写入数据 【支持字符串，数字，字典，数组】
table.put( "name" <- ("sgxiang" as NSString) )

// 获取数据
let objct = table.get("name")    // YTKObject?
let item = table.getItem("name")   // YTKItem?
let allItems = table.getAllItems()  // [YTKItem]?

// 删除数据
table.delete()  //删除所有数据
table.delete(like:false , name)   //删除键为name的数据
table.delete(like:false , name , name2)   //删除键为name name2的数据 
table.delete(like:true , name)   //删除键前缀为name的数据
table.delete(like:true , name , name2)   //删除键前缀为name name2的数据  
```

### YTKItem

有三个属性，分别保存数据的ID，数据的值，数据创建的时间

### YTKObject

```
objectValue       读取出AnyObject?的类型
stringValue       读取出String?的类型
numberValue       读取出NSNumber?的类型
dictionaryValue   读取出Dictionary<String , AnyObject>?的类型
arrayValue        读取出Array<AnyObject>?的类型
```




