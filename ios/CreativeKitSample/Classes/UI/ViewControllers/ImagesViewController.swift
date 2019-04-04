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
  // Configuration
  
  enum Constants {
    static let gridCount = 32
    static let reuseIdentifier = "ImageGridCellIdentifer"
  }
  
  // Visual components
  
  @IBOutlet weak var collectionView: UICollectionView?
  @IBOutlet weak var shareButton: UIBarButtonItem?
  
  // State variables

  public var caption: String?
  private var indices: [Int]?
  private var selectedIndex: IndexPath?
  
  // MARK: - Helpers
  
  // We are using https://picsum.photos, a free online photo gallery API to pull
  // a list of images for us to send the image URL to Snapchat as an attachment URL.
  // A picsum image is represented by an URL bearing its ID as well as the width and
  // height, to which you wish to scale.
  
  private func fetchImageMetaData() {
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
  
  func getURL(width: Int, height: Int, id: Int?) -> URL? {
    guard let id = id else {
        return nil
    }
    
    let urlString = String(format: "https://picsum.photos/%d/%d?image=%d", width, height, id)
    
    return URL(string: urlString)
  }
  
  // MARK: - Event Handlers
  
  @IBAction func shareDidTap() {
    guard let url = getURL(width: Int(view.bounds.size.width),
                           height: Int(view.bounds.size.height),
                           id: selectedIndex?.row) else {
                      return
    }
    let snapPhoto = SCSDKSnapPhoto(imageUrl: url)
    let snapContent = SCSDKPhotoSnapContent(snapPhoto: snapPhoto)
    snapContent.caption = caption
    
    // Send it over to Snapchat
    let snapAPI = SCSDKSnapAPI(content: snapContent)
    snapAPI.startSnapping { (error: Error?) in
      print("Sharing \(String(describing: url.absoluteString)) on SnapChat.")
    }
  }
  
  @IBAction func cancelDidTap() {
    dismiss(animated: true)
  }
  
  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fetchImageMetaData()
  }
}

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
