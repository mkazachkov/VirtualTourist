//
//  SearchPhotosResponse.swift
//  VirtualTourist
//
//  Created by Mikhail on 11/13/20.
//

import Foundation

struct SearchPhotosResponse: Codable {
    let photos: Photos
    let stat: String
}
