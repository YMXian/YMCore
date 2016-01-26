//
//  YMLogger.swift
//  YMCore
//
//  Created by Yanke Guo on 16/1/26.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

public let kYMLoggerThreadLocalName = "com.juxian.logger.thread-local-name"

public let YMLoggerDefaultThreadLocalName = "default"

public enum YMLogLevel: Int {
  case Debug = 0
  case Info  = 1
  case Warn  = 2
  case Error = 3
  case Fatal = 5

  func shortName() -> String {
    return ["D", "I", "W", "E", "-", "F"][self.rawValue]
  }
}

public func Logger(target: AnyObject? = nil) -> YMLogger {
  if let target = target {
    return YMLogger.sharedInstance.of(String(target.dynamicType))
  } else {
    return YMLogger.sharedInstance.of(YMLoggerDefaultThreadLocalName)
  }
}

public class YMLogger {

  public static let sharedInstance = YMLogger()

  public var name: String {
    get {
      return NSThread.currentThread().threadDictionary[kYMLoggerThreadLocalName] as? String ?? YMLoggerDefaultThreadLocalName
    }
    set(newValue) {
      NSThread.currentThread().threadDictionary[kYMLoggerThreadLocalName] = newValue
    }
  }

  private var logLevelOverrides = [String: YMLogLevel]()

  public var defaultMinLogLevel = YMLogLevel.Warn

  public var minLogLevel: YMLogLevel {
    get {
      return self.logLevelOverrides[self.name] ?? self.defaultMinLogLevel
    }
    set(newValue) {
      self.logLevelOverrides[self.name] = newValue
    }
  }

  public func clearMinLogLevel() -> Self {
    self.logLevelOverrides.removeValueForKey(self.name)
    return self
  }

  public func of(name: String) -> Self {
    self.name = name
    return self
  }

  public func log(level: YMLogLevel, items: [Any], line: UInt = __LINE__, file: StaticString = __FILE__) -> Self {
    if level.rawValue >= self.minLogLevel.rawValue {
      print("\(level.shortName()), (\((file.stringValue as NSString).lastPathComponent):\(line)) \(self.name):", items.map({ v in String(v) }).joinWithSeparator(" "))
    }
    return self
  }

  public func debug(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) -> Self {
    return log(.Debug, items: items, line : line, file : file)
  }

  public func info(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) -> Self {
    return log(.Debug, items: items, line : line, file : file)
  }

  public func warn(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) -> Self {
    return log(.Debug, items: items, line : line, file : file)
  }

  public func error(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) -> Self {
    return log(.Debug, items: items, line : line, file : file)
  }

  public func fatal(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) -> Self {
    return log(.Fatal, items: items, line : line, file : file)
  }

}
