//
//  RefreshTokenResponse.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct RefreshTokenResponse: Mappable {
  
  var accessToken: String?
  var expiresIn: Int?
  var refreshToken: String?
  var tokenType: String?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    accessToken <- map["access_token"]
    expiresIn <- map["expires_in"]
    refreshToken <- map["refresh_token"]
    tokenType <- map["token_type"]
  }
}
