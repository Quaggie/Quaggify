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
