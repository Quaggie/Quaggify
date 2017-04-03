//
//  SearchViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class SearchViewController: ViewController {
  
  var spotifySearchResponse: SpotifySearchResponse? {
    didSet {
      sections.removeAll()

      if let albums = spotifySearchResponse?.albums {
        sections.append(albums)
        if albums.next != nil {
          let albumFooter = SpotifyFooter<SpotifyObject<Album>>(type: albums, title: "See all albums")
          sections.append(albumFooter)
        }
      }
      if let artists = spotifySearchResponse?.artists {
        sections.append(artists)
        if artists.next != nil {
          let artistFooter = SpotifyFooter<SpotifyObject<Artist>>(type: artists, title: "See all artists")
          sections.append(artistFooter)
        }
      }
      if let tracks = spotifySearchResponse?.tracks {
        sections.append(tracks)
        if tracks.next != nil {
          let trackFooter = SpotifyFooter<SpotifyObject<Track>>(type: tracks, title: "See all songs")
          sections.append(trackFooter)
        }
      }
      if let playlists = spotifySearchResponse?.playlists {
        sections.append(playlists)
        if playlists.next != nil {
          let playlistFooter = SpotifyFooter<SpotifyObject<Playlist>>(type: playlists, title: "See all playlists")
          sections.append(playlistFooter)
        }
      }
      
      collectionView.reloadData()
    }
  }
  
  var sections: [Any] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  
  let lineSpacing: CGFloat = 16
  let interItemSpacing: CGFloat = 8
  let contentInset: CGFloat = 8
  
  lazy var searchController: UISearchController = {
    let sc = UISearchController(searchResultsController: nil)
    sc.navigationController?.navigationBar.isOpaque = true
    sc.searchResultsUpdater = self
    sc.dimsBackgroundDuringPresentation = false
    sc.hidesNavigationBarDuringPresentation = false
    sc.searchBar.sizeToFit()
    sc.searchBar.placeholder = "Search"
    sc.searchBar.autocapitalizationType = .sentences
    sc.searchBar.autocorrectionType = .no
    sc.searchBar.returnKeyType = .default
    sc.searchBar.enablesReturnKeyAutomatically = false
    sc.searchBar.delegate = self
    return sc
  }()
  
  lazy var collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    flowLayout.minimumLineSpacing = self.lineSpacing
    flowLayout.minimumInteritemSpacing = self.interItemSpacing
    let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    cv.keyboardDismissMode = .onDrag
    cv.alwaysBounceVertical = true
    cv.showsVerticalScrollIndicator = false
    cv.contentInset = UIEdgeInsets(top: 0, left: self.contentInset, bottom: 0, right: self.contentInset)
    cv.backgroundColor = .clear
    cv.delegate = self
    cv.dataSource = self
    cv.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.identifier)
    cv.register(ArtistCell.self, forCellWithReuseIdentifier: ArtistCell.identifier)
    cv.register(TrackCell.self, forCellWithReuseIdentifier: TrackCell.identifier)
    cv.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.identifier)
    cv.register(RecentSearchesCell.self, forCellWithReuseIdentifier: RecentSearchesCell.identifier)
    cv.register(SeeAllCell.self, forCellWithReuseIdentifier: SeeAllCell.identifier)
    cv.register(SearchHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SearchHeaderView.identifier)
    return cv
  }()
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    // Needed for the searchBar controller
    definesPresentationContext = true
    addListeners()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    collectionView.reloadData()
  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView.collectionViewLayout.invalidateLayout()
  }
    
  override func setupViews() {
    super.setupViews()
    navigationItem.titleView = searchController.searchBar
    
    setupCollectionView()
  }
}

// MARK: Actions
extension SearchViewController {
  func fetchSearchResults () {
    // Api call
    if let text = searchController.searchBar.text {
      API.fetchSearchResults(query: text) { [weak self] (response, error) in
        RecentSearches.shared.add(search: text)
        self?.spotifySearchResponse = response
      }
    }
  }
  
  func resetSearch () {
    spotifySearchResponse = nil
  }
}

// MARK: Layout
extension SearchViewController {
  func setupCollectionView () {
    view.addSubview(collectionView)
    
    collectionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
  }
}

