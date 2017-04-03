//
//  TrackViewController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 05/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class TrackViewController: ViewController {
  
  var track: Track? {
    didSet {
      guard let track = track else {
        return
      }
      if let name = track.name {
        titleLabel.text = name
      }
      if let artists = track.artists {
        let names = artists.map { $0.name ?? "Uknown Artist" }.joined(separator: ", ")
        subTitleLabel.text = names
        navigationItem.title = names
      }
      if let smallerImage = track.album?.images?[safe: 1], let imgUrlString = smallerImage.url, let url = URL(string: imgUrlString) {
        imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else if let smallerImage = track.album?.images?[safe: 0], let imgUrlString = smallerImage.url, let url = URL(string: imgUrlString) {
        imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else {
        imageView.image = #imageLiteral(resourceName: "placeholder")
      }
    }
  }
  
  // MARK: Views
  
  var titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.montSerratBold(size: 20)
    label.textColor = ColorPalette.white
    label.textAlignment = .center
    return label
  }()
  
  var subTitleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.montSerratRegular(size: 18)
    label.textColor = ColorPalette.lightGray
    label.textAlignment = .center
    return label
  }()
  
  lazy var addToPlaylistButton: UIButton = {
    let btn = UIButton(type: .system)
    let img = #imageLiteral(resourceName: "icon_add_playlist").withRenderingMode(.alwaysTemplate)
    btn.tintColor = ColorPalette.white
    btn.titleLabel?.font = Font.montSerratRegular(size: 30)
    btn.setTitle("Add to Playlist", for: .normal)
    btn.addTarget(self, action: #selector(addToPlaylist), for: .touchUpInside)
    return btn
  }()
  
  var imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    return iv
  }()
  
  let stackView: UIStackView = {
    let sv = UIStackView()
    sv.alignment = .fill
    sv.axis = .vertical
    sv.distribution = .fillEqually
    sv.backgroundColor = .clear
    sv.spacing = 8
    return sv
  }()
  
  let containerView: UIView = {
    let v = UIView()
    v.backgroundColor = .clear
    return v
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchTrack()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    switch UIApplication.shared.statusBarOrientation {
    case .portrait: fallthrough
    case .portraitUpsideDown: fallthrough
    case .unknown:
      setPortraitLayout()
      break
    case .landscapeLeft: fallthrough
    case .landscapeRight:
      setLandscapeLayout()
      break
    }
    view.layoutIfNeeded()
  }
  
  // MARK: Layout
  override func setupViews() {
    super.setupViews()
    
    view.addSubview(stackView)
    view.addSubview(imageView)
    view.addSubview(containerView)
    view.addSubview(titleLabel)
    view.addSubview(subTitleLabel)
    view.addSubview(addToPlaylistButton)
    view.backgroundColor = ColorPalette.black
    
    stackView.addArrangedSubview(imageView)
    stackView.addArrangedSubview(containerView)
    
    stackView.anchor(topLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: bottomLayoutGuide.topAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    
    titleLabel.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
    
    subTitleLabel.anchor(titleLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 24)
    
    addToPlaylistButton.anchor(subTitleLabel.bottomAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
  }
}

// MARK: Layout
extension TrackViewController {
  func setPortraitLayout () {
    stackView.axis = .vertical
  }
  
  func setLandscapeLayout () {
    stackView.axis = .horizontal
  }
}

// MARK: Actions
extension TrackViewController {
  func addToPlaylist () {
    let trackOptionsVC = TrackOptionsViewController()
    trackOptionsVC.track = track
    
    let trackOptionsNav = NavigationController(rootViewController: trackOptionsVC)
    present(trackOptionsNav, animated: true, completion: nil)
  }
  
  func fetchTrack () {
    API.fetchTrack(track: track) { [weak self] (trackResponse, error) in
      guard let strongSelf = self else {
        return
      }
      if let error = error {
        print(error)
        Alert.shared.show(title: "Error", message: "Error communicating with the server")
      } else if let trackResponse = trackResponse {
        strongSelf.track = trackResponse
      }
    }
  }
}
















