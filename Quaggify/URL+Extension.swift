//
//  URL+Extension.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import Foundation

extension URL {
  func queryItemValueFor (key: String) -> String? {
    guard
      let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
      let queryItems = components.queryItems
    else {
      return nil
    }
    
    return queryItems.first(where: { $0.name == key })?.value
  }
}
