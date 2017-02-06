//
//  Track.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct Track: Mappable {
  
  var album: Album?
  var artists: [Artist]?
  var availableMarkets: [String]?
  var discNumber: Int?
  var durationMS: Int?
  var isExplicit: Bool?
  var externalIds: ExternalIds?
  var externalUrls: ExternalUrls?
  var href: String?
  var id: String?
  var name: String?
  var popularity: Int?
  var previewUrl: String?
  var trackNumber: Int?
  var type: SpotifyObjectType?
  var uri: String?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    album <- map["album"]
    artists <- map["artists"]
    availableMarkets <- map["available_markets"]
    discNumber <- map["disc_number"]
    durationMS <- map["duration_ms"]
    isExplicit <- map["explicit"]
    externalIds <- map["external_ids"]
    externalUrls <- map["external_urls"]
    href <- map["href"]
    id <- map["id"]
    name <- map["name"]
    popularity <- map["popularity"]
    previewUrl <- map["preview_url"]
    trackNumber <- map["track_number"]
    type <- map["type"]
    uri <- map["uri"]
  }
}


extension Track: Equatable {
  static func ==(lhs: Track, rhs: Track) -> Bool {
    return lhs.id == rhs.id
  }
}


