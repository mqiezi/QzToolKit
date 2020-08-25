# QzToolKit

[![CI Status](https://img.shields.io/travis/mqiezi/QzToolKit.svg?style=flat)](https://travis-ci.org/mqiezi/QzToolKit)
[![Version](https://img.shields.io/cocoapods/v/QzToolKit.svg?style=flat)](https://cocoapods.org/pods/QzToolKit)
[![License](https://img.shields.io/cocoapods/l/QzToolKit.svg?style=flat)](https://cocoapods.org/pods/QzToolKit)
[![Platform](https://img.shields.io/cocoapods/p/QzToolKit.svg?style=flat)](https://cocoapods.org/pods/QzToolKit)


## `QzToolkit` 工具库说明

`QzToolkit` 工具库是日常工程开发中收集整理聚合成的一些常用工具代码。有些代码已经记不起摘自哪里，觉得好用就收集在这里做一个通用工具。


+ `QzMacros`:
  `QzMacros` 中提供了一些工程开发中常用的宏。

+ `QzLogger`:
  `QzLogger` 中提供了简易的日志工具，支持日志的终端显示和本地存储。

+ `QzUserDefaults`:
  `QzUserDefaults`中提供`NSUserDefaults`的简易封装。

+ `QzKeyChain`:
   `QzKeyChain`中提供`KeyChain`的简易封装。

+ `QzExtension`:
  `QzExtension`中包含一些常用的扩展方法，为了避免使用`-ObjC、-all_load`等编译参数，这里都写成`QzExtension`的类方法。

+ `QzCryptor`:
  `QzCryptor`中包含一些常用的加密、解密方法(如：AES、RSA)。具体实现来源自`github`中的一些相关加解密库（例如：[CommonCrypto](https://github.com/lgc107/CommonCrypto/tree/master/CommonCrypto)）.

+ `QzReachability`:
  `QzReachability`中是常用的网络状态库，也收集自网络。

+ `QzLocation`:
  `QzLocation`提供地理位置获取。

+ `QzUA`:
  `QzUA`提供`UserAgent`获取.

+ `QzFileManager`:
  `QzFileManager`提供常用文件位置的获取、文件的下载缓存(参考`SDWebImage`)等。
  
+  `QzError`：
    `QzError`是错误码定义的一个示例。
    
+  `QzQueue`:
    `QzQueue`通过泛型方式定义一个队列。
    
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

QzToolKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'QzToolKit'
```

## Author

mqiezi, mqiezi@qq.com

## License

QzToolKit is available under the MIT license. See the LICENSE file for more info.
