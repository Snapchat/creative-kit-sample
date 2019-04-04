//
//  UIImageView.swift
//  CreativeKitSample
//
//  Created by Samuel Chow on 3/27/19.
//  Copyright © 2019 Snap Inc. All rights reserved.
//

import UIKit

extension UIImageView {
  // The retrieve the image defined by the url.
  public func setImage(withURL url:URL?) {
    guard let url = url else {
      return
    }
    
    let urlRequest = URLRequest(url: url,
                                cachePolicy: .returnCacheDataElseLoad,
                                timeoutInterval: 60.0)
    let task = URLSession.shared.dataTask(with: urlRequest) { [weak self]
      (data: Data?, response: URLResponse?, error: Error?) in
      guard error == nil,
        let data = data else {
        return
      }
      
      DispatchQueue.main.async {
        let image = UIImage(data: data)
        self?.image = image
      }
    }
    task.resume()
  }
}
