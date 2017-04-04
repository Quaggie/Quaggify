//
//  AlbumsViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 03/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class AlbumsViewController: ViewController {
  
  var spotifyObject: SpotifyObject<Album>?
  var query: String? {
    didSet {
      if let query = query {
        navigationItem.title = "\"\(query)\" in Albums"
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
    cv.contentInset = UIEdgeInsets(top: self.contentInset, left: self.contentInset, bottom: self.contentInset, right: self.contentInset)
    cv.backgroundColor = .clear
    cv.delegate = self
    cv.dataSource = self
    cv.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.identifier)
    cv.register(LoadingFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LoadingFooterView.identifier)
    return cv
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchAlbums()
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
extension AlbumsViewController {
  func fetchAlbums () {
    isFetching = true
    print("Fetching albums offset(\(offset)) ")
    
    if let query = query {
      API.fetchAlbums(query: query, limit: limit, offset: offset) { [weak self] (spotifyObject, error) in
        guard let strongSelf = self else {
          return
        }
        strongSelf.isFetching = false
        strongSelf.offset += strongSelf.limit
        
        if let error = error {
          Alert.shared.show(title: "Error", message: error.localizedDescription)
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
extension AlbumsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let albumVC = AlbumViewController()
    let album = spotifyObject?.items?[safe: indexPath.item]
    albumVC.album = album
    navigationController?.pushViewController(albumVC, animated: true)
  }
}

// MARK: UICollectionViewDataSource
extension AlbumsViewController: UICollectionViewDataSource {
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
    case UICollectionElementKindSectionFooter:
      if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LoadingFooterView.identifier, for: indexPath) as? LoadingFooterView {
        return footerView
      }
    default: break
    }
    return UICollectionReusableView()
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension AlbumsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width - (contentInset * 2), height: 72)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    if spotifyObject?.next != nil {
      return CGSize(width: view.frame.width, height: 36)
    }
    return .zero
  }
}


