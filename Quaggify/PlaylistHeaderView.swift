//
//  PlaylistHeaderView.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 06/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class PlaylistHeaderView: UICollectionReusableView {
  static var identifier: String {
    return String(describing: self)
  }
  
  var playlist: Playlist? {
    didSet {
      guard let playlist = playlist else {
        return
      }
      if let ownerName = playlist.owner?.id {
        ownerNameLabel.text = "Playlist By \(ownerName)".uppercased()
      } else {
        ownerNameLabel.text = "Playlist By"
      }
      if let img = playlist.images?[safe: 0], let imgUrlString = img.url, let url = URL(string: imgUrlString) {
        playlistImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else {
        playlistImageView.image = #imageLiteral(resourceName: "placeholder")
      }
      if let playlistName = playlist.name {
        playlistNameLabel.text = playlistName
      }
    }
  }
  
  let playlistImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    return iv
  }()
  
  let ownerNameLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.textColor = ColorPalette.white
    label.textAlignment = .left
    label.font = Font.montSerratRegular(size: 16)
    return label
  }()
  
  let playlistNameLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.textColor = ColorPalette.white
    label.textAlignment = .center
    label.numberOfLines = 2
    label.lineBreakMode = .byWordWrapping
    label.font = Font.montSerratBold(size:26)
    return label
  }()
  
  override init (frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private let ownerNameHeight: CGFloat = 50
  private let playlistImgViewSize = CGSize(width: 150, height: 150)
  
  private func setupViews () {
    backgroundColor = .clear
    addSubview(ownerNameLabel)
    addSubview(playlistImageView)
    addSubview(playlistNameLabel)
    
    ownerNameLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: ownerNameHeight)
    
    playlistImageView.anchorCenterXToSuperview()
    playlistImageView.anchor(ownerNameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: playlistImgViewSize.width, heightConstant: playlistImgViewSize.height)
    playlistNameLabel.anchor(playlistImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
  }
}