// MARK: UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    if let text = searchController.searchBar.text {
      if text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
        resetSearch()
        return
      }
      // Throttling the input
      NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchSearchResults), object: nil)
      perform(#selector(fetchSearchResults), with: nil, afterDelay: 0.5)
    }
  }
}

// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    resetSearch()
    searchBar.resignFirstResponder()
  }
}

// MARK: UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = indexPath.item
    
    if let currentSearchItem = RecentSearches.shared.items[safe: item], spotifySearchResponse == nil {
      searchController.searchBar.text = currentSearchItem
      return
    }
    
    let section = indexPath.section
    let spotifyObject = sections[section]
    
    if let spotifyObject = spotifyObject as? SpotifyObject<Album> {
      let albumVC = AlbumViewController()
      let album = spotifyObject.items?[safe: indexPath.item]
      albumVC.album = album
      navigationController?.pushViewController(albumVC, animated: true)
    }
    if let spotifyObject = spotifyObject as? SpotifyObject<Artist> {
      let artistVC = ArtistViewController()
      let artist = spotifyObject.items?[safe: indexPath.item]
      artistVC.artist = artist
      navigationController?.pushViewController(artistVC, animated: true)
    }
    if let spotifyObject = spotifyObject as? SpotifyObject<Track> {
      let trackVC = TrackViewController()
      trackVC.track = spotifyObject.items?[safe: indexPath.item]
      navigationController?.pushViewController(trackVC, animated: true)
    }
    if let spotifyObject = spotifyObject as? SpotifyObject<Playlist> {
      let playlistVC = PlaylistViewController()
      playlistVC.playlist = spotifyObject.items?[safe: indexPath.item]
      navigationController?.pushViewController(playlistVC, animated: true)
    }
    
    if let spotifyObject = spotifyObject as? SpotifyFooter<SpotifyObject<Album>> {
      let vc = AlbumsViewController()
      vc.spotifyObject = spotifyObject.type
      vc.query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
      navigationController?.pushViewController(vc, animated: true)
    }
    
    if let spotifyObject = spotifyObject as? SpotifyFooter<SpotifyObject<Artist>> {
      let vc = ArtistsViewController()
      vc.spotifyObject = spotifyObject.type
      vc.query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
      navigationController?.pushViewController(vc, animated: true)
    }
    
    if let spotifyObject = spotifyObject as? SpotifyFooter<SpotifyObject<Track>> {
      let vc = TracksViewController()
      vc.spotifyObject = spotifyObject.type
      vc.query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
      navigationController?.pushViewController(vc, animated: true)
    }
    
    if let spotifyObject = spotifyObject as? SpotifyFooter<SpotifyObject<Playlist>> {
      let vc = PlaylistsViewController()
      vc.spotifyObject = spotifyObject.type
      vc.query = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}

