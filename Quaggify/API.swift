//
//  API.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

struct API {
  static func fetchCurrentUser (service: SpotifyService = SpotifyService.shared, completion: @escaping (User?, Error?) -> Void) {
    service.fetchCurrentUser(completion: completion)
  }
  
  static func requestToken (code: String, service: SpotifyService = SpotifyService.shared, completion: @escaping (Error?) -> Void) {
    service.requestToken(code: code, completion: completion)
  }
  
  static func fetchSearchResults (query: String, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifySearchResponse?, Error?) -> Void) {
    service.fetchSearchResults(query: query, completion: completion)
  }
  
  static func fetchAlbums (query: String, limit: Int = 20, offset: Int = 0, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifyObject<Album>?, Error?) -> Void) {
    service.fetchAlbums(query: query, limit: limit, offset: offset, completion: completion)
  }
  
  static func fetchAlbumTracks (album: Album?, limit: Int = 20, offset: Int = 0, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifyObject<Track>?, Error?) -> Void) {
    service.fetchAlbumTracks(album: album, limit: limit, offset: offset, completion: completion)
  }
  
  static func fetchArtist (artist: Artist?, service: SpotifyService = SpotifyService.shared, completion: @escaping (Artist?, Error?) -> Void) {
    service.fetchArtist(artist: artist, completion: completion)
  }
  
  static func fetchArtists (query: String, limit: Int = 20, offset: Int = 0, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifyObject<Artist>?, Error?) -> Void) {
    service.fetchArtists(query: query, limit: limit, offset: offset, completion: completion)
  }
  
  static func fetchArtistAlbums (artist: Artist?, limit: Int = 20, offset: Int = 0, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifyObject<Album>?, Error?) -> Void) {
    service.fetchArtistAlbums(artist: artist, limit: limit, offset: offset, completion: completion)
  }
  
  static func fetchTrack (track: Track?, service: SpotifyService = SpotifyService.shared, completion: @escaping (Track?, Error?) -> Void) {
    service.fetchTrack(track: track, completion: completion)
  }
  
  static func fetchTracks (query: String, limit: Int = 20, offset: Int = 0, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifyObject<Track>?, Error?) -> Void) {
    service.fetchTracks(query: query, limit: limit, offset: offset, completion: completion)
  }
  
  static func fetchNewReleases (limit: Int = 20, offset: Int = 0, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifyObject<Album>?, Error?) -> Void) {
    service.fetchNewReleases(limit: limit, offset: offset, completion: completion)
  }
  
  static func fetchPlaylists (query: String, limit: Int = 20, offset: Int = 0, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifyObject<Playlist>?, Error?) -> Void) {
    service.fetchPlaylists(query: query, limit: limit, offset: offset, completion: completion)
  }
  
  static func fetchPlaylistTracks (playlist: Playlist?, limit: Int = 20, offset: Int = 0, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifyObject<PlaylistTrack>?, Error?) -> Void) {
    service.fetchPlaylistTracks(playlist: playlist, limit: limit, offset: offset, completion: completion)
  }
  
  static func removePlaylistTrack (track: Track?, position: Int?, playlist: Playlist?, service: SpotifyService = SpotifyService.shared, completion: @escaping(String?, Error?) -> Void) {
    service.removePlaylistTrack(track: track, position: position, playlist: playlist, completion: completion)
  }
  
  static func addTrackToPlaylist (track: Track?, playlist: Playlist?, service: SpotifyService = SpotifyService.shared, completion: @escaping (String?, Error?) -> Void) {
    service.addTrackToPlaylist(track: track, playlist: playlist, completion: completion)
  }
  
  static func fetchCurrentUsersPlaylists (limit: Int = 20, offset: Int = 0, service: SpotifyService = SpotifyService.shared, completion: @escaping (SpotifyObject<Playlist>?, Error?) -> Void) {
    service.fetchCurrentUsersPlaylists(limit: limit, offset: offset, completion: completion)
  }
  
  static func createNewPlaylist (name: String, service: SpotifyService = SpotifyService.shared, completion: @escaping (Playlist?, Error?) -> Void) {
    service.createNewPlaylist(name: name, completion: completion)
  }
  
}
