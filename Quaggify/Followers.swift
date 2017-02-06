//
//  Followers.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct Followers: Mappable {
  var href: String?
  var total: Int?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    href <- map["href"]
    total <- map["total"]
  }
}
