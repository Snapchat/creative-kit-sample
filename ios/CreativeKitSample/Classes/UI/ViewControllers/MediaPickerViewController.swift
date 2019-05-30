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
    // MARK: - Properties
    
    fileprivate lazy var snapAPI = {
        return SCSDKSnapAPI()
    }()
}

// MARK: Private helpers

extension MediaPickerViewController {
    fileprivate func shareVideo(mediaURL: URL) {
        let snapVideo = SCSDKSnapVideo(videoUrl: mediaURL)
        let snapContent = SCSDKVideoSnapContent(snapVideo: snapVideo)
        
        // Send it over to Snapchat
        snapAPI.startSending(snapContent)
    }
    
    fileprivate func shareImage(image: UIImage) {
        let snapPhoto = SCSDKSnapPhoto(image: image)
        let snapContent = SCSDKPhotoSnapContent(snapPhoto: snapPhoto)
        
        // Send it over to Snapchat
        snapAPI.startSending(snapContent)
    }
}

// MARK: Action handlers

extension MediaPickerViewController {
    @IBAction fileprivate func cameraButtonDidTap(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            pickerController.delegate = self
            pickerController.sourceType = .camera
            present(pickerController, animated: true)
        }
    }
    
    @IBAction fileprivate func photoLibraryButtonDidTap(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            present(pickerController, animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension MediaPickerViewController: UIImagePickerControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true)
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