extension SearchViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if spotifySearchResponse == nil {
      return RecentSearches.shared.items.count
    }
    let spotifyObject = sections[section]
    
    if spotifyObject is SpotifyObject<Album> {
      return spotifySearchResponse?.albums?.items?.count ?? 0
    }
    if spotifyObject is SpotifyFooter<SpotifyObject<Album>> {
      return spotifySearchResponse?.albums?.next != nil ? 1 : 0
    }
    if spotifyObject is SpotifyObject<Artist> {
      return spotifySearchResponse?.artists?.items?.count ?? 0
    }
    if spotifyObject is SpotifyFooter<SpotifyObject<Artist>> {
      return spotifySearchResponse?.artists?.next != nil ? 1 : 0
    }
    if spotifyObject is SpotifyObject<Track> {
      return spotifySearchResponse?.tracks?.items?.count ?? 0
    }
    if spotifyObject is SpotifyFooter<SpotifyObject<Track>> {
      return spotifySearchResponse?.tracks?.next != nil ? 1 : 0
    }
    if spotifyObject is SpotifyObject<Playlist> {
      return spotifySearchResponse?.playlists?.items?.count ?? 0
    }
    if spotifyObject is SpotifyFooter<SpotifyObject<Playlist>> {
      return spotifySearchResponse?.playlists?.next != nil ? 1 : 0
    }
    
    return  0
    
  }
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if spotifySearchResponse == nil, RecentSearches.shared.items.count > 0 {
      return 1
    }
    
    return spotifySearchResponse?.numberOfSections ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    // Search view
    if spotifySearchResponse == nil {
      if RecentSearches.shared.items.count == 0 {
        // show empty view
        print("Showing empty view")
      } else {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchesCell.identifier, for: indexPath) as? RecentSearchesCell {
          let item = indexPath.item
          cell.title = RecentSearches.shared.items[safe: item]
          return cell
        }
      }
    }
    // Spotify cells
    let section = indexPath.section
    let spotifyObject = sections[section]
    
    if spotifyObject is SpotifyObject<Album> {
      if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.identifier, for: indexPath) as? AlbumCell {
        let album = spotifySearchResponse?.albums?.items?[safe: indexPath.item]
        cell.album = album
        return cell
      }
    }
    if spotifyObject is SpotifyObject<Artist> {
      if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistCell.identifier, for: indexPath) as? ArtistCell {
        let artist = spotifySearchResponse?.artists?.items?[safe: indexPath.item]
        cell.artist = artist
        return cell
      }
    }
    if spotifyObject is SpotifyObject<Track> {
      if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCell.identifier, for: indexPath) as? TrackCell {
        let track = spotifySearchResponse?.tracks?.items?[safe: indexPath.item]
        cell.track = track
        return cell
      }
    }
    if spotifyObject is SpotifyObject<Playlist> {
      if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCell.identifier, for: indexPath) as? PlaylistCell {
        let playlist = spotifySearchResponse?.playlists?.items?[safe: indexPath.item]
        cell.playlist = playlist
        return cell
      }
    }
    // SeeAll cells
    if let footer = spotifyObject as? SpotifyFooter<SpotifyObject<Album>> {
      if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllCell.identifier, for: indexPath) as? SeeAllCell {
        cell.title = footer.title
        return cell
      }
    }
    if let footer = spotifyObject as? SpotifyFooter<SpotifyObject<Artist>> {
      if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllCell.identifier, for: indexPath) as? SeeAllCell {
        cell.title = footer.title
        return cell
      }
    }
    if let footer = spotifyObject as? SpotifyFooter<SpotifyObject<Track>> {
      if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllCell.identifier, for: indexPath) as? SeeAllCell {
        cell.title = footer.title
        return cell
      }
    }
    if let footer = spotifyObject as? SpotifyFooter<SpotifyObject<Playlist>> {
      if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeeAllCell.identifier, for: indexPath) as? SeeAllCell {
        cell.title = footer.title
        return cell
      }
    }
    return UICollectionViewCell()
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    switch kind {
    case UICollectionElementKindSectionHeader:
      if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SearchHeaderView.identifier, for: indexPath) as? SearchHeaderView {
        
        let section = indexPath.section
        let spotifyObject = sections[section]
        
        if spotifyObject is SpotifyObject<Album> {
          headerView.title = "Albums"
        } else if spotifyObject is SpotifyObject<Artist> {
          headerView.title = "Artists"
        } else if spotifyObject is SpotifyObject<Track> {
          headerView.title = "Songs"
        } else if spotifyObject is SpotifyObject<Playlist> {
          headerView.title = "Playlists"
        }
        
        return headerView
      }
    default: break
    }
    return UICollectionReusableView()
  }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if spotifySearchResponse == nil {
      return CGSize(width: view.frame.width - (contentInset * 2), height: 46)
    }
    return CGSize(width: view.frame.width - (contentInset * 2), height: 72)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    
    if spotifySearchResponse == nil {
      return .zero
    }
    
    switch sections[section] {
    case is SpotifyObject<Album>: fallthrough
    case is SpotifyObject<Artist>: fallthrough
    case is SpotifyObject<Track>: fallthrough
    case is SpotifyObject<Playlist>:
      return CGSize(width: view.frame.width, height: 72)
    default:
      return .zero
    }
  }
}

// MARK: Notification observer
extension SearchViewController {
  func addListeners () {
    NotificationCenter.default.addObserver(forName: .onRecentSearchesRemove, object: nil, queue: nil, using: onRecentSearchesRemove)
  }
  
  func onRecentSearchesRemove (notification: Notification) {
    collectionView.reloadData()
  }
}

extension SearchViewController: ScrollDelegate {
  func scrollToTop() {
    if sections.count > 0 {
      collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
  }
}






















