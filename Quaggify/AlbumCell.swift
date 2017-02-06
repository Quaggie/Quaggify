//
//  AlbumCell.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit
import Kingfisher

class AlbumCell: CollectionViewCell {
  
  var album: Album? {
    didSet {
      guard let album = album else {
        return
      }
      if let smallerImage = album.images?[safe: 1], let imgUrlString = smallerImage.url, let url = URL(string: imgUrlString) {
        imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else if let smallerImage = album.images?[safe: 0], let imgUrlString = smallerImage.url, let url = URL(string: imgUrlString) {
        imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else {
        imageView.image = #imageLiteral(resourceName: "placeholder")
      }
      if let albumName = album.name {
        titleLabel.text = albumName
      }
      if let artists = album.artists {
        let names = artists.map { $0.name ?? "Uknown Artist" }.joined(separator: ", ")
        subTitleLabel.text = names
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
    label.font = Font.montSerratRegular(size: 16)
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

















