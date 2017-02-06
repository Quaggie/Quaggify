//
//  SpotifyFooter.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import Foundation
import ObjectMapper

struct SpotifyFooter<T: Mappable> {
  var type: T?
  var title: String?
}
