//
//  Album.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit
import ObjectMapper

struct Album: Mappable {
  
  var albumType: String?
  var artists: [Artist]?
  var availableMarkets: [String]?
  var externalUrls: ExternalUrls?
  var href: String?
  var id: String?
  var images: [Image]?
  var name: String?
  var type: SpotifyObjectType?
  var uri: String?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    albumType <- map["album_type"]
    artists <- map["artists"]
    availableMarkets <- map["available_markets"]
    externalUrls <- map["external_urls"]
    href <- map["href"]
    id <- map["id"]
    images <- map["images"]
    name <- map["name"]
    type <- map["type"]
    uri <- map["uri"]
  }
}
