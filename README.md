YTKKeyValueStore_Swfit
==========

`YTKKeyValueStore`的swift版本

源oc版地址：https://github.com/yuantiku/YTKKeyValueStore

![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

## 0.2.1 

* 移除FMDB
* 加入`SQLite` (swift版本) 作为底层数据库    ->  github地址： [https://github.com/stephencelis/SQLite.swift](https://github.com/stephencelis/SQLite.swift)
* 优化部分操作


## 使用示例

```swift
var store = YTKKeyValueStore_Swift(dbName: "test_siwft.db")
let tableName = "user_table_swift"
store.createTable(tableName: tableName)
//保存
let key = "1"
let user = ["id":1 , "name" : "tangqiao" , "age" : 30]
store.putObject(user, withId: key, intoTable: tableName)
//查询
if let queryUser: AnyObject = store.getObjectById(key, fromTable: tableName)?.dictionaryValue{
	println("[swift] query data result: \(queryUser)")
}
```

## 使用说明

所有的接口都封装在`YTKKeyValueStore_Swift.swift`类中。以下是一些常用方法说明。

### 打开（或创建）数据库

通过`init(dbName:)`方法，即可在程序的`Document`目录打开指定的数据库文件。如果该文件不存在，则会创建一个新的数据库。

```swift
// 打开名为test.db的数据库，如果该文件不存在，则创新一个新的。
var store = YTKKeyValueStore_Swift(dbName: "test.db")
```

### 创建数据库表

通过`createTable(tableName:)`方法，我们可以在打开的数据库中创建表，如果表名已经存在，则会忽略该操作。如下所示：

```swift
var store = YTKKeyValueStore_Swift(dbName: "test.db")
let tableName = "user_table"
// 创建名为user_table的表，如果已存在，则忽略该操作
store.createTable(tableName: tableName)
```

### 读写数据

`YTKKeyValueStore_Swift`类提供key-value的存储接口，存入的所有数据需要提供key以及其对应的value，读取的时候需要提供key来获得相应的value。

`YTKKeyValueStore_Swift`类支持的value类型包括：字符串, 数字, 字典和数组，为此提供了以下接口：

```
//写入数据
putObject(objct:withId:intoTable:)
//读取数据
getObjectById(objectId:fromTable:)->YTKObject?
```

### 删除数据接口

`YTKKeyValueStore_Swift`提供了以下接口用于删除数据。

```
// 清除数据表中所有数据
clearTable(#tableName:)

// 删除指定key的数据
deleteObjectById(objectId:fromTable:)

// 批量删除一组key数组的数据
deleteObjectsByIdArray(objectIdArray:fromTable:)

// 批量删除所有带指定前缀的数据
deleteObjectsByIdPrefix(objectIdfix:fromTable:)
```

### 更多接口

`YTKKeyValueStore_Swift`还提供了以下接口来获取表示内部存储的key-value对象。

```
// 获得指定key的数据
getYTKKeyValueItemById(objectId:fromTable:)->YTKKeyValueItem_Swift?
// 获得所有数据
getAllItemsFromTable(tableName:)->[YTKKeyValueItem_Swift]?
```

由于`YTKKeyValueItem_Swift`类带有`createdTime`字段，可以获得该条数据的插入（或更新）时间，以便上层做复杂的处理（例如用来做缓存过期逻辑）。

### `YTKObject`对象

`getObjectById(objectId:fromTable:)->YTKObject?`返回的YTKObject?对象有以下属性来读取所需要的数据。

```
objectValue       读取出AnyObject?的类型
stringValue       读取出String?的类型
numberValue       读取出NSNumber?的类型
dictionaryValue   读取出Dictionary<String , AnyObject>?的类型
arrayValue        读取出Array<AnyObject>?的类型
```

