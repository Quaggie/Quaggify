//
//  PlaylistCell.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 01/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class PlaylistCell: CollectionViewCell {
  
  var omitName = false

  var playlist: Playlist? {
    didSet {
      guard let playlist = playlist else {
        return
      }
      if let smallerImage = playlist.images?[safe: 1], let imgUrlString = smallerImage.url, let url = URL(string: imgUrlString) {
        imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else if let smallerImage = playlist.images?[safe: 0], let imgUrlString = smallerImage.url, let url = URL(string: imgUrlString) {
        imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else {
        imageView.image = #imageLiteral(resourceName: "placeholder")
      }
      if let playlistName = playlist.name {
        titleLabel.text = playlistName
      } else {
        titleLabel.text = "Unkown Playlist"
      }
      if let id = playlist.owner?.id, let totalTracks = playlist.tracks?.total {
        subTitleLabel.isHidden = false
        if omitName {
          subTitleLabel.text = "\(totalTracks) \(totalTracks == 1 ? "song" : "songs")".uppercased()
        } else {
          subTitleLabel.text = "\(id) ・ \(totalTracks) \(totalTracks == 1 ? "song" : "songs")".uppercased()
        }
      } else {
        subTitleLabel.isHidden = true
      }
    }
  }
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    return iv
  }()
  
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
  
  override func setupViews() {
    super.setupViews()
    
    addSubview(imageView)
    addSubview(stackView)
    
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(subTitleLabel)
    
    imageView.anchorCenterYToSuperview()
    imageView.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 64, heightConstant: 64)
    
    stackView.anchor(imageView.topAnchor, left: imageView.rightAnchor, bottom: imageView.bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
  }

}
