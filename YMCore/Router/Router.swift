//
//  Router.swift
//  Core
//
//  Created by Yanke Guo on 16/1/26.
//  Copyright © 2016年 Juxian(Beijing) Technology Co., Ltd. All rights reserved.
//

import Foundation

/// Action for a router item

public typealias RouterAction = (params: Dictionary<String,String>) -> Void

/// AbstractRouter abstracts the function of a Router, enables external objects to work together

public protocol AbstractRouter {

  /// Handle incoming url
  ///
  /// :param: url the incoming url
  /// :returns: whether incoming url has been recognized and proceed
  ///
  func routeUrl(url: NSURL) -> Bool

}

/// Extend AbstractRouter for some convenient methods

extension AbstractRouter {

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

/// RouteEntryComponent stands for a path component of routing path

private struct RouteEntryComponent {

  /// Whether this component is a wildcard
  let isWildcard: Bool

  /// the value of this path component
  let value: String

}

/// RouteEntry stands for a entry

private struct RouteEntry {

  /// path components
  let components: [RouteEntryComponent]

  /// action
  let action: RouterAction

  init(pattern: String, action: RouterAction) {
    var components = [RouteEntryComponent]()
    for component in (pattern as NSString).pathComponents {
      if !component.isEmpty {
        if component.hasPrefix(":") {
          components.append(RouteEntryComponent(isWildcard: true, value: component.substringFromIndex(component.startIndex.advancedBy(1))))
        } else {
          components.append(RouteEntryComponent(isWildcard: false, value: component as String))
        }
      }
    }
    self.components = components
    self.action = action
  }

  /// Match against url components components
  ///
  /// :param: components decomposed url path components
  ///
  /// :returns: nil if not matched, [String:String] if matched
  ///
  func match(components: [String]) -> [String:String]? {
    // return nil if count not equal
    if components.count != self.components.count {
      return nil
    }
    // prepare the result
    var result = [String:String]()

    for (index, component) in self.components.enumerate() {
      let src = components[index]
      //  set key-value if isWildcard
      if component.isWildcard {
        result[component.value] = src
      } else {
        //  return nil if not equals
        if component.value != src {
          return nil
        }
      }
    }

    return result
  }

}

/// Router provides a basic AbstractRouter implementation with a default scheme

public class Router: AbstractRouter, Loggable {

  /// Main scheme of this router
  public let scheme: String

  /// Storage for alias
  private var alias = [String:String]()

  /// Sub-routers
  private var subRouters = [String: AbstractRouter]()

  /// Routes
  private var routes = [RouteEntry]()

  /// Init a Router
  /// :param: scheme the main scheme of this router
  ///
  public init(scheme: String) {
    self.scheme = scheme
  }

  /// Register a sub-router for specified scheme
  public func registerRouter(router: AbstractRouter, forScheme scheme: String) {
    self.subRouters[scheme] = router
  }

  /// Handle incoming url
  ///
  /// :param: url the incoming url
  ///
  /// :returns: Bool whether incoming url has been recognized and proceed
  ///
  public func routeUrl(url: NSURL) -> Bool {
    // try self first
    if url.scheme == self.scheme {
      if internalRouteUrl(fixedUrl(url)) {
        return true
      }
    }
    // find a subRouter and send url to it
    if let subRouter = self.subRouters[url.scheme] {
      return subRouter.routeUrl(url)
    }
    WLog("Cannot route url \(url)")
    return false
  }

  /// Register a route
  ///
  /// :param: path
  /// :param: action
  ///
  /// :returns: self

  public func on(path: String, action: RouterAction) -> Self {
    self.routes.append(RouteEntry(pattern: path, action: action))
    return self
  }

  /// Create a alias
  ///
  /// :param: from
  /// :param: to
  ///
  /// :returns: self

  public func alias(from: String, to: String) -> Self {
    self.alias[from] = to
    return self
  }

  private func internalRouteUrl(url: NSURL) -> Bool {
    let orignalPath = url.path ?? ""
    let path = self.alias[orignalPath] ?? orignalPath
    // get path components
    let components = (path as NSString).pathComponents
    if components.isEmpty {
      return false
    }
    // try routes
    for route in self.routes {
      if let routeParams = route.match(components) {
        var params = routeParams
        // resolve query items
        let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
        if let queryItems = urlComponents?.queryItems {
          for queryItem in queryItems {
            params[queryItem.name] = queryItem.value ?? ""
          }
        }
        // execute action
        route.action(params: params)
        return true
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

/// Extend Router with some convenient methods

extension Router {

  /// Handle a path, with default scheme
  ///
  /// :param: path the path of incoming url
  ///
  /// :returns: Bool whether incoming url has been recognized and proceed
  ///
  public func routePath(path: String, params: [String: String] = [:]) -> Bool {
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

}
