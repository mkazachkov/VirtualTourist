//
//  SearchPhotosResponse.swift
//  VirtualTourist
//
//  Created by Mikhail on 11/13/20.
//

import Foundation

struct SearchPhotosResponse: Codable {
    let photos: FlickrPhotos
    let stat: String
}
