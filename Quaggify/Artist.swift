//
//  Artist.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct Artist: Mappable {
  
  var externalUrls: ExternalUrls?
  var followers: Followers?
  var genres: [String]?
  var href: String?
  var id: String?
  var images: [Image]?
  var name: String?
  var popularity: Int?
  var type: SpotifyObjectType?
  var uri: String?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    externalUrls <- map["external_urls"]
    followers <- map["followers"]
    genres <- map["genres"]
    href <- map["href"]
    id <- map["id"]
    images <- map["images"]
    name <- map["name"]
    popularity <- map["popularity"]
    type <- map["type"]
    uri <- map["uri"]
  }
}

extension Artist: Equatable {
  static func ==(lhs: Artist, rhs: Artist) -> Bool {
    return lhs.id == rhs.id
  }
}

