//
//  ImageCollectionViewCell.swift
//  CreativeKitSample
//
//  Created by Samuel Chow on 3/27/19.
//  Copyright © 2019 Snap Inc. All rights reserved.
//

import UIKit

import FLAnimatedImage

// The grid cell used in the images screens
class ImageCollectionViewCell: UICollectionViewCell {
  // Visual components
  
  @IBOutlet weak var animView: FLAnimatedImageView?
  
  // MARK: - UICollectionViewCell
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  convenience init() {
    self.init(frame: CGRect.zero)
  }
  
  // MARK: - ImageCollectionViewCell
  
  var media: Media? {
    willSet(value) {
      guard let value = value else {
        return
      }
      
      switch value.type {
      case .still:
        if value.source == .bundle {
          animView?.image = UIImage(named: value.name.fileName)
        } else if value.source == .remote {
          animView?.setImage(withURL: URL(string: value.name))
        }
      case .animated:
        if value.source == .remote {
          guard let url = URL(string: value.name),
            let animImageData = try? Data(contentsOf: url) else {
              return
          }
          
          let animImage = FLAnimatedImage(animatedGIFData: animImageData)
          animView?.animatedImage = animImage
        }
      default:
        assertionFailure("Implment a switch case for enum MediaType \(value.type)")
      }
    }
  }
  
  // Draw a border around the cell to indicate selection
  func select(withColor color:UIColor) {
    let layer = animView?.layer
    layer?.borderColor = color.cgColor
    layer?.borderWidth = 2.0
  }
}
