//
//  TrackCell.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 01/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class TrackCell: CollectionViewCell {

  var track: Track? {
    didSet {
      guard let track = track else {
        return
      }
      if let artistName = track.name {
        titleLabel.text = artistName
      }
      if let artists = track.artists {
        let names = artists.map { $0.name ?? "Uknown Artist" }.joined(separator: ", ")
        subTitleLabel.text = names
        if let albumName = track.album?.name {
          subTitleLabel.text?.append(" ・ \(albumName)")
        }
      }
    }
  }
  
  var position: Int?
  
  let stackView: UIStackView = {
    let sv = UIStackView()
    sv.axis = .vertical
    sv.alignment = .fill
    sv.distribution = .fillEqually
    sv.backgroundColor = .clear
    sv.spacing = 4
    return sv
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = ColorPalette.white
    label.font = Font.montSerratBold(size: 16)
    label.textAlignment = .left
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  let subTitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = ColorPalette.lightGray
    label.font = Font.montSerratRegular(size: 12)
    label.textAlignment = .left
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var moreButton: UIButton = {
    let button = UIButton(type: .system)
    button.setImage(#imageLiteral(resourceName: "icon_more").withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = ColorPalette.white
    button.addTarget(self, action: #selector(showTrackOptions), for: .touchUpInside)
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(onHold(sender:)))
    addGestureRecognizer(longGesture)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupViews() {
    super.setupViews()
    
    addSubview(stackView)
    addSubview(moreButton)
    
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(subTitleLabel)
    
    stackView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: moreButton.leftAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    moreButton.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 56, heightConstant: 0)
  }
  
  @objc func onHold (sender : UIGestureRecognizer) {
    if sender.state == .began {
      showTrackOptions()
    }
  }
  
  @objc func showTrackOptions () {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    if let name = track?.name {
      alertController.title = name
    }
    alertController.addAction(UIAlertAction(title: "Add to playlist", style: .default) { [weak self] _ in
      let trackOptionsVC = TrackOptionsViewController()
      trackOptionsVC.track = self?.track
      
      let trackOptionsNav = NavigationController(rootViewController: trackOptionsVC)

      UIApplication.topViewController()?.present(trackOptionsNav, animated: true, completion: nil)
    })
    if let topViewController = UIApplication.topViewController() {
      if !(topViewController is AlbumViewController) {
        alertController.addAction(UIAlertAction(title: "Go to Album", style: .default, handler: { [weak self] _ in
          let albumVC = AlbumViewController()
          albumVC.album = self?.track?.album
          topViewController.navigationController?.pushViewController(albumVC, animated: true)
        }))
      }
      if !(topViewController is ArtistViewController) {
        alertController.addAction(UIAlertAction(title: "Go to Artist", style: .default, handler: { [weak self] _ in
          let artistVC = ArtistViewController()
          artistVC.artist = self?.track?.artists?.first
          topViewController.navigationController?.pushViewController(artistVC, animated: true)
        }))
      }
      
      alertController.addAction(UIAlertAction(title: "Open in Spotify", style: .default) { [weak self] _ in
        if let uri = self?.track?.uri, let url = URL(string: uri), UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if let href = self?.track?.externalUrls?.spotify, let url = URL(string: href), UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
      })
      
      if let playlistVC = topViewController as? PlaylistViewController, User.current.id == playlistVC.playlist?.owner?.id {
        alertController.addAction(UIAlertAction(title: "Remove from playlist", style: .destructive, handler: { [weak self] _ in
          playlistVC.removeFromPlaylist(track: self?.track, position: self?.position)
        }))
      }
    }
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
  }

}
