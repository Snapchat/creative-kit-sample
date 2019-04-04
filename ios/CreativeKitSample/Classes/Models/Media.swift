//
//  Media.swift
//  CreativeKitSample
//
//  Created by Samuel Chow on 3/27/19.
//  Copyright © 2019 Snap Inc. All rights reserved.
//

enum MediaSource {
  case bundle
  case remote
}

enum MediaType {
  case still
  case animated
  case video
}

// Structure to represent the media on the Stickers controller
struct Media {
  var name: String
  var source: MediaSource
  var type: MediaType
}
