//
//  ImagePickerSelectorViewController.swift
//  CreativeKitSample
//
//  Created by Samuel Chow on 3/27/19.
//  Copyright © 2019 Snap Inc. All rights reserved.
//

import CoreServices
import UIKit

import SCSDKCreativeKit

class MediaPickerViewController: UITableViewController {
  // MARK: - Helpers
  
  func shareVideo(mediaURL: URL) {
    let snapVideo = SCSDKSnapVideo(videoUrl: mediaURL)
    let snapContent = SCSDKVideoSnapContent(snapVideo: snapVideo)
    
    // Send it over to Snapchat
    let snapAPI = SCSDKSnapAPI(content: snapContent)
    snapAPI.startSnapping { (error: Error?) in
      print("Sharing a video on SnapChat.")
    }
  }
  
  func shareImage(image: UIImage) {
    let snapPhoto = SCSDKSnapPhoto(image: image)
    let snapContent = SCSDKPhotoSnapContent(snapPhoto: snapPhoto)
    
    // Send it over to Snapchat
    let snapAPI = SCSDKSnapAPI(content: snapContent)
    snapAPI.startSnapping { (error: Error?) in
      print("Sharing a photo on SnapChat.")
    }
  }
  
  // MARK: - Event handlers
  
  @IBAction func cameraButtonDidTap(_ sender: Any) {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let pickerController = UIImagePickerController()
      pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
      pickerController.delegate = self
      pickerController.sourceType = .camera
      present(pickerController, animated: true, completion: nil)
    }
  }
  
  @IBAction func photoLibraryButtonDidTap(_ sender: Any) {
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      let pickerController = UIImagePickerController()
      pickerController.delegate = self
      pickerController.sourceType = .photoLibrary
      present(pickerController, animated: true, completion: nil)
    }
  }
  
  // MARK: - UIViewController
  
  override func viewDidLoad() {
      super.viewDidLoad()

  }
}

extension MediaPickerViewController: UIImagePickerControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    dismiss(animated: true) {
      let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
      if CFStringCompare(kUTTypeImage, mediaType, CFStringCompareFlags.compareLocalized) == CFComparisonResult.compareEqualTo {
        guard let capturedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
          return
        }
        self.shareImage(image: capturedImage)
      } else if CFStringCompare(kUTTypeMovie, mediaType, CFStringCompareFlags.compareLocalized) == CFComparisonResult.compareEqualTo {
        guard let capturedMovieURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
          return
        }
        self.shareVideo(mediaURL: capturedMovieURL)
      }
    }
  }
}

extension MediaPickerViewController: UINavigationControllerDelegate {}
