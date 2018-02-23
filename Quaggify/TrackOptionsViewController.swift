//
//  TrackOptionsViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class TrackOptionsViewController: ViewController {
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  var track: Track? {
    didSet{
      if let createNewPlaylistSection = Playlist(JSON: ["name": "Create new playlist"]) {
        sections.append([createNewPlaylistSection])
      }
    }
  }
  
  var spotifyObject: SpotifyObject<Playlist>? {
    didSet {
      collectionView.reloadData()
    }
  }
  
  var sections: [[Playlist]] = [] {
    didSet {
      collectionView.reloadData()
    }
  }
  var isDismissing = false
  
  var limit = 20
  var offset = 0
  var isFetching = false
  
  lazy var closeModalButton: UIBarButtonItem = {
    let button = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_remove"), style: .plain, target: self, action: #selector(dismissModal))
    button.tintColor = ColorPalette.black
    return button
  }()
  
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
    cv.backgroundColor = ColorPalette.white
    cv.delegate = self
    cv.dataSource = self
    cv.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.identifier)
    cv.register(SearchHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: SearchHeaderView.identifier)
    cv.register(LoadingFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LoadingFooterView.identifier)
    return cv
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupNavigationBar()
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

extension TrackOptionsViewController {
  
  func setupNavigationBar () {
    navigationController?.navigationBar.barTintColor = ColorPalette.white
    navigationController?.navigationBar.isOpaque = true
    navigationController?.navigationBar.isTranslucent = false
    navigationItem.leftBarButtonItem = closeModalButton
    navigationItem.title = "Add to Playlist".uppercased()
    if let titleFont = Font.montSerratRegular(size: 16) {
      navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: titleFont, NSAttributedStringKey.foregroundColor: ColorPalette.black]
    }
  }
}

// MARK: Actions
extension TrackOptionsViewController {
  @objc func dismissModal () {
    dismiss(animated: true, completion: nil)
  }
  
  func fetchPlaylists () {
    isFetching = true
    print("Fetching playlists offset(\(offset)) ")
    
    API.fetchCurrentUsersPlaylists(limit: limit, offset: offset) { [weak self] (spotifyObject, error) in
      guard let strongSelf = self else {
        return
      }
      strongSelf.isFetching = false
      strongSelf.offset += strongSelf.limit
      
      if let error = error {
        print(error)
        Alert.shared.show(title: "Error", message: "Error communicating with the server")
      } else if let items = spotifyObject?.items {
        if strongSelf.sections[safe: 1] != nil {
          strongSelf.sections[1].append(contentsOf: items)
        } else {
          strongSelf.sections.append(items)
        }
        strongSelf.spotifyObject = spotifyObject
      }
    }
  }
  
  func showNewPlaylistModal (track: Track?) {
    let alertController = UIAlertController(title: "Create new Playlist".uppercased(), message: nil, preferredStyle: .alert)
    alertController.addTextField { textfield in
      textfield.placeholder = "Playlist name"
      textfield.addTarget(self, action: #selector(self.textDidChange(textField:)), for: .editingChanged)
    }
    let cancelAction = UIAlertAction(title: "Cancel".uppercased(), style: .destructive, handler: nil)
    let createAction = UIAlertAction(title: "Create".uppercased(), style: .default) { _ in
      if let textfield = alertController.textFields?.first, let playlistName = textfield.text {
        API.createNewPlaylist(name: playlistName) { [weak self] (playlist, error) in
          if let error = error {
            print(error)
            // Showing error message
            Alert.shared.show(title: "Error", message: "Error communicating with the server")
          } else if let playlist = playlist {
            // Adding track to palylist
            API.addTrackToPlaylist(track: track, playlist: playlist) { [weak self] (snapshotId, error) in
              if let error = error {
                print(error)
                // Showing error message
                Alert.shared.show(title: "Error", message: "Error communicating with the server")
              } else if let _ = snapshotId {
                self?.dismiss(animated: true) {
                  Alert.shared.show(title: "Success!", message: "Playlist \(playlistName) created")
                  // Message to update library tab
                  NotificationCenter.default.post(name: .onUserPlaylistUpdate, object: playlist)
                }
              }
            }
          }
        }
      }
    }
    createAction.isEnabled = false
    alertController.addAction(cancelAction)
    alertController.addAction(createAction)
    present(alertController, animated: true, completion: nil)
  }
  
  @objc func textDidChange (textField: UITextField) {
    if let topVc = UIApplication.topViewController() as? UIAlertController, let createAction = topVc.actions[safe: 1] {
      if let text = textField.text, text != "" {
        createAction.isEnabled = true
      } else {
        createAction.isEnabled = false
      }
    }
  }
  
  func addTrackToPlaylist(playlist: Playlist?) {
    API.addTrackToPlaylist(track: track, playlist: playlist) { [weak self] (snapshotId, error) in
      if let error = error {
        print(error)
        Alert.shared.show(title: "Error", message: "Error communicating with the server")
      } else if let _ = snapshotId {
        self?.dismiss(animated: true) {
          Alert.shared.show(title: "Success!", message: "Track added to Playlist")
          // Message to update library tab
          NotificationCenter.default.post(name: .onUserPlaylistUpdate, object: playlist)
        }
      }
    }
  }
}

// MARK: UICollectionViewDelegate
extension TrackOptionsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // Dismiss modal & add track to playlist
    if indexPath.section == 0 {
      showNewPlaylistModal(track: track)
    } else {
      let playlist = sections[safe: indexPath.section]?[safe: indexPath.item]
      addTrackToPlaylist(playlist: playlist)
    }
  }
}

