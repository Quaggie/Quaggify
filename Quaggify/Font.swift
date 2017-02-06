//
//  Font.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

struct Font {
  fileprivate static let montSerratRegularName = "Montserrat Regular"
  fileprivate static let montSerratBoldName = "Montserrat Bold"
  
  static func montSerratRegular (size: CGFloat) -> UIFont? {
    return UIFont(name: Font.montSerratRegularName, size: size) ?? UIFont.systemFont(ofSize: size)
  }
  static func montSerratBold (size: CGFloat) -> UIFont? {
    return UIFont(name: Font.montSerratBoldName, size: size) ?? UIFont.systemFont(ofSize: size, weight: 0.4)
  }
}
