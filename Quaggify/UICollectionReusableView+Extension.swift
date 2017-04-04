//
//  UICollectionReusableView+Extension.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 04/04/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

extension UICollectionReusableView {
  static var identifier: String {
    return String(describing: self)
  }
}
