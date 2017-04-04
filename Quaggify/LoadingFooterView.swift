//
//  LoadingFooterView.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 04/04/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class LoadingFooterView: UICollectionReusableView {
  
  let activityIndicator: UIActivityIndicatorView = {
    let ai = UIActivityIndicatorView(activityIndicatorStyle: .white)
    ai.hidesWhenStopped = true
    ai.startAnimating()
    return ai
  }()
  
  var isLoading = true {
    didSet {
      if isLoading {
        activityIndicator.startAnimating()
      } else {
        activityIndicator.stopAnimating()
      }
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: Layout
extension LoadingFooterView {
  func setupViews () {
    backgroundColor = .clear
    
    addSubview(activityIndicator)
    activityIndicator.anchorCenterSuperview()
  }
}
