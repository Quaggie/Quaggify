//
//  ArtistHeaderView.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 05/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class ArtistHeaderView: UICollectionReusableView {
  
  static var identifier: String {
    return String(describing: self)
  }
  
  var artist: Artist? {
    didSet {
      guard let artist = artist else {
        return
      }
      if let img = artist.images?[safe: 0], let imgUrlString = img.url, let url = URL(string: imgUrlString) {
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
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.textColor = ColorPalette.white
    label.textAlignment = .center
    label.font = Font.montSerratBold(size: 20)
    return label
  }()
  
  var subTitleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.montSerratRegular(size: 14)
    label.textColor = ColorPalette.lightGray
    label.textAlignment = .center
    return label
  }()
  
  override init (frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private let imgViewSize = CGSize(width: 150, height: 150)
  
  private func setupViews () {
    addSubview(imageView)
    addSubview(titleLabel)
    addSubview(subTitleLabel)
    
    imageView.layer.cornerRadius = imgViewSize.height / 2
    imageView.anchorCenterXToSuperview()
    imageView.anchor(topAnchor, left: nil, bottom: nil, right: nil, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: imgViewSize.width, heightConstant: imgViewSize.height)
    
    titleLabel.anchor(imageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 24)
    
    subTitleLabel.anchor(titleLabel.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    
    backgroundColor = .clear
  }
}

















