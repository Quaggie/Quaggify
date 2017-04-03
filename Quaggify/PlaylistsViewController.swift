//
//  PlaylistsViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 03/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class PlaylistsViewController: ViewController {
  
  var spotifyObject: SpotifyObject<Playlist>?
  var query: String? {
    didSet {
      if let query = query {
        navigationItem.title = "\"\(query)\" in Playlists"
      }
    }
  }
  var limit = 20
  var offset = 5
  var isFetching = false
  
  let lineSpacing: CGFloat = 16
  let interItemSpacing: CGFloat = 8
  let contentInset: CGFloat = 8
  
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
    cv.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.identifier)
    return cv
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchPlaylists()
  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
  // MARK: Layout
  override func setupViews() {
    super.setupViews()
    
    view.addSubview(collectionView)
    collectionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
  }
}

// MARK: Actions
extension PlaylistsViewController {
  func fetchPlaylists () {
    isFetching = true
    print("Fetching albums offset(\(offset)) ")
    
    if let query = query {
      API.fetchPlaylists(query: query, limit: limit, offset: offset) { [weak self] (spotifyObject, error) in
        guard let strongSelf = self else {
          return
        }
        strongSelf.isFetching = false
        strongSelf.offset += strongSelf.limit
        
        if let error = error {
          print(error)
          Alert.shared.show(title: "Error", message: "Error communicating with the server")
        } else if let spotifyObject = spotifyObject, let items = spotifyObject.items {
          strongSelf.spotifyObject?.items?.append(contentsOf: items)
          strongSelf.spotifyObject?.next = spotifyObject.next
          strongSelf.spotifyObject?.total = spotifyObject.total
          strongSelf.collectionView.reloadData()
        }
      }
    }
  }
}

// MARK: UICollectionViewDelegate
extension PlaylistsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let playlistVC = PlaylistViewController()
    playlistVC.playlist = spotifyObject?.items?[safe: indexPath.item]
    navigationController?.pushViewController(playlistVC, animated: true)
  }
}

// MARK: UICollectionViewDataSource
extension PlaylistsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spotifyObject?.items?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCell.identifier, for: indexPath) as? PlaylistCell {
      let playlist = spotifyObject?.items?[safe: indexPath.item]
      cell.playlist = playlist
      
      if let totalItems = spotifyObject?.items?.count, indexPath.item == totalItems - 1, spotifyObject?.next != nil {
        if !isFetching {
          fetchPlaylists()
        }
      }
      
      return cell
    }
    return UICollectionViewCell()
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension PlaylistsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width - (contentInset * 2), height: 72)
  }
}

