extension TrackOptionsViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if isDismissing {
      return
    }
    let touchPoint = scrollView.contentOffset
    print(touchPoint)
    
    // Change frame if user is scrolling up
    if let navController = navigationController, let window = view.window, touchPoint.y < 0 {
      navController.view.frame = CGRect(x: 0, y: -touchPoint.y, width: window.frame.size.width, height: window.frame.size.height)
    } else {
      // Only animate if it's not already on top
      if let navController = self.navigationController, navController.view.frame.origin.y > 0 {
        // Animate to top
        UIView.animate(withDuration: 0.3) {
          navController.view.frame = CGRect(x: 0, y: 0, width: navController.view.frame.size.width, height: navController.view.frame.size.height)
        }
      }
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if let navController = navigationController, navController.view.frame.origin.y > 100 {
      self.isDismissing = true
      UIView.animate(withDuration: 0.3, animations: {
        navController.view.frame.origin.y = navController.view.frame.height
      }, completion: { _ in
        self.dismiss(animated: false, completion: nil)
      })
    }
  }
}

// MARK: UICollectionViewDataSource
extension TrackOptionsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return sections[safe: section]?.count ?? 0
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return sections.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCell.identifier, for: indexPath) as? PlaylistCell {
      let section = indexPath.section
      let playlist = sections[safe: section]?[safe: indexPath.item]
      cell.playlist = playlist
      cell.titleLabel.textColor = ColorPalette.black
      
      if section == 0 {
        cell.imageView.image = #imageLiteral(resourceName: "icon_add_playlist").withRenderingMode(.alwaysTemplate)
        cell.subTitleLabel.isHidden = true
        cell.imageView.tintColor = ColorPalette.black
      }
      
      // Only on the user's playlists
      if  section == 1 {
        if let totalItems = sections[safe: section]?.count, indexPath.item == totalItems - 1, spotifyObject?.next != nil {
          if !isFetching {
            fetchPlaylists()
          }
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
        
        if indexPath.section == 1 {
          headerView.title = "Your playlists"
          headerView.titleLabel.textColor = ColorPalette.black
          headerView.titleLabel.font = Font.montSerratBold(size: 20)
        }
        return headerView
      }
    case UICollectionElementKindSectionFooter:
      if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: LoadingFooterView.identifier, for: indexPath) as? LoadingFooterView {
        footerView.activityIndicator.color = ColorPalette.gray
        return footerView
      }
    default: break
    }
    return UICollectionReusableView()
  }
}

// MARK: UICollectionViewDelegateFlowLayout
extension TrackOptionsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width - (contentInset * 2), height: 72)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 1 {
      return CGSize(width: view.frame.width, height: 72)
    }
    return .zero
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    if section == 1, spotifyObject?.next != nil {
      return CGSize(width: view.frame.width, height: 36)
    }
    return .zero
  }
}



















