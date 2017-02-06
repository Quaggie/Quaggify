//
//  Image.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct Image: Mappable {
  
  var height: Int?
  var url: String?
  var width: Int?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    height <- map["height"]
    url <- map["url"]
    width <- map["width"]
  }
}

