//
//  ArtistsCell.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 01/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class ArtistViewController: ViewController, CellSpecs {
  
  var artist: Artist? {
    didSet {
      guard let artist = artist else {
        return
      }
      if let name = artist.name {
        navigationItem.title = name
      }
      collectionView.reloadData()
    }
  }

  fileprivate var spotifyObject: SpotifyObject<Album>?

  let limit = 20
  var offset = 0
  var isFetching = false
  
  let lineSpacing: CGFloat = 16
  let interItemSpacing: CGFloat = 8
  let contentInset: CGFloat = 8
  let cellHeight: CGFloat = 72
  var cellWidth: CGFloat {
    return view.frame.width - (contentInset * 2)
  }
  let cellHeaderHeight: CGFloat = 220
  var cellHeaderWidth: CGFloat {
    return view.frame.width
  }
  let cellFooterHeight: CGFloat = 0
  var cellFooterWidth: CGFloat {
    return view.frame.width
  }
  
  fileprivate lazy var collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    flowLayout.minimumLineSpacing = self.lineSpacing
    flowLayout.minimumInteritemSpacing = self.interItemSpacing
    let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    cv.keyboardDismissMode = .onDrag
    cv.alwaysBounceVertical = true
    cv.showsVerticalScrollIndicator = false
    cv.contentInset = UIEdgeInsets(top: self.contentInset, left: self.contentInset, bottom: self.contentInset, right: self.contentInset)
    cv.backgroundColor = ColorPalette.black
    cv.delegate = self
    cv.dataSource = self
    cv.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.identifier)
    cv.register(ArtistHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ArtistHeaderView.identifier)
    cv.register(LoadingFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LoadingFooterView.identifier)
    return cv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchArtist()
    fetchAlbums()
  }
  
  // MARK: Layout
  override func setupViews() {
    super.setupViews()
    
    view.addSubview(collectionView)
    collectionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
}

// MARK: Actions
extension ArtistViewController {
  func fetchArtist () {
    API.fetchArtist(artist: artist) { [weak self] (artistResponse, error) in
      guard let strongSelf = self else {
        return
      }
      if let error = error {
        print(error)
        Alert.shared.show(title: "Error", message: "Error communicating with the server")
      } else if let artistResponse = artistResponse {
        strongSelf.artist = artistResponse
      }
    }
  }
  
  func fetchAlbums () {
    isFetching = true
    print("Fetching albums offset(\(offset)) ")
    
    API.fetchArtistAlbums(artist: artist, limit: limit, offset: offset) { [weak self] (spotifyObject, error) in
      guard let strongSelf = self else {
        return
      }
      strongSelf.isFetching = false
      strongSelf.offset += strongSelf.limit
      
      if let error = error {
        print(error)
        Alert.shared.show(title: "Error", message: "Error communicating with the server")
      } else if let spotifyObject = spotifyObject, let items = spotifyObject.items {
        if strongSelf.spotifyObject == nil {
          strongSelf.spotifyObject = spotifyObject
        } else {
          strongSelf.spotifyObject?.items?.append(contentsOf: items)
          strongSelf.spotifyObject?.next = spotifyObject.next
          strongSelf.spotifyObject?.total = spotifyObject.total
        }
        strongSelf.collectionView.reloadData()
      }
    }
  }
}

extension ArtistViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let albumVC = AlbumViewController()
    let album = spotifyObject?.items?[safe: indexPath.item]
    albumVC.album = album
    navigationController?.pushViewController(albumVC, animated: true)
  }
}

extension ArtistViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spotifyObject?.items?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCell.identifier, for: indexPath) as? AlbumCell {
      let album = spotifyObject?.items?[safe: indexPath.item]
      cell.album = album
      
      if let totalItems = spotifyObject?.items?.count, indexPath.item == totalItems - 1, spotifyObject?.next != nil {
        if !isFetching {
          fetchAlbums()
        }
      }
      
      return cell
    }
    return UICollectionViewCell()
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ArtistHeaderView.identifier, for: indexPath) as? ArtistHeaderView {
        headerView.artist = artist
        return headerView
      }
    case UICollectionElementKindSectionFooter:
      if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LoadingFooterView.identifier, for: indexPath) as? LoadingFooterView {
        return footerView
      }
    default: break
    }
    return UICollectionReusableView()
  }
}

extension ArtistViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return cellHeaderSize
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return cellFooterSize
  }
}











