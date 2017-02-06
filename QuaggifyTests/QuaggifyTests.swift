//
//  QuaggifyTests.swift
//  QuaggifyTests
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import XCTest
@testable import Quaggify

class QuaggifyTests: XCTestCase {
  
  typealias JSON = [String: Any]
  
  class FakeSpotifyService: SpotifyService {
    override func fetchSearchResults(query: String, completion: @escaping (SpotifySearchResponse?, Error?) -> Void) {
      
      
      let albumJson: JSON = [
        "href": "https://api.spotify.com/v1/search?query=Behemoth&type=album&market=US&offset=0&limit=5",
        "items": [
          [:]
        ]
      ]
      
      let spotifySearchResponseJson: JSON = [
        "albums": "",
        "artists": "",
        "tracks": "",
        "playlists": ""
      ]
      let spotifySearchResponse = SpotifySearchResponse(JSON: spotifySearchResponseJson)
      
      completion(spotifySearchResponse, nil)
    }
  }
    
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
  func testSpotifySearch () {
    
  }
  
}
