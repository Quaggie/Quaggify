//
//  AlbumViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 05/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class AlbumViewController: ViewController, CellSpecs {
  
  var album: Album? {
    didSet {
      guard let album = album else {
        return
      }
      if let name = album.name {
        navigationItem.title = name
      }
      collectionView.reloadData()
    }
  }
  
  fileprivate var spotifyObject: SpotifyObject<Track>?
  
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
  let cellHeaderHeight: CGFloat = 300
  var cellHeaderWidth: CGFloat {
    return view.frame.width
  }
  let cellFooterHeight: CGFloat = 72
  var cellFooterWidth: CGFloat {
    return view.frame.width
  }
  var cellFooterSize: CGSize {
    if spotifyObject?.next != nil {
      return CGSize(width: cellFooterWidth, height: cellFooterHeight)
    }
    return .zero
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
    cv.register(TrackCell.self, forCellWithReuseIdentifier: TrackCell.identifier)
    cv.register(AlbumHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: AlbumHeaderView.identifier)
    cv.register(LoadingFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LoadingFooterView.identifier)
    return cv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchTracks()
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
extension AlbumViewController {
  func fetchTracks () {
    isFetching = true
    print("Fetching tracks offset(\(offset)) ")
    
    API.fetchAlbumTracks(album: album, limit: limit, offset: offset) { [weak self] (spotifyObject, error) in
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

// MARK: UICollectionViewDelegate
extension AlbumViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let trackVC = TrackViewController()
    trackVC.track = spotifyObject?.items?[safe: indexPath.item]
    navigationController?.pushViewController(trackVC, animated: true)
  }
}

// MARK: UICollectionViewDataSource
extension AlbumViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return spotifyObject?.items?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCell.identifier, for: indexPath) as? TrackCell {
      let track = spotifyObject?.items?[safe: indexPath.item]
      cell.track = track
      
      if let totalItems = spotifyObject?.items?.count, indexPath.item == totalItems - 1, spotifyObject?.next != nil {
        if !isFetching {
          fetchTracks()
        }
      }
      
      return cell
    }
    return UICollectionViewCell()
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: AlbumHeaderView.identifier, for: indexPath) as? AlbumHeaderView {
        headerView.album = album
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

// MARK: UICollectionViewDelegateFlowLayout
extension AlbumViewController: UICollectionViewDelegateFlowLayout {
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


















