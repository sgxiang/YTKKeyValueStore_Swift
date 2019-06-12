Pod::Spec.new do |s|
  s.name         = "YTKKeyValueStore_Swift"
  s.version      = "0.5.0"
  s.summary      = "A simple Key-Value storage tool, using Sqlite as backend."
  s.homepage     = "https://github.com/sgxiang/YTKKeyValueStore_Swift"
  s.license      = "MIT"
  s.author       = { "sgxiang" => "690228918@qq.com" }
  s.platform     = :ios, '9.0'
  s.source       = { :git => "https://github.com/sgxiang/YTKKeyValueStore_Swift.git", :tag => "0.5.0" }
  s.source_files = "YTKKeyValueStore/*.swift"
  s.requires_arc = true
  s.module_name  = 'YTKKeyValueStore'
  s.dependency   "SQLite.swift", "~> 0.12.0"
end