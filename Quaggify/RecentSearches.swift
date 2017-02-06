//
//  RecentSearches.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 01/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import Foundation

struct RecentSearches {
  
  static let shared = RecentSearches()
  private init () {}
  
  private var defaults = UserDefaults.standard
  
  private let SEARCHES_KEY = "RECENT_SEARCHES"
  
  var items: [String] {
    return defaults.stringArray(forKey: SEARCHES_KEY) ?? []
  }
  
  func add (search: String) {
    let trimmedSearch = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    var searches = defaults.stringArray(forKey: SEARCHES_KEY)
    // Veryfing so it won't repeat on the history
    if let s = searches, !s.contains(trimmedSearch) {
      searches?.insert(trimmedSearch, at: 0)
      defaults.setValue([trimmedSearch], forKey: SEARCHES_KEY)
    }
    defaults.setValue(searches ?? [trimmedSearch], forKey: SEARCHES_KEY)
    
    sync()
  }
  
  func remove (search: String) {
    var searches = defaults.stringArray(forKey: SEARCHES_KEY)
    searches?.enumerated().forEach { (index, item) in
      if item == search, searches?[safe: index] != nil {
        searches?.remove(at: index)
      }
    }
    defaults.setValue(searches, forKey: SEARCHES_KEY)
    
    sync()
    notifyOnRemove()
  }
  
  func removeAll () {
    var searches = defaults.stringArray(forKey: SEARCHES_KEY)
    searches?.removeAll()
    
    defaults.setValue(searches, forKey: SEARCHES_KEY)
    
    sync()
    notifyOnRemove()
  }
  
  func sync () {
    defaults.synchronize()
  }
  
  private func notifyOnRemove () {
    NotificationCenter.default.post(name: .onRecentSearchesRemove, object: nil)
  }
  
}
