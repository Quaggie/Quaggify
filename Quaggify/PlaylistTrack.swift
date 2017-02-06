//
//  PlaylistTracksResponse.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 06/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit
import ObjectMapper

struct PlaylistTrack: Mappable {
  var track: Track?
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    track <- map["track"]
  }
}
