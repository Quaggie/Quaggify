//
//  SearchHeaderView.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class SearchHeaderView: UICollectionReusableView {
  var title = "" {
    didSet {
      titleLabel.text = title
    }
  }
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .clear
    label.textColor = ColorPalette.white
    label.textAlignment = .center
    label.font = Font.montSerratBold(size: 18)
    return label
  }()
  
  override init (frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupViews () {
    addSubview(titleLabel)
    titleLabel.fillSuperview()
  }
}
