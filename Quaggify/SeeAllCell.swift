//
//  SeeAllCell.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class SeeAllCell: CollectionViewCell {
  
  var title: String? {
    didSet {
      if let title = title {
        titleLabel.text = title
      }
    }
  }
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.textColor = ColorPalette.white
    label.textAlignment = .left
    label.font = Font.montSerratRegular(size: 16)
    return label
  }()

  override func setupViews() {
    super.setupViews()
    
    addSubview(titleLabel)
    titleLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
  }
}
