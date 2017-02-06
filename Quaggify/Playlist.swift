//
//  Playlist.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct Playlist: Mappable {
  
  var isCollaborative: Bool?
  var externalUrls: ExternalUrls?
  var href: String?
  var id: String?
  var images: [Image]?
  var name: String?
  var owner: User?
  var isPublic: Bool?
  var snapshotId: String?
  var tracks: PlaylistTracks?
  var type: SpotifyObjectType?
  var uri: String?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    isCollaborative <- map["collaborative"]
    externalUrls <- map["external_urls"]
    href <- map["href"]
    id <- map["id"]
    images <- map["images"]
    name <- map["name"]
    owner <- map["owner"]
    isPublic <- map["public"]
    snapshotId <- map["snapshot_id"]
    tracks <- map["tracks"]
    type <- map["type"]
    uri <- map["uri"]
  }
}

extension Playlist: Equatable {
  static func ==(lhs: Playlist, rhs: Playlist) -> Bool {
    return lhs.id == rhs.id
  }
}
