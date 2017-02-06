//
//  ExternalUrl.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct ExternalUrls: Mappable {
  var spotify: String?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    spotify <- map["spotify"]
  }
}

