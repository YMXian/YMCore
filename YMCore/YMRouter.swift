//
//  YMRouter.swift
//  YMCore
//
//  Created by Yanke Guo on 16/1/26.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

/// Action for a router item

typealias YMRouterAction = (params: Dictionary<String,String>) -> Void

/// YMAbstractRouter abstracts the function of a Router, enables external objects to work together

public protocol YMAbstractRouter {

  /// Handle incoming url
  ///
  /// :param: url the incoming url
  /// :returns: whether incoming url has been recognized and proceed
  ///
  func routeUrl(url: NSURL) -> Bool

}

/// Extend YMAbstractRouter for some convenient methods

extension YMAbstractRouter {

  /// Handle incoming url string
  ///
  /// :param: urlString the incoming url string
  /// :returns: whether incoming url string has been recognized and proceed
  ///
  func routeUrlString(urlString: String) -> Bool {
    if (urlString.isEmpty) {
      return false
    }
    if let url = NSURL(string: urlString) {
      return self.routeUrl(url)
    } else {
      return false
    }
  }

}

/// YMRouter provides a basic YMAbstractRouter implementation with a default scheme

public class YMRouter: YMAbstractRouter {

  /// Main scheme of this router
  public let scheme: String

  /// Init a YMRouter
  /// :param: scheme the main scheme of this router
  ///
  public init(scheme: String) {
    self.scheme = scheme
  }

  /// Register a sub-router for specified scheme
  public func registerRouter(router: YMAbstractRouter, forScheme scheme:String) {
  }

  /// Handle incoming url
  ///
  /// :param: url the incoming url
  ///
  /// :returns: Bool whether incoming url has been recognized and proceed
  ///
  public func routeUrl(url: NSURL) -> Bool {
    return true
  }
}

/// Extend YMRouter with some convenient methods

extension YMRouter {

  /// Handle a path, with default scheme
  ///
  /// :param: path the path of incoming url
  ///
  /// :returns: Bool whether incoming url has been recognized and proceed
  ///
  public func routePath(path: String, params: [String:String] = [:]) -> Bool {
    // create a NSURLComponents
    if let urlComponents = NSURLComponents(string: path) {
      // set scheme
      urlComponents.scheme = self.scheme
      // enumerate params and append to urlComponent.queryItems
      if !params.isEmpty {
        var queryItems = urlComponents.queryItems ?? []
        for (key, value) in params {
          queryItems.append(NSURLQueryItem(name: key, value: value))
        }
        urlComponents.queryItems = queryItems
      }
      // create URL
      if let url = urlComponents.URL {
        return self.routeUrl(url)
      }
    }
    return false
  }

  /// Fix NSURL by padding host to first path components
  ///
  /// Pad scheme://path/to/action to scheme:///path/to/action to use host as first path component
  ///
  /// :param: url the incoming url
  ///
  /// :returns: NSURL the fixed url
  ///
  private func fixedUrl(url: NSURL) -> NSURL {
    let falsePrefix = "\(self.scheme)://"
    let rightPrefix = "\(self.scheme):///"
    if !(url.absoluteString.hasPrefix(rightPrefix)) {
      let urlString = url.absoluteString.stringByReplacingOccurrencesOfString(falsePrefix, withString: rightPrefix)
      if let fixedUrl = NSURL(string: urlString) {
        return fixedUrl
      }
    }
    return url
  }

}
