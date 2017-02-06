//
//  String+Extension.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 03/02/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

import Foundation
import Alamofire

extension String: Error {}

extension String: LocalizedError {
  public var errorDescription: String? { return self }
}
