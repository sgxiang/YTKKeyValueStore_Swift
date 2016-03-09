YTKKeyValueStore
==========

[![CocoaPods Version](https://cocoapod-badges.herokuapp.com/v/YTKKeyValueStore_Swift/badge.png)](http://cocoadocs.org/docsets/YTKKeyValueStore_Swift) [![Platform](https://cocoapod-badges.herokuapp.com/p/YTKKeyValueStore_Swift/badge.png)](http://cocoadocs.org/docsets/YTKKeyValueStore_Swift) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)

objc version ：https://github.com/yuantiku/YTKKeyValueStore



## Requirements

- iOS 8.0+ 
- Xcode 7.0
- Swift 2.0

## Usage 

```swift
import YTKKeyValueStore
```

### YTKKeyValueStore

```swift
var store = try! YTKKeyValueStore("test.db")   // create or open the key-value store

try! store.createTable("User")    // create table

let table = store["User"]      // get table (YTKTable)

try! store.dropTable("User")    // drop table
```

### YTKTable

```swift
let isExists = table.isExists

try! table.put( "name" <- "sgxiang")     // put value("sgxiang") for key("name") into table , support string,number,dictionary,array


let objct = try! table.get("name")    // get object with key , return YTKObject?
let item = try! table.getItem("name")   // get item with key ,return YTKItem?
let allItems = try! table.getAllItems()  // get all item with key , return  [YTKItem]?


try! table.clear()  // clear table
try! table.delete("name1","name2")   // delete row where key == "name1" and "name2"
try! table.deletePreLike("name")   // delete row where key pre like "name"
```

### YTKItem

```
itemId       :   itemKey
itemObject   :   itemValue , is json string
createdTime  :   item created time
```
### YTKObject

```
objectValue       :     return  AnyObject?
stringValue       :     return  String?
numberValue       :     return  NSNumber?
dictionaryValue   :     return  Dictionary<String , AnyObject>?
arrayValue        :     return  Array<AnyObject>?
```

## Installation

### Embedded Framework

- Add YTKKeyValueStore as a submodule by opening the Terminal, cd-ing into your top-level project directory, and entering the following command:

```
$ git submodule add https://github.com/Sgxiang/YTKKeyValueStore_Swift.git
```
- Open the YTKKeyValueStore folder, and drag YTKKeyValueStore.xcodeproj into the file navigator of your app project.

- In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.

- Ensure that the deployment target of YTKKeyValueStore.framework matches that of the application target.

- In the tab bar at the top of that window, open the "Build Phases" panel.
Expand the "Target Dependencies" group, and add YTKKeyValueStore.framework.

- Click on the + button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add YTKKeyValueStore.framework.

### CocoaPods

Update Podfile to include the following:

```
use_frameworks!

pod 'YTKKeyValueStore_Swift', '~> 0.3.4'
```

Run `pod install`

## Communication

- Found a bug or have a feature request? [Open an issue](https://github.com/sgxiang/YTKKeyValueStore_Swift/issues).

- Want to contribute? [Submit a pull request](https://github.com/sgxiang/YTKKeyValueStore_Swift/pulls).

## Author

- [sgxiang](https://twitter.com/sgxiang1992)

