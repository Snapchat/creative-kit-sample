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
    fileprivate enum Constants {
        static let reuseIdentifier = "StickerGridCellIdentifer"
    }
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView?
    @IBOutlet fileprivate weak var shareButton: UIBarButtonItem?
    
    internal var caption: String?
    fileprivate var isSharing = false
    fileprivate var selectedIndex: IndexPath?
    fileprivate let stickers = [
        Media(name: "icon-new.png", source: .bundle, type: .still),
        Media(name: "icon-badge.png", source: .bundle, type: .still),
        Media(name: "https://raw.githubusercontent.com/Snapchat/creative-kit-sample/master/ios/images/rainbow-spinner.gif", source: .remote, type: .animated),
        Media(name: "https://raw.githubusercontent.com/Snapchat/creative-kit-sample/master/ios/images/oscillating-green-ball.gif", source: .remote, type: .animated),
    ]
    fileprivate lazy var snapAPI = {
        return SCSDKSnapAPI()
    }()
}

// MARK: Action handlers

extension StickersViewController {
    @IBAction func shareDidTap(_ sender: UINavigationItem) {
        guard !isSharing,
            let selectedIndex = selectedIndex else {
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
        
        isSharing = true
        let snapContent = SCSDKNoSnapContent()
        snapContent.sticker = sticker
        snapContent.caption = caption
        
        // Send it over to Snapchat
        // NOTE: startSending() makes use of the global UIPasteboard. Calling the method without synchronization
        //       might cause the UIPasteboard data to be overwritten, while the pasteboard is being read from Snapchat.
        //       Either synchronize the method call yourself or disable user interaction until the share is over.
        view.isUserInteractionEnabled = false
        snapAPI.startSending(snapContent) { [weak self] (error: Error?) in
            self?.view.isUserInteractionEnabled = true
            self?.isSharing = false
        }
    }
    
    @IBAction func cancelDidTap(_ sender: UINavigationItem) {
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource

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

// MARK: - UICollectionViewDelegate

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
