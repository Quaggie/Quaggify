//
//  SpotifySearchResponse.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct SpotifySearchResponse: Mappable {
  var albums: SpotifyObject<Album>?
  var artists: SpotifyObject<Artist>?
  var tracks: SpotifyObject<Track>?
  var playlists: SpotifyObject<Playlist>?
  
  var numberOfSections: Int {
    var total = 0
    
    if let items = albums?.items, items.count > 0 {
      total += 1
      if albums?.next != nil {
        total += 1
      }
    }
    if let items = artists?.items, items.count > 0 {
      total += 1
      if artists?.next != nil {
        total += 1
      }
    }
    if let items = tracks?.items, items.count > 0 {
      total += 1
      if tracks?.next != nil {
        total += 1
      }
    }
    if let items = playlists?.items, items.count > 0 {
      total += 1
      if playlists?.next != nil {
        total += 1
      }
    }
    
    return total
  }
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    albums <- map["albums"]
    artists <- map["artists"]
    tracks <- map["tracks"]
    playlists <- map["playlists"]
  }
}
