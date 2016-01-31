//
//  CallbackStore.swift
//  YMCore
//
//  Created by Yanke Guo on 16/1/31.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

public class CallbackStore<T> {

  public typealias CallbackHandler = (T) -> Void

  private let expirationConfig: (NSTimeInterval, CallbackHandler)?

  private var callbacks = [UInt : T]()

  private var callbackId: UInt = 0

  public init(expires: NSTimeInterval? = nil, expirationHandler: CallbackHandler? = nil) {
    if expires != nil && expirationHandler != nil {
      self.expirationConfig = (expires!, expirationHandler!)
    } else {
      self.expirationConfig = nil
    }
  }

  public func addCallback(callback: T) -> UInt {
    let callbackId = bumpCallbackId()
    self.callbacks[callbackId] = callback
    if let (expires, expirationCallbackHandler) = self.expirationConfig {
      dispatch_main_after(expires, block: {
        if let callback = self.callbacks[callbackId] {
          self.callbacks.removeValueForKey(callbackId)
          expirationCallbackHandler(callback)
        }
      })
    }
    return callbackId
  }

  public func invokeAndRemoveAllCallbacks(handler: CallbackHandler) {
    dispatch_async_main {
      for callback in self.callbacks.values {
        handler(callback)
      }
      self.callbacks.removeAll()
    }
  }

  public func removeCallbackWithId(callbackId: UInt) {
    dispatch_sync_main_alt {
      self.callbacks.removeValueForKey(callbackId)
    }
  }

  private func bumpCallbackId() -> UInt {
    dispatch_sync_main_alt {
      self.callbackId = self.callbackId + 1
    }
    return self.callbackId
  }

}
