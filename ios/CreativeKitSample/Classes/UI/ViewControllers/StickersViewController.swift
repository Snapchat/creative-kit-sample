//
//  StickersViewController.swift
//  CreativeKitSample
//
//  Created by Samuel Chow on 3/27/19.
//  Copyright © 2019 Snap Inc. All rights reserved.
//

import UIKit

import FLAnimatedImage
import SCSDKCreativeKit

class StickersViewController: UIViewController {
  // Configuration
  
  enum Constants {
    static let reuseIdentifier = "StickerGridCellIdentifer"
  }
  
  // Visual components
  
  @IBOutlet weak var collectionView: UICollectionView?
  @IBOutlet weak var shareButton: UIBarButtonItem?
  
  // State variables
  
  public var caption: String?
  private var selectedIndex: IndexPath?
  private let stickers = [
    Media(name: "icon-new.png", source: .bundle, type: .still),
    Media(name: "icon-badge.png", source: .bundle, type: .still),
    Media(name: "icon-warning.png", source: .bundle, type: .still),
    Media(name: "icon-20-percent.png", source: .bundle, type: .still),
    Media(name: "https://cybersamx.github.io/images/rainbow-spinner.gif", source: .remote, type: .animated),
    Media(name: "https://cybersamx.github.io/images/oscillating-green-ball.gif", source: .remote, type: .animated),
  ]
  
  // MARK: - Event Handlers
  
  @IBAction func shareDidTap() {
    guard let selectedIndex = selectedIndex else {
      print("Need to select a sticker")
      return
    }
    
    let selectedCell = collectionView?.cellForItem(at: selectedIndex) as? ImageCollectionViewCell
    var sticker:SCSDKSnapSticker? = nil
    if selectedCell?.media?.type == .still {
      guard let stickerImage = selectedCell?.animView?.image else {
        return
      }
      
      sticker = SCSDKSnapSticker(stickerImage: stickerImage)
    } else if selectedCell?.media?.type == .animated {
      if selectedCell?.media?.source == .remote {
        guard let urlString = selectedCell?.media?.name,
          let url = URL(string: urlString) else {
            return
        }
        
        sticker = SCSDKSnapSticker(stickerUrl: url, isAnimated: true)
      }
    }

    let snapContent = SCSDKNoSnapContent()
    snapContent.sticker = sticker
    snapContent.caption = caption
    
    // Send it over to Snapchat
    let snapAPI = SCSDKSnapAPI(content: snapContent)
    snapAPI.startSnapping { (error: Error?) in
      print("Sharing a sticker on SnapChat.")
    }
  }
  
  @IBAction func cancelDidTap() {
    dismiss(animated: true)
  }
  
  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension StickersViewController: UICollectionViewDataSource {
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return stickers.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier,
                                                  for: indexPath)
    guard let imageCell = cell as? ImageCollectionViewCell else {
      return cell
    }
    
    imageCell.media = stickers[indexPath.row]
    
    return imageCell
  }
}

extension StickersViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let selectedIndex = selectedIndex {
      guard let prevSelectedCell = collectionView.cellForItem(at: selectedIndex)
        as? ImageCollectionViewCell else {
          return
      }

      prevSelectedCell.select(withColor: UIColor.clear)
    }
    
    guard let selectedCell = collectionView.cellForItem(at: indexPath) as?
      ImageCollectionViewCell else {
        return
    }
    
    selectedCell.select(withColor: UIColor.orange)
    selectedIndex = indexPath
    shareButton?.isEnabled = true
  }
}

