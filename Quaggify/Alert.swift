//
//  Alert.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import Foundation
import UIKit

class Alert: NSObject {
  static let shared = Alert()
  private override init () {}
  
  var isShown = false
  
  func show(title: String, message: String, completion: (() -> Void)? = nil) {
    if isShown == true {
      return
    }
    isShown = true
    
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
      self?.isShown = false
      completion?()
    })
    UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
  }
}

