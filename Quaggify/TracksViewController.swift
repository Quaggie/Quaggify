//
//  TracksViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class TracksViewController: ViewController {
  
  var spotifyObject: SpotifyObject<Track>?
  var query: String? {
    didSet {
      if let query = query {
        navigationItem.title = "\"\(query)\" in Songs"
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
    cv.register(TrackCell.self, forCellWithReuseIdentifier: TrackCell.identifier)
    return cv
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchTracks()
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
extension TracksViewController {
  func fetchTracks () {
    isFetching = true
    print("Fetching albums offset(\(offset)) ")
    
    if let query = query {
      API.fetchTracks(query: query, limit: limit, offset: offset) { [weak self] (spotifyObject, error) in
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
extension TracksViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let trackVC = TrackViewController()
    trackVC.track = spotifyObject?.items?[safe: indexPath.item]
    navigationController?.pushViewController(trackVC, animated: true)
  }
}

// MARK: UICollectionViewDataSource
extension TracksViewController: UICollectionViewDataSource {
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
}

// MARK: UICollectionViewDelegateFlowLayout
extension TracksViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width - (contentInset * 2), height: 72)
  }
}




















