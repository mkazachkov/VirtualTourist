//
//  FlickrPhotos.swift
//  VirtualTourist
//
//  Created by Mikhail on 11/14/20.
//

import Foundation

class FlickrPhotos: Codable {
    let pages: Int
    let photo: [FlickrPhoto]
}
