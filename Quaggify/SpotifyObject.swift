//
//  SpotifyObject.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct SpotifyObject<T: Mappable>: Mappable {
  var href: String?
  var limit: Int?
  var next: String?
  var offset: Int?
  var previous: String?
  var total: Int?
  var items: [T]?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    href <- map["href"]
    limit <- map["limit"]
    next <- map["next"]
    offset <- map["offset"]
    previous <- map["previous"]
    total <- map["total"]
    items <- map["items"]
  }
}

extension SpotifyObject: Equatable {
  static func ==(lhs: SpotifyObject<T>, rhs: SpotifyObject<T>) -> Bool {
    return lhs.href == rhs.href &&
    lhs.limit == rhs.limit &&
    lhs.next == rhs.next &&
    lhs.offset == rhs.offset &&
    lhs.previous == rhs.previous &&
    lhs.total == rhs.total &&
    lhs.items?.count == rhs.items?.count
  }
}
