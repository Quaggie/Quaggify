//
//  SpotifyAPI.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class SpotifyService: NSObject {
  let CLIENT_ID = "{ INSERT CLIENT_ID HERE }"
  let CLIENT_SECRET = "{ INSERT CLIENT_SECRET HERE }"
  let REDIRECT_URI = "quaggify://authorization"
  
  var AUTHORIZATION_CODE: String? {
    return UserDefaults.standard.string(forKey: AUTHORIZATION_CODE_KEY)
  }
  var ACCESS_TOKEN: String? {
    return UserDefaults.standard.string(forKey: ACCESS_TOKEN_KEY)
  }
  var EXPIRES_IN: String? {
    return UserDefaults.standard.string(forKey: EXPIRES_IN_KEY)
  }
  var REFRESH_TOKEN: String? {
    return UserDefaults.standard.string(forKey: REFRESH_TOKEN_KEY)
  }
  var TOKEN_TYPE: String? {
    return UserDefaults.standard.string(forKey: TOKEN_TYPE_KEY)
  }
  
  private let AUTHORIZATION_CODE_KEY = "AUTHORIZATION_CODE_KEY"
  private let ACCESS_TOKEN_KEY = "ACCESS_TOKEN_KEY"
  private let EXPIRES_IN_KEY = "EXPIRES_IN_KEY"
  private let REFRESH_TOKEN_KEY = "REFRESH_TOKEN_KEY"
  private let TOKEN_TYPE_KEY = "TOKEN_TYPE_KEY"
  
  private let searchUrl = "https://api.spotify.com/v1/search"
  private let tokenUrl = "https://accounts.spotify.com/api/token"
  private let currentUserUrl = "https://api.spotify.com/v1/me"
  private let currentUsersPlaylistsUrl = "https://api.spotify.com/v1/me/playlists"
  private let newReleasesUrl = "https://api.spotify.com/v1/browse/new-releases"
  private func albumTracksUrl (album: Album?) -> String? {
    if let id = album?.id {
      return "https://api.spotify.com/v1/albums/\(id)/tracks"
    }
    return nil
  }
  private func artistAlbumsUrl (artist: Artist?) -> String? {
    if let id = artist?.id {
      return "https://api.spotify.com/v1/artists/\(id)/albums"
    }
    return nil
  }
  private func trackUrl (track: Track?) -> String? {
    if let id = track?.id {
      return "https://api.spotify.com/v1/tracks/\(id)"
    }
    return nil
  }
  private func artistUrl (artist: Artist?) -> String? {
    if let id = artist?.id {
      return "https://api.spotify.com/v1/artists/\(id)"
    }
    return nil
  }
  private func playlistTracksUrl (playlist: Playlist?) -> String? {
    if let ownerId = playlist?.owner?.id, let playlistId = playlist?.id {
      return "https://api.spotify.com/v1/users/\(ownerId)/playlists/\(playlistId)/tracks"
    }
    return nil
  }
  private var createNewPlaylistUrl: String? {
    if let userId = User.current.id {
      return "https://api.spotify.com/v1/users/\(userId)/playlists"
    }
    return nil
  }
  
  var isLoggedIn: Bool {
    return AUTHORIZATION_CODE != nil
  }
  
  private let scopes = ["playlist-read-private", "playlist-read-collaborative", "playlist-modify-public", "playlist-modify-private"]
  
  private var encodedScopes: String {
    return scopes.joined(separator: "%20")
  }
  
  static let shared = SpotifyService()
  private override init () {}
  
  func login () {
    let urlString = "https://accounts.spotify.com/authorize?client_id=\(SpotifyService.shared.CLIENT_ID)&response_type=code&redirect_uri=\(SpotifyService.shared.REDIRECT_URI)&scope=\(encodedScopes)"
    if let url = URL(string: urlString) {
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.openURL(url)
      }
    }
  }
  
  func logout () {
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: AUTHORIZATION_CODE_KEY)
    defaults.removeObject(forKey: ACCESS_TOKEN_KEY)
    defaults.removeObject(forKey: EXPIRES_IN_KEY)
    defaults.removeObject(forKey: REFRESH_TOKEN_KEY)
    defaults.removeObject(forKey: TOKEN_TYPE_KEY)
    defaults.synchronize()
    UIApplication.topViewController()?.present(LoginViewController(), animated: true, completion: nil)
  }
  
  func requestToken (code: String, completion: @escaping (Error?) -> Void) {
    // Saving token
    SpotifyService.shared.saveAuthorizationCode(code: code)
    
    let parameters: Parameters = [
      "grant_type": "authorization_code",
      "code": code,
      "redirect_uri": REDIRECT_URI,
      "client_id": CLIENT_ID,
      "client_secret": CLIENT_SECRET
    ]
    
    Alamofire.request(tokenUrl, method: .post, parameters: parameters).responseObject { [weak self] (response: DataResponse<RefreshTokenResponse>) in
        switch response.result {
        case .success(let refreshTokenResponse):
          // Saving response to defaults
          self?.saveRefreshTokenResponse(refreshTokenResponse: refreshTokenResponse)
          completion(nil)
          break
        case .failure(let error):
          print(error)
          completion(error)
          break
        }
    }
  }
  
  func refreshToken (completion: @escaping (Error?) -> Void) {
    let parameters: Parameters = [
      "grant_type": "refresh_token",
      "refresh_token": REFRESH_TOKEN ?? "",
      "client_id": CLIENT_ID,
      "client_secret": CLIENT_SECRET
    ]
    
    Alamofire.request(tokenUrl, method: .post, parameters: parameters).responseObject { [weak self] (response: DataResponse<RefreshTokenResponse>) in
      switch response.result {
      case .success(let refreshTokenResponse):
        // Saving response to defaults
        self?.saveRefreshTokenResponse(refreshTokenResponse: refreshTokenResponse)
        completion(nil)
        break
      case .failure(let error):
        print(error)
        completion(error)
        break
      }
    }
  }
  
  func fetchSearchResults (query: String, completion: @escaping (SpotifySearchResponse?, Error?) -> Void) {
    let parameters: Parameters = [
      "query": query,
      "type": "track,album,playlist,artist",
      "market": "US",
      "offset": 0,
      "limit": 5
    ]
    
    Alamofire.request(searchUrl, method: .get, parameters: parameters).responseObject { (response: DataResponse<SpotifySearchResponse>) in
        switch response.result {
        case .success(let spotifyResponseObject):
          completion(spotifyResponseObject, nil)
          break
        case .failure(let error):
          print(error)
          completion(nil, error)
          break
      }
    }
  }
  
  func fetchCurrentUser (completion: @escaping (User?, Error?) -> Void) {
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    Alamofire.request(currentUserUrl, method: .get, headers: headers).responseObject { [weak self] (response: DataResponse<User>) in
        switch response.result {
        case .success(let user):
          if let statusCode = response.response?.statusCode, statusCode == 401 {
            self?.refreshToken { (error) in
              if let error = error {
                completion(nil, error)
              } else {
                self?.fetchCurrentUser(completion: completion)
              }
            }
            break
          }
          completion(user, nil)
          break
        case .failure(let error):
          print(error)
          completion(nil, error)
          break
        }
    }
  }
  
  func fetchTrack (track: Track?, completion: @escaping (Track?, Error?) -> Void) {
    let parameters: Parameters = [
      "market": "US"
    ]
    
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    guard let trackUrl = trackUrl(track: track) else {
      completion(nil , "No track found")
      return
    }
    
    Alamofire.request(trackUrl, method: .get, parameters: parameters, headers: headers).responseObject { [weak self] (response: DataResponse<Track>) in
        switch response.result {
        case .success(let spotifyObject):
          if let statusCode = response.response?.statusCode, statusCode == 401 {
            self?.refreshToken { (error) in
              if let error = error {
                completion(nil, error)
              } else {
                self?.fetchTrack(track: track, completion: completion)
              }
            }
            break
          }
          completion(spotifyObject, nil)
          break
        case .failure(let error):
          completion(nil, error)
          break
        }
    }
  }
  
  func fetchTracks (query: String, limit: Int = 20, offset: Int = 0, completion: @escaping (SpotifyObject<Track>?, Error?) -> Void) {
    let parameters: Parameters = [
      "query": query,
      "type": "track",
      "market": "US",
      "offset": offset,
      "limit": limit
    ]
    Alamofire.request(searchUrl, method: .get, parameters: parameters)
      .responseObject(keyPath: "tracks") { (response: DataResponse<SpotifyObject<Track>>) in
        switch response.result {
        case .success(let spotifyObject):
          completion(spotifyObject, nil)
          break
        case .failure(let error):
          completion(nil, error)
          break
        }
    }
  }
  
  func fetchAlbums (query: String, limit: Int = 20, offset: Int = 0, completion: @escaping (SpotifyObject<Album>?, Error?) -> Void) {
    let parameters: Parameters = [
      "query": query,
      "type": "album",
      "market": "US",
      "offset": offset,
      "limit": limit
    ]
    
    Alamofire.request(searchUrl, method: .get, parameters: parameters)
      .responseObject(keyPath: "albums") { (response: DataResponse<SpotifyObject<Album>>) in
        switch response.result {
        case .success(let spotifyObject):
          completion(spotifyObject, nil)
          break
        case .failure(let error):
          completion(nil, error)
          break
        }
    }
  }
  
  func fetchAlbumTracks (album: Album?, limit: Int = 20, offset: Int = 0, completion: @escaping (SpotifyObject<Track>?, Error?) -> Void) {
    let parameters: Parameters = [
      "market": "US",
      "offset": offset,
      "limit": limit
    ]
    
    guard let albumTracksUrl = albumTracksUrl(album: album) else {
      completion(nil, "No album found")
      return
    }
    
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    Alamofire.request(albumTracksUrl, method: .get, parameters: parameters, headers: headers).responseObject { (response: DataResponse<SpotifyObject<Track>>) in
        switch response.result {
        case .success(let spotifyObject):
          completion(spotifyObject, nil)
          break
        case .failure(let error):
          completion(nil, error)
          break
        }
    }
  }
  
  func fetchArtist (artist: Artist?, completion: @escaping (Artist?, Error?) -> Void) {
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    guard let artistUrl = artistUrl(artist: artist) else {
      completion(nil, "No artist found")
      return
    }
    
    Alamofire.request(artistUrl, method: .get, headers: headers).responseObject { [weak self] (response: DataResponse<Artist>) in
      switch response.result {
      case .success(let spotifyObject):
        if let statusCode = response.response?.statusCode, statusCode == 401 {
          self?.refreshToken { (error) in
            if let error = error {
              completion(nil, error)
            } else {
              self?.fetchArtist(artist: artist, completion: completion)
            }
          }
          break
        }
        completion(spotifyObject, nil)
        break
      case .failure(let error):
        completion(nil, error)
        break
      }
    }
  }
  
  func fetchArtists (query: String, limit: Int = 20, offset: Int = 0, completion: @escaping (SpotifyObject<Artist>?, Error?) -> Void) {
    let parameters: Parameters = [
      "query": query,
      "type": "artist",
      "market": "US",
      "offset": offset,
      "limit": limit
    ]
    Alamofire.request(searchUrl, method: .get, parameters: parameters)
      .responseObject(keyPath: "artists") { (response: DataResponse<SpotifyObject<Artist>>) in
        switch response.result {
        case .success(let spotifyObject):
          completion(spotifyObject, nil)
          break
        case .failure(let error):
          completion(nil, error)
          break
        }
    }
  }
  
  func fetchNewReleases (limit: Int = 20, offset: Int = 0, completion: @escaping (SpotifyObject<Album>?, Error?) -> Void) {
    let parameters: Parameters = [
      "country": "US",
      "offset": offset,
      "limit": limit
    ]
    
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    Alamofire.request(newReleasesUrl, method: .get, parameters: parameters, headers: headers)
      .responseObject(keyPath: "albums") { [weak self] (response: DataResponse<SpotifyObject<Album>>) in
        switch response.result {
        case .success(let spotifyObject):
          if let statusCode = response.response?.statusCode, statusCode == 401 {
            self?.refreshToken { (error) in
              if let error = error {
                completion(nil, error)
              } else {
                self?.fetchNewReleases(limit: limit, offset: offset, completion: completion)
              }
            }
            break
          }
          completion(spotifyObject, nil)
          break
        case .failure(let error):
          completion(nil, error)
          break
        }
    }
  }
  
  func fetchPlaylists (query: String, limit: Int = 20, offset: Int = 0, completion: @escaping (SpotifyObject<Playlist>?, Error?) -> Void) {
    let parameters: Parameters = [
      "query": query,
      "type": "playlist",
      "market": "US",
      "offset": offset,
      "limit": limit
    ]
    
    Alamofire.request(searchUrl, method: .get, parameters: parameters)
      .responseObject(keyPath: "playlists") { (response: DataResponse<SpotifyObject<Playlist>>) in
        switch response.result {
        case .success(let spotifyObject):
          completion(spotifyObject, nil)
          break
        case .failure(let error):
          completion(nil, error)
          break
        }
    }
  }
  
  func fetchPlaylistTracks (playlist: Playlist?, limit: Int = 20, offset: Int = 0, completion: @escaping (SpotifyObject<PlaylistTrack>?, Error?) -> Void) {
    let parameters: Parameters = [
      "fields": "href,next, items.track,limit,offset,previous,total",
      "offset": offset,
      "limit": limit
    ]
    
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    guard let playlistTracksUrl = playlistTracksUrl(playlist: playlist) else {
      completion(nil, "No playlist found")
      return
    }
    
    Alamofire.request(playlistTracksUrl, method: .get, parameters: parameters, headers: headers).responseObject { [weak self] (response: DataResponse<SpotifyObject<PlaylistTrack>>) in
      switch response.result {
      case .success(let spotifyObject):
        if let statusCode = response.response?.statusCode, statusCode == 401 {
          self?.refreshToken { (error) in
            if let error = error {
              completion(nil, error)
            } else {
              self?.fetchPlaylistTracks(playlist: playlist, limit: limit, offset: offset, completion: completion)
            }
          }
          break
        }
        completion(spotifyObject, nil)
        break
      case .failure(let error):
        completion(nil, error)
        break
      }
    }
  }
  
  func removePlaylistTrack (track: Track?, position: Int?, playlist: Playlist?, completion: @escaping(String?, Error?) -> Void) {
    
    let tracks = [[
      "uri": track?.uri ?? "",
      "positions": [position ?? 0]
    ]]
    let parameters: Parameters = [
      "tracks": tracks,
      "snapshot_id": playlist?.snapshotId ?? ""
    ]
    
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    guard let playlistTracksUrl = playlistTracksUrl(playlist: playlist) else {
      completion(nil, "No playlist found")
      return
    }
    Alamofire.request(playlistTracksUrl, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { [weak self] response in
      switch response.result {
      case .success(let json):
        print(json)
        if let statusCode = response.response?.statusCode, statusCode == 401 {
          self?.refreshToken { (error) in
            if let error = error {
              completion(nil, error)
            } else {
              self?.removePlaylistTrack(track: track, position: position, playlist: playlist, completion: completion)
            }
          }
          break
        }
        if let json = json as? [String: Any], let snapshotId = json["snapshot_id"] as? String {
          completion(snapshotId, nil)
        } else {
          completion(nil, nil)
        }
        break
      case .failure(let error):
        completion(nil, error)
        break
      }
    }
  }
  
  func fetchCurrentUsersPlaylists (limit: Int = 20, offset: Int = 0, completion: @escaping (SpotifyObject<Playlist>?, Error?) -> Void) {
    let parameters: Parameters = [
      "offset": offset,
      "limit": limit
    ]
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    Alamofire.request(currentUsersPlaylistsUrl, method: .get, parameters: parameters, headers: headers).responseObject { [weak self] (response: DataResponse<SpotifyObject<Playlist>>) in
        switch response.result {
        case .success(let spotifyObject):
          if let statusCode = response.response?.statusCode, statusCode == 401 {
            self?.refreshToken { (error) in
              if let error = error {
                completion(nil, error)
              } else {
                self?.fetchCurrentUsersPlaylists(limit: limit, offset: offset, completion: completion)
              }
            }
            break
          }
          completion(spotifyObject, nil)
          break
        case .failure(let error):
          completion(nil, error)
          break
        }
    }
  }
  
  func createNewPlaylist (name: String, completion: @escaping (Playlist?, Error?) -> Void) {
    
    let parameters: Parameters = [
      "name": name,
      "public": true
    ]
    
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    guard let createNewPlaylistUrl = createNewPlaylistUrl else {
      refreshToken { [weak self] (error) in
        if let error = error {
          completion(nil, error)
        } else {
          self?.createNewPlaylist(name: name, completion: completion)
        }
      }
      return
    }
 
    Alamofire.request(createNewPlaylistUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseObject { [weak self] (response: DataResponse<Playlist>) in
      switch response.result {
      case .success(let playlist):
        if let statusCode = response.response?.statusCode {
          if statusCode == 401 {
            self?.refreshToken { (error) in
              if let error = error {
                completion(nil, error)
              } else {
                self?.createNewPlaylist(name: name, completion: completion)
              }
            }
          } else if statusCode == 403 {
            completion(nil, "You need to update spotify's permission on login to create a playist ):")
          } else if statusCode == 400 {
            completion(nil, "Bad request")
          }
          break
        }
        completion(playlist, nil)
        break
      case .failure(let error):
        completion(nil, error)
        break
      }
    }
  }
  
  func addTrackToPlaylist (track: Track?, playlist: Playlist?, completion: @escaping (String?, Error?) -> Void) {
    let parameters: Parameters = [
      "uris": [track?.uri ?? ""]
    ]
    
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    guard let playlistTracksUrl = playlistTracksUrl(playlist: playlist) else {
      completion(nil, "No playlist found")
      return
    }
    
    Alamofire.request(playlistTracksUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { [weak self] response in
      switch response.result {
      case .success(let json):
        if let statusCode = response.response?.statusCode, statusCode == 401 {
          self?.refreshToken { (error) in
            if let error = error {
              completion(nil, error)
            } else {
              self?.addTrackToPlaylist(track: track, playlist: playlist, completion: completion)
            }
          }
          break
        }
        if let json = json as? [String: Any], let snapshotId = json["snapshot_id"] as? String {
          completion(snapshotId, nil)
        } else {
          completion(nil, nil)
        }
        break
      case .failure(let error):
        completion(nil, error)
        break
      }
    }
  }
  
  func fetchArtistAlbums (artist: Artist?, limit: Int = 20, offset: Int = 0, completion: @escaping (SpotifyObject<Album>?, Error?) -> Void) {
    let parameters: Parameters = [
      "album_type": "album",
      "market": "US",
      "offset": offset,
      "limit": limit
    ]
    
    var headers: HTTPHeaders = [:]
    if let accessToken = ACCESS_TOKEN {
      headers["Authorization"] = "Bearer \(accessToken)"
    }
    
    guard let artistAlbumsUrl = artistAlbumsUrl(artist: artist) else {
      completion(nil, "No artist found")
      return
    }
    
    Alamofire.request(artistAlbumsUrl, method: .get, parameters: parameters, headers: headers).responseObject { (response: DataResponse<SpotifyObject<Album>>) in
        switch response.result {
        case .success(let spotifyObject):
          completion(spotifyObject, nil)
          break
        case .failure(let error):
          completion(nil, error)
          break
        }
    }
  }

  private func saveAuthorizationCode (code: String) {
    UserDefaults.standard.set(code, forKey: AUTHORIZATION_CODE_KEY)
    UserDefaults.standard.synchronize()
  }
  
  private func saveRefreshTokenResponse (refreshTokenResponse: RefreshTokenResponse?) {
    let defaults = UserDefaults.standard
    guard let refreshTokenResponse = refreshTokenResponse else {
      return
    }
    if let accessToken = refreshTokenResponse.accessToken {
      defaults.set(accessToken, forKey: ACCESS_TOKEN_KEY)
    }
    if let expiresIn = refreshTokenResponse.expiresIn {
      defaults.set(expiresIn, forKey: EXPIRES_IN_KEY)
    }
    if let refreshToken = refreshTokenResponse.refreshToken {
      defaults.set(refreshToken, forKey: REFRESH_TOKEN_KEY)
    }
    if let tokenType = refreshTokenResponse.tokenType {
      defaults.set(tokenType, forKey: TOKEN_TYPE_KEY)
    }
    defaults.synchronize()
  }
}
