//
//  NavigationController.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationBar.barTintColor = ColorPalette.gray
    navigationBar.shadowImage = UIImage()
    navigationBar.barStyle = .blackTranslucent
    navigationBar.tintColor = .white
    
    if let titleFont = Font.montSerratRegular(size: 16) {
      navigationBar.titleTextAttributes = [NSAttributedStringKey.font: titleFont]
    }
  }
}
