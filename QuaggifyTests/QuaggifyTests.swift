//
//  QuaggifyTests.swift
//  QuaggifyTests
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import XCTest
@testable import Quaggify
@testable import ObjectMapper

class QuaggifyTests: XCTestCase {
  
  typealias JSON = [String: Any]
  
  class FakeSpotifyService: SpotifyService {
    override func fetchSearchResults(query: String, completion: @escaping (SpotifySearchResponse?, Error?) -> Void) {
      
      var albumJson: JSON = [
        "href": "https://api.spotify.com/v1/search?query=\(query)&type=album&market=US&offset=0&limit=1",
      ]
      let items: JSON = [
        "href": "https://api.spotify.com/v1/albums/7l0L2YHlQwAyI4QyZTIWGS",
        "id": "7l0L2YHlQwAyI4QyZTIWGS",
      ]
      albumJson["items"] = items
      
      let album = SpotifyObject<Album>(JSON: albumJson)
      
      if let album = album {
        let spotifySearchResponse = SpotifySearchResponse(JSON: ["albums": album])
        completion(spotifySearchResponse, nil)
      } else {
        completion(nil, NSError(domain: "No search error", code: 111, userInfo: nil))
      }
    }
  }
  
  func testSpotifySearch () {
    let promise = expectation(description: "Search for behemoth on spotify")
    let mockSearchResponse = SpotifySearchResponse(JSON: ["Teste": "123"])
    
    API.fetchSearchResults(query: "behemoth", service: FakeSpotifyService.shared) { (spotifySearchResponse, error) in
      
      guard let mockSearchResponse = mockSearchResponse,
        let spotifySearchResponse = spotifySearchResponse else {
          XCTFail("Failed to unwrap response")
          promise.fulfill()
          return
      }
      XCTAssertNotEqual(mockSearchResponse, spotifySearchResponse)
      promise.fulfill()
    }
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        XCTFail("waitForExpectations errored: \(error)")
      }
    }
  }
  
}















