//
//  ExternalIds.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct ExternalIds: Mappable {
  var isrc: String?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    isrc <- map["isrc"]
  }
}
