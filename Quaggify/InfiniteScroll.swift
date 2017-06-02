//
//  InfiniteScroll.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/06/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//

protocol InfiniteScroll: class {
  var limit: Int { get }
  var offset: Int { get set }
  var isFetching: Bool { get set }
}
