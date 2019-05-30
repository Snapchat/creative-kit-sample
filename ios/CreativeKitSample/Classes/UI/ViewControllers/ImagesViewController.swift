//
//  ImagesViewController.swift
//  CreativeKitSample
//
//  Created by Samuel Chow on 3/27/19.
//  Copyright © 2019 Snap Inc. All rights reserved.
//

import Foundation
import UIKit

import SCSDKCreativeKit

class ImagesViewController: UIViewController {
    fileprivate enum Constants {
        static let gridCount = 32
        static let reuseIdentifier = "ImageGridCellIdentifer"
    }
    
    // MARK: - Properties
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView?
    @IBOutlet fileprivate weak var shareButton: UIBarButtonItem?

    internal var caption: String?
    fileprivate var isSharing = false
    fileprivate var indices: [Int]?
    fileprivate var selectedIndex: IndexPath?
    fileprivate lazy var snapAPI = {
        return SCSDKSnapAPI()
    }()
}

// MARK: - Private helpers

extension ImagesViewController {
    // We are using https://picsum.photos, a free online photo gallery API to pull
    // a list of images for us to send the image URL to Snapchat as an attachment URL.
    // A picsum image is represented by an URL bearing its ID as well as the width and
    // height, to which you wish to scale.
    
    fileprivate func fetchImageMetaData() {
        let session = URLSession.shared
        let url = URL(string: "https://picsum.photos/list")!
        let task = session.dataTask(with: url) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil,
                let data = data,
                let jsonArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
                    print("No or bad data received from picsum.photos.")
                    return
            }
            
            #if swift(>=4.1)
            self?.indices = jsonArray?.compactMap({ (element: [String: Any]) -> Int? in
                return element["id"] as? Int
            })
            #else
            self?.indices = jsonArray?.flatMap({ (element: [String: Any]) -> Int? in
            return element["id"] as? Int
            })
            #endif
            
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        }
        task.resume()
    }
    
    fileprivate func getURL(width: Int, height: Int, id: Int?) -> URL? {
        guard let id = id else {
            return nil
        }
        
        let urlString = String(format: "https://picsum.photos/%d/%d?image=%d", width, height, id)
        
        return URL(string: urlString)
    }
}

// MARK: - Action handlers

extension ImagesViewController {
    @IBAction func shareDidTap(_ sender: UINavigationItem) {
        guard !isSharing,
            let url = getURL(width: Int(view.bounds.size.width),
                               height: Int(view.bounds.size.height),
                               id: selectedIndex?.row) else {
                                return
        }
        
        isSharing = true
        let snapPhoto = SCSDKSnapPhoto(imageUrl: url)
        let snapContent = SCSDKPhotoSnapContent(snapPhoto: snapPhoto)
        snapContent.caption = caption
        
        // Send it over to Snapchat
        
        // NOTE: startSending() makes use of the global UIPasteboard. Calling the method without synchronization
        //       might cause the UIPasteboard data to be overwritten, while the pasteboard is being read from Snapchat.
        //       Either synchronize the method call yourself or disable user interaction until the share is over.
        view.isUserInteractionEnabled = false
        snapAPI.startSending(snapContent) { [weak self] (error: Error?) in
            self?.view.isUserInteractionEnabled = true
            self?.isSharing = false
            print("Shared \(String(describing: url.absoluteString)) on SnapChat.")
        }
    }
    
    @IBAction func cancelDidTap(_ sender: UINavigationItem) {
        dismiss(animated: true)
    }
}

// MARK: - UIViewController

extension ImagesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchImageMetaData()
    }
}

// MARK: - UICollectionViewDataSource

extension ImagesViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // We cap the number of images to the gridCount.
        return indices == nil ? 0 : min(indices!.count, Constants.gridCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseIdentifier,
                                                      for: indexPath)
        guard indices != nil,
            indices!.count > 0,
            let imageCell = cell as? ImageCollectionViewCell else {
                return cell
        }
        
        let index = indices![indexPath.row]
        let url = getURL(width: Int(imageCell.bounds.size.width),
                         height: Int(imageCell.bounds.size.height),
                         id: index)
        imageCell.animView?.setImage(withURL: url)
        
        return imageCell
    }
}

// MARK: - UICollectionViewDelegate

extension ImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedIndex = selectedIndex {
            guard let prevSelectedCell = collectionView.cellForItem(at: selectedIndex)
                as? ImageCollectionViewCell else {
                    return
            }
            prevSelectedCell.animView?.layer.borderColor = UIColor.clear.cgColor
            prevSelectedCell.animView?.layer.borderWidth = 0.0
        }
        
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as?
            ImageCollectionViewCell else {
                return
        }
        
        selectedCell.animView?.layer.borderColor = UIColor.orange.cgColor
        selectedCell.animView?.layer.borderWidth = 2.0
        selectedIndex = indexPath
        shareButton?.isEnabled = true
    }
}
