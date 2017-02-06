//
//  UIColor+Extension.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import UIKit

extension UIColor {
  convenience init(hexString: String) {
    var cString: String = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
      cString = (cString as NSString).substring(from: 1)
    }
    
    if (cString.characters.count != 6) {
      self.init(white: 0.5, alpha: 1.0)
    } else {
      let rString: String = (cString as NSString).substring(to: 2)
      let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
      let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
      
      var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0;
      Scanner(string: rString).scanHexInt32(&r)
      Scanner(string: gString).scanHexInt32(&g)
      Scanner(string: bString).scanHexInt32(&b)
      
      self.init(red: CGFloat(r) / CGFloat(255.0), green: CGFloat(g) / CGFloat(255.0), blue: CGFloat(b) / CGFloat(255.0), alpha: CGFloat(1))
    }
    
  }
}
