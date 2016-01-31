//
//  ExpirableStore.swift
//  YMCore
//
//  Created by Yanke Guo on 16/1/31.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

public class ExpirableStore<T> {

  public typealias ElementHandler = (T) -> Void

  public typealias ElementId      = Int64

  private var elements = [ElementId : T]()

  private var currentElementId: ElementId = 0

  private let expires: NSTimeInterval

  private let expirationHandler: ElementHandler?

  public init(expires: NSTimeInterval, expirationHandler: ElementHandler? = nil) {
    self.expires = expires
    self.expirationHandler = expirationHandler
  }

  public func add(element: T) -> ElementId {
    let elementId = bumpElementId()
    self.elements[elementId] = element
    dispatch_main_after(self.expires) {
      if let element = self.elements.removeValueForKey(elementId) {
        self.expirationHandler?(element)
      }
    }
    return elementId
  }

  public func enumerateAndRemoveAll(handler: ElementHandler) {
    dispatch_async_main {
      for element in self.elements.values {
        handler(element)
      }
      self.elements.removeAll()
    }
  }

  public func remove(elementId: ElementId) {
    dispatch_sync_main_alt {
      self.elements.removeValueForKey(elementId)
    }
  }

  private func bumpElementId() -> ElementId {
    dispatch_sync_main_alt {
      self.currentElementId = self.currentElementId &+ 1
    }
    return self.currentElementId
  }

}
