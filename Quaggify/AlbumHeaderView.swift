//
//  AlbumHeaderView.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 05/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class AlbumHeaderView: UICollectionReusableView {
  static var identifier: String {
    return String(describing: self)
  }
  
  var album: Album? {
    didSet {
      guard let album = album else {
        return
      }
      if let img = album.images?[safe: 0], let imgUrlString = img.url, let url = URL(string: imgUrlString) {
        albumImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else {
        albumImageView.image = #imageLiteral(resourceName: "placeholder")
      }
      if let albumName = album.name {
        albumNameLabel.text = albumName
      }
      if let artistName = album.artists?.first?.name {
        artistNameLabel.text = "Album by \(artistName)".uppercased()
      }
    }
  }
  
  let albumImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    return iv
  }()
  
  let artistNameLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.textColor = ColorPalette.white
    label.textAlignment = .left
    label.font = Font.montSerratRegular(size: 16)
    return label
  }()
  
  let albumNameLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.textColor = ColorPalette.white
    label.textAlignment = .center
    label.font = Font.montSerratBold(size: 30)
    return label
  }()
  
  override init (frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private let artistNameHeight: CGFloat = 30
  private let albumImgViewSize = CGSize(width: 150, height: 150)
  
  private func setupViews () {
    backgroundColor = .clear
    addSubview(albumImageView)
    addSubview(artistNameLabel)
    addSubview(albumNameLabel)

    artistNameLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: artistNameHeight)
    
    albumImageView.anchorCenterXToSuperview()
    albumImageView.anchor(artistNameLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: albumImgViewSize.width, heightConstant: albumImgViewSize.height)
    albumNameLabel.anchor(albumImageView.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
  }
}
















