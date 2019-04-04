//
//  CaptionViewController.swift
//  CreativeKitSample
//
//  Created by Samuel Chow on 3/27/19.
//  Copyright © 2019 Snap Inc. All rights reserved.
//

import UIKit

class CaptionViewController: UIViewController {
  // Visual components
  
  @IBOutlet weak var textField: UITextField?
  
  // MARK: - Event handlers
  
  @IBAction func cancelDidTap() {
    dismiss(animated: true)
  }
  
  @objc func textFieldDidChange(_ textField: UITextField) {
    if let text = textField.text, text == String.empty {
      navigationItem.rightBarButtonItem?.title = "Skip"
    } else {
      navigationItem.rightBarButtonItem?.title = "Next"
    }
  }
  
  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showStickers" {
      if let stickersController = segue.destination as? StickersViewController {
        stickersController.caption = textField?.text
      }
    } else if segue.identifier == "showImages" {
      if let imagesController = segue.destination as? ImagesViewController {
        imagesController.caption = textField?.text
      }
    }
  }
}

