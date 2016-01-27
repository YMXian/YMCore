//
//  YMLogger.swift
//  YMCore
//
//  Created by Yanke Guo on 16/1/26.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

//  MARK: - YMLogLevel Enum

/**
 Log Level

 - Debug: DEBUG
 - Info:  INFO
 - Warn:  WARN
 - Error: ERROR
 - Crit:  CRIT
 - Fatal: FATAL
 */
public enum YMLogLevel: Int {

  case Debug = 0
  case Info  = 1
  case Warn  = 2
  case Error = 3
  case Crit  = 4
  case Fatal = 5

  public func shortName() -> String {
    return ["D", "I", "W", "E", "C", "F"][self.rawValue]
  }

  public func name() -> String {
    return ["DEBUG", "INFO", "WARN", "ERROR", "CRIT", "FATAL"][self.rawValue]
  }
}

//  MARK: - YMLogger Globals

/// Default minLevel for logger
public var YMLoggerDefaultMinLevel = YMLogLevel.Warn

/// Default name for logger
public var YMLoggerDefaultName     = "default"

/// Overriden for default min log level
private var YMLoggerMinLogLevelOverriden = [String : YMLogLevel]()

//  MARK: - YMAbstractLogger

/**
 *  YMAbstractLogger abstracts the most basic method for logging
 */
public protocol YMAbstractLogger {

  /**
   Basic log method

   - parameter level: level
   - parameter items: items for logging, will concat
   - parameter line:  line of code
   - parameter file:  file of code

   */
  func Log(level: YMLogLevel, items: [Any], line: UInt, file: StaticString)

}

/**
 *  Add convenient methods to YMAbstractLogger
 */
extension YMAbstractLogger {

  public func DLog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
    Log(.Debug, items: items, line : line, file : file)
  }

  public func ILog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
    Log(.Debug, items: items, line : line, file : file)
  }

  public func WLog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
    Log(.Debug, items: items, line : line, file : file)
  }

  public func ELog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
    Log(.Debug, items: items, line : line, file : file)
  }

  public func CLog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
    Log(.Crit, items: items, line : line, file : file)
  }

  public func FLog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
    Log(.Fatal, items: items, line : line, file : file)
  }

}

//  MARK: - YMLoggable

/**
 *  Loggable Protocol, just include this into your class / struct / enum
 */
public protocol YMLoggable: YMAbstractLogger {

  /// loggable name for identification and display
  func loggableName() -> String

}

/**
 *  Implement YMAbstractLogger for YMLoggable
 */
public extension YMLoggable {

  public func Log(level: YMLogLevel, items: [Any], line: UInt = __LINE__, file: StaticString = __FILE__) {
    if level.rawValue >= minLogLevel().rawValue {
      print("\(level.shortName()), (\((file.stringValue as NSString).lastPathComponent):\(line)) \(loggableName()):", items.map({ v in String(v) }).joinWithSeparator(" "))
    }
  }

  /**
   Loggable name

   - returns: type name by default
   */
  public func loggableName() -> String {
    return String(self.dynamicType)
  }

  /**
   Get the min log level for current name

   - returns: level, default level is returned if not set
   */
  public func minLogLevel() -> YMLogLevel {
    return YMLoggerMinLogLevelOverriden[loggableName()] ?? YMLoggerDefaultMinLevel
  }

  /**
   Set the min log level for current name

   - parameter level: min log level, nil to use default
   */
  public func setMinLogLevel(level: YMLogLevel?) {
    if let level = level {
      YMLoggerMinLogLevelOverriden[loggableName()] = level
    } else {
      YMLoggerMinLogLevelOverriden.removeValueForKey(loggableName())
    }
  }
}

//  MARK: - Logger for Wild Use

private class YMWildLogger: YMLoggable {

  static let shared = YMWildLogger()

  func loggableName() -> String { return YMLoggerDefaultName }
}

public func Log(level: YMLogLevel, items: [Any], line: UInt = __LINE__, file: StaticString = __FILE__) {
  YMWildLogger.shared.Log(level, items: items, line: line, file: file)
}

public func DLog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
  Log(.Debug, items: items, line : line, file : file)
}

public func ILog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
  Log(.Debug, items: items, line : line, file : file)
}

public func WLog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
  Log(.Debug, items: items, line : line, file : file)
}

public func ELog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
  Log(.Debug, items: items, line : line, file : file)
}

public func CLog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
  Log(.Crit, items: items, line : line, file : file)
}

public func FLog(items: Any..., line: UInt = __LINE__, file: StaticString = __FILE__) {
  Log(.Fatal, items: items, line : line, file : file)
}
