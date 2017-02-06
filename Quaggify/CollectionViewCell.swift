//
//  CollectionViewCell.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
  
  static var identifier: String {
    return String(describing: self)
  }
  
  override var isHighlighted: Bool {
    didSet {
      alpha = isHighlighted ? 0.5 : 1
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupViews()
  }
  
  func setupViews () {
    backgroundColor = .clear
  }
  
}
