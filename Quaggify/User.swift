//
//  File.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import ObjectMapper

struct User: Mappable {

  var country: String?
  var displayName: String?
  var email: String?
  var externalUrls: ExternalUrls?
  var followers: Followers?
  var href: String?
  var id: String?
  var images: [Image]?
  var product: String?
  var type: String?
  var uri: String?
  
  static var current = User()
  private init () {}
  
  func saveToDefaults () {
    let defaults = UserDefaults.standard
    
    defaults.set(id, forKey: "currentUserId")
    
    defaults.synchronize()
  }
  
  static func getFromDefaults () -> User? {
    if let id = UserDefaults.standard.object(forKey: "currentUserId") {
      return User(JSON: ["id": id])
    }
    
    return nil
  }
  
  init?(map: Map) {
    
  }
  
  mutating func mapping(map: Map) {
    country <- map["country"]
    displayName <- map["display_name"]
    email <- map["email"]
    externalUrls <- map["external_urls"]
    followers <- map["followers"]
    href <- map["href"]
    id <- map["id"]
    images <- map["images"]
    product <- map["product"]
    type <- map["type"]
    uri <- map["uri"]
  }
}
