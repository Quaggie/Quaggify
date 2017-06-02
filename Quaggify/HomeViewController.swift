//
//  ViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit
import Alamofire

class HomeViewController: ViewController {
  
  var spotifyObject: SpotifyObject<Album>?
  
  var limit = 20
  var offset = 0
  var isFetching = false
  
  let lineSpacing: CGFloat = 16
  let interItemSpacing: CGFloat = 8
  let contentInset: CGFloat = 8
  
  lazy var refreshControl: UIRefreshControl = {
    let rc = UIRefreshControl()
    rc.addTarget(self, action: #selector(refreshAlbums), for: .valueChanged)
    return rc
  }()
  
  lazy var collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    flowLayout.minimumLineSpacing = self.lineSpacing
    flowLayout.minimumInteritemSpacing = self.interItemSpacing
    let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    cv.addSubview(self.refreshControl)
    cv.keyboardDismissMode = .onDrag
    cv.alwaysBounceVertical = true
    cv.showsVerticalScrollIndicator = false
    cv.contentInset = UIEdgeInsets(top: self.contentInset, left: self.contentInset, bottom: self.contentInset, right: self.contentInset)
    cv.backgroundColor = .clear
    cv.delegate = self
    cv.dataSource = self
    cv.register(AlbumCell.self, forCellWithReuseIdentifier: AlbumCell.identifier)
    cv.register(SearchHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SearchHeaderView.identifier)
    cv.register(LoadingFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LoadingFooterView.identifier)
    return cv
  }()
  
  // MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchAlbums()
    setup3dTouch()
  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
  // MARK: Layout
  override func setupViews() {
    super.setupViews()
    navigationItem.title = "Home".uppercased()
    
    view.addSubview(collectionView)
    collectionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
  }
  
  func setup3dTouch () {
    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: view)
    }
  }
}

// MARK: Actions
extension HomeViewController {
  func fetchAlbums () {
    if refreshControl.isRefreshing || isFetching {
      return
    }
    isFetching = true
    print("Fetching albums offset(\(offset)) ")
    
    API.fetchNewReleases(limit: limit, offset: offset) { [weak self] (spotifyObject, error) in
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
  
  func refreshAlbums () {
    if isFetching {
      return
    }
    isFetching = true
    print("Refreshing albums")
    
    API.fetchNewReleases(limit: limit, offset: 0) { [weak self] (spotifyObject, error) in
      guard let strongSelf = self else {
        return
      }
      strongSelf.isFetching = false
      strongSelf.refreshControl.endRefreshing()
      strongSelf.offset = strongSelf.limit
      
      if let error = error {
        print(error)
        Alert.shared.show(title: "Error", message: "Error communicating with the server")
      } else if let spotifyObject = spotifyObject, let items = spotifyObject.items {
        if strongSelf.spotifyObject == nil {
          strongSelf.spotifyObject = spotifyObject
        } else {
          strongSelf.spotifyObject?.items?.removeAll()
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
extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let albumVC = AlbumViewController()
    let album = spotifyObject?.items?[safe: indexPath.item]
    albumVC.album = album
    navigationController?.pushViewController(albumVC, animated: true)
  }
}

// MARK: UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
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
      if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SearchHeaderView.identifier, for: indexPath) as? SearchHeaderView {
        headerView.title = "New Releases"
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
extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width - (contentInset * 2), height: 72)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if spotifyObject?.items?.count ?? 0 > 0 {
      return CGSize(width: view.frame.width, height: 72)
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    if spotifyObject?.next != nil {
      return CGSize(width: view.frame.width, height: 36)
    }
    return .zero
  }
}

extension HomeViewController: ScrollDelegate {
  func scrollToTop() {
    if spotifyObject?.items?.count ?? 0 > 0 {
      collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
  }
}

extension HomeViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let indexPath = collectionView.indexPathForItem(at: location),
    let cell = collectionView.cellForItem(at: indexPath) else {
      return nil
    }
    let albumVC = AlbumViewController()
    albumVC.preferredContentSize = CGSize(width: 0.0, height: 600)
    let album = spotifyObject?.items?[safe: indexPath.item]
    albumVC.album = album
    
    previewingContext.sourceRect = cell.frame
    return albumVC
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    show(viewControllerToCommit, sender: self)
  }
}

















