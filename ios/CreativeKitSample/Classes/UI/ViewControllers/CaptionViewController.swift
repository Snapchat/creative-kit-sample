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
    
    @IBOutlet fileprivate weak var textField: UITextField?
}

// MARK: - Action handlers

extension CaptionViewController {
    @IBAction func cancelDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if let text = sender.text, text == String.Empty {
            navigationItem.rightBarButtonItem?.title = "Skip"
        } else {
            navigationItem.rightBarButtonItem?.title = "Next"
        }
    }
}

// MARK: - UIViewController

extension CaptionViewController {    
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
