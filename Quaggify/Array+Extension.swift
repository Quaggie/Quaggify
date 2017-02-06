//
//  Array+Extension.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 31/01/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import Foundation

extension Array {
  subscript (safe index: Int) -> Element? {
    return index < count ? self[index] : nil
  }
}
