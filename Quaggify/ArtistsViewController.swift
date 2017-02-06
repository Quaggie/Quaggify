//
//  ArtistsViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 03/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class ArtistsViewController: ViewController {
  
  var spotifyObject: SpotifyObject<Artist>?
  var query: String? {
    didSet {
      if let query = query {
        navigationItem.title = "\"\(query)\" in Artists"
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
    cv.register(ArtistCell.self, forCellWithReuseIdentifier: ArtistCell.identifier)
    return cv
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchArtists()
  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView.collectionViewLayout.invalidateLayout()
  }
}

// MARK: Layout
extension ArtistsViewController {
  override func setupViews() {
    super.setupViews()
    
    view.addSubview(collectionView)
    collectionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
  }
}

// MARK: Actions
extension ArtistsViewController {
  func fetchArtists () {
    isFetching = true
    print("Fetching artists offset(\(offset)) ")
    
    if let query = query {
      API.fetchArtists(query: query, limit: limit, offset: offset) { [weak self] (spotifyObject, error) in
        guard let strongSelf = self else {
          return
        }
        strongSelf.isFetching = false
        strongSelf.offset += strongSelf.limit
        
        if let error = error {
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
extension ArtistsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let artistVC = ArtistViewController()
    let artist = spotifyObject?.items?[safe: indexPath.item]
    artistVC.artist = artist
    navigationController?.pushViewController(artistVC, animated: true)
  }
}

// MARK: UICollectionViewDataSource
extension ArtistsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spotifyObject?.items?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistCell.identifier, for: indexPath) as? ArtistCell {
      let artist = spotifyObject?.items?[safe: indexPath.item]
      cell.artist = artist
      
      if let totalItems = spotifyObject?.items?.count, indexPath.item == totalItems - 1, spotifyObject?.next != nil {
        if !isFetching {
          fetchArtists()
        }
      }
      
      return cell
    }
    return UICollectionViewCell()
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ArtistsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width - (contentInset * 2), height: 72)
  }
}









