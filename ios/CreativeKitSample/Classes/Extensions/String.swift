//
//  String.swift
//  CreativeKitSample
//
//  Created by Samuel Chow on 3/27/19.
//  Copyright © 2019 Snap Inc. All rights reserved.
//

import UIKit

extension String {
  static let empty = ""
  
  // Returns the file name without the file extension.
  public var fileName: String {
    return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
  }
  
  // Returns the file extension.
  public var fileExtension: String {
    return URL(fileURLWithPath: self).pathExtension
  }
}
