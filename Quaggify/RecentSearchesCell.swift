//
//  RecentSearchesCell.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 01/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class RecentSearchesCell: CollectionViewCell {
  
  var title: String? {
    didSet {
      guard let title = title else {
        return
      }
      titleLabel.text = title
    }
  }
  
  var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = ColorPalette.white
    label.font = Font.montSerratBold(size: 14)
    label.textAlignment = .left
    return label
  }()
  
  lazy var removeImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.image = #imageLiteral(resourceName: "icon_remove").withRenderingMode(.alwaysTemplate)
    iv.tintColor = ColorPalette.lightGray
    return iv
  }()
  
  lazy var removeButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .clear
    button.setImage(#imageLiteral(resourceName: "icon_remove").withRenderingMode(.alwaysTemplate), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    button.tintColor = ColorPalette.white
    button.addTarget(self, action: #selector(removeRecentSearch), for: .touchUpInside)
    return button
  }()
  
  override func setupViews() {
    addSubview(titleLabel)
    addSubview(removeButton)
    
    titleLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: removeButton.leftAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    removeButton.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 0)
  }
  
  func removeRecentSearch () {
    if let title = title {
      RecentSearches.shared.remove(search: title)
    }
  }
  
  func removeAllRecentSearches () {
    RecentSearches.shared.removeAll()
  }
}
