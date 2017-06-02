//
//  CellSpecs.swift
//  Quaggify
//
//  Created by Jonathan Bijos on 02/06/17.
//  Copyright © 2017 Quaggie. All rights reserved.
//
import UIKit

protocol CellSpecs: class {
  var lineSpacing: CGFloat { get }
  var interItemSpacing: CGFloat { get }
  var contentInset: CGFloat { get }
  
  var cellHeight: CGFloat { get }
  var cellWidth: CGFloat { get }
  var cellHeaderHeight: CGFloat { get }
  var cellHeaderWidth: CGFloat { get }
  var cellFooterHeight: CGFloat { get }
  var cellFooterWidth: CGFloat { get }
  
  func cellInstance (_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
  func headerInstance (_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView
  func footerInstance (_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionReusableView
}

extension CellSpecs {
  var cellSize: CGSize {
    return CGSize(width: cellWidth, height: cellHeight)
  }
  var cellHeaderSize: CGSize {
    return CGSize(width: cellHeaderWidth, height: cellHeaderHeight)
  }
  var cellFooterSize: CGSize {
    return CGSize(width: cellFooterWidth, height: cellFooterHeight)
  }
}
