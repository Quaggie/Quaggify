//
//  ArtistCell.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 01/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class ArtistCell: CollectionViewCell {
  var artist: Artist? {
    didSet {
      guard let artist = artist else {
        return
      }
      if let smallerImage = artist.images?[safe: 2], let imgUrlString = smallerImage.url, let url = URL(string: imgUrlString) {
        imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else if let smallerImage = artist.images?[safe: 1], let imgUrlString = smallerImage.url, let url = URL(string: imgUrlString) {
        imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else if let smallerImage = artist.images?[safe: 0], let imgUrlString = smallerImage.url, let url = URL(string: imgUrlString) {
        imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"), options: [.transition(.fade(0.2))])
      } else {
        imageView.image = #imageLiteral(resourceName: "placeholder")
      }
      if let artistName = artist.name {
        titleLabel.text = artistName
      }
      if let totalFollowers = artist.followers?.total {
        subTitleLabel.text = "\(totalFollowers) Followers".uppercased()
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
  
  private let imgViewSize = CGSize(width: 64, height: 64)
  
  override func setupViews() {
    super.setupViews()
    
    addSubview(imageView)
    imageView.layer.cornerRadius = imgViewSize.height / 2
    addSubview(stackView)
    
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(subTitleLabel)
    
    imageView.anchorCenterYToSuperview()
    imageView.anchor(nil, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: imgViewSize.width, heightConstant: imgViewSize.height)
    
    stackView.anchor(imageView.topAnchor, left: imageView.rightAnchor, bottom: imageView.bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
  }
}
