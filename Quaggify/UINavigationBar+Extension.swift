//
//  UINavigationBar+Extension.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 03/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

extension UINavigationBar {
  func makeTransparent() {
    setBackgroundImage(UIImage(), for: UIBarMetrics.default)
    shadowImage = UIImage()
    isTranslucent = true
    backgroundColor = UIColor.clear
  }
}
